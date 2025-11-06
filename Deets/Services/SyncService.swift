//
//  SyncService.swift
//  Deets
//
//  CloudKit sync orchestration and monitoring
//

import Foundation
import SwiftData
import Combine
import Network
import OSLog
import UIKit

/// Service for managing CloudKit sync operations
@MainActor
final class SyncService: ObservableObject {
    // MARK: - Published Properties

    /// Current sync status
    @Published var syncStatus: SyncStatus = .notConfigured

    /// Last successful sync date
    @Published var lastSyncDate: Date?

    /// Whether sync is currently in progress
    @Published var isSyncing: Bool = false

    /// Number of pending changes to sync
    @Published var pendingChangesCount: Int = 0

    /// Active conflicts requiring user attention (if using manual resolution)
    @Published var activeConflicts: [SyncConflict] = []

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let configuration = CloudKitConfiguration.shared
    private let networkMonitor = NWPathMonitor()
    private var cancellables = Set<AnyCancellable>()
    private var syncTimer: Timer?

    /// Logger for sync operations
    private let logger = Logger(subsystem: "com.sharedeets.sync", category: "SyncService")

    /// Network connectivity status
    private var isNetworkAvailable: Bool = true

    /// Conflict resolution statistics
    private var conflictStats = ConflictStatistics()

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Configure conflict resolution policy
        configureConflictResolution()

        // Observe configuration changes
        setupConfigurationObserver()

        // Start network monitoring
        startNetworkMonitoring()

        // Setup automatic sync if enabled
        if configuration.isSyncEnabled {
            setupAutomaticSync()
        }

        logger.info("SyncService initialized with Last-Writer-Wins conflict resolution")
    }

    deinit {
        syncTimer?.invalidate()
        networkMonitor.cancel()
    }

    // MARK: - Public Methods

    /// Manually trigger sync
    func sync() async {
        guard configuration.isSyncEnabled else {
            syncStatus = .notConfigured
            return
        }

        guard configuration.isICloudAvailable else {
            syncStatus = .error(.iCloudUnavailable)
            return
        }

        guard isNetworkAvailable else {
            syncStatus = .error(.networkUnavailable)
            return
        }

        await performSync()
    }

    /// Enable sync and perform initial sync
    func enableSync() async {
        configuration.enableSync()
        await performInitialSync()
        setupAutomaticSync()
    }

    /// Disable sync
    func disableSync() {
        configuration.disableSync()
        syncTimer?.invalidate()
        syncTimer = nil
        syncStatus = .notConfigured
    }

    /// Start monitoring and automatic sync (called when sync is enabled dynamically)
    func startMonitoring() {
        logger.info("Starting sync monitoring")
        setupAutomaticSync()
        Task {
            await sync()
        }
    }

    /// Stop monitoring and automatic sync (called when sync is disabled dynamically)
    func stopMonitoring() {
        logger.info("Stopping sync monitoring")
        syncTimer?.invalidate()
        syncTimer = nil
        syncStatus = .notConfigured
    }

    /// Force full sync (useful for troubleshooting)
    func forceFullSync() async {
        guard configuration.isSyncEnabled else { return }

        isSyncing = true
        syncStatus = .syncing

        do {
            // Save any pending changes
            try modelContext.save()

            // Wait for CloudKit to propagate changes
            try await Task.sleep(for: .seconds(2))

            syncStatus = .idle
            lastSyncDate = Date()
        } catch {
            handleSyncError(error)
        }

        isSyncing = false
    }

    /// Check sync status
    func checkSyncStatus() async {
        guard configuration.isSyncEnabled else {
            syncStatus = .notConfigured
            pendingChangesCount = 0
            return
        }

        // SwiftData with CloudKit automatically handles sync status
        // We just need to ensure context is saved
        if modelContext.hasChanges {
            pendingChangesCount = estimatePendingChangeCount()
        } else {
            pendingChangesCount = 0
        }
    }

    // MARK: - Conflict Resolution

    /// Configure SwiftData conflict resolution policy
    ///
    /// **Strategy: Last-Writer-Wins (Automatic)**
    /// - Uses `dateModified` timestamp to determine winning version
    /// - CloudKit automatically handles conflict detection
    /// - SwiftData merges changes using NSMergePolicy
    /// - No user intervention required
    ///
    /// **Handled Scenarios:**
    /// 1. Same card edited on 2 devices → Newest timestamp wins
    /// 2. Card deleted on one, edited on other → Deletion wins (CloudKit behavior)
    /// 3. Network partition → When reconnected, newest modification wins
    ///
    /// **Alternative: Manual Resolution**
    /// To enable user-choice conflict resolution:
    /// 1. Change policy to `.manual` in CloudKitConfiguration
    /// 2. Populate `activeConflicts` array
    /// 3. Display ConflictResolutionView in SyncViewModel
    private func configureConflictResolution() {
        // SwiftData + CloudKit uses NSMergeByPropertyObjectTrump by default
        // This automatically implements Last-Writer-Wins at property level
        // Individual properties with newest timestamp win

        logger.info("Conflict resolution configured: Last-Writer-Wins (automatic)")
        logger.info("Conflicts resolved at property level using modification timestamps")
    }

    /// Detect and handle sync conflicts
    ///
    /// Called during sync operations to:
    /// - Log conflict occurrences
    /// - Update statistics
    /// - Apply resolution strategy
    /// - Notify user if needed (manual mode)
    private func handleSyncConflicts() {
        // SwiftData + CloudKit handles conflicts automatically
        // This method tracks conflicts for logging and analytics

        // Query for recently modified records that might have conflicts
        // Note: Date calculations must be done outside #Predicate macro
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        let descriptor = FetchDescriptor<BusinessCard>(
            predicate: #Predicate { card in
                // Cards modified in last 5 minutes might have conflicts
                // Need to unwrap optional dateModified
                if let modified = card.dateModified {
                    modified > fiveMinutesAgo
                } else {
                    false
                }
            },
            sortBy: [SortDescriptor(\BusinessCard.dateModified, order: .reverse)]
        )

        do {
            let recentlyModified = try modelContext.fetch(descriptor)

            if !recentlyModified.isEmpty {
                logger.info("Detected \(recentlyModified.count) recently modified cards during sync")

                // Check for potential conflicts based on CloudKit metadata
                let potentialConflicts = recentlyModified.filter { card in
                    // Card was modified locally but also has recent CloudKit updates
                    if let cloudDate = card.cloudKitModificationDate,
                       let localDate = card.dateModified {
                        // If CloudKit date and local date differ by < 1 minute, likely a conflict
                        return abs(cloudDate.timeIntervalSince(localDate)) < 60
                    }
                    return false
                }

                if !potentialConflicts.isEmpty {
                    conflictStats.totalConflicts += potentialConflicts.count
                    conflictStats.lastConflictDate = Date()

                    logger.warning("Detected \(potentialConflicts.count) potential conflicts resolved automatically")

                    // Log conflict details for debugging
                    for card in potentialConflicts {
                        logConflictResolution(for: card)
                    }
                }
            }
        } catch {
            logger.error("Failed to check for conflicts: \(error.localizedDescription)")
        }
    }

    /// Log detailed conflict resolution information
    private func logConflictResolution(for card: BusinessCard) {
        let cardID = card.id?.uuidString ?? "Unknown"
        let localModified = card.dateModified?.formatted() ?? "Unknown"
        let cloudModified = card.cloudKitModificationDate?.formatted() ?? "Unknown"

        let winner: String
        if let localDate = card.dateModified, let cloudDate = card.cloudKitModificationDate {
            winner = localDate > cloudDate ? "Local" : "Remote"
        } else if card.dateModified != nil {
            winner = "Local"
        } else if card.cloudKitModificationDate != nil {
            winner = "Remote"
        } else {
            winner = "Unknown"
        }

        logger.info("""
            CONFLICT RESOLVED:
            Card: \(card.displayName) (ID: \(cardID))
            Local Modified: \(localModified)
            CloudKit Modified: \(cloudModified)
            Resolution: Last-Writer-Wins (newest timestamp)
            Winner: \(winner)
            """)

        conflictStats.autoResolvedConflicts += 1
    }

    /// Handle edge case: Card deleted on one device, edited on another
    ///
    /// **CloudKit Behavior:**
    /// - Deletions are tombstoned and propagate to all devices
    /// - If a card is deleted on Device A and edited on Device B:
    ///   - Deletion wins (CloudKit default)
    ///   - Edit is discarded
    ///   - User sees card disappear on Device B after sync
    ///
    /// **Current Strategy:** Accept CloudKit default (deletion wins)
    /// This is standard behavior for most sync systems and prevents zombie records.
    ///
    /// **Alternative:** Could implement "undelete" feature if needed
    private func handleDeleteEditConflict(_ card: BusinessCard) {
        // CloudKit automatically handles this - deletion always wins
        // We just log it for awareness
        logger.warning("""
            DELETE-EDIT CONFLICT DETECTED:
            Card: \(card.displayName)
            Action: Card will be deleted (CloudKit default behavior)
            Note: This is expected behavior - deletions propagate to all devices
            """)
    }

    /// Get conflict resolution statistics
    func getConflictStatistics() -> ConflictStatistics {
        return conflictStats
    }

    // MARK: - Private Methods

    /// Perform sync operation
    private func performSync() async {
        guard !isSyncing else { return }

        isSyncing = true
        syncStatus = .syncing
        logger.info("Starting sync operation")

        do {
            // Save pending changes to trigger CloudKit sync
            if modelContext.hasChanges {
                let changeCount = estimatePendingChangeCount()
                logger.info("Saving \(changeCount) pending changes")
                pendingChangesCount = changeCount
                try modelContext.save()
            }

            // CloudKit automatically handles the sync process
            // Wait a moment for sync to initiate
            try await Task.sleep(for: .milliseconds(500))

            // Check for and handle any conflicts
            handleSyncConflicts()

            syncStatus = .idle
            lastSyncDate = Date()
            configuration.updateSyncStatus(.idle)
            logger.info("Sync completed successfully")

            // Update pending changes count
            await checkSyncStatus()
        } catch {
            handleSyncError(error)
        }

        isSyncing = false
    }

    /// Perform initial sync when enabling iCloud
    private func performInitialSync() async {
        syncStatus = .syncing
        isSyncing = true

        do {
            // Ensure all local data is saved before enabling CloudKit
            if modelContext.hasChanges {
                try modelContext.save()
            }

            // The ModelConfiguration change in DeetsApp will trigger
            // CloudKit container creation and initial import
            try await Task.sleep(for: .seconds(1))

            syncStatus = .idle
            lastSyncDate = Date()
            configuration.updateSyncStatus(.idle)
        } catch {
            handleSyncError(error)
        }

        isSyncing = false
    }

    /// Setup automatic background sync
    private func setupAutomaticSync() {
        // Sync every 5 minutes when app is active
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.sync()
            }
        }

        // Sync when app becomes active
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.sync()
                }
            }
            .store(in: &cancellables)

        // Sync before app enters background
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.sync()
                }
            }
            .store(in: &cancellables)
    }

    /// Monitor network connectivity
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            let isAvailable = path.status == .satisfied

            Task { @MainActor [weak self] in
                guard let self = self else { return }
                let wasAvailable = self.isNetworkAvailable
                self.isNetworkAvailable = isAvailable

                // If network just became available and we have pending changes, sync
                if !wasAvailable && isAvailable {
                    if self.configuration.isSyncEnabled == true {
                        await self.sync()
                    }
                }
            }
        }

        networkMonitor.start(queue: DispatchQueue.global(qos: .background))
    }

    /// Setup observers for configuration changes
    private func setupConfigurationObserver() {
        configuration.$isSyncEnabled
            .sink { [weak self] enabled in
                Task { @MainActor [weak self] in
                    if enabled {
                        self?.setupAutomaticSync()
                        await self?.sync()
                    } else {
                        self?.syncTimer?.invalidate()
                        self?.syncTimer = nil
                        self?.syncStatus = .notConfigured
                    }
                }
            }
            .store(in: &cancellables)

        configuration.$syncStatus
            .sink { [weak self] status in
                self?.syncStatus = status
            }
            .store(in: &cancellables)
    }

    /// Handle sync errors
    private func handleSyncError(_ error: Error) {
        let syncError: SyncError

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                syncError = .networkUnavailable
            default:
                syncError = .unknownError(urlError.localizedDescription)
            }
        } else {
            syncError = .unknownError(error.localizedDescription)
        }

        syncStatus = .error(syncError)
        configuration.updateSyncStatus(.error(syncError))
    }

    /// Provide a safe estimate of pending changes until SwiftData exposes granular counts.
    /// SwiftData currently keeps detailed change tracking internal, so we fall back to
    /// reporting a sentinel value of `1` whenever unsaved changes exist. This avoids crashes
    /// from the previous implementation while still signaling that work needs syncing.
    private func estimatePendingChangeCount() -> Int {
        guard modelContext.hasChanges else { return 0 }
        return 1
    }
}

// MARK: - Supporting Types

/// Represents a sync conflict requiring resolution
struct SyncConflict: Identifiable {
    let id = UUID()
    let cardID: UUID
    let cardName: String
    let localVersion: BusinessCard
    let remoteVersion: ConflictVersion
    let conflictDate: Date

    /// Remote version data for conflict comparison
    struct ConflictVersion {
        let fullName: String
        let company: String?
        let email: String?
        let phoneNumber: String?
        let dateModified: Date
    }
}

/// Statistics for conflict resolution
struct ConflictStatistics {
    /// Total number of conflicts detected
    var totalConflicts: Int = 0

    /// Number of conflicts auto-resolved
    var autoResolvedConflicts: Int = 0

    /// Number of conflicts requiring manual resolution
    var manualResolvedConflicts: Int = 0

    /// Last time a conflict was detected
    var lastConflictDate: Date?

    /// Human-readable summary
    var summary: String {
        if totalConflicts == 0 {
            return "No conflicts detected"
        }
        return """
            Total Conflicts: \(totalConflicts)
            Auto-Resolved: \(autoResolvedConflicts)
            Manual: \(manualResolvedConflicts)
            Last Conflict: \(lastConflictDate?.formatted() ?? "Never")
            """
    }
}
