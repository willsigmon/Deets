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

    // Photo picker states
    @State private var showPhotoOptions = false
    @State private var showPhotoPicker = false
    @State private var showPhotoSearch = false
    @State private var selectedPhoto: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with avatar
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            // Avatar image or initials
                            Group {
                                if let photo = selectedPhoto {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.teal.opacity(0.15))
                                        .frame(width: 100, height: 100)
                                        .overlay {
                                            Text(String(card.displayName.prefix(2)).uppercased())
                                                .font(.largeTitle.weight(.bold))
                                                .foregroundStyle(Color.teal)
                                        }
                                }
                            }

                            // Add photo button
                            Button {
                                HapticManager.shared.selectionChanged()
                                showPhotoOptions = true
                            } label: {
                                Image(systemName: selectedPhoto == nil ? "camera.circle.fill" : "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .background {
                                        Circle()
                                            .fill(Color.teal)
                                            .frame(width: 32, height: 32)
                                    }
                            }
                            .offset(x: 4, y: 4)
                        }
                        .accessibilityLabel("\(card.displayName) avatar")

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
                            if card.isFavorite == true {
                                StatusBadge(systemImage: "star.fill", text: "Favorite", color: .yellow)
                            }

                            if card.savedToContacts == true {
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
                            value: card.dateScanned?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown"
                        )

                        MetadataRow(
                            icon: "pencil",
                            title: "Last Modified",
                            value: card.dateModified?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown"
                        )
                    }
                    .padding(.horizontal, 20)

                    // Action buttons
                    VStack(spacing: 12) {
                        if card.savedToContacts != true {
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
                                card.isFavorite ?? false ? "Unfavorite" : "Favorite",
                                systemImage: (card.isFavorite ?? false) ? "star.slash" : "star.fill"
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
            .confirmationDialog("Add Photo", isPresented: $showPhotoOptions) {
                Button("Choose from Photos") {
                    showPhotoPicker = true
                }

                Button("Find in Photo Library") {
                    showPhotoSearch = true
                }

                Button("Search LinkedIn", action: {})
                    .disabled(true) // Placeholder for future

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Add a photo for \(card.displayName)")
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView(selectedImage: $selectedPhoto)
            }
            .sheet(isPresented: $showPhotoSearch) {
                PhotoSearchView(contact: card.toParsedContact(), selectedImage: $selectedPhoto)
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Actions

    private func toggleFavorite() {
        card.isFavorite = !(card.isFavorite ?? false)
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
            let nameParts = (card.fullName ?? "").components(separatedBy: " ")
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
        var lines: [String] = [card.displayName]

        if let jobTitle = card.jobTitle {
            lines.append(jobTitle)
        }

        if let company = card.company {
            lines.append(company)
        }

        if let email = card.email {
            lines.append(email)
        }

        if let phone = card.phoneNumber {
            lines.append(phone)
        }

        if let website = card.website {
            lines.append(website)
        }

        if let address = card.address {
            lines.append(address)
        }

        if let notes = card.notes {
            lines.append("\nNotes:\n\(notes)")
        }

        return lines.joined(separator: "\n")
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

// MARK: - Business Card Extension

extension BusinessCard {
    func toParsedContact() -> ParsedContact {
        let nameParts = (fullName ?? "").components(separatedBy: " ")
        var contact = ParsedContact(rawText: fullName ?? "")

        contact.givenName = nameParts.first
        contact.familyName = nameParts.dropFirst().joined(separator: " ").isEmpty ? nil : nameParts.dropFirst().joined(separator: " ")
        contact.organizationName = company
        contact.jobTitle = jobTitle

        if let email = email {
            contact.emailAddresses = [ParsedEmail(address: email, label: "Work", confidence: 1.0)]
        }

        if let phone = phoneNumber {
            contact.phoneNumbers = [ParsedPhoneNumber(number: phone, label: "Work", confidence: 1.0)]
        }

        if let website = website {
            contact.urls = [ParsedURL(url: website, label: "Work", confidence: 1.0)]
        }

        // Address parsing skipped - would need structured parsing

        return contact
    }
}

// MARK: - Photo Picker Views

import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else {
                parent.dismiss()
                return
            }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                        self.parent.dismiss()
                    }
                }
            } else {
                parent.dismiss()
            }
        }
    }
}

struct PhotoSearchView: View {
    let contact: ParsedContact
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    @State private var searchResults: [PhotoCandidate] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isSearching {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Searching for photos...")
                            .foregroundColor(.secondary)
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)

                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)

                        Button("Try Again") {
                            searchPhotos()
                        }
                    }
                    .padding()
                } else if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("No photos found")
                            .font(.headline)

                        Text("Try adding \(contact.displayName ?? "this person") to your People album in Photos app.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(searchResults) { candidate in
                                Button {
                                    selectedImage = candidate.image
                                    dismiss()
                                } label: {
                                    if let image = candidate.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Find Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                searchPhotos()
            }
        }
    }

    private func searchPhotos() {
        isSearching = true
        errorMessage = nil

        Task {
            do {
                let photoService = PhotoDiscoveryService.shared

                // Request permission first
                let status = await photoService.requestAuthorization()
                guard status == .authorized || status == .limited else {
                    await MainActor.run {
                        errorMessage = "Photo library access is required"
                        isSearching = false
                    }
                    return
                }

                // Search for photos
                let results = try await photoService.findPhotos(for: contact, limit: 20)

                await MainActor.run {
                    searchResults = results
                    isSearching = false

                    if results.isEmpty {
                        errorMessage = nil // Show empty state instead
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSearching = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Card Detail") {
    CardDetailView(card: BusinessCard.sampleData[0])
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
