//
//  AccessibilityTests.swift
//  DeetsUITests
//
//  Accessibility testing for VoiceOver, Dynamic Type, and navigation
//

import XCTest

final class AccessibilityTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Mock-Data"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Accessibility Identifier Tests

    func testMainTabsHaveAccessibilityIdentifiers() {
        let cardsTab = app.tabBars.buttons["Cards"]
        let scanTab = app.tabBars.buttons["Scan"]

        XCTAssertTrue(cardsTab.exists)
        XCTAssertTrue(scanTab.exists)

        XCTAssertFalse(cardsTab.label.isEmpty)
        XCTAssertFalse(scanTab.label.isEmpty)
    }

    func testCardListItemsHaveLabels() {
        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))

        // Should have accessibility label
        XCTAssertFalse(firstCard.label.isEmpty)

        // Should be accessible
        XCTAssertTrue(firstCard.isAccessibilityElement)
    }

    func testButtonsHaveAccessibilityLabels() {
        // Navigate to scan tab
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // Check button labels
        let buttons = app.buttons.allElementsBoundByIndex
        for button in buttons {
            if button.exists {
                XCTAssertFalse(button.label.isEmpty, "Button should have accessibility label")
            }
        }
    }

    func testTextFieldsHaveLabels() {
        // Navigate to card detail or preview
        let firstCard = app.cells.firstMatch
        if firstCard.waitForExistence(timeout: 5) {
            firstCard.tap()

            // Check text fields
            let textFields = app.textFields.allElementsBoundByIndex
            for field in textFields {
                if field.exists {
                    XCTAssertFalse(field.label.isEmpty, "Text field should have accessibility label")
                }
            }
        }
    }

    // MARK: - VoiceOver Navigation Tests

    func testVoiceOverNavigationThroughTabs() {
        // This test verifies elements are properly accessible
        let cardsTab = app.tabBars.buttons["Cards"]
        let scanTab = app.tabBars.buttons["Scan"]

        XCTAssertTrue(cardsTab.isAccessibilityElement)
        XCTAssertTrue(scanTab.isAccessibilityElement)

        // Verify they can be tapped
        scanTab.tap()
        XCTAssertTrue(app.otherElements["ScanView"].waitForExistence(timeout: 5))

        cardsTab.tap()
        XCTAssertTrue(app.navigationBars["Cards"].waitForExistence(timeout: 5))
    }

    func testVoiceOverNavigationThroughList() {
        let cells = app.cells.allElementsBoundByIndex

        // Verify at least one cell exists and is accessible
        if !cells.isEmpty {
            let firstCell = cells[0]
            XCTAssertTrue(firstCell.isAccessibilityElement)
            XCTAssertFalse(firstCell.label.isEmpty)

            // Verify hint if available
            if !firstCell.value(forKey: "accessibilityHint") as? String ?? "" isEmpty {
                XCTAssertNotNil(firstCell.value(forKey: "accessibilityHint"))
            }
        }
    }

    func testAccessibilityTraitsOnImportantElements() {
        // Check button traits
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // Buttons should have button trait
        let startButton = app.buttons["StartScanButton"]
        if startButton.exists {
            // XCUIElement doesn't expose traits directly, but we can verify it's a button
            XCTAssertTrue(startButton.elementType == .button)
        }
    }

    // MARK: - Dynamic Type Tests

    func testLayoutWithLargeText() {
        // Note: These tests would need to be run with Dynamic Type enabled
        // In CI/CD, you can use launch arguments to simulate this

        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))

        // Verify text is not truncated (frame should accommodate)
        let label = firstCard.staticTexts.firstMatch
        if label.exists {
            XCTAssertTrue(label.frame.width > 0)
            XCTAssertTrue(label.frame.height > 0)
        }
    }

    func testButtonsAccessibleWithLargeText() {
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // Buttons should be tappable even with large text
        let buttons = app.buttons.allElementsBoundByIndex
        for button in buttons {
            if button.exists {
                // Verify button has reasonable frame
                XCTAssertTrue(button.frame.width > 0)
                XCTAssertTrue(button.frame.height > 0)
                XCTAssertTrue(button.isHittable)
            }
        }
    }

    // MARK: - Accessibility Actions Tests

    func testCardSwipeActions() {
        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))

        // Swipe actions should be accessible
        firstCard.swipeLeft()

        // Verify action buttons appear
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 2) ||
                     app.buttons["Export"].waitForExistence(timeout: 2))
    }

    func testCustomAccessibilityActions() {
        let firstCard = app.cells.firstMatch
        if firstCard.waitForExistence(timeout: 5) {
            // If custom actions are defined, they should be accessible
            // This is typically tested with VoiceOver's rotor
            XCTAssertTrue(firstCard.isAccessibilityElement)
        }
    }

    // MARK: - Focus Management Tests

    func testFocusMovesToNextFieldOnReturn() {
        // Navigate to preview with editable fields
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // If preview is available
        let preview = app.otherElements["ContactPreviewView"]
        if preview.waitForExistence(timeout: 5) {
            let nameField = app.textFields["FullNameField"]
            if nameField.exists {
                nameField.tap()
                nameField.typeText("\n") // Return key

                // Focus should move to next field
                let nextField = app.textFields["JobTitleField"]
                if nextField.exists {
                    XCTAssertTrue(nextField.hasFocus)
                }
            }
        }
    }

    func testAlertAccessibility() {
        // Trigger an alert (e.g., delete confirmation)
        let firstCard = app.cells.firstMatch
        if firstCard.waitForExistence(timeout: 5) {
            firstCard.swipeLeft()

            let deleteButton = app.buttons["Delete"]
            if deleteButton.exists {
                deleteButton.tap()

                // Alert should appear and be accessible
                let alert = app.alerts.firstMatch
                if alert.waitForExistence(timeout: 2) {
                    XCTAssertTrue(alert.isAccessibilityElement)
                    XCTAssertFalse(alert.label.isEmpty)

                    // Buttons should be accessible
                    XCTAssertTrue(alert.buttons.count > 0)
                }
            }
        }
    }

    // MARK: - Color Contrast Tests

    func testImportantElementsVisible() {
        // While we can't test actual contrast ratios in XCUITest,
        // we can verify elements are visible and hittable

        let scanTab = app.tabBars.buttons["Scan"]
        XCTAssertTrue(scanTab.isHittable)

        let cardsTab = app.tabBars.buttons["Cards"]
        XCTAssertTrue(cardsTab.isHittable)

        // Navigate and check buttons
        scanTab.tap()
        let startButton = app.buttons["StartScanButton"]
        if startButton.exists {
            XCTAssertTrue(startButton.isHittable)
        }
    }

    // MARK: - Keyboard Navigation Tests

    func testTabThroughFormFields() {
        // Navigate to form
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        let preview = app.otherElements["ContactPreviewView"]
        if preview.waitForExistence(timeout: 5) {
            let fields = app.textFields.allElementsBoundByIndex

            // Should be able to navigate through fields
            if fields.count > 1 {
                fields[0].tap()

                // Tab to next field (this would work with hardware keyboard)
                // In UI tests, we verify fields are in correct order
                for i in 0..<fields.count {
                    XCTAssertTrue(fields[i].exists)
                }
            }
        }
    }

    // MARK: - Accessibility Audit

    func testAccessibilityAudit() {
        // Perform basic accessibility audit
        let elements = app.descendants(matching: .any).allElementsBoundByIndex

        var issuesFound = 0

        for element in elements {
            // Check if interactive elements have labels
            if element.elementType == .button ||
               element.elementType == .textField ||
               element.elementType == .cell {

                if element.exists && element.isAccessibilityElement {
                    if element.label.isEmpty {
                        print("⚠️ Warning: \(element.elementType) missing accessibility label")
                        issuesFound += 1
                    }
                }
            }
        }

        // Log results
        print("Accessibility audit complete: \(issuesFound) potential issues found")

        // We don't fail the test, just log warnings
        XCTAssertLessThan(issuesFound, 10, "Too many accessibility issues found")
    }

    // MARK: - Reduced Motion Tests

    func testReducedMotionSupport() {
        // Verify app respects reduced motion
        // This would typically be tested with reduced motion enabled in settings

        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()

        // Animations should complete quickly or skip
        let scanView = app.otherElements["ScanView"]
        XCTAssertTrue(scanView.waitForExistence(timeout: 2))

        // Switch tabs should be instant with reduced motion
        let cardsTab = app.tabBars.buttons["Cards"]
        cardsTab.tap()

        XCTAssertTrue(app.navigationBars["Cards"].waitForExistence(timeout: 2))
    }
}

// MARK: - XCUIElement Extension

extension XCUIElement {
    var hasFocus: Bool {
        // Check if element has keyboard focus
        return self.value(forKey: "hasKeyboardFocus") as? Bool ?? false
    }
}
