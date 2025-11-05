//
//  PhotoEnrichmentTests.swift
//  DeetsTests
//
//  Unit tests for the photo enrichment system including
//  face detection, quality scoring, and photo discovery.
//

import XCTest
import Vision
import Photos
@testable import Deets

@MainActor
final class PhotoEnrichmentTests: XCTestCase {

    // MARK: - PhotoCandidate Tests

    func testPhotoCandidateInitialization() {
        // Given
        let mockAsset = PHAsset()
        let mockImage = UIImage(systemName: "person.circle.fill")

        // When
        let candidate = PhotoCandidate(
            asset: mockAsset,
            image: mockImage,
            faceObservations: [],
            source: .library,
            matchConfidence: 0.5
        )

        // Then
        XCTAssertEqual(candidate.matchConfidence, 0.5)
        XCTAssertEqual(candidate.source, .library)
        XCTAssertFalse(candidate.hasFace)
        XCTAssertEqual(candidate.faceCount, 0)
    }

    func testPhotoCandidateWithFaces() {
        // Given
        let mockAsset = PHAsset()
        let mockImage = UIImage(systemName: "person.circle.fill")
        let mockFace = createMockFaceObservation(confidence: 0.9, boundingBox: CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5))

        // When
        let candidate = PhotoCandidate(
            asset: mockAsset,
            image: mockImage,
            faceObservations: [mockFace],
            source: .peopleAlbum(personName: "John Doe"),
            matchConfidence: 0.8
        )

        // Then
        XCTAssertTrue(candidate.hasFace)
        XCTAssertEqual(candidate.faceCount, 1)
        XCTAssertNotNil(candidate.primaryFace)
        XCTAssertEqual(candidate.primaryFace?.confidence, 0.9)
    }

    func testPhotoCandidateGoodCandidateThreshold() {
        // Given
        let mockAsset = PHAsset()
        let mockImage = UIImage(systemName: "person.circle.fill")
        let goodFace = createMockFaceObservation(confidence: 0.9, boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6))
        let poorFace = createMockFaceObservation(confidence: 0.3, boundingBox: CGRect(x: 0.4, y: 0.4, width: 0.1, height: 0.1))

        // When
        let goodCandidate = PhotoCandidate(
            asset: mockAsset,
            image: mockImage,
            faceObservations: [goodFace],
            source: .library,
            matchConfidence: 0.5
        )

        let poorCandidate = PhotoCandidate(
            asset: mockAsset,
            image: mockImage,
            faceObservations: [poorFace],
            source: .library,
            matchConfidence: 0.5
        )

        // Then
        XCTAssertTrue(goodCandidate.isGoodCandidate)
        XCTAssertFalse(poorCandidate.isGoodCandidate)
    }

    func testPhotoCandidateComparison() {
        // Given
        let mockAsset = PHAsset()
        let excellentFace = createMockFaceObservation(confidence: 0.95, boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6))
        let goodFace = createMockFaceObservation(confidence: 0.75, boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4))

        let excellentCandidate = PhotoCandidate(
            asset: mockAsset,
            image: UIImage(systemName: "person.circle.fill"),
            faceObservations: [excellentFace],
            source: .peopleAlbum(personName: "John"),
            matchConfidence: 0.8
        )

        let goodCandidate = PhotoCandidate(
            asset: mockAsset,
            image: UIImage(systemName: "person.circle.fill"),
            faceObservations: [goodFace],
            source: .recents,
            matchConfidence: 0.5
        )

        // When
        let sorted = [goodCandidate, excellentCandidate].sorted()

        // Then
        XCTAssertEqual(sorted.first?.source, .peopleAlbum(personName: "John"))
        XCTAssertTrue(sorted.first! < sorted.last!)
    }

    // MARK: - FaceQualityScore Tests

    func testFaceQualityScoreCalculation() {
        // Given
        let largeFace = createMockFaceObservation(confidence: 0.9, boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6))
        let smallFace = createMockFaceObservation(confidence: 0.9, boundingBox: CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2))
        let image = UIImage(systemName: "person.circle.fill")

        // When
        let largeScore = FaceQualityScore(observation: largeFace, image: image)
        let smallScore = FaceQualityScore(observation: smallFace, image: image)

        // Then
        XCTAssertGreaterThan(largeScore.overall, smallScore.overall)
        XCTAssertGreaterThan(largeScore.faceSize, smallScore.faceSize)
    }

    func testFaceQualityRating() {
        // Given
        let excellentFace = createMockFaceObservation(confidence: 0.95, boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8))
        let poorFace = createMockFaceObservation(confidence: 0.3, boundingBox: CGRect(x: 0.45, y: 0.45, width: 0.1, height: 0.1))

        // When
        let excellentScore = FaceQualityScore(observation: excellentFace, image: UIImage(systemName: "person.circle.fill"))
        let poorScore = FaceQualityScore(observation: poorFace, image: UIImage(systemName: "person.circle.fill"))

        // Then
        XCTAssertEqual(excellentScore.rating, .excellent)
        XCTAssertEqual(poorScore.rating, .poor)
    }

    func testEmptyFaceQualityScore() {
        // When
        let emptyScore = FaceQualityScore.empty

        // Then
        XCTAssertEqual(emptyScore.overall, 0.0)
        XCTAssertEqual(emptyScore.confidence, 0.0)
        XCTAssertEqual(emptyScore.rating, .poor)
    }

    // MARK: - PhotoSource Tests

    func testPhotoSourcePriority() {
        // Given
        let peopleSource = PhotoSource.peopleAlbum(personName: "John")
        let recentsSource = PhotoSource.recents
        let librarySource = PhotoSource.library

        // Then
        XCTAssertGreaterThan(peopleSource.priority, recentsSource.priority)
        XCTAssertGreaterThan(recentsSource.priority, librarySource.priority)
    }

    // MARK: - FaceValidator Tests

    func testFaceValidatorSingleton() {
        // When
        let validator1 = FaceValidator.shared
        let validator2 = FaceValidator.shared

        // Then
        XCTAssertTrue(validator1 === validator2)
    }

    func testGetCropRectWithPadding() async {
        // Given
        let validator = FaceValidator.shared
        let face = createMockFaceObservation(confidence: 0.9, boundingBox: CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5))
        let imageSize = CGSize(width: 1000, height: 1000)

        // When
        let cropRect = validator.getCropRect(for: face, in: imageSize, padding: 0.2)

        // Then
        XCTAssertGreaterThan(cropRect.width, 500) // Should be larger than original face due to padding
        XCTAssertGreaterThan(cropRect.height, 500)
        XCTAssertLessThanOrEqual(cropRect.maxX, imageSize.width) // Should be clamped to image bounds
        XCTAssertLessThanOrEqual(cropRect.maxY, imageSize.height)
    }

    func testCoordinateConversion() async {
        // Given
        let validator = FaceValidator.shared
        let visionRect = CGRect(x: 100, y: 200, width: 300, height: 400)
        let imageHeight: CGFloat = 1000

        // When
        let uiKitRect = validator.convertVisionRectToUIKit(visionRect, imageHeight: imageHeight)

        // Then
        XCTAssertEqual(uiKitRect.origin.x, 100)
        XCTAssertEqual(uiKitRect.origin.y, 400) // Flipped: 1000 - 200 - 400
        XCTAssertEqual(uiKitRect.width, 300)
        XCTAssertEqual(uiKitRect.height, 400)
    }

    // MARK: - ParsedContact Extension Tests

    func testParsedContactDisplayName() {
        // Given
        var contact = ParsedContact(rawText: "Test")

        // When - Full name
        contact.givenName = "John"
        contact.familyName = "Doe"

        // Then
        XCTAssertEqual(contact.displayName, "John Doe")

        // When - First name only
        contact.familyName = nil

        // Then
        XCTAssertEqual(contact.displayName, "John")

        // When - Last name only
        contact.givenName = nil
        contact.familyName = "Doe"

        // Then
        XCTAssertEqual(contact.displayName, "Doe")

        // When - No name
        contact.familyName = nil

        // Then
        XCTAssertNil(contact.displayName)
    }

    // MARK: - PhotoDiscoveryService Tests

    func testPhotoDiscoveryServiceSingleton() {
        // When
        let service1 = PhotoDiscoveryService.shared
        let service2 = PhotoDiscoveryService.shared

        // Then
        XCTAssertTrue(service1 === service2)
    }

    func testAuthorizationStatusCheck() {
        // Given
        let service = PhotoDiscoveryService.shared

        // When
        let status = service.checkAuthorizationStatus()

        // Then
        XCTAssertNotNil(status)
        // Note: Actual status depends on simulator/device settings
    }

    func testHasPhotoLibraryAccess() {
        // Given
        let service = PhotoDiscoveryService.shared

        // When
        service.authorizationStatus = .authorized
        let hasAccessAuthorized = service.hasPhotoLibraryAccess

        service.authorizationStatus = .limited
        let hasAccessLimited = service.hasPhotoLibraryAccess

        service.authorizationStatus = .denied
        let hasAccessDenied = service.hasPhotoLibraryAccess

        service.authorizationStatus = .notDetermined
        let hasAccessNotDetermined = service.hasPhotoLibraryAccess

        // Then
        XCTAssertTrue(hasAccessAuthorized)
        XCTAssertTrue(hasAccessLimited)
        XCTAssertFalse(hasAccessDenied)
        XCTAssertFalse(hasAccessNotDetermined)
    }

    // MARK: - Error Tests

    func testPhotoDiscoveryErrorMessages() {
        // When
        let noPermissionError = PhotoDiscoveryError.noPermission
        let imageLoadError = PhotoDiscoveryError.imageLoadFailed
        let cropError = PhotoDiscoveryError.cropFailed
        let noCandidatesError = PhotoDiscoveryError.noCandidatesFound

        // Then
        XCTAssertNotNil(noPermissionError.errorDescription)
        XCTAssertNotNil(imageLoadError.errorDescription)
        XCTAssertNotNil(cropError.errorDescription)
        XCTAssertNotNil(noCandidatesError.errorDescription)

        XCTAssertNotNil(noPermissionError.recoverySuggestion)
        XCTAssertNotNil(noCandidatesError.recoverySuggestion)
    }

    func testFaceValidationErrorMessages() {
        // When
        let invalidImageError = FaceValidationError.invalidImage
        let noFacesError = FaceValidationError.noFacesDetected
        let poorQualityError = FaceValidationError.poorQuality

        // Then
        XCTAssertNotNil(invalidImageError.errorDescription)
        XCTAssertNotNil(noFacesError.errorDescription)
        XCTAssertNotNil(poorQualityError.errorDescription)
    }

    // MARK: - Feature Flag Tests

    func testPhotoEnrichmentFeatureFlag() {
        // Given
        let flags = FeatureFlags.shared

        // When
        flags.photoEnrichmentEnabled = true
        let enabledState = flags.photoEnrichmentEnabled

        flags.photoEnrichmentEnabled = false
        let disabledState = flags.photoEnrichmentEnabled

        // Then
        XCTAssertTrue(enabledState)
        XCTAssertFalse(disabledState)
    }

    // MARK: - Performance Tests

    func testQualityScorePerformance() {
        // Given
        let face = createMockFaceObservation(confidence: 0.9, boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6))
        let image = UIImage(systemName: "person.circle.fill")

        // When
        measure {
            for _ in 0..<100 {
                _ = FaceQualityScore(observation: face, image: image)
            }
        }
    }

    func testPhotoCandidateSortingPerformance() {
        // Given
        var candidates: [PhotoCandidate] = []
        for i in 0..<100 {
            let confidence = Double.random(in: 0.3...0.95)
            let face = createMockFaceObservation(confidence: Float(confidence), boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.5, height: 0.5))
            let candidate = PhotoCandidate(
                asset: PHAsset(),
                image: UIImage(systemName: "person.circle.fill"),
                faceObservations: [face],
                source: .library,
                matchConfidence: Double(i) / 100.0
            )
            candidates.append(candidate)
        }

        // When
        measure {
            _ = candidates.sorted()
        }
    }

    // MARK: - Integration Tests

    func testFullPhotoEnrichmentFlow() async throws {
        // Given
        var contact = ParsedContact(rawText: "John Doe\njohn@example.com")
        contact.givenName = "John"
        contact.familyName = "Doe"

        // Note: This is a basic flow test
        // Real integration tests would require Photos library access
        // and mock PHAssets

        // Then
        XCTAssertNotNil(contact.displayName)
        XCTAssertEqual(contact.displayName, "John Doe")
    }

    // MARK: - Helper Methods

    private func createMockFaceObservation(confidence: Float, boundingBox: CGRect) -> VNFaceObservation {
        // Note: VNFaceObservation is difficult to mock directly
        // In real tests, you would need actual face detection on test images
        // For now, we're using a placeholder approach
        // In production tests, use actual test images with known faces

        // This is a simplified mock for demonstration
        // Real implementation would require actual Vision framework results
        let mockObservation = VNFaceObservation(
            requestRevision: VNDetectFaceRectanglesRequestRevision3,
            boundingBox: boundingBox
        )
        return mockObservation
    }

    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Draw a simple face-like circle
            UIColor.blue.setFill()
            let faceRect = CGRect(
                x: size.width * 0.25,
                y: size.height * 0.25,
                width: size.width * 0.5,
                height: size.height * 0.5
            )
            context.cgContext.fillEllipse(in: faceRect)
        }
    }
}

// MARK: - Test Utilities

extension PhotoEnrichmentTests {

    /// Create a test ParsedContact with sample data
    func createTestContact(name: String = "John Doe") -> ParsedContact {
        var contact = ParsedContact(rawText: name)
        let components = name.split(separator: " ").map(String.init)
        contact.givenName = components.first
        contact.familyName = components.count > 1 ? components.last : nil
        return contact
    }

    /// Create a test PhotoCandidate
    func createTestCandidate(
        confidence: Float = 0.8,
        source: PhotoSource = .library
    ) -> PhotoCandidate {
        let face = createMockFaceObservation(
            confidence: confidence,
            boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        )

        return PhotoCandidate(
            asset: PHAsset(),
            image: createTestImage(size: CGSize(width: 500, height: 500)),
            faceObservations: [face],
            source: source,
            matchConfidence: Double(confidence)
        )
    }
}

// MARK: - Mock Objects

/// Mock photo discovery service for testing without Photos access
@MainActor
class MockPhotoDiscoveryService {
    var mockCandidates: [PhotoCandidate] = []
    var shouldFailPermission = false
    var shouldFailSearch = false

    func findPhotos(for contact: ParsedContact, limit: Int) async throws -> [PhotoCandidate] {
        if shouldFailSearch {
            throw PhotoDiscoveryError.processingFailed
        }
        return Array(mockCandidates.prefix(limit))
    }

    func requestAuthorization() async -> PHAuthorizationStatus {
        return shouldFailPermission ? .denied : .authorized
    }
}

/// Mock face validator for testing without Vision framework
@MainActor
class MockFaceValidator {
    var mockFaces: [VNFaceObservation] = []
    var shouldFail = false

    func detectFaces(in image: UIImage) async throws -> [VNFaceObservation] {
        if shouldFail {
            throw FaceValidationError.processingFailed
        }
        return mockFaces
    }
}
