//
//  PhotoEnrichmentIntegration.swift
//  Deets
//
//  Example implementation showing how to integrate photo enrichment
//  into the contact preview and editing flow.
//

import SwiftUI
import Contacts

// MARK: - Integration Example 1: Contact Preview View

/// Example showing how to add photo enrichment to ContactPreviewView
struct ContactPreviewWithPhotoExample: View {
    @StateObject private var viewModel: ContactPreviewViewModel
    @State private var showPhotoSelection = false
    @State private var contactPhoto: UIImage?
    @Environment(\.featureFlags) var flags

    let parsedContact: ParsedContact

    init(parsedContact: ParsedContact) {
        self.parsedContact = parsedContact
        _viewModel = StateObject(wrappedValue: ContactPreviewViewModel(contact: parsedContact))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Contact Photo Section
                photoSection

                // Contact Details
                contactDetailsSection

                // Save Button
                saveButton
            }
            .padding()
        }
        .sheet(isPresented: $showPhotoSelection) {
            PhotoSelectionView(contact: parsedContact) { selectedImage in
                contactPhoto = selectedImage
            }
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(spacing: 12) {
            // Photo display or placeholder
            if let photo = contactPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray.opacity(0.5))
            }

            // Add/Change Photo Button (only if feature enabled)
            if flags.photoEnrichmentEnabled {
                Button {
                    showPhotoSelection = true
                } label: {
                    HStack {
                        Image(systemName: contactPhoto == nil ? "photo" : "photo.badge.plus")
                        Text(contactPhoto == nil ? "Add Photo" : "Change Photo")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
        }
    }

    // MARK: - Contact Details

    private var contactDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let name = parsedContact.displayName {
                Text(name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            if let org = parsedContact.organizationName {
                Text(org)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Phone, email, etc.
            // ... (existing contact details UI)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            Task {
                await saveContact()
            }
        } label: {
            Text("Save to Contacts")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }

    private func saveContact() async {
        let contact = parsedContact.toCNMutableContact()

        // Attach photo if available
        if let photo = contactPhoto {
            contact.imageData = photo.jpegData(compressionQuality: 0.8)
        }

        // Save contact via ContactsService
        do {
            try await ContactsService.shared.saveContact(contact)
            // Show success
        } catch {
            // Show error
        }
    }
}

// MARK: - Integration Example 2: Post-Scan Flow

/// Example showing photo enrichment after successful scan
struct PostScanFlowWithPhotoExample: View {
    enum FlowStep {
        case reviewing
        case addingPhoto
        case saving
    }

    @State private var currentStep: FlowStep = .reviewing
    @State private var contactPhoto: UIImage?

    let parsedContact: ParsedContact

    var body: some View {
        NavigationView {
            ZStack {
                switch currentStep {
                case .reviewing:
                    reviewStep
                case .addingPhoto:
                    PhotoSelectionView(contact: parsedContact) { image in
                        contactPhoto = image
                        currentStep = .saving
                    }
                case .saving:
                    savingStep
                }
            }
            .navigationTitle("New Contact")
        }
    }

    private var reviewStep: some View {
        VStack(spacing: 20) {
            // Contact preview
            Text("Contact scanned successfully!")
                .font(.headline)

            // Show parsed data
            // ...

            // Photo enrichment prompt
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .iconMedium()
                    .foregroundColor(.blue)

                Text("Add a photo to this contact?")
                    .font(.headline)

                Text("We can search your Photos library for pictures of \(parsedContact.displayName ?? "this person")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button("Skip") {
                        currentStep = .saving
                    }
                    .buttonStyle(.bordered)

                    Button("Add Photo") {
                        currentStep = .addingPhoto
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }

    private var savingStep: some View {
        VStack(spacing: 20) {
            if let photo = contactPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }

            Text("Saving contact...")
                .font(.headline)

            ProgressView()
        }
        .task {
            await saveContactWithPhoto()
        }
    }

    private func saveContactWithPhoto() async {
        let contact = parsedContact.toCNMutableContact()

        if let photo = contactPhoto {
            contact.imageData = photo.jpegData(compressionQuality: 0.8)
        }

        // Save contact
        // ...
    }
}

// MARK: - Integration Example 3: Batch Photo Enrichment

/// Example showing photo enrichment for multiple contacts
struct BatchPhotoEnrichmentExample: View {
    @State private var contacts: [ParsedContact]
    @State private var currentContactIndex = 0
    @State private var contactPhotos: [String: UIImage] = [:] // ID -> Image

    init(contacts: [ParsedContact]) {
        _contacts = State(initialValue: contacts)
    }

    var body: some View {
        NavigationView {
            VStack {
                // Progress indicator
                progressHeader

                // Current contact photo selector
                if currentContactIndex < contacts.count {
                    PhotoSelectionView(contact: currentContact) { image in
                        savePhotoAndContinue(image)
                    }
                } else {
                    completionView
                }
            }
            .navigationTitle("Add Photos")
        }
    }

    private var currentContact: ParsedContact {
        contacts[currentContactIndex]
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            Text("Contact \(currentContactIndex + 1) of \(contacts.count)")
                .font(.headline)

            ProgressView(value: Double(currentContactIndex), total: Double(contacts.count))
                .padding(.horizontal)
        }
        .padding()
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .iconMediumLarge()
                .foregroundColor(.green)

            Text("Photos Added!")
                .font(.title2)
                .fontWeight(.semibold)

            Text("\(contactPhotos.count) of \(contacts.count) contacts have photos")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func savePhotoAndContinue(_ image: UIImage) {
        // Save photo for current contact
        contactPhotos[currentContact.rawText] = image

        // Move to next contact
        currentContactIndex += 1

        // If done, save all contacts
        if currentContactIndex >= contacts.count {
            Task {
                await saveAllContacts()
            }
        }
    }

    private func saveAllContacts() async {
        for contact in contacts {
            let cnContact = contact.toCNMutableContact()

            // Attach photo if available
            if let photo = contactPhotos[contact.rawText] {
                cnContact.imageData = photo.jpegData(compressionQuality: 0.8)
            }

            // Save contact
            // ...
        }
    }
}

// MARK: - Integration Example 4: Settings Toggle

/// Example showing how to add feature toggle in settings
struct PhotoEnrichmentSettingsExample: View {
    @ObservedObject var flags = FeatureFlags.shared

    var body: some View {
        Form {
            Section {
                Toggle("Photo Enrichment", isOn: $flags.photoEnrichmentEnabled)
            } header: {
                Text("Features")
            } footer: {
                Text("Automatically suggest photos from your library when adding contacts")
            }

            if flags.photoEnrichmentEnabled {
                Section {
                    NavigationLink("Photo Discovery Settings") {
                        photoDiscoverySettings
                    }
                } header: {
                    Text("Photo Settings")
                }
            }
        }
        .navigationTitle("Settings")
    }

    private var photoDiscoverySettings: some View {
        Form {
            Section {
                Toggle("Search People Album", isOn: .constant(true))
                Toggle("Search Recent Photos", isOn: .constant(true))
                Toggle("Face Quality Filtering", isOn: .constant(true))
            } header: {
                Text("Discovery Options")
            }

            Section {
                HStack {
                    Text("Maximum Candidates")
                    Spacer()
                    Text("12")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Minimum Quality")
                    Spacer()
                    Text("Good")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Quality Thresholds")
            }
        }
        .navigationTitle("Photo Discovery")
    }
}

// MARK: - Integration Example 5: Error Handling

/// Example showing comprehensive error handling
struct PhotoEnrichmentWithErrorHandlingExample: View {
    @State private var showPhotoSelection = false
    @State private var errorAlert: PhotoEnrichmentError?
    @State private var contactPhoto: UIImage?

    let parsedContact: ParsedContact

    var body: some View {
        VStack {
            Button("Add Photo") {
                handleAddPhoto()
            }
        }
        .sheet(isPresented: $showPhotoSelection) {
            PhotoSelectionView(contact: parsedContact) { image in
                contactPhoto = image
            }
        }
        .alert(item: $errorAlert) { error in
            Alert(
                title: Text("Photo Error"),
                message: Text(error.message),
                primaryButton: .default(Text(error.actionTitle)) {
                    error.action()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func handleAddPhoto() {
        // Check permission status
        let status = PhotoDiscoveryService.shared.checkAuthorizationStatus()

        switch status {
        case .notDetermined:
            // Request permission
            Task {
                let newStatus = await PhotoDiscoveryService.shared.requestAuthorization()
                if newStatus == .authorized || newStatus == .limited {
                    showPhotoSelection = true
                } else {
                    errorAlert = .permissionDenied
                }
            }

        case .authorized, .limited:
            // Show photo selection
            showPhotoSelection = true

        case .denied, .restricted:
            // Show error
            errorAlert = .permissionDenied

        @unknown default:
            errorAlert = .unknown
        }
    }
}

// MARK: - Error Types

enum PhotoEnrichmentError: Identifiable {
    case permissionDenied
    case noCandidatesFound
    case processingFailed
    case unknown

    var id: String {
        switch self {
        case .permissionDenied: return "denied"
        case .noCandidatesFound: return "noCandidates"
        case .processingFailed: return "failed"
        case .unknown: return "unknown"
        }
    }

    var message: String {
        switch self {
        case .permissionDenied:
            return "Photo library access is required to add photos to contacts."
        case .noCandidatesFound:
            return "No suitable photos were found in your library."
        case .processingFailed:
            return "An error occurred while processing photos."
        case .unknown:
            return "An unexpected error occurred."
        }
    }

    var actionTitle: String {
        switch self {
        case .permissionDenied:
            return "Open Settings"
        case .noCandidatesFound:
            return "Choose Manually"
        case .processingFailed, .unknown:
            return "Try Again"
        }
    }

    func action() {
        switch self {
        case .permissionDenied:
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        case .noCandidatesFound:
            // Show manual photo picker
            break
        case .processingFailed, .unknown:
            // Retry
            break
        }
    }
}

// MARK: - Usage Notes

/*

 ## Integration Checklist

 1. **Add Feature Flag Check**
    ```swift
    if FeatureFlags.shared.photoEnrichmentEnabled {
        // Show photo enrichment UI
    }
    ```

 2. **Import Required Frameworks**
    ```swift
    import Photos
    import Vision
    ```

 3. **Verify Info.plist**
    - NSPhotoLibraryUsageDescription ✓ (already present)

 4. **Handle Permission Flow**
    - Request authorization
    - Handle denial gracefully
    - Provide fallback (manual picker)

 5. **Attach Photo to Contact**
    ```swift
    contact.imageData = image.jpegData(compressionQuality: 0.8)
    ```

 6. **Test Edge Cases**
    - No permission
    - No photos found
    - Multiple faces
    - Low quality photos
    - Large images

 7. **Performance Testing**
    - Test with large photo libraries (10,000+ photos)
    - Monitor memory usage
    - Ensure UI stays responsive

 8. **Accessibility Testing**
    - VoiceOver navigation
    - Dynamic Type support
    - Reduced motion compliance

 */
