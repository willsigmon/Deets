//
//  SyncStatusView.swift
//  Deets
//
//  User interface for iCloud sync settings and status
//

import SwiftUI

/// View for managing iCloud sync settings
struct SyncStatusView: View {
    @EnvironmentObject private var viewModel: SyncViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Sync Toggle Section
                Section {
                    Toggle(isOn: Binding(
                        get: { viewModel.isSyncEnabled },
                        set: { _ in viewModel.toggleSync() }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud Sync")
                                .font(.headline)
                            Text("Keep your business cards synced across devices")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(!viewModel.isICloudAvailable)
                } footer: {
                    if !viewModel.isICloudAvailable {
                        Text("iCloud is not available. Please sign in to iCloud in Settings.")
                            .foregroundStyle(.red)
                    }
                }

                // MARK: - Status Section
                if viewModel.isSyncEnabled {
                    Section("Sync Status") {
                        HStack {
                            Image(systemName: viewModel.statusIcon)
                                .foregroundStyle(viewModel.statusColor)
                                .imageScale(.large)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.statusText)
                                    .font(.body)

                                if viewModel.isSyncing {
                                    Text("Syncing in progress...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Last sync: \(viewModel.lastSyncText)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            if viewModel.isSyncing {
                                ProgressView()
                            }
                        }

                        // Pending changes indicator
                        if viewModel.pendingChangesCount > 0 {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundStyle(.orange)
                                Text(viewModel.pendingChangesText)
                                    .font(.caption)
                            }
                        }
                    }

                    // MARK: - Sync Actions Section
                    Section {
                        Button {
                            viewModel.syncNow()
                        } label: {
                            Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .disabled(!viewModel.canSync)

                        Button {
                            viewModel.refreshStatus()
                        } label: {
                            Label("Refresh Status", systemImage: "arrow.clockwise")
                        }
                    }

                    // MARK: - Troubleshooting Section
                    Section("Troubleshooting") {
                        Button {
                            viewModel.forceFullSync()
                        } label: {
                            Label("Force Full Sync", systemImage: "arrow.triangle.2.circlepath.circle")
                        }
                        .disabled(!viewModel.canSync)
                    } footer: {
                        Text("Use 'Force Full Sync' if you're experiencing sync issues.")
                    }
                }

                // MARK: - Information Section
                Section("About iCloud Sync") {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(
                            icon: "lock.shield",
                            title: "Private & Secure",
                            description: "Your data is encrypted and stored in your personal iCloud account"
                        )

                        InfoRow(
                            icon: "arrow.triangle.2.circlepath.circle",
                            title: "Automatic Sync",
                            description: "Changes sync automatically across all your devices"
                        )

                        InfoRow(
                            icon: "iphone.and.ipad",
                            title: "All Devices",
                            description: "Access your business cards on iPhone, iPad, and Mac"
                        )

                        InfoRow(
                            icon: "eye.slash",
                            title: "Optional Feature",
                            description: "You can disable sync at any time without losing local data"
                        )
                    }
                    .padding(.vertical, 4)
                }

                // MARK: - Settings Link Section
                if !viewModel.isICloudAvailable {
                    Section {
                        Button {
                            viewModel.openSettings()
                        } label: {
                            Label("Open Settings", systemImage: "gear")
                        }
                    } footer: {
                        Text("Open Settings to sign in to iCloud")
                    }
                }
            }
            .navigationTitle("iCloud Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Sync Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {}
                if !viewModel.isICloudAvailable {
                    Button("Open Settings") {
                        viewModel.openSettings()
                    }
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Info Row Component

private struct InfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.teal)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Compact Sync Status Button

/// Compact button for showing sync status in other views
struct SyncStatusButton: View {
    @EnvironmentObject private var viewModel: SyncViewModel
    @State private var showingSyncSheet = false

    var body: some View {
        Button {
            showingSyncSheet = true
        } label: {
            Image(systemName: viewModel.statusIcon)
                .foregroundStyle(viewModel.statusColor)
                .imageScale(.large)
        }
        .sheet(isPresented: $showingSyncSheet) {
            SyncStatusView()
        }
    }
}

// MARK: - Preview

#Preview("Sync Enabled") {
    NavigationStack {
        SyncStatusView()
            .environmentObject(SyncViewModel.mock)
    }
}

#Preview("Sync Disabled") {
    NavigationStack {
        SyncStatusView()
            .environmentObject(SyncViewModel())
    }
}
