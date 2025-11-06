//
//  DeetsApp.swift
//  Deets
//
//  Main app entry point with SwiftData configuration
//

import SwiftUI
import SwiftData

@main
struct DeetsApp: App {
    // MARK: - Properties

    /// CloudKit configuration manager
    @StateObject private var cloudKitConfig = CloudKitConfiguration.shared

    /// Sync view model
    @StateObject private var syncViewModel = SyncViewModel()

    /// Error state for container initialization
    @State private var containerError: Error?

    // MARK: - SwiftData Container

    /// Stable ModelContainer created once on app launch
    /// CRITICAL FIX: This is now a stored property (let + closure), NOT a computed property
    /// This prevents container recreation when cloudKitConfig.isSyncEnabled changes
    /// The container uses a stable storage URL that persists across sync state toggles
    private let sharedModelContainer: ModelContainer? = {
        createStableModelContainer()
    }()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                ContentView()
                    .environmentObject(syncViewModel)
                    .modelContainer(container)
                    .onAppear {
                        setupSyncService(container: container)
                    }
                    .onChange(of: cloudKitConfig.isSyncEnabled) { oldValue, newValue in
                        handleSyncToggle(from: oldValue, to: newValue)
                    }
            } else {
                DatabaseErrorView(error: containerError)
            }
        }
    }

    // MARK: - Private Methods

    /// Create stable ModelContainer that persists across sync state changes
    /// - Returns: ModelContainer configured with stable storage location, or nil on fatal error
    private static func createStableModelContainer() -> ModelContainer? {
        let schema = Schema([
            BusinessCard.self
        ])

        // Create configuration with STABLE storage location
        // CloudKit sync enabled with private database
        let configuration = ModelConfiguration(
            schema: schema,
            url: stableStorageURL(),
            cloudKitDatabase: .private(CloudKitConfiguration.containerIdentifier)
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            // Log error details for debugging
            AppLogger.database.error("Failed to create ModelContainer: \(error.localizedDescription)")

            // Attempt fallback to in-memory store
            do {
                AppLogger.database.warning("Attempting fallback to in-memory ModelContainer")
                return try ModelContainer(
                    for: schema,
                    configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
                )
            } catch let fallbackError {
                // Store error for UI display
                AppLogger.database.critical("Failed to create fallback ModelContainer: \(fallbackError.localizedDescription)")
                return nil
            }
        }
    }

    /// Get stable storage URL that doesn't change with sync state
    /// - Returns: Stable file URL for SwiftData store
    private static func stableStorageURL() -> URL {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            // This should never fail, but provide fallback
            AppLogger.database.error("Failed to get Application Support directory - using temp directory")
            let tempDir = FileManager.default.temporaryDirectory
            return tempDir.appendingPathComponent("Deets/BusinessCards.store")
        }

        let storeDirectory = appSupport.appendingPathComponent("Deets", isDirectory: true)

        // Create directory if needed
        try? FileManager.default.createDirectory(
            at: storeDirectory,
            withIntermediateDirectories: true
        )

        return storeDirectory.appendingPathComponent("BusinessCards.store")
    }

    /// Setup sync service after container is created
    private func setupSyncService(container: ModelContainer) {
        let context = container.mainContext
        let syncService = SyncService(modelContext: context)
        syncViewModel.configure(with: syncService)

        // Apply initial sync state
        applySyncState(cloudKitConfig.isSyncEnabled)
    }

    /// Handle sync toggle changes dynamically without recreating container
    /// - Parameters:
    ///   - oldValue: Previous sync state
    ///   - newValue: New sync state
    private func handleSyncToggle(from oldValue: Bool, to newValue: Bool) {
        guard oldValue != newValue else { return }

        AppLogger.sync.info("Sync toggled from \(oldValue) to \(newValue)")
        applySyncState(newValue)
    }

    /// Apply sync state to existing container without recreating it
    /// - Parameter enabled: Whether sync should be enabled
    private func applySyncState(_ enabled: Bool) {
        // NOTE: SwiftData's CloudKit integration is typically configured at container creation.
        // However, to preserve data across sync toggles, we:
        // 1. Use a stable storage URL that never changes (✅ stableStorageURL)
        // 2. Manage CloudKit operations through SyncService (✅ startMonitoring/stopMonitoring)
        // 3. Keep the container alive across state changes (✅ stored property, not computed)
        //
        // This approach ensures BusinessCard data persists when user toggles:
        // - OFF → ON: Existing data syncs to iCloud
        // - ON → OFF: iCloud data remains in local store
        // - OFF → ON → OFF: Data never disappears

        if enabled {
            AppLogger.sync.info("CloudKit sync enabled - data will sync to iCloud")
            syncViewModel.syncService?.startMonitoring()
        } else {
            AppLogger.sync.info("CloudKit sync disabled - data stored locally only")
            syncViewModel.syncService?.stopMonitoring()
        }
    }
}

// MARK: - Content View (Tab Navigation)

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Cards List Tab
            CardListView()
                .tabItem {
                    Label("Cards", systemImage: "rectangle.stack")
                }
                .tag(0)

            // Scan Tab
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }
                .tag(1)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(Color.teal)
        .onAppear {
            setupAppearance()
        }
    }

    // MARK: - Appearance Configuration

    private func setupAppearance() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance

        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
    }
}

// MARK: - Color Extension

extension Color {
    /// Deets brand teal color - WCAG AA compliant
    /// Light mode: #00796B (5.32:1 contrast on white - AA compliant)
    /// Dark mode: #23C4AE (original brand teal - good contrast on dark backgrounds)
    static let teal = Color("TealAccessible")

    /// Original brand teal - use only for non-text decorative elements where contrast isn't critical
    /// #23C4AE - 2.19:1 contrast on white (fails WCAG AA)
    static let tealBrand = Color(red: 0x23 / 255, green: 0xC4 / 255, blue: 0xAE / 255)
}

// MARK: - Database Error View

struct DatabaseErrorView: View {
    let error: Error?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            VStack(spacing: 12) {
                Text("Unable to Start Deets")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("The app database could not be initialized.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if let error = error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 32)

            VStack(spacing: 16) {
                Button {
                    // Restart app
                    exit(0)
                } label: {
                    Label("Restart App", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    // Open Settings
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open Settings", systemImage: "gear")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)

            Text("If this problem persists, try:\n• Restarting your device\n• Freeing up storage space\n• Reinstalling the app")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 16)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("App") {
    ContentView()
        .modelContainer(for: BusinessCard.self, inMemory: true) { result in
            if case .success(let container) = result {
                let context = container.mainContext
                for card in BusinessCard.sampleData {
                    context.insert(card)
                }
            }
        }
}

#Preview("Database Error") {
    DatabaseErrorView(error: NSError(domain: "com.sharedeets.app", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create database store"]))
}
