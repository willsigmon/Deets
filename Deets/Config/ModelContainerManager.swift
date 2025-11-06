//
//  ModelContainerManager.swift
//  Deets
//
//  Manages dynamic ModelContainer recreation for sync toggle
//

import Foundation
import SwiftData
import SwiftUI
import Combine

/// Manager for creating and recreating ModelContainer when sync settings change
@MainActor
final class ModelContainerManager: ObservableObject {
    // MARK: - Singleton

    static let shared = ModelContainerManager()

    // MARK: - Published Properties

    /// Current model container
    @Published private(set) var container: ModelContainer

    /// Whether container is being recreated
    @Published private(set) var isRecreating: Bool = false

    /// Container recreation error
    @Published var recreationError: Error?

    // MARK: - Private Properties

    private let configuration = CloudKitConfiguration.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        // Create initial container
        self.container = Self.createContainer(syncEnabled: configuration.isSyncEnabled)

        // Observe sync toggle changes
        setupSyncObserver()
    }

    // MARK: - Public Methods

    /// Recreate container with new sync settings
    /// - Parameter syncEnabled: Whether CloudKit sync should be enabled
    /// - Throws: Container creation or migration errors
    func recreateContainer(syncEnabled: Bool) async throws {
        guard !isRecreating else {
            throw ContainerError.recreationInProgress
        }

        isRecreating = true
        recreationError = nil

        defer {
            isRecreating = false
        }

        do {
            // Save any pending changes in current container
            let currentContext = container.mainContext
            if currentContext.hasChanges {
                try currentContext.save()
            }

            // Give CloudKit time to process pending changes
            try await Task.sleep(for: .milliseconds(500))

            // Create new container with updated sync settings
            let newContainer = Self.createContainer(syncEnabled: syncEnabled)

            // Replace container
            self.container = newContainer

            print("✅ Container recreated with sync: \(syncEnabled)")
        } catch {
            recreationError = error
            print("❌ Container recreation failed: \(error)")
            throw error
        }
    }

    // MARK: - Private Methods

    /// Create ModelContainer with specified sync settings
    /// - Parameter syncEnabled: Whether CloudKit sync should be enabled
    /// - Returns: Configured ModelContainer
    private static func createContainer(syncEnabled: Bool) -> ModelContainer {
        let schema = Schema([
            BusinessCard.self
        ])

        // Create configuration with current sync setting
        let cloudKitDatabase: ModelConfiguration.CloudKitDatabase = syncEnabled
            ? .private("iCloud.com.sharedeets.businesscards")
            : .none

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: cloudKitDatabase
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            print("📦 ModelContainer created with sync: \(syncEnabled)")
            return container
        } catch {
            // Log error and attempt fallback to in-memory store
            AppLogger.database.error("Failed to create ModelContainer with sync=\(syncEnabled, privacy: .public): \(error.localizedDescription)")

            // Fallback: try in-memory container
            do {
                AppLogger.database.warning("Attempting fallback to in-memory ModelContainer")
                let fallbackConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                let container = try ModelContainer(
                    for: schema,
                    configurations: [fallbackConfig]
                )
                print("⚠️ ModelContainer created in-memory mode (fallback)")
                return container
            } catch {
                // This is catastrophic - show error UI instead of crashing
                AppLogger.database.critical("Failed to create fallback in-memory container: \(error.localizedDescription)")

                // Last resort: create minimal in-memory container with basic config
                // This should virtually never fail
                do {
                    let emergencyConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                    return try ModelContainer(for: schema, configurations: [emergencyConfig])
                } catch {
                    // If we can't even create an in-memory container, something is fundamentally broken
                    // Use preconditionFailure with clear message for debugging
                    preconditionFailure("Critical: Unable to initialize SwiftData in any mode. Error: \(error)")
                }
            }
        }
    }

    /// Setup observer for sync toggle changes
    private func setupSyncObserver() {
        // Don't automatically recreate - let SyncViewModel control this
        // This prevents unwanted recreations during app lifecycle
    }
}

// MARK: - Supporting Types

enum ContainerError: LocalizedError {
    case recreationInProgress
    case migrationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .recreationInProgress:
            return "Container recreation is already in progress"
        case .migrationFailed(let error):
            return "Failed to migrate data: \(error.localizedDescription)"
        }
    }
}
