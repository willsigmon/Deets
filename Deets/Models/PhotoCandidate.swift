//
//  PhotoCandidate.swift
//  Deets
//
//  Model for representing photo candidates from the Photos library
//  with face detection metadata and quality scoring.
//

import Foundation
import Photos
import Vision
import UIKit

/// Represents a photo from the library that potentially matches a contact
struct PhotoCandidate: Identifiable {
    let id: String
    let asset: PHAsset
    let image: UIImage?
    let faceObservations: [VNFaceObservation]
    let qualityScore: FaceQualityScore
    let source: PhotoSource
    let matchConfidence: Double

    init(
        asset: PHAsset,
        image: UIImage?,
        faceObservations: [VNFaceObservation] = [],
        source: PhotoSource,
        matchConfidence: Double = 0.0
    ) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.image = image
        self.faceObservations = faceObservations
        self.source = source
        self.matchConfidence = matchConfidence

        // Calculate quality score for primary face (if any)
        if let primaryFace = faceObservations.first {
            self.qualityScore = FaceQualityScore(observation: primaryFace, image: image)
        } else {
            self.qualityScore = FaceQualityScore.empty
        }
    }

    /// The primary (highest quality) face observation
    var primaryFace: VNFaceObservation? {
        faceObservations.first
    }

    /// Whether this candidate has at least one detected face
    var hasFace: Bool {
        !faceObservations.isEmpty
    }

    /// Number of faces detected in the image
    var faceCount: Int {
        faceObservations.count
    }

    /// Whether this is a good candidate based on quality thresholds
    var isGoodCandidate: Bool {
        hasFace && qualityScore.overall >= 0.6
    }

    /// Human-readable source description
    var sourceDescription: String {
        switch source {
        case .peopleAlbum(let name):
            return "People: \(name)"
        case .recents:
            return "Recent Photos"
        case .library:
            return "Photo Library"
        }
    }
}

// MARK: - Photo Source

/// Where the photo candidate was found
enum PhotoSource: Equatable {
    case peopleAlbum(personName: String)
    case recents
    case library

    var priority: Int {
        switch self {
        case .peopleAlbum: return 3 // Highest priority
        case .recents: return 2
        case .library: return 1
        }
    }
}

// MARK: - Face Quality Score

/// Comprehensive quality assessment for a detected face
struct FaceQualityScore {
    let overall: Double          // 0.0 - 1.0 combined score
    let faceSize: Double         // How large the face is in the image
    let sharpness: Double        // Image sharpness (via laplacian variance)
    let lighting: Double         // Lighting quality estimate
    let angle: Double            // Face angle quality (frontal is best)
    let resolution: Double       // Pixel resolution of face region
    let confidence: Double       // VNFaceObservation confidence

    init(observation: VNFaceObservation, image: UIImage?) {
        self.confidence = Double(observation.confidence)

        // Calculate face size relative to image
        let boundingBox = observation.boundingBox
        let faceArea = boundingBox.width * boundingBox.height
        self.faceSize = min(Double(faceArea) * 4.0, 1.0) // Normalize to 0-1

        // Estimate angle quality based on roll, yaw, pitch
        var angleQuality = 1.0
        if let roll = observation.roll?.doubleValue {
            angleQuality *= max(0.0, 1.0 - abs(roll) / .pi)
        }
        if let yaw = observation.yaw?.doubleValue {
            angleQuality *= max(0.0, 1.0 - abs(yaw) / (.pi / 2))
        }
        self.angle = angleQuality

        // Calculate resolution of face region
        if let image = image {
            let imageSize = image.size
            let facePixelWidth = boundingBox.width * imageSize.width
            let facePixelHeight = boundingBox.height * imageSize.height
            let facePixels = facePixelWidth * facePixelHeight
            // Good face photo should be at least 200x200 pixels
            self.resolution = min(facePixels / (200 * 200), 1.0)
        } else {
            self.resolution = 0.5 // Unknown
        }

        // Estimate sharpness (would need actual image processing)
        // For now, use a placeholder based on confidence
        self.sharpness = self.confidence

        // Estimate lighting (would need actual image analysis)
        // For now, use a placeholder
        self.lighting = 0.8

        // Calculate overall weighted score
        self.overall = (
            confidence * 0.3 +
            faceSize * 0.25 +
            angle * 0.2 +
            resolution * 0.15 +
            sharpness * 0.05 +
            lighting * 0.05
        )
    }

    /// Empty score for photos with no faces
    static let empty = FaceQualityScore(
        overall: 0.0,
        faceSize: 0.0,
        sharpness: 0.0,
        lighting: 0.0,
        angle: 0.0,
        resolution: 0.0,
        confidence: 0.0
    )

    private init(
        overall: Double,
        faceSize: Double,
        sharpness: Double,
        lighting: Double,
        angle: Double,
        resolution: Double,
        confidence: Double
    ) {
        self.overall = overall
        self.faceSize = faceSize
        self.sharpness = sharpness
        self.lighting = lighting
        self.angle = angle
        self.resolution = resolution
        self.confidence = confidence
    }

    /// Human-readable quality rating
    var rating: QualityRating {
        switch overall {
        case 0.8...1.0: return .excellent
        case 0.6..<0.8: return .good
        case 0.4..<0.6: return .fair
        default: return .poor
        }
    }

    enum QualityRating: String {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"

        var icon: String {
            switch self {
            case .excellent: return "star.fill"
            case .good: return "star.leadinghalf.filled"
            case .fair: return "star"
            case .poor: return "exclamationmark.triangle"
            }
        }
    }
}

// MARK: - Comparable Extensions

extension PhotoCandidate: Comparable {
    static func < (lhs: PhotoCandidate, rhs: PhotoCandidate) -> Bool {
        // Sort by source priority first
        if lhs.source.priority != rhs.source.priority {
            return lhs.source.priority > rhs.source.priority
        }

        // Then by quality score
        if lhs.qualityScore.overall != rhs.qualityScore.overall {
            return lhs.qualityScore.overall > rhs.qualityScore.overall
        }

        // Finally by match confidence
        return lhs.matchConfidence > rhs.matchConfidence
    }

    static func == (lhs: PhotoCandidate, rhs: PhotoCandidate) -> Bool {
        lhs.id == rhs.id
    }
}
