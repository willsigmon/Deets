//
//  FaceValidator.swift
//  Deets
//
//  Advanced face quality validation using Vision framework.
//  Scores faces based on size, angle, lighting, and sharpness.
//

import Foundation
import Vision
import UIKit
import Accelerate

/// Service for validating and scoring face quality in images
@MainActor
final class FaceValidator {

    // MARK: - Singleton

    static let shared = FaceValidator()

    private init() {}

    // MARK: - Quality Thresholds

    struct QualityThresholds {
        static let minimumFaceSize: Double = 0.15        // 15% of image area
        static let minimumConfidence: Double = 0.5       // VNFaceObservation confidence
        static let minimumResolution: Double = 200.0     // Pixels width/height
        static let minimumSharpness: Double = 100.0      // Laplacian variance
        static let preferredFaceSize: Double = 0.30      // 30% of image for "good" photo
    }

    // MARK: - Face Detection

    /// Detect all faces in an image
    func detectFaces(in image: UIImage) async throws -> [VNFaceObservation] {
        guard let cgImage = image.cgImage else {
            throw FaceValidationError.invalidImage
        }

        let request = VNDetectFaceRectanglesRequest()
        request.revision = VNDetectFaceRectanglesRequestRevision3

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        try handler.perform([request])

        guard let results = request.results else {
            return []
        }

        // Sort by confidence (highest first)
        return results.sorted { $0.confidence > $1.confidence }
    }

    /// Detect faces with landmarks (eyes, nose, mouth)
    func detectFacesWithLandmarks(in image: UIImage) async throws -> [VNFaceObservation] {
        guard let cgImage = image.cgImage else {
            throw FaceValidationError.invalidImage
        }

        let request = VNDetectFaceLandmarksRequest()
        request.revision = VNDetectFaceLandmarksRequestRevision3

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        try handler.perform([request])

        guard let results = request.results else {
            return []
        }

        return results.sorted { $0.confidence > $1.confidence }
    }

    // MARK: - Quality Assessment

    /// Assess the quality of a specific face in an image
    func assessQuality(
        observation: VNFaceObservation,
        in image: UIImage
    ) -> FaceQualityScore {
        return FaceQualityScore(observation: observation, image: image)
    }

    /// Find the best quality face from multiple observations
    func findBestFace(
        in observations: [VNFaceObservation],
        image: UIImage
    ) -> VNFaceObservation? {
        guard !observations.isEmpty else { return nil }

        let scored = observations.map { observation in
            (observation, assessQuality(observation: observation, in: image))
        }

        return scored.max { $0.1.overall < $1.1.overall }?.0
    }

    /// Recommend the best photo from multiple candidates
    func recommendBestPhoto(from candidates: [PhotoCandidate]) -> PhotoCandidate? {
        // Filter to only candidates with faces
        let withFaces = candidates.filter { $0.hasFace }
        guard !withFaces.isEmpty else { return nil }

        // Sort by quality (using Comparable implementation)
        let sorted = withFaces.sorted()

        return sorted.first
    }

    // MARK: - Advanced Image Analysis

    /// Calculate image sharpness using Laplacian variance
    func calculateSharpness(image: UIImage) -> Double {
        guard let cgImage = image.cgImage else { return 0.0 }

        // Convert to grayscale
        guard let grayscale = convertToGrayscale(cgImage: cgImage) else {
            return 0.0
        }

        // Calculate Laplacian variance
        let variance = calculateLaplacianVariance(grayscale: grayscale)
        return variance
    }

    /// Analyze lighting quality in the face region
    func analyzeLighting(
        observation: VNFaceObservation,
        in image: UIImage
    ) -> Double {
        guard let cgImage = image.cgImage else { return 0.5 }

        // Extract face region
        let imageSize = CGSize(
            width: cgImage.width,
            height: cgImage.height
        )

        let boundingBox = observation.boundingBox
        // Vision uses bottom-left origin, convert to top-left
        let rect = CGRect(
            x: boundingBox.origin.x * imageSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
            width: boundingBox.width * imageSize.width,
            height: boundingBox.height * imageSize.height
        )

        guard let faceImage = cgImage.cropping(to: rect) else {
            return 0.5
        }

        // Calculate brightness statistics
        guard let grayscale = convertToGrayscale(cgImage: faceImage) else {
            return 0.5
        }

        let (mean, stdDev) = calculateBrightnessStatistics(grayscale: grayscale)

        // Good lighting: mean in middle range (0.3-0.7), moderate std dev
        let meanScore = 1.0 - abs(mean - 0.5) * 2.0 // Peaks at 0.5
        let contrastScore = min(stdDev * 4.0, 1.0)  // Some contrast is good

        return (meanScore * 0.7 + contrastScore * 0.3)
    }

    // MARK: - Private Helpers

    private func convertToGrayscale(cgImage: CGImage) -> [UInt8]? {
        let width = cgImage.width
        let height = cgImage.height

        var pixelData = [UInt8](repeating: 0, count: width * height)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        return pixelData
    }

    private func calculateLaplacianVariance(grayscale: [UInt8]) -> Double {
        // Simplified Laplacian calculation
        // In production, use vDSP for performance
        guard grayscale.count > 9 else { return 0.0 }

        var variance = 0.0
        let width = Int(sqrt(Double(grayscale.count)))

        for y in 1..<(width - 1) {
            for x in 1..<(width - 1) {
                let idx = y * width + x
                let laplacian = abs(
                    -Int(grayscale[idx - width - 1]) - Int(grayscale[idx - width]) - Int(grayscale[idx - width + 1]) +
                    -Int(grayscale[idx - 1]) + 8 * Int(grayscale[idx]) - Int(grayscale[idx + 1]) +
                    -Int(grayscale[idx + width - 1]) - Int(grayscale[idx + width]) - Int(grayscale[idx + width + 1])
                )
                variance += Double(laplacian * laplacian)
            }
        }

        return variance / Double(grayscale.count)
    }

    private func calculateBrightnessStatistics(grayscale: [UInt8]) -> (mean: Double, stdDev: Double) {
        guard !grayscale.isEmpty else { return (0.0, 0.0) }

        let sum = grayscale.reduce(0) { $0 + Double($1) }
        let mean = sum / Double(grayscale.count) / 255.0 // Normalize to 0-1

        let variance = grayscale.reduce(0.0) { result, pixel in
            let diff = Double(pixel) / 255.0 - mean
            return result + (diff * diff)
        } / Double(grayscale.count)

        let stdDev = sqrt(variance)

        return (mean, stdDev)
    }

    // MARK: - Face Cropping Utilities

    /// Get the recommended crop rect for a face with padding
    func getCropRect(
        for observation: VNFaceObservation,
        in imageSize: CGSize,
        padding: CGFloat = 0.3
    ) -> CGRect {
        let boundingBox = observation.boundingBox

        // Vision uses normalized coordinates with bottom-left origin
        // Add padding around the face
        let paddedBox = boundingBox.insetBy(
            dx: -boundingBox.width * padding,
            dy: -boundingBox.height * padding
        )

        // Clamp to image bounds
        let clampedBox = CGRect(
            x: max(0, paddedBox.origin.x),
            y: max(0, paddedBox.origin.y),
            width: min(1.0 - paddedBox.origin.x, paddedBox.width),
            height: min(1.0 - paddedBox.origin.y, paddedBox.height)
        )

        // Convert to pixel coordinates (still bottom-left origin)
        return CGRect(
            x: clampedBox.origin.x * imageSize.width,
            y: clampedBox.origin.y * imageSize.height,
            width: clampedBox.width * imageSize.width,
            height: clampedBox.height * imageSize.height
        )
    }

    /// Convert Vision coordinate system (bottom-left) to UIKit (top-left)
    func convertVisionRectToUIKit(
        _ visionRect: CGRect,
        imageHeight: CGFloat
    ) -> CGRect {
        return CGRect(
            x: visionRect.origin.x,
            y: imageHeight - visionRect.origin.y - visionRect.height,
            width: visionRect.width,
            height: visionRect.height
        )
    }
}

// MARK: - Errors

enum FaceValidationError: LocalizedError {
    case invalidImage
    case noFacesDetected
    case poorQuality
    case processingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The provided image is invalid or corrupted."
        case .noFacesDetected:
            return "No faces were detected in this image."
        case .poorQuality:
            return "The detected face quality is too low for use."
        case .processingFailed:
            return "Failed to process the image."
        }
    }
}
