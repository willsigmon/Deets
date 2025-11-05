//
//  PhotoDiscoveryService.swift
//  Deets
//
//  Service for discovering photos in the user's library that match a contact.
//  Integrates with PhotoKit and Vision framework for intelligent photo matching.
//

import Foundation
import Photos
import Vision
import UIKit

/// Service for discovering and matching photos from the user's photo library
@MainActor
final class PhotoDiscoveryService: ObservableObject {

    // MARK: - Singleton

    static let shared = PhotoDiscoveryService()

    private init() {}

    // MARK: - Published State

    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isSearching = false

    // MARK: - Authorization

    /// Request photo library access permission
    func requestAuthorization() async -> PHAuthorizationStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        self.authorizationStatus = status
        return status
    }

    /// Check current authorization status
    func checkAuthorizationStatus() -> PHAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        self.authorizationStatus = status
        return status
    }

    /// Whether the user has granted photo library access
    var hasPhotoLibraryAccess: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }

    // MARK: - Photo Discovery

    /// Search for photos matching a contact
    func findPhotos(
        for contact: ParsedContact,
        limit: Int = 20
    ) async throws -> [PhotoCandidate] {
        guard hasPhotoLibraryAccess else {
            throw PhotoDiscoveryError.noPermission
        }

        isSearching = true
        defer { isSearching = false }

        var candidates: [PhotoCandidate] = []

        // Strategy 1: Search People album by name
        if let personName = contact.displayName {
            let peoplePhotos = try await searchPeopleAlbum(for: personName, limit: limit)
            candidates.append(contentsOf: peoplePhotos)
        }

        // Strategy 2: Search recent photos (last 30 days) if not enough matches
        if candidates.count < 5 {
            let recentPhotos = try await searchRecentPhotos(limit: min(limit - candidates.count, 10))
            candidates.append(contentsOf: recentPhotos)
        }

        // Strategy 3: Search all library (with face detection) if still not enough
        if candidates.isEmpty {
            let libraryPhotos = try await searchLibraryPhotos(limit: 5)
            candidates.append(contentsOf: libraryPhotos)
        }

        // Sort candidates by quality and source priority
        let sorted = candidates.sorted()

        return Array(sorted.prefix(limit))
    }

    // MARK: - Search Strategies

    /// Search the People album for a specific person
    private func searchPeopleAlbum(
        for personName: String,
        limit: Int
    ) async throws -> [PhotoCandidate] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = limit

        // Fetch person objects from Photos
        let people = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: nil
        )

        var candidates: [PhotoCandidate] = []

        // Search through People album
        people.enumerateObjects { collection, _, _ in
            // Check if collection name matches contact name
            guard let name = collection.localizedTitle,
                  self.namesMatch(name, personName) else {
                return
            }

            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)

            assets.enumerateObjects { asset, _, _ in
                // Only process images
                guard asset.mediaType == .image else { return }

                Task {
                    if let candidate = await self.processAsset(
                        asset,
                        source: .peopleAlbum(personName: personName),
                        matchConfidence: 0.8
                    ) {
                        candidates.append(candidate)
                    }
                }
            }
        }

        return candidates
    }

    /// Search recent photos (last 30 days)
    private func searchRecentPhotos(limit: Int) async throws -> [PhotoCandidate] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = limit
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        // Filter to last 30 days
        if let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) {
            fetchOptions.predicate = NSPredicate(
                format: "creationDate > %@ AND mediaType == %d",
                thirtyDaysAgo as NSDate,
                PHAssetMediaType.image.rawValue
            )
        } else {
            // Fallback: just filter by media type without date restriction
            AppLogger.photos.warning("Failed to calculate date 30 days ago - fetching all recent photos")
            fetchOptions.predicate = NSPredicate(
                format: "mediaType == %d",
                PHAssetMediaType.image.rawValue
            )
        }

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var candidates: [PhotoCandidate] = []

        for index in 0..<min(assets.count, limit) {
            let asset = assets.object(at: index)

            if let candidate = await processAsset(
                asset,
                source: .recents,
                matchConfidence: 0.3
            ) {
                candidates.append(candidate)
            }
        }

        return candidates
    }

    /// Search all library photos with faces
    private func searchLibraryPhotos(limit: Int) async throws -> [PhotoCandidate] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = limit * 3 // Fetch more since we'll filter
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(
            format: "mediaType == %d",
            PHAssetMediaType.image.rawValue
        )

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var candidates: [PhotoCandidate] = []

        for index in 0..<min(assets.count, limit * 3) {
            let asset = assets.object(at: index)

            if let candidate = await processAsset(
                asset,
                source: .library,
                matchConfidence: 0.1
            ) {
                // Only include if it has a face
                if candidate.hasFace {
                    candidates.append(candidate)
                }

                // Stop once we have enough
                if candidates.count >= limit {
                    break
                }
            }
        }

        return candidates
    }

    // MARK: - Asset Processing

    /// Process a PHAsset into a PhotoCandidate with face detection
    private func processAsset(
        _ asset: PHAsset,
        source: PhotoSource,
        matchConfidence: Double
    ) async -> PhotoCandidate? {
        // Load the image
        guard let image = await loadImage(from: asset) else {
            return nil
        }

        // Detect faces
        let faces = (try? await FaceValidator.shared.detectFaces(in: image)) ?? []

        // Create candidate
        return PhotoCandidate(
            asset: asset,
            image: image,
            faceObservations: faces,
            source: source,
            matchConfidence: matchConfidence
        )
    }

    /// Load a UIImage from a PHAsset
    private func loadImage(from asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            let targetSize = CGSize(width: 1024, height: 1024) // Reasonable size for face detection

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                continuation.resume(returning: image)
            }
        }
    }

    // MARK: - Image Export

    /// Export a cropped image for use as contact photo
    func exportImage(
        candidate: PhotoCandidate,
        cropRect: CGRect? = nil
    ) async throws -> UIImage {
        guard let originalImage = candidate.image else {
            throw PhotoDiscoveryError.imageLoadFailed
        }

        // If no crop rect specified, use the primary face with padding
        let finalCropRect: CGRect
        if let cropRect = cropRect {
            finalCropRect = cropRect
        } else if let primaryFace = candidate.primaryFace {
            let imageSize = originalImage.size
            finalCropRect = FaceValidator.shared.getCropRect(
                for: primaryFace,
                in: imageSize,
                padding: 0.2
            )
        } else {
            // No face, use center crop
            finalCropRect = getCenterSquareCrop(for: originalImage.size)
        }

        // Crop the image
        guard let croppedImage = cropImage(originalImage, to: finalCropRect) else {
            throw PhotoDiscoveryError.cropFailed
        }

        return croppedImage
    }

    /// Crop an image to a specific rectangle
    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // Convert Vision coordinates (bottom-left) to CGImage coordinates (top-left)
        let convertedRect = FaceValidator.shared.convertVisionRectToUIKit(
            rect,
            imageHeight: CGFloat(cgImage.height)
        )

        guard let croppedCGImage = cgImage.cropping(to: convertedRect) else {
            return nil
        }

        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Get a center square crop rect for an image
    private func getCenterSquareCrop(for imageSize: CGSize) -> CGRect {
        let dimension = min(imageSize.width, imageSize.height)
        let x = (imageSize.width - dimension) / 2
        let y = (imageSize.height - dimension) / 2

        return CGRect(x: x, y: y, width: dimension, height: dimension)
    }

    // MARK: - Helpers

    /// Check if two names match (fuzzy matching)
    private func namesMatch(_ name1: String, _ name2: String) -> Bool {
        let normalized1 = name1.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized2 = name2.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Exact match
        if normalized1 == normalized2 {
            return true
        }

        // Contains match (for "John Doe" matching "John" or "Doe")
        if normalized1.contains(normalized2) || normalized2.contains(normalized1) {
            return true
        }

        // First/last name components match
        let components1 = normalized1.components(separatedBy: " ")
        let components2 = normalized2.components(separatedBy: " ")

        for comp1 in components1 {
            for comp2 in components2 {
                if comp1 == comp2 && !comp1.isEmpty {
                    return true
                }
            }
        }

        return false
    }
}

// MARK: - ParsedContact Extension

extension ParsedContact {
    /// Display name for photo matching
    var displayName: String? {
        var parts: [String] = []

        if let given = givenName {
            parts.append(given)
        }
        if let family = familyName {
            parts.append(family)
        }

        let name = parts.joined(separator: " ")
        return name.isEmpty ? nil : name
    }
}

// MARK: - Errors

enum PhotoDiscoveryError: LocalizedError {
    case noPermission
    case imageLoadFailed
    case cropFailed
    case noCandidatesFound
    case processingFailed

    var errorDescription: String? {
        switch self {
        case .noPermission:
            return "Photo library access is required to find photos."
        case .imageLoadFailed:
            return "Failed to load the selected image."
        case .cropFailed:
            return "Failed to crop the image."
        case .noCandidatesFound:
            return "No suitable photos were found in your library."
        case .processingFailed:
            return "Failed to process photos from your library."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noPermission:
            return "Grant photo library access in Settings to enable this feature."
        case .imageLoadFailed, .cropFailed, .processingFailed:
            return "Please try again or select a different photo."
        case .noCandidatesFound:
            return "Try adding the person to your People album in Photos."
        }
    }
}
