//
//  CardDetailView.swift
//  Deets
//
//  Detailed view of a business card with edit and export options
//

import SwiftUI
import SwiftData
import Contacts

struct CardDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var card: BusinessCard

    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    @State private var showShareSheet = false
    @State private var showExportOptions = false
    @State private var exportError: String?
    @StateObject private var exportViewModel = ExportViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with avatar
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.teal.opacity(0.15))
                                .frame(width: 100, height: 100)

                            Text(card.fullName.prefix(2).uppercased())
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(Color.teal)
                        }
                        .accessibilityLabel("\(card.fullName) avatar")

                        VStack(spacing: 4) {
                            Text(card.displayName)
                                .font(.title.weight(.bold))
                                .multilineTextAlignment(.center)

                            if let subtitle = card.displaySubtitle {
                                Text(subtitle)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        // Status badges
                        HStack(spacing: 12) {
                            if card.isFavorite {
                                StatusBadge(systemImage: "star.fill", text: "Favorite", color: .yellow)
                            }

                            if card.savedToContacts {
                                StatusBadge(systemImage: "checkmark.circle.fill", text: "In Contacts", color: .green)
                            }
                        }
                    }
                    .padding(.top, 24)

                    // Contact information sections
                    VStack(spacing: 20) {
                        if let email = card.email {
                            ContactInfoRow(
                                icon: "envelope.fill",
                                title: "Email",
                                value: email,
                                action: {
                                    if let url = URL(string: "mailto:\(email)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }

                        if let phone = card.phoneNumber {
                            ContactInfoRow(
                                icon: "phone.fill",
                                title: "Phone",
                                value: phone,
                                action: {
                                    if let url = URL(string: "tel:\(phone.filter { $0.isNumber })") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }

                        if let website = card.website {
                            ContactInfoRow(
                                icon: "globe",
                                title: "Website",
                                value: website,
                                action: {
                                    if let url = URL(string: website) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }

                        if let address = card.address {
                            ContactInfoRow(
                                icon: "location.fill",
                                title: "Address",
                                value: address,
                                action: {
                                    let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                    if let url = URL(string: "http://maps.apple.com/?address=\(encodedAddress)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }

                        if let jobTitle = card.jobTitle {
                            ContactInfoRow(
                                icon: "briefcase.fill",
                                title: "Job Title",
                                value: jobTitle
                            )
                        }

                        if let notes = card.notes {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Notes", systemImage: "note.text")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)

                                Text(notes)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Metadata
                    VStack(spacing: 12) {
                        MetadataRow(
                            icon: "calendar",
                            title: "Scanned",
                            value: card.dateScanned.formatted(date: .abbreviated, time: .shortened)
                        )

                        MetadataRow(
                            icon: "pencil",
                            title: "Last Modified",
                            value: card.dateModified.formatted(date: .abbreviated, time: .shortened)
                        )
                    }
                    .padding(.horizontal, 20)

                    // Action buttons
                    VStack(spacing: 12) {
                        if !card.savedToContacts {
                            PrimaryButton("Save to Contacts", systemImage: "person.crop.circle.badge.plus") {
                                Task {
                                    await saveToContacts()
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        HStack(spacing: 12) {
                            SecondaryButton(
                                "Export",
                                systemImage: "square.and.arrow.up"
                            ) {
                                exportViewModel.configureSingleCard(card)
                                showExportOptions = true
                            }

                            SecondaryButton(
                                "Share",
                                systemImage: "shared.with.you"
                            ) {
                                showShareSheet = true
                            }

                            SecondaryButton(
                                card.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: card.isFavorite ? "star.slash" : "star.fill"
                            ) {
                                toggleFavorite()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Contact Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            exportViewModel.configureSingleCard(card)
                            showExportOptions = true
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            isEditing = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        HapticManager.shared.buttonTap()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(text: formatCardText())
            }
            .sheet(isPresented: $showExportOptions) {
                ExportOptionsView(viewModel: exportViewModel)
            }
            .confirmationDialog("Delete Card", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteCard()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this business card? This action cannot be undone.")
            }
            .alert("Export Error", isPresented: .constant(exportError != nil)) {
                Button("OK") {
                    exportError = nil
                }
            } message: {
                if let error = exportError {
                    Text(error)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Actions

    private func toggleFavorite() {
        card.isFavorite.toggle()
        card.dateModified = Date()
        try? modelContext.save()
        HapticManager.shared.toggle()
    }

    private func deleteCard() {
        modelContext.delete(card)
        try? modelContext.save()
        HapticManager.shared.deleted()
        dismiss()
    }

    private func saveToContacts() async {
        let store = CNContactStore()

        do {
            // Request authorization
            let status = CNContactStore.authorizationStatus(for: .contacts)

            switch status {
            case .notDetermined:
                let granted = try await store.requestAccess(for: .contacts)
                if !granted {
                    exportError = "Contacts permission denied"
                    return
                }
            case .denied, .restricted:
                exportError = "Contacts permission is required. Please enable it in Settings."
                return
            case .authorized:
                break
            @unknown default:
                exportError = "Unable to access contacts"
                return
            }

            // Create contact
            let contact = CNMutableContact()
            let nameParts = card.fullName.components(separatedBy: " ")
            contact.givenName = nameParts.first ?? ""
            contact.familyName = nameParts.dropFirst().joined(separator: " ")

            if let jobTitle = card.jobTitle {
                contact.jobTitle = jobTitle
            }

            if let company = card.company {
                contact.organizationName = company
            }

            if let email = card.email {
                contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: email as NSString)]
            }

            if let phone = card.phoneNumber {
                let phoneNumber = CNPhoneNumber(stringValue: phone)
                contact.phoneNumbers = [CNLabeledValue(label: CNLabelWork, value: phoneNumber)]
            }

            if let website = card.website {
                contact.urlAddresses = [CNLabeledValue(label: CNLabelWork, value: website as NSString)]
            }

            if let address = card.address {
                let postalAddress = CNMutablePostalAddress()
                postalAddress.street = address
                contact.postalAddresses = [CNLabeledValue(label: CNLabelWork, value: postalAddress)]
            }

            if let notes = card.notes {
                contact.note = notes
            }

            // Save
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            try store.execute(saveRequest)

            // Update card
            card.savedToContacts = true
            card.dateModified = Date()
            try? modelContext.save()

            HapticManager.shared.saved()
        } catch {
            exportError = "Failed to save contact: \(error.localizedDescription)"
            HapticManager.shared.scanError()
        }
    }

    private func formatCardText() -> String {
        var text = card.fullName

        if let jobTitle = card.jobTitle {
            text += "\\n\(jobTitle)"
        }

        if let company = card.company {
            text += "\\n\(company)"
        }

        if let email = card.email {
            text += "\\n\(email)"
        }

        if let phone = card.phoneNumber {
            text += "\\n\(phone)"
        }

        if let website = card.website {
            text += "\\n\(website)"
        }

        if let address = card.address {
            text += "\\n\(address)"
        }

        return text
    }
}

// MARK: - Supporting Views

struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    var action: (() -> Void)?

    var body: some View {
        Button {
            if let action {
                HapticManager.shared.buttonTap()
                action()
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color.teal)
                    .frame(width: 32)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(value)
                        .font(.body)
                        .foregroundStyle(.primary)
                }

                Spacer()

                if action != nil {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityHint(action != nil ? "Double tap to open" : "")
    }
}

struct StatusBadge: View {
    let systemImage: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption2)

            Text(text)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
        .accessibilityElement(children: .combine)
    }
}

struct MetadataRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("Card Detail") {
    CardDetailView(card: BusinessCard.sampleData[0])
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
