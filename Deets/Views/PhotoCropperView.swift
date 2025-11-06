//
//  PhotoCropperView.swift
//  Deets
//
//  SwiftUI interface for cropping contact photos with face-aware suggestions.
//  Provides manual adjustment controls and quality preview.
//

import SwiftUI
import Vision
import PhotosUI

/// Interactive photo cropping view with face detection support
struct PhotoCropperView: View {
    @StateObject private var viewModel: PhotoCropperViewModel
    @Environment(\.dismiss) private var dismiss

    let candidate: PhotoCandidate
    let onSave: (UIImage) -> Void

    init(candidate: PhotoCandidate, onSave: @escaping (UIImage) -> Void) {
        self.candidate = candidate
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: PhotoCropperViewModel(candidate: candidate))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Quality indicator
                qualityHeader

                // Image cropper
                GeometryReader { geometry in
                    ZStack {
                        // Background image
                        if let image = candidate.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)

                            // Crop overlay
                            CropOverlay(
                                cropRect: $viewModel.cropRect,
                                imageSize: image.size,
                                containerSize: geometry.size
                            )
                        }
                    }
                }
                .background(Color.black)

                // Controls
                controlsSection

                // Action buttons
                actionButtons
            }
            .navigationTitle("Crop Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Quality Header

    private var qualityHeader: some View {
        HStack(spacing: 12) {
            // Quality indicator
            Image(systemName: candidate.qualityScore.rating.icon)
                .foregroundColor(qualityColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(candidate.qualityScore.rating.rawValue + " Quality")
                    .font(.headline)

                if candidate.faceCount > 1 {
                    Text("\(candidate.faceCount) faces detected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if candidate.faceCount == 1 {
                    Text("1 face detected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Source badge
            Text(candidate.sourceDescription)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(6)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 2)
    }

    private var qualityColor: Color {
        switch candidate.qualityScore.rating {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(spacing: 16) {
            // Preset crop buttons
            if candidate.hasFace {
                HStack(spacing: 12) {
                    ForEach(0..<min(candidate.faceCount, 3), id: \.self) { index in
                        Button {
                            viewModel.cropToFace(at: index)
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "person.crop.circle")
                                    .font(.title2)
                                Text("Face \(index + 1)")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                    }
                }
            }

            // Manual adjustment
            VStack(alignment: .leading, spacing: 8) {
                Text("Crop Size")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Slider(
                    value: $viewModel.cropScale,
                    in: 0.3...1.0,
                    step: 0.05
                )
                .accentColor(.blue)
            }

            // Reset button
            Button {
                viewModel.resetCrop()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Preview
            Button {
                viewModel.showPreview.toggle()
            } label: {
                HStack {
                    Image(systemName: "eye")
                    Text("Preview")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }

            // Save
            Button {
                Task {
                    await viewModel.saveCroppedImage()
                    if let croppedImage = viewModel.croppedImage {
                        onSave(croppedImage)
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Use Photo")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: -2)
        .sheet(isPresented: $viewModel.showPreview) {
            previewSheet
        }
    }

    // MARK: - Preview Sheet

    private var previewSheet: some View {
        NavigationView {
            VStack {
                if let croppedImage = viewModel.previewImage {
                    Image(uiImage: croppedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .shadow(radius: 4)

                    Text("Contact Photo Preview")
                        .font(.headline)
                        .padding(.top)

                    Text("This is how the photo will appear in Contacts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    ProgressView("Generating preview...")
                }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.showPreview = false
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.generatePreview()
            }
        }
    }
}

// MARK: - Crop Overlay

private struct CropOverlay: View {
    @Binding var cropRect: CGRect
    let imageSize: CGSize
    let containerSize: CGSize

    var body: some View {
        GeometryReader { geometry in
            let scale = calculateScale()
            let offset = calculateOffset(scale: scale)

            ZStack {
                // Dimmed areas outside crop
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .fill(Color.white)
                            .overlay(
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(
                                        width: cropRect.width * scale,
                                        height: cropRect.height * scale
                                    )
                                    .offset(
                                        x: cropRect.origin.x * scale + offset.x,
                                        y: cropRect.origin.y * scale + offset.y
                                    )
                            )
                    )

                // Crop border
                Rectangle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(
                        width: cropRect.width * scale,
                        height: cropRect.height * scale
                    )
                    .offset(
                        x: cropRect.origin.x * scale + offset.x,
                        y: cropRect.origin.y * scale + offset.y
                    )

                // Corner handles
                ForEach(0..<4) { corner in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(
                            x: cornerOffset(corner, scale: scale, offset: offset).x,
                            y: cornerOffset(corner, scale: scale, offset: offset).y
                        )
                }
            }
        }
    }

    private func calculateScale() -> CGFloat {
        min(
            containerSize.width / imageSize.width,
            containerSize.height / imageSize.height
        )
    }

    private func calculateOffset(scale: CGFloat) -> CGPoint {
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale

        return CGPoint(
            x: (containerSize.width - scaledWidth) / 2,
            y: (containerSize.height - scaledHeight) / 2
        )
    }

    private func cornerOffset(_ corner: Int, scale: CGFloat, offset: CGPoint) -> CGPoint {
        let x = cropRect.origin.x * scale + offset.x + (corner % 2 == 0 ? 0 : cropRect.width * scale)
        let y = cropRect.origin.y * scale + offset.y + (corner < 2 ? 0 : cropRect.height * scale)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - View Model

@MainActor
private class PhotoCropperViewModel: ObservableObject {
    @Published var cropRect: CGRect
    @Published var cropScale: Double = 0.6
    @Published var showPreview = false
    @Published var croppedImage: UIImage?
    @Published var previewImage: UIImage?

    private let candidate: PhotoCandidate
    private let originalCropRect: CGRect

    init(candidate: PhotoCandidate) {
        self.candidate = candidate

        // Initialize with face-aware crop if available
        if let primaryFace = candidate.primaryFace,
           let image = candidate.image {
            let rect = FaceValidator.shared.getCropRect(
                for: primaryFace,
                in: image.size,
                padding: 0.3
            )
            self.cropRect = rect
            self.originalCropRect = rect
        } else if let image = candidate.image {
            // Center square crop
            let dimension = min(image.size.width, image.size.height)
            let x = (image.size.width - dimension) / 2
            let y = (image.size.height - dimension) / 2
            let rect = CGRect(x: x, y: y, width: dimension, height: dimension)
            self.cropRect = rect
            self.originalCropRect = rect
        } else {
            self.cropRect = .zero
            self.originalCropRect = .zero
        }
    }

    func cropToFace(at index: Int) {
        guard index < candidate.faceObservations.count,
              let image = candidate.image else {
            return
        }

        let face = candidate.faceObservations[index]
        cropRect = FaceValidator.shared.getCropRect(
            for: face,
            in: image.size,
            padding: 0.3
        )
    }

    func resetCrop() {
        cropRect = originalCropRect
        cropScale = 0.6
    }

    func saveCroppedImage() async {
        guard let image = candidate.image else { return }

        croppedImage = await cropImage(image, to: cropRect)
    }

    func generatePreview() async {
        guard let image = candidate.image else { return }

        previewImage = await cropImage(image, to: cropRect)
    }

    private func cropImage(_ image: UIImage, to rect: CGRect) async -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // Convert Vision coordinates to CGImage coordinates
        let convertedRect = FaceValidator.shared.convertVisionRectToUIKit(
            rect,
            imageHeight: CGFloat(cgImage.height)
        )

        guard let croppedCGImage = cgImage.cropping(to: convertedRect) else {
            return nil
        }

        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

// MARK: - Preview

#Preview {
    PhotoCropperView(
        candidate: PhotoCandidate(
            asset: PHAsset(),
            image: UIImage(systemName: "person.circle.fill"),
            faceObservations: [],
            source: .library,
            matchConfidence: 0.5
        ),
        onSave: { _ in }
    )
}
