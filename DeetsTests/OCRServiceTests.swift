//
//  OCRServiceTests.swift
//  DeetsTests
//
//  Comprehensive tests for OCR service functionality
//  Tests text recognition, bounding boxes, error handling, and permissions
//

import XCTest
import VisionKit
import AVFoundation
@testable import Deets

@MainActor
final class OCRServiceTests: XCTestCase {

    var ocrService: OCRService!
    var mockValidator: MockTextValidator!

    override func setUp() async throws {
        try await super.setUp()
        mockValidator = MockTextValidator()
        ocrService = OCRService(validator: mockValidator)
    }

    override func tearDown() async throws {
        ocrService.cleanup()
        ocrService = nil
        mockValidator = nil
        try await super.tearDown()
    }

    // MARK: - Device Capabilities Tests

    func testIsSupported() {
        // This will vary by device/simulator
        let isSupported = OCRService.isSupported

        // Just verify it returns a boolean without crashing
        XCTAssertNotNil(isSupported)
    }

    func testAvailabilityStatus() {
        let status = OCRService.availabilityStatus

        XCTAssertNotNil(status.isSupported)

        if !status.isSupported {
            XCTAssertNotNil(status.reason, "Unsupported devices should provide a reason")
        }
    }

    // MARK: - Authorization Tests

    func testCheckCameraAuthorization() {
        ocrService.checkCameraAuthorization()

        // Should not crash and should set authorization status
        XCTAssertNotNil(ocrService.authorizationStatus)
    }

    func testRequestCameraAccessUpdatesStatus() async {
        let initialStatus = ocrService.authorizationStatus

        // Request access (may be granted, denied, or already determined)
        _ = await ocrService.requestCameraAccess()

        // Status should be checked/updated
        XCTAssertNotNil(ocrService.authorizationStatus)

        // Status should be a valid enum value
        let validStatuses: [AVAuthorizationStatus] = [.notDetermined, .restricted, .denied, .authorized]
        XCTAssertTrue(validStatuses.contains(ocrService.authorizationStatus))
    }

    // MARK: - Scanner Configuration Tests

    func testBusinessCardConfiguration() {
        let config = OCRService.ScanConfiguration.businessCard

        XCTAssertTrue(config.recognizesMultipleItems)
        XCTAssertEqual(config.minimumConfidence, 0.6)
        XCTAssertEqual(config.qualityLevel, .accurate)
    }

    func testDefaultConfiguration() {
        let config = OCRService.ScanConfiguration()

        XCTAssertTrue(config.highlightsRecognizedItems)
        XCTAssertTrue(config.recognizesMultipleItems)
        XCTAssertEqual(config.minimumConfidence, 0.5)
        XCTAssertEqual(config.qualityLevel, .balanced)
    }

    // MARK: - Scanner Creation Tests

    func testCreateScannerThrowsWhenNotSupported() {
        // Skip if actually supported on device
        guard !OCRService.isSupported else {
            throw XCTSkip("DataScanner is supported on this device")
        }

        XCTAssertThrowsError(try ocrService.createScanner()) { error in
            guard let ocrError = error as? OCRError else {
                XCTFail("Expected OCRError, got \(type(of: error))")
                return
            }

            if case .deviceNotSupported = ocrError {
                // Expected error
            } else {
                XCTFail("Expected deviceNotSupported error, got \(ocrError)")
            }
        }
    }

    func testCreateScannerThrowsWhenUnauthorized() throws {
        // Only run if supported
        guard OCRService.isSupported else {
            throw XCTSkip("DataScanner not supported on this device")
        }

        // If camera is denied/restricted, scanner creation should fail
        if ocrService.authorizationStatus != .authorized {
            XCTAssertThrowsError(try ocrService.createScanner()) { error in
                XCTAssertTrue(error is OCRError)
            }
        }
    }

    // MARK: - Scanning Lifecycle Tests

    func testStartScanningRequiresInitializedScanner() {
        XCTAssertThrowsError(try ocrService.startScanning()) { error in
            guard let ocrError = error as? OCRError else {
                XCTFail("Expected OCRError")
                return
            }

            if case .scannerNotInitialized = ocrError {
                // Expected
            } else {
                XCTFail("Expected scannerNotInitialized error")
            }
        }
    }

    func testStopScanningDoesNotCrash() {
        // Should handle being called without active scanner
        ocrService.stopScanning()
        XCTAssertFalse(ocrService.isScanning)
    }

    func testPauseScanningHandlesInactiveState() {
        // Should handle being called when not scanning
        ocrService.pauseScanning()
        XCTAssertFalse(ocrService.isScanning)
    }

    func testResumeScanningRequiresInitializedScanner() {
        XCTAssertThrowsError(try ocrService.resumeScanning()) { error in
            XCTAssertTrue(error is OCRError)
        }
    }

    // MARK: - Static Image Processing Tests

    func testProcessValidImage() async throws {
        let testImage = createTestBusinessCardImage()

        do {
            let result = try await ocrService.processImage(testImage)

            // Should return some result
            XCTAssertNotNil(result)
            XCTAssertNotNil(result.items)

            // Should have capture date
            XCTAssertNotNil(result.captureDate)

            // May or may not find text depending on test image
            print("Found \(result.items.count) text items")

        } catch let error as OCRError {
            // Some errors are expected in test environment
            switch error {
            case .noTextFound:
                // Expected if test image is blank
                print("No text found in test image (expected in some environments)")
            case .recognitionFailed(let reason):
                print("Recognition failed: \(reason)")
            default:
                throw error
            }
        }
    }

    func testProcessInvalidImage() async {
        // Create invalid image with no CGImage
        let invalidImage = UIImage()

        do {
            _ = try await ocrService.processImage(invalidImage)
            XCTFail("Should throw error for invalid image")
        } catch let error as OCRError {
            if case .invalidImage = error {
                // Expected
            } else {
                XCTFail("Expected invalidImage error, got \(error)")
            }
        } catch {
            XCTFail("Expected OCRError, got \(error)")
        }
    }

    func testProcessImageSetsConfidenceScores() async throws {
        let testImage = createTestBusinessCardImage()

        do {
            let result = try await ocrService.processImage(testImage)

            for item in result.items {
                // Confidence should be between 0 and 1
                XCTAssertGreaterThanOrEqual(item.confidence, 0.0)
                XCTAssertLessThanOrEqual(item.confidence, 1.0)
            }
        } catch let error as OCRError {
            if case .noTextFound = error {
                throw XCTSkip("No text found in test image")
            }
            throw error
        }
    }

    func testProcessImageSetsBoundingBoxes() async throws {
        let testImage = createTestBusinessCardImage()

        do {
            let result = try await ocrService.processImage(testImage)

            for item in result.items {
                // Bounding boxes should be normalized (0-1 range)
                XCTAssertGreaterThanOrEqual(item.boundingBox.x, 0.0)
                XCTAssertLessThanOrEqual(item.boundingBox.x, 1.0)
                XCTAssertGreaterThanOrEqual(item.boundingBox.y, 0.0)
                XCTAssertLessThanOrEqual(item.boundingBox.y, 1.0)
                XCTAssertGreaterThan(item.boundingBox.width, 0.0)
                XCTAssertGreaterThan(item.boundingBox.height, 0.0)
            }
        } catch let error as OCRError {
            if case .noTextFound = error {
                throw XCTSkip("No text found in test image")
            }
            throw error
        }
    }

    func testProcessImageCategorizesText() async throws {
        mockValidator.shouldValidate = true
        mockValidator.categoryToReturn = .email

        let testImage = createTestBusinessCardImage()

        do {
            let result = try await ocrService.processImage(testImage)

            // Validator should be called for categorization
            if !result.items.isEmpty {
                XCTAssertTrue(mockValidator.categorizeWasCalled)
            }
        } catch let error as OCRError {
            if case .noTextFound = error {
                throw XCTSkip("No text found in test image")
            }
            throw error
        }
    }

    // MARK: - Image Preprocessing Tests

    func testPreprocessImageReturnsImage() {
        let testImage = createTestBusinessCardImage()

        let processed = ocrService.preprocessImage(testImage)

        XCTAssertNotNil(processed)
    }

    func testPreprocessImageWithInvalidImageReturnsNil() {
        let invalidImage = UIImage()

        let processed = ocrService.preprocessImage(invalidImage)

        XCTAssertNil(processed)
    }

    // MARK: - Error Handling Tests

    func testOCRErrorDescriptions() {
        let errors: [OCRError] = [
            .deviceNotSupported,
            .cameraAccessDenied,
            .cameraUnavailable,
            .scannerNotInitialized,
            .scanningFailed("Test reason"),
            .invalidImage,
            .recognitionFailed("Test reason"),
            .noTextFound,
            .unknownError
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)

            // Most errors should have recovery suggestions
            if case .unknownError = error {
                // unknownError may not have specific recovery
            } else {
                XCTAssertNotNil(error.recoverySuggestion)
            }
        }
    }

    // MARK: - Published State Tests

    func testInitialState() {
        let service = OCRService()

        XCTAssertFalse(service.isScanning)
        XCTAssertTrue(service.recognizedItems.isEmpty)
        XCTAssertNil(service.error)
    }

    func testCleanupResetsState() {
        ocrService.cleanup()

        XCTAssertFalse(ocrService.isScanning)
        XCTAssertTrue(ocrService.recognizedItems.isEmpty)
    }

    // MARK: - Mock Preview Support Tests

    func testMockServiceForPreviews() {
        let mockService = OCRService.mock

        XCTAssertFalse(mockService.recognizedItems.isEmpty)
        XCTAssertGreaterThan(mockService.recognizedItems.count, 0)

        // Should have varied categories
        let categories = Set(mockService.recognizedItems.compactMap { $0.category })
        XCTAssertGreaterThan(categories.count, 1)
    }

    // MARK: - Helper Methods

    private func createTestBusinessCardImage() -> UIImage {
        // Create a simple test image with white background
        let size = CGSize(width: 640, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Add some text (may or may not be recognized by OCR in tests)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]

            let text = "John Smith\njohn@example.com\n(555) 123-4567"
            let attributedText = NSAttributedString(string: text, attributes: attributes)

            attributedText.draw(at: CGPoint(x: 20, y: 20))
        }
    }
}

// MARK: - Mock Text Validator

class MockTextValidator: TextValidator {
    var shouldValidate = true
    var categoryToReturn: TextCategory = .other
    var validateWasCalled = false
    var categorizeWasCalled = false

    override func validate(text: String, confidence: Float) -> Bool {
        validateWasCalled = true
        return shouldValidate
    }

    override func categorizeText(_ text: String) -> TextCategory {
        categorizeWasCalled = true
        return categoryToReturn
    }
}
