//
//  SettingsView.swift
//  Deets
//
//  Settings page with iCloud sync, app info, and preferences
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var cloudKitConfig = CloudKitConfiguration.shared
    @EnvironmentObject private var syncViewModel: SyncViewModel

    var body: some View {
        NavigationStack {
            List {
                // MARK: - iCloud Sync Section
                Section {
                    Toggle(isOn: $cloudKitConfig.isSyncEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "icloud.fill")
                                .foregroundColor(.blue)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("iCloud Sync")
                                    .font(.body)

                                Text("Sync cards across your devices")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onChange(of: cloudKitConfig.isSyncEnabled) { oldValue, newValue in
                        if newValue {
                            HapticManager.shared.toggle()
                        }
                    }

                    // Sync Status
                    if cloudKitConfig.isSyncEnabled {
                        HStack {
                            Image(systemName: syncStatusIcon)
                                .foregroundColor(syncStatusColor)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Status")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(syncStatusText)
                                    .font(.body)
                            }

                            Spacer()
                        }
                    }
                } header: {
                    Text("iCloud")
                } footer: {
                    if !cloudKitConfig.isSyncEnabled {
                        Text("Enable iCloud sync to keep your business cards synced across all your devices.")
                            .font(.caption)
                    }
                }

                // MARK: - App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(buildNumber)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }

                // MARK: - Privacy Section
                Section {
                    NavigationLink {
                        PrivacyInfoView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.green)
                            Text("Privacy Policy")
                        }
                    }

                    NavigationLink {
                        SettingsPermissionsView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.blue)
                            Text("Permissions")
                        }
                    }
                } header: {
                    Text("Privacy & Security")
                }

                // MARK: - Support Section
                Section {
                    Link(destination: URL(string: "https://github.com/yourusername/deets")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("Help & Support")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://github.com/yourusername/deets/issues")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "ladybug.fill")
                                .foregroundColor(.red)
                            Text("Report a Bug")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Support")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Computed Properties

    private var syncStatusIcon: String {
        guard let syncViewModel = syncViewModel.syncService else {
            return "xmark.icloud"
        }

        // Check if syncing
        // Note: SyncViewModel would need to expose sync state
        return "checkmark.icloud.fill"
    }

    private var syncStatusColor: Color {
        guard cloudKitConfig.isSyncEnabled else {
            return .secondary
        }
        return .green
    }

    private var syncStatusText: String {
        guard cloudKitConfig.isSyncEnabled else {
            return "Disabled"
        }
        return "Active"
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - Privacy Info View

struct PrivacyInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Privacy Matters")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Deets is designed with privacy as a core principle. Your business card data belongs to you.")
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    PrivacyFeature(
                        icon: "lock.shield.fill",
                        color: .blue,
                        title: "Local-First Storage",
                        description: "All scanned business cards are stored locally on your device by default."
                    )

                    PrivacyFeature(
                        icon: "icloud.fill",
                        color: .cyan,
                        title: "Optional iCloud Sync",
                        description: "You control whether your data syncs to iCloud. It's off by default."
                    )

                    PrivacyFeature(
                        icon: "eye.slash.fill",
                        color: .purple,
                        title: "No Tracking",
                        description: "Deets doesn't track you, collect analytics, or share your data with third parties."
                    )

                    PrivacyFeature(
                        icon: "camera.fill",
                        color: .orange,
                        title: "Camera Access",
                        description: "Camera is used only for scanning business cards. No images are uploaded anywhere."
                    )

                    PrivacyFeature(
                        icon: "person.crop.circle.fill",
                        color: .green,
                        title: "Contacts Access",
                        description: "Contacts permission is optional and only used when you choose to save a card to Contacts."
                    )
                }

                Divider()
                    .padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Questions?")
                        .font(.headline)

                    Text("For more details, see our full privacy policy or contact us with any concerns.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Feature Component

private struct PrivacyFeature: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Permissions View (alternative to OnboardingView version)

struct SettingsPermissionsView: View {
    @State private var cameraStatus: String = "Checking..."
    @State private var contactsStatus: String = "Checking..."
    @State private var photoLibraryStatus: String = "Checking..."

    var body: some View {
        List {
            Section {
                PermissionRow(
                    icon: "camera.fill",
                    color: .blue,
                    title: "Camera",
                    status: cameraStatus,
                    description: "Required to scan business cards"
                )

                PermissionRow(
                    icon: "person.crop.circle.fill",
                    color: .green,
                    title: "Contacts",
                    status: contactsStatus,
                    description: "Optional - Save cards to Contacts app"
                )

                PermissionRow(
                    icon: "photo.fill",
                    color: .purple,
                    title: "Photo Library",
                    status: photoLibraryStatus,
                    description: "Optional - Find contact photos"
                )
            } header: {
                Text("App Permissions")
            } footer: {
                Text("Tap to open Settings and manage permissions.")
            }

            Section {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Open Settings")
                        Spacer()
                        Image(systemName: "arrow.up.forward")
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Permissions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkPermissions()
        }
    }

    private func checkPermissions() {
        // Check camera
        let cameraAuth = AVCaptureDevice.authorizationStatus(for: .video)
        cameraStatus = authStatusString(cameraAuth)

        // Check contacts
        let contactsAuth = CNContactStore.authorizationStatus(for: .contacts)
        contactsStatus = contactsAuthString(contactsAuth)

        // Check photo library
        let photoAuth = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        photoLibraryStatus = photoAuthString(photoAuth)
    }

    private func authStatusString(_ status: AVAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Granted"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Requested"
        @unknown default: return "Unknown"
        }
    }

    private func contactsAuthString(_ status: CNAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Granted"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Requested"
        @unknown default: return "Unknown"
        }
    }

    private func photoAuthString(_ status: PHAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Granted"
        case .limited: return "Limited Access"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Requested"
        @unknown default: return "Unknown"
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let color: Color
    let title: String
    let status: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(status)
                .font(.caption)
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .cornerRadius(6)
        }
    }

    private var statusColor: Color {
        switch status {
        case "Granted", "Limited Access": return .green
        case "Denied": return .red
        case "Not Requested": return .orange
        default: return .secondary
        }
    }
}

// MARK: - Imports for permissions

import AVFoundation
import Contacts
import Photos

// MARK: - Preview

#Preview("Settings") {
    SettingsView()
        .environmentObject(SyncViewModel())
}

#Preview("Privacy") {
    NavigationStack {
        PrivacyInfoView()
    }
}

#Preview("Permissions") {
    NavigationStack {
        SettingsPermissionsView()
    }
}
