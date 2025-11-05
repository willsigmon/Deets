//
//  LocalizationIntegrationExample.swift
//  Deets
//
//  Examples showing how to integrate L10n into existing views
//  This file is for reference - copy patterns into your actual views
//

import SwiftUI

// MARK: - Example 1: Updating ScanView

struct ScanView_Localized: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Icon
                Image(systemName: "camera.viewfinder")
                    .iconXLarge()
                    .foregroundStyle(Color.teal)
                    .accessibilityHidden(true)

                // Title and description
                VStack(spacing: 12) {
                    // ✅ BEFORE: Text("Scan Business Card")
                    Text(L10n.Scan.headerTitle)
                        .font(.largeTitle.weight(.bold))

                    // ✅ BEFORE: Text("Point your camera at a business card...")
                    Text(L10n.Scan.headerMessage)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Scan button
                // ✅ BEFORE: PrimaryButton("Start Scanning", ...)
                PrimaryButton(
                    L10n.Scan.Button.start,
                    systemImage: "camera.fill"
                ) {
                    // Start scanning
                }

                // Requirements text
                // ✅ BEFORE: Text("Requires iOS 16+ and camera access")
                Text(L10n.Scan.requirements)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            // ✅ BEFORE: .navigationTitle("Scan")
            .navigationTitle(L10n.Scan.title)
        }
    }
}

// MARK: - Example 2: Contact Preview with Validation

struct ContactPreviewView_Localized: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var isValidEmail = true

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    // ✅ BEFORE: Text("Review Contact")
                    Text(L10n.Preview.headerTitle)
                        .font(.title2.weight(.bold))

                    // ✅ BEFORE: Text("Verify and edit the extracted information")
                    Text(L10n.Preview.headerMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Form fields
                VStack(spacing: 20) {
                    // Name field
                    ValidatedTextField(
                        // ✅ BEFORE: title: "Full Name *"
                        title: L10n.Preview.Field.fullNameRequired,
                        // ✅ BEFORE: placeholder: "John Doe"
                        placeholder: L10n.Preview.Field.fullNamePlaceholder,
                        text: $fullName,
                        isValid: !fullName.isEmpty
                    )

                    // Email field
                    ValidatedTextField(
                        // ✅ BEFORE: title: "Email"
                        title: L10n.Preview.Field.email,
                        // ✅ BEFORE: placeholder: "name@company.com"
                        placeholder: L10n.Preview.Field.emailPlaceholder,
                        text: $email,
                        isValid: isValidEmail,
                        // ✅ BEFORE: errorMessage: "Please enter a valid email"
                        errorMessage: L10n.Preview.Validation.emailInvalid
                    )
                }

                // Buttons
                VStack(spacing: 12) {
                    // ✅ BEFORE: PrimaryButton("Save to Database & Contacts", ...)
                    PrimaryButton(L10n.Preview.Button.saveBoth) {
                        saveContact()
                    }

                    // ✅ BEFORE: SecondaryButton("Save to Database Only", ...)
                    SecondaryButton(L10n.Preview.Button.saveDatabaseOnly) {
                        saveToDatabaseOnly()
                    }
                }
            }
        }
        // ✅ BEFORE: .navigationTitle("New Contact")
        .navigationTitle(L10n.Preview.title)
    }

    func saveContact() { }
    func saveToDatabaseOnly() { }
}

// MARK: - Example 3: Empty State

struct EmptyStateView_Localized: View {
    var body: some View {
        EmptyStateView(
            systemImage: "rectangle.stack.badge.plus",
            // ✅ BEFORE: title: "No Business Cards Yet"
            title: L10n.List.Empty.title,
            // ✅ BEFORE: message: "Scan your first business card..."
            message: L10n.List.Empty.message,
            // ✅ BEFORE: actionTitle: "Scan First Card"
            actionTitle: L10n.List.Empty.action
        ) {
            // Navigate to scan
        }
    }
}

// MARK: - Example 4: Alerts with Localized Text

struct ScanView_WithAlerts: View {
    @State private var showError = false
    @State private var errorType: ScanError = .noText

    enum ScanError {
        case noText
        case poorQuality
        case timeout
    }

    var body: some View {
        Text("Scanning...")
            .alert(
                // ✅ BEFORE: "Scan Error"
                L10n.Scan.Error.title,
                isPresented: $showError
            ) {
                // ✅ BEFORE: Button("Retry")
                Button(L10n.Scan.Button.retry) {
                    retryScan()
                }
                // ✅ BEFORE: Button("Cancel", role: .cancel)
                Button(L10n.Scan.Button.cancel, role: .cancel) { }
            } message: {
                Text(errorMessage(for: errorType))
            }
    }

    func errorMessage(for error: ScanError) -> String {
        switch error {
        case .noText:
            // ✅ BEFORE: "No text detected on the card..."
            return L10n.Scan.Error.noText
        case .poorQuality:
            // ✅ BEFORE: "The image quality is too low..."
            return L10n.Scan.Error.poorQuality
        case .timeout:
            // ✅ BEFORE: "Scanning timed out..."
            return L10n.Scan.Error.timeout
        }
    }

    func retryScan() { }
}

// MARK: - Example 5: List with Sort/Filter

struct CardListView_Localized: View {
    @State private var searchQuery = ""
    @State private var showFavoritesOnly = false

    var body: some View {
        NavigationStack {
            List {
                // Card rows...
            }
            .searchable(
                text: $searchQuery,
                // ✅ BEFORE: prompt: "Search cards..."
                prompt: L10n.List.searchPlaceholder
            )
            // ✅ BEFORE: .navigationTitle("Cards")
            .navigationTitle(L10n.List.title)
            .toolbar {
                // Sort menu
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        sortMenuContent
                    } label: {
                        // ✅ BEFORE: Label("Sort", systemImage: ...)
                        Label(L10n.List.Sort.title, systemImage: "arrow.up.arrow.down")
                    }
                    // ✅ BEFORE: .accessibilityLabel("Sort options")
                    .accessibilityLabel(L10n.Accessibility.sortOptions)
                }

                // Filter menu
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        // ✅ BEFORE: Toggle("Favorites Only")
                        Toggle(L10n.List.Filter.favorites, isOn: $showFavoritesOnly)
                    } label: {
                        // ✅ BEFORE: Label("Filter", systemImage: ...)
                        Label(L10n.List.Filter.title, systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var sortMenuContent: some View {
        // ✅ BEFORE: Button("Newest First")
        Button(L10n.List.Sort.dateNewest) { }
        // ✅ BEFORE: Button("Oldest First")
        Button(L10n.List.Sort.dateOldest) { }
        // ✅ BEFORE: Button("Name (A-Z)")
        Button(L10n.List.Sort.nameAZ) { }
    }
}

// MARK: - Example 6: Using Format Strings with Parameters

struct SuccessView_WithParameters: View {
    let contactName = "Sarah Chen"
    let cardCount = 42

    var body: some View {
        VStack(spacing: 16) {
            // Success message with name parameter
            // ✅ BEFORE: Text("\\(contactName) has been saved to your database and Contacts.")
            Text(L10n.Preview.Success.withContacts(contactName))

            // Card count (handles pluralization)
            // ✅ BEFORE: Text("\\(cardCount) cards")
            Text(L10n.Count.cards(cardCount))

            // Days ago
            // ✅ BEFORE: Text("\\(days) days ago")
            Text(L10n.Date.daysAgo(3))
        }
    }
}

// MARK: - Example 7: Delete Confirmation

struct DeleteConfirmation_Localized: View {
    let contactName = "John Doe"
    @State private var showDeleteAlert = false

    var body: some View {
        Button("Delete") {
            showDeleteAlert = true
        }
        .alert(
            // ✅ BEFORE: "Delete Contact?"
            L10n.List.DeleteConfirm.title,
            isPresented: $showDeleteAlert
        ) {
            Button(
                // ✅ BEFORE: "Delete"
                L10n.List.DeleteConfirm.delete,
                role: .destructive
            ) {
                deleteContact()
            }
            Button(
                // ✅ BEFORE: "Cancel"
                L10n.List.DeleteConfirm.cancel,
                role: .cancel
            ) { }
        } message: {
            // ✅ BEFORE: "This will permanently delete \\(name)..."
            Text(L10n.List.DeleteConfirm.message(contactName))
        }
    }

    func deleteContact() { }
}

// MARK: - Example 8: Settings Screen

struct SettingsView_Localized: View {
    @State private var autoSave = false
    @State private var hapticsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                // Scanning section
                Section {
                    Toggle(
                        // ✅ BEFORE: "Auto-save After Scan"
                        L10n.Settings.Scanning.autoSave,
                        isOn: $autoSave
                    )
                    // ✅ BEFORE: Text("Automatically save contacts...")
                    Text(L10n.Settings.Scanning.autoSaveDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Toggle(
                        // ✅ BEFORE: "Haptic Feedback"
                        L10n.Settings.Scanning.haptics,
                        isOn: $hapticsEnabled
                    )
                } header: {
                    // ✅ BEFORE: Text("Scanning")
                    Text(L10n.Settings.Section.scanning)
                }

                // Privacy section
                Section {
                    NavigationLink {
                        Text("Privacy details")
                    } label: {
                        VStack(alignment: .leading) {
                            // ✅ BEFORE: Text("Your Data")
                            Text(L10n.Settings.Privacy.dataLocation)
                            // ✅ BEFORE: Text("All business cards are stored locally...")
                            Text(L10n.Settings.Privacy.dataLocationDetail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    // ✅ BEFORE: Text("Privacy")
                    Text(L10n.Settings.Section.privacy)
                }
            }
            // ✅ BEFORE: .navigationTitle("Settings")
            .navigationTitle(L10n.Settings.title)
        }
    }
}

// MARK: - Example 9: Using String Extension (Alternative)

struct AlternativeApproach: View {
    var body: some View {
        VStack {
            // Instead of L10n enum, can use String extension
            // (Less type-safe but more flexible for dynamic keys)

            // ✅ Simple localization
            Text("scan.title".localized)

            // ✅ With format parameters
            Text("preview.success.withContacts".localized(with: "Sarah Chen"))

            // Still works, but L10n enum is preferred for type-safety
        }
    }
}

// MARK: - Example 10: Accessibility Labels

struct AccessibleButton_Localized: View {
    var body: some View {
        Button {
            // Cancel action
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
        }
        // ✅ BEFORE: .accessibilityLabel("Cancel scanning")
        .accessibilityLabel(L10n.Accessibility.scannerCancel)
        // ✅ BEFORE: .accessibilityHint("Double tap to close scanner")
        .accessibilityHint(L10n.Accessibility.scannerCancelHint)
    }
}

// MARK: - Quick Migration Checklist

/*
 To migrate an existing view to use localization:

 1. Import the LocalizationHelper (automatic if in same project)
 2. Find all hard-coded strings:
    - Text("...")
    - Button("...")
    - Label("...")
    - navigationTitle("...")
    - Alert titles/messages
    - Placeholders
    - Accessibility labels

 3. Replace with L10n equivalents:
    - Check L10n enum structure
    - Use appropriate category (Scan, Preview, List, etc.)
    - Maintain string formatting (%@, %d parameters)

 4. Test:
    - Verify text displays correctly
    - Check string parameters work
    - Test accessibility with VoiceOver
    - Preview in different languages (if added)

 5. Common patterns:
    - L10n.Feature.title for screen titles
    - L10n.Feature.Button.action for button labels
    - L10n.Feature.Field.name for form fields
    - L10n.Feature.Error.type for error messages
*/
