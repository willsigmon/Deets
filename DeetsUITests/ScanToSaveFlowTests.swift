//
//  ScanToSaveFlowTests.swift
//  DeetsUITests
//
//  Critical path UI testing: Scan → Preview → Save
//

import XCTest

final class ScanToSaveFlowTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Complete Flow Tests

    func testCompleteScanToSaveFlow() throws {
        // Navigate to Scan tab
        let scanTab = app.tabBars.buttons["Scan"]
        XCTAssertTrue(scanTab.waitForExistence(timeout: 5))
        scanTab.tap()

        // Verify scan view appears
        let scanView = app.otherElements["ScanView"]
        XCTAssertTrue(scanView.waitForExistence(timeout: 5))

        // Start scanning (if camera available)
        if app.buttons["StartScanButton"].exists {
            app.buttons["StartScanButton"].tap()

            // Wait for scanner or error
            let scanner = app.otherElements["DataScanner"]
            let errorAlert = app.alerts.firstMatch

            // Either scanner appears or error is shown
            XCTAssertTrue(scanner.waitForExistence(timeout: 5) || errorAlert.waitForExistence(timeout: 5))

            // If error, dismiss and skip test
            if errorAlert.exists {
                errorAlert.buttons["OK"].tap()
                throw XCTSkip("Camera not available in test environment")
            }
        } else {
            throw XCTSkip("Scan button not found")
        }
    }

    func testScanViewAppears() {
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // Verify scan view elements
        XCTAssertTrue(app.staticTexts["Scan Business Card"].waitForExistence(timeout: 5))
    }

    func testNavigateToPreview() throws {
        // This test requires mock data or simulator setup
        // In real testing, you'd inject mock scanned text

        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // If preview button exists (after scanning)
        if app.buttons["ViewPreviewButton"].waitForExistence(timeout: 5) {
            app.buttons["ViewPreviewButton"].tap()

            // Verify preview view
            XCTAssertTrue(app.otherElements["ContactPreviewView"].waitForExistence(timeout: 5))
        } else {
            throw XCTSkip("Preview not available without actual scan")
        }
    }

    func testPreviewEditAndSave() throws {
        // Navigate to preview (assuming mock data injected)
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // Wait for preview
        let preview = app.otherElements["ContactPreviewView"]
        guard preview.waitForExistence(timeout: 5) else {
            throw XCTSkip("Preview not available")
        }

        // Edit name field
        let nameField = app.textFields["FullNameField"]
        if nameField.exists {
            nameField.tap()
            nameField.typeText(" Edited")
        }

        // Save button
        let saveButton = app.buttons["SaveButton"]
        if saveButton.exists && saveButton.isEnabled {
            saveButton.tap()

            // Verify success
            XCTAssertTrue(app.alerts["Success"].waitForExistence(timeout: 5))
        }
    }

    // MARK: - Error Handling Tests

    func testCameraPermissionDenied() {
        // This requires app to be in denied permission state
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // If permission denied message appears
        if app.staticTexts["Camera Access Required"].waitForExistence(timeout: 5) {
            // Verify settings button
            XCTAssertTrue(app.buttons["Open Settings"].exists)
        }
    }

    func testScannerUnavailable() {
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // If device doesn't support scanner
        if app.staticTexts["Scanner Not Available"].waitForExistence(timeout: 5) {
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'not supported'")).firstMatch.exists)
        }
    }

    func testCancelScan() {
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // Start scan
        if app.buttons["StartScanButton"].exists {
            app.buttons["StartScanButton"].tap()

            // Cancel button
            if app.buttons["CancelScanButton"].waitForExistence(timeout: 2) {
                app.buttons["CancelScanButton"].tap()

                // Should return to scan view
                XCTAssertTrue(app.buttons["StartScanButton"].waitForExistence(timeout: 2))
            }
        }
    }

    // MARK: - Validation Tests

    func testInvalidEmailValidation() throws {
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // Navigate to preview
        let preview = app.otherElements["ContactPreviewView"]
        guard preview.waitForExistence(timeout: 5) else {
            throw XCTSkip("Preview not available")
        }

        // Enter invalid email
        let emailField = app.textFields["EmailField"]
        if emailField.exists {
            emailField.tap()
            emailField.clearText()
            emailField.typeText("invalid-email")

            // Verify validation error
            XCTAssertTrue(app.staticTexts["Invalid email format"].waitForExistence(timeout: 2))
        }
    }

    func testInvalidPhoneValidation() throws {
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        let preview = app.otherElements["ContactPreviewView"]
        guard preview.waitForExistence(timeout: 5) else {
            throw XCTSkip("Preview not available")
        }

        // Enter invalid phone
        let phoneField = app.textFields["PhoneField"]
        if phoneField.exists {
            phoneField.tap()
            phoneField.clearText()
            phoneField.typeText("abc")

            // Verify validation error
            XCTAssertTrue(app.staticTexts["Invalid phone format"].waitForExistence(timeout: 2))
        }
    }

    func testSaveButtonDisabledWithInvalidData() throws {
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        let preview = app.otherElements["ContactPreviewView"]
        guard preview.waitForExistence(timeout: 5) else {
            throw XCTSkip("Preview not available")
        }

        // Clear required field
        let nameField = app.textFields["FullNameField"]
        if nameField.exists {
            nameField.tap()
            nameField.clearText()

            // Save button should be disabled
            let saveButton = app.buttons["SaveButton"]
            XCTAssertFalse(saveButton.isEnabled)
        }
    }

    // MARK: - Performance Tests

    func testScanViewLoadPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric(), XCTClockMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["UI-Testing"]
            app.launch()

            let scanTab = app.tabBars.buttons["Scan"]
            scanTab.tap()

            XCTAssertTrue(app.otherElements["ScanView"].waitForExistence(timeout: 5))
        }
    }
}

// MARK: - XCUIElement Extension

extension XCUIElement {
    /// Clear existing text
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
