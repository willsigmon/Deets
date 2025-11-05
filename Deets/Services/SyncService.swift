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

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let configuration = CloudKitConfiguration.shared
    private let networkMonitor = NWPathMonitor()
    private var cancellables = Set<AnyCancellable>()
    private var syncTimer: Timer?

    /// Network connectivity status
    private var isNetworkAvailable: Bool = true

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Observe configuration changes
        setupConfigurationObserver()

        // Start network monitoring
        startNetworkMonitoring()

        // Setup automatic sync if enabled
        if configuration.isSyncEnabled {
            setupAutomaticSync()
        }
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
            return
        }

        // SwiftData with CloudKit automatically handles sync status
        // We just need to ensure context is saved
        if modelContext.hasChanges {
            pendingChangesCount = modelContext.insertedModelsArray.count +
                                  modelContext.changedModelsArray.count +
                                  modelContext.deletedModelsArray.count
        } else {
            pendingChangesCount = 0
        }
    }

    // MARK: - Private Methods

    /// Perform sync operation
    private func performSync() async {
        guard !isSyncing else { return }

        isSyncing = true
        syncStatus = .syncing

        do {
            // Save pending changes to trigger CloudKit sync
            if modelContext.hasChanges {
                try modelContext.save()
            }

            // CloudKit automatically handles the sync process
            // Wait a moment for sync to initiate
            try await Task.sleep(for: .milliseconds(500))

            syncStatus = .idle
            lastSyncDate = Date()
            configuration.updateSyncStatus(.idle)

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
            let wasAvailable = self?.isNetworkAvailable ?? true
            let isAvailable = path.status == .satisfied

            Task { @MainActor [weak self] in
                self?.isNetworkAvailable = isAvailable

                // If network just became available and we have pending changes, sync
                if !wasAvailable && isAvailable {
                    if self?.configuration.isSyncEnabled == true {
                        await self?.sync()
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
}

// MARK: - Supporting Extensions

extension ModelContext {
    /// Get array of inserted models (helper for counting)
    var insertedModelsArray: [any PersistentModel] {
        Array(insertedModelsArray)
    }

    /// Get array of changed models
    var changedModelsArray: [any PersistentModel] {
        // SwiftData doesn't expose changed models directly
        // This is a simplified version
        []
    }

    /// Get array of deleted models
    var deletedModelsArray: [any PersistentModel] {
        // SwiftData doesn't expose deleted models directly
        // This is a simplified version
        []
    }
}
