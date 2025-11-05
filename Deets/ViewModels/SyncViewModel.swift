//
//  SyncViewModel.swift
//  Deets
//
//  ViewModel for managing iCloud sync UI state and user interactions
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for sync settings and status
@MainActor
final class SyncViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Whether iCloud sync is enabled
    @Published var isSyncEnabled: Bool = false

    /// Current sync status
    @Published var syncStatus: SyncStatus = .notConfigured

    /// Whether sync is currently in progress
    @Published var isSyncing: Bool = false

    /// Last sync date formatted for display
    @Published var lastSyncText: String = "Never"

    /// Whether to show sync error alert
    @Published var showErrorAlert: Bool = false

    /// Current error message
    @Published var errorMessage: String = ""

    /// Whether iCloud is available
    @Published var isICloudAvailable: Bool = false

    /// Number of pending changes
    @Published var pendingChangesCount: Int = 0

    // MARK: - Private Properties

    private let configuration = CloudKitConfiguration.shared
    private var syncService: SyncService?
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    // MARK: - Initialization

    init() {
        setupBindings()
    }

    // MARK: - Public Methods

    /// Configure with sync service (called after ModelContext is available)
    func configure(with syncService: SyncService) {
        self.syncService = syncService
        setupSyncServiceBindings()
    }

    /// Toggle iCloud sync on/off
    func toggleSync() {
        guard isICloudAvailable else {
            errorMessage = "iCloud is not available. Please sign in to iCloud in Settings."
            showErrorAlert = true
            return
        }

        if isSyncEnabled {
            // Disable sync
            syncService?.disableSync()
            isSyncEnabled = false
        } else {
            // Enable sync
            Task {
                await syncService?.enableSync()
                isSyncEnabled = true
            }
        }
    }

    /// Manually trigger sync
    func syncNow() {
        guard isSyncEnabled else { return }

        Task {
            await syncService?.sync()
        }
    }

    /// Force full sync (for troubleshooting)
    func forceFullSync() {
        Task {
            await syncService?.forceFullSync()
        }
    }

    /// Open iOS Settings app
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    /// Refresh sync status
    func refreshStatus() {
        Task {
            await syncService?.checkSyncStatus()
        }
    }

    // MARK: - Private Methods

    /// Setup bindings to configuration
    private func setupBindings() {
        // Bind sync enabled state
        configuration.$isSyncEnabled
            .assign(to: &$isSyncEnabled)

        // Bind iCloud availability
        configuration.$isICloudAvailable
            .assign(to: &$isICloudAvailable)

        // Bind sync status
        configuration.$syncStatus
            .sink { [weak self] status in
                self?.syncStatus = status
                self?.updateErrorState(for: status)
            }
            .store(in: &cancellables)

        // Bind last sync date
        configuration.$lastSyncDate
            .compactMap { $0 }
            .sink { [weak self] date in
                self?.updateLastSyncText(date)
            }
            .store(in: &cancellables)
    }

    /// Setup bindings to sync service
    private func setupSyncServiceBindings() {
        guard let syncService = syncService else { return }

        // Bind syncing state
        syncService.$isSyncing
            .assign(to: &$isSyncing)

        // Bind sync status
        syncService.$syncStatus
            .assign(to: &$syncStatus)

        // Bind last sync date
        syncService.$lastSyncDate
            .compactMap { $0 }
            .sink { [weak self] date in
                self?.updateLastSyncText(date)
            }
            .store(in: &cancellables)

        // Bind pending changes count
        syncService.$pendingChangesCount
            .assign(to: &$pendingChangesCount)
    }

    /// Update last sync text with relative time
    private func updateLastSyncText(_ date: Date) {
        lastSyncText = dateFormatter.localizedString(for: date, relativeTo: Date())
    }

    /// Update error state based on sync status
    private func updateErrorState(for status: SyncStatus) {
        if case .error(let error) = status {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

// MARK: - Computed Properties

extension SyncViewModel {
    /// Status icon for display
    var statusIcon: String {
        switch syncStatus {
        case .notConfigured:
            return "icloud.slash"
        case .idle:
            return "icloud.and.arrow.up"
        case .syncing:
            return "icloud.and.arrow.up.fill"
        case .error:
            return "exclamationmark.icloud"
        }
    }

    /// Status color for display
    var statusColor: Color {
        switch syncStatus {
        case .notConfigured:
            return .gray
        case .idle:
            return .green
        case .syncing:
            return .blue
        case .error:
            return .red
        }
    }

    /// Status text for display
    var statusText: String {
        syncStatus.description
    }

    /// Whether sync controls should be enabled
    var canSync: Bool {
        isSyncEnabled && isICloudAvailable && !isSyncing
    }

    /// Pending changes text
    var pendingChangesText: String {
        if pendingChangesCount == 0 {
            return "No pending changes"
        } else if pendingChangesCount == 1 {
            return "1 change pending"
        } else {
            return "\(pendingChangesCount) changes pending"
        }
    }
}

// MARK: - Preview Mock

extension SyncViewModel {
    /// Create mock view model for previews
    static var mock: SyncViewModel {
        let vm = SyncViewModel()
        vm.isSyncEnabled = true
        vm.isICloudAvailable = true
        vm.syncStatus = .idle
        vm.lastSyncText = "2 minutes ago"
        return vm
    }
}
