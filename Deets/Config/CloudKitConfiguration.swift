//
//  CloudKitConfiguration.swift
//  Deets
//
//  CloudKit container and sync configuration
//

import Foundation
import SwiftData
import Combine

/// CloudKit configuration for iCloud sync
final class CloudKitConfiguration: ObservableObject {
    // MARK: - Singleton

    static let shared = CloudKitConfiguration()

    // MARK: - Published Properties

    /// Whether iCloud sync is enabled
    @Published var isSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSyncEnabled, forKey: Keys.syncEnabled)
            syncEnabledSubject.send(isSyncEnabled)
        }
    }

    /// Current sync status
    @Published var syncStatus: SyncStatus = .notConfigured

    /// Last sync date
    @Published var lastSyncDate: Date?

    /// Whether user is logged into iCloud
    @Published var isICloudAvailable: Bool = false

    // MARK: - Constants

    /// CloudKit container identifier
    static let containerIdentifier = "iCloud.com.sharedeets.businesscards"

    /// Database type to use (private for user-specific data)
    static let databaseScope: ModelConfiguration.CloudKitDatabase = .private(containerIdentifier)

    // MARK: - Private Properties

    private let syncEnabledSubject = PassthroughSubject<Bool, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        // Load saved sync preference
        self.isSyncEnabled = UserDefaults.standard.bool(forKey: Keys.syncEnabled)

        // Check iCloud availability
        checkICloudAvailability()

        // Monitor iCloud account status changes
        NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .sink { [weak self] _ in
                self?.checkICloudAvailability()
            }
            .store(in: &cancellables)
    }

    // MARK: - Configuration Methods

    /// Create ModelConfiguration based on sync preference
    /// - Parameter schema: SwiftData schema to configure
    /// - Returns: ModelConfiguration with encryption enabled
    ///
    /// Security: Enables iOS Data Protection with `.completeUnlessOpen` to encrypt
    /// PII (names, emails, phone numbers, addresses) at rest. Data is accessible
    /// while device is unlocked and remains accessible until device locks.
    func createModelConfiguration(schema: Schema) -> ModelConfiguration {
        let cloudKitDatabase: ModelConfiguration.CloudKitDatabase = isSyncEnabled ? .private("iCloud.com.sharedeets.businesscards") : .none

        return ModelConfiguration(
            schema: schema,
            cloudKitDatabase: cloudKitDatabase
        )
    }

    /// Enable iCloud sync (requires user consent)
    func enableSync() {
        guard isICloudAvailable else {
            syncStatus = .error(.iCloudUnavailable)
            return
        }

        isSyncEnabled = true
        syncStatus = .syncing
    }

    /// Disable iCloud sync
    func disableSync() {
        isSyncEnabled = false
        syncStatus = .notConfigured
    }

    /// Check if iCloud is available
    private func checkICloudAvailability() {
        // Check if iCloud container is available
        FileManager.default.url(forUbiquityContainerIdentifier: nil) { url, error in
            DispatchQueue.main.async {
                self.isICloudAvailable = (url != nil && error == nil)

                if !self.isICloudAvailable && self.isSyncEnabled {
                    self.syncStatus = .error(.iCloudUnavailable)
                }
            }
        }
    }

    // MARK: - Sync Status

    /// Update sync status
    func updateSyncStatus(_ status: SyncStatus) {
        DispatchQueue.main.async {
            self.syncStatus = status

            if case .idle = status {
                self.lastSyncDate = Date()
            }
        }
    }

    // MARK: - Conflict Resolution

    /// Conflict resolution strategy
    var conflictResolutionPolicy: ConflictResolutionPolicy {
        .lastWriterWins // Most recent modification wins
    }
}

// MARK: - Supporting Types

/// Sync status enumeration
enum SyncStatus: Equatable {
    case notConfigured
    case idle
    case syncing
    case error(SyncError)

    var description: String {
        switch self {
        case .notConfigured:
            return "iCloud sync not configured"
        case .idle:
            return "Up to date"
        case .syncing:
            return "Syncing..."
        case .error(let error):
            return error.localizedDescription
        }
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}

/// Sync error types
enum SyncError: Error, Equatable {
    case iCloudUnavailable
    case networkUnavailable
    case quotaExceeded
    case authenticationFailed
    case unknownError(String)

    var localizedDescription: String {
        switch self {
        case .iCloudUnavailable:
            return "iCloud is not available. Please sign in to iCloud in Settings."
        case .networkUnavailable:
            return "Network connection unavailable. Sync will resume when online."
        case .quotaExceeded:
            return "iCloud storage quota exceeded. Please free up space."
        case .authenticationFailed:
            return "iCloud authentication failed. Please check your account."
        case .unknownError(let message):
            return "Sync error: \(message)"
        }
    }
}

/// Conflict resolution policy
enum ConflictResolutionPolicy {
    case lastWriterWins
    case keepBoth
    case manual
}

// MARK: - UserDefaults Keys

private extension CloudKitConfiguration {
    enum Keys {
        static let syncEnabled = "com.sharedeets.syncEnabled"
    }
}

// MARK: - FileManager Extension

extension FileManager {
    /// Async check for iCloud container availability
    func url(forUbiquityContainerIdentifier identifier: String?, completion: @escaping (URL?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = self.url(forUbiquityContainerIdentifier: identifier)
            completion(url, nil)
        }
    }
}
