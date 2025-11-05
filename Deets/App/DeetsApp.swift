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

    // MARK: - SwiftData Container

    var sharedModelContainer: ModelContainer {
        createModelContainer()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(syncViewModel)
                .onAppear {
                    setupSyncService()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    // MARK: - Private Methods

    /// Create ModelContainer with current CloudKit configuration
    private func createModelContainer() -> ModelContainer {
        let schema = Schema([
            BusinessCard.self
        ])

        // Use CloudKitConfiguration to determine sync settings
        let modelConfiguration = cloudKitConfig.createModelConfiguration(schema: schema)

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    /// Setup sync service after container is created
    private func setupSyncService() {
        let context = sharedModelContainer.mainContext
        let syncService = SyncService(modelContext: context)
        syncViewModel.configure(with: syncService)
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
    /// Deets brand teal color (#23C4AE)
    static let teal = Color(red: 0x23 / 255, green: 0xC4 / 255, blue: 0xAE / 255)
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
