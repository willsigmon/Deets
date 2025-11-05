//
//  PhotoSelectionView.swift
//  Deets
//
//  View for selecting a photo from discovered candidates.
//  Integrates with PhotoDiscoveryService to find and display matching photos.
//

import SwiftUI
import Photos

/// View for selecting a contact photo from discovered candidates
struct PhotoSelectionView: View {
    @StateObject private var viewModel: PhotoSelectionViewModel
    @Environment(\.dismiss) private var dismiss

    let contact: ParsedContact
    let onPhotoSelected: (UIImage) -> Void

    init(contact: ParsedContact, onPhotoSelected: @escaping (UIImage) -> Void) {
        self.contact = contact
        self.onPhotoSelected = onPhotoSelected
        _viewModel = StateObject(wrappedValue: PhotoSelectionViewModel(contact: contact))
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.authorizationStatus == .notDetermined {
                    permissionPrompt
                } else if viewModel.authorizationStatus == .denied || viewModel.authorizationStatus == .restricted {
                    permissionDenied
                } else {
                    mainContent
                }
            }
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.initialize()
            }
            .sheet(item: $viewModel.selectedCandidate) { candidate in
                PhotoCropperView(candidate: candidate) { croppedImage in
                    onPhotoSelected(croppedImage)
                    dismiss()
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Permission Prompt

    private var permissionPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .iconMediumLarge()
                .foregroundColor(.blue)

            Text("Find Contact Photo")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Deets can search your Photos library to find pictures of \(contact.displayName ?? "this contact").")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "person.crop.circle",
                    title: "Smart Matching",
                    description: "Automatically finds photos tagged with this person"
                )

                FeatureRow(
                    icon: "face.smiling",
                    title: "Face Detection",
                    description: "Detects and suggests the best face photo"
                )

                FeatureRow(
                    icon: "lock.shield",
                    title: "Privacy First",
                    description: "Photos stay on your device, never uploaded"
                )
            }
            .padding()

            Button {
                Task {
                    await viewModel.requestPermission()
                }
            } label: {
                Text("Allow Photo Access")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button("Not Now") {
                dismiss()
            }
            .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - Permission Denied

    private var permissionDenied: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .iconMediumLarge()
                .foregroundColor(.orange)

            Text("Photo Access Disabled")
                .font(.title2)
                .fontWeight(.semibold)

            Text("To add photos to contacts, enable photo library access in Settings.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            } label: {
                Text("Open Settings")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search header
                if viewModel.isSearching {
                    searchingIndicator
                } else if !viewModel.candidates.isEmpty {
                    searchResultsHeader
                } else if viewModel.hasSearched {
                    noCandidatesView
                }

                // Photo grid
                if !viewModel.candidates.isEmpty {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(viewModel.candidates) { candidate in
                            PhotoCandidateCard(candidate: candidate) {
                                viewModel.selectCandidate(candidate)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Manual photo picker
                manualPickerButton
            }
            .padding(.vertical)
        }
    }

    // MARK: - Searching Indicator

    private var searchingIndicator: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Searching for photos...")
                .font(.headline)

            Text("Looking through your library for \(contact.displayName ?? "this contact")")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Search Results Header

    private var searchResultsHeader: some View {
        VStack(spacing: 8) {
            Text("Found \(viewModel.candidates.count) Photo\(viewModel.candidates.count == 1 ? "" : "s")")
                .font(.headline)

            if let bestCandidate = viewModel.candidates.first {
                HStack(spacing: 4) {
                    Image(systemName: bestCandidate.qualityScore.rating.icon)
                        .foregroundColor(.blue)
                    Text("Best: \(bestCandidate.qualityScore.rating.rawValue) quality")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }

    // MARK: - No Candidates

    private var noCandidatesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .iconMedium()
                .foregroundColor(.gray)

            Text("No Photos Found")
                .font(.headline)

            Text("We couldn't find any photos matching \(contact.displayName ?? "this contact") in your library.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    // MARK: - Manual Picker Button

    private var manualPickerButton: some View {
        Button {
            viewModel.showManualPicker = true
        } label: {
            HStack {
                Image(systemName: "photo.on.rectangle")
                Text("Choose from Library")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .sheet(isPresented: $viewModel.showManualPicker) {
            ImagePicker(image: $viewModel.manuallySelectedImage)
        }
        .onChange(of: viewModel.manuallySelectedImage) { _, newImage in
            if let image = newImage {
                onPhotoSelected(image)
                dismiss()
            }
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Photo Candidate Card

private struct PhotoCandidateCard: View {
    let candidate: PhotoCandidate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Image
                if let image = candidate.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Quality badge
                HStack(spacing: 4) {
                    Image(systemName: candidate.qualityScore.rating.icon)
                        .font(.caption2)
                    Text(candidate.qualityScore.rating.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundColor(qualityColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(qualityColor.opacity(0.1))
                .cornerRadius(4)

                // Face count
                if candidate.faceCount > 1 {
                    Text("\(candidate.faceCount) faces")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var qualityColor: Color {
        switch candidate.qualityScore.rating {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }
}

// MARK: - Image Picker

private struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - View Model

@MainActor
private class PhotoSelectionViewModel: ObservableObject {
    @Published var candidates: [PhotoCandidate] = []
    @Published var selectedCandidate: PhotoCandidate?
    @Published var isSearching = false
    @Published var hasSearched = false
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var showError = false
    @Published var error: Error?
    @Published var showManualPicker = false
    @Published var manuallySelectedImage: UIImage?

    private let contact: ParsedContact
    private let photoService = PhotoDiscoveryService.shared

    init(contact: ParsedContact) {
        self.contact = contact
    }

    func initialize() async {
        authorizationStatus = photoService.checkAuthorizationStatus()

        if photoService.hasPhotoLibraryAccess {
            await searchPhotos()
        }
    }

    func requestPermission() async {
        authorizationStatus = await photoService.requestAuthorization()

        if photoService.hasPhotoLibraryAccess {
            await searchPhotos()
        }
    }

    func searchPhotos() async {
        isSearching = true
        hasSearched = false

        do {
            candidates = try await photoService.findPhotos(for: contact, limit: 12)
            hasSearched = true
        } catch {
            self.error = error
            showError = true
        }

        isSearching = false
    }

    func selectCandidate(_ candidate: PhotoCandidate) {
        selectedCandidate = candidate
    }
}

// MARK: - Preview

#Preview {
    PhotoSelectionView(
        contact: ParsedContact(rawText: "John Doe"),
        onPhotoSelected: { _ in }
    )
}
