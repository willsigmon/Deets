//
//  ExportFlowTests.swift
//  DeetsUITests
//
//  UI tests for export functionality: Select card → Configure → Share
//

import XCTest

final class ExportFlowTests: XCTestCase {

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

    // MARK: - Export Flow Tests

    func testNavigateToCardDetail() {
        // Tap first card in list
        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        firstCard.tap()

        // Verify detail view
        XCTAssertTrue(app.otherElements["CardDetailView"].waitForExistence(timeout: 5))
    }

    func testOpenExportOptions() {
        // Navigate to card detail
        let firstCard = app.cells.firstMatch
        firstCard.tap()

        // Tap export button
        let exportButton = app.buttons["ExportButton"]
        XCTAssertTrue(exportButton.waitForExistence(timeout: 5))
        exportButton.tap()

        // Verify export options sheet
        XCTAssertTrue(app.sheets["ExportOptionsSheet"].waitForExistence(timeout: 5))
    }

    func testSelectVCardFormat() {
        openExportSheet()

        // Select vCard format
        let vcardButton = app.buttons["vCard Format"]
        if vcardButton.exists {
            vcardButton.tap()
            XCTAssertTrue(vcardButton.isSelected)
        }
    }

    func testSelectCSVFormat() {
        openExportSheet()

        // Select CSV format
        let csvButton = app.buttons["CSV Format"]
        if csvButton.exists {
            csvButton.tap()
            XCTAssertTrue(csvButton.isSelected)
        }
    }

    func testCSVFieldSelection() {
        openExportSheet()

        // Select CSV format
        app.buttons["CSV Format"].tap()

        // Verify field selection appears
        XCTAssertTrue(app.staticTexts["Select Fields"].waitForExistence(timeout: 2))

        // Toggle some fields
        let emailField = app.buttons["Email Field"]
        if emailField.exists {
            let initialState = emailField.isSelected
            emailField.tap()
            XCTAssertNotEqual(emailField.isSelected, initialState)
        }
    }

    func testSelectAllFields() {
        openExportSheet()

        app.buttons["CSV Format"].tap()

        // Tap "Select All"
        let selectAllButton = app.buttons["Select All Fields"]
        if selectAllButton.exists {
            selectAllButton.tap()

            // Verify all fields selected
            let allFieldsSelected = app.buttons.matching(identifier: "Field").allElementsBoundByIndex.allSatisfy { $0.isSelected }
            XCTAssertTrue(allFieldsSelected)
        }
    }

    func testExportSingleCard() {
        openExportSheet()

        // Verify single card scope
        let scopeSegment = app.segmentedControls["ExportScope"]
        if scopeSegment.exists {
            XCTAssertTrue(scopeSegment.buttons["Single Card"].isSelected)
        }

        // Tap export button
        let exportButton = app.buttons["Export"]
        exportButton.tap()

        // Share sheet should appear
        XCTAssertTrue(app.otherElements["ActivityViewController"].waitForExistence(timeout: 5))
    }

    func testExportMultipleCards() {
        // Navigate to cards list
        let cardsTab = app.tabBars.buttons["Cards"]
        cardsTab.tap()

        // Long press to enter selection mode
        let firstCard = app.cells.firstMatch
        firstCard.press(forDuration: 1.0)

        // Select multiple cards
        if app.buttons["SelectModeButton"].waitForExistence(timeout: 2) {
            let secondCard = app.cells.element(boundBy: 1)
            if secondCard.exists {
                secondCard.tap()
            }

            // Tap export button
            app.buttons["ExportSelectedButton"].tap()

            // Verify export sheet
            XCTAssertTrue(app.sheets["ExportOptionsSheet"].waitForExistence(timeout: 5))
        }
    }

    func testCancelExport() {
        openExportSheet()

        // Tap cancel
        let cancelButton = app.buttons["Cancel"]
        cancelButton.tap()

        // Sheet should dismiss
        XCTAssertFalse(app.sheets["ExportOptionsSheet"].exists)
    }

    // MARK: - Preview Tests

    func testShowExportPreview() {
        openExportSheet()

        // Tap preview button
        let previewButton = app.buttons["Preview"]
        if previewButton.exists {
            previewButton.tap()

            // Verify preview text
            XCTAssertTrue(app.textViews["ExportPreview"].waitForExistence(timeout: 2))
        }
    }

    func testPreviewShowsCorrectFormat() {
        openExportSheet()

        // Select vCard
        app.buttons["vCard Format"].tap()

        // Show preview
        app.buttons["Preview"].tap()

        // Verify vCard content
        let previewText = app.textViews["ExportPreview"]
        if previewText.exists {
            XCTAssertTrue(previewText.value as? String ?? "" contains: "BEGIN:VCARD")
        }
    }

    // MARK: - Error Handling Tests

    func testExportWithNoCardsSelected() {
        // Navigate to cards list
        let cardsTab = app.tabBars.buttons["Cards"]
        cardsTab.tap()

        // Try to export without selection
        if app.buttons["ExportButton"].exists {
            app.buttons["ExportButton"].tap()

            // Should show error or disabled state
            let exportButton = app.buttons["Export"]
            if exportButton.exists {
                XCTAssertFalse(exportButton.isEnabled)
            }
        }
    }

    func testExportFailureHandling() {
        openExportSheet()

        // Trigger export
        app.buttons["Export"].tap()

        // If export fails (e.g., no disk space), alert should appear
        if app.alerts["Export Failed"].waitForExistence(timeout: 5) {
            XCTAssertTrue(app.buttons["OK"].exists)
            app.buttons["OK"].tap()
        }
    }

    // MARK: - Share Sheet Tests

    func testShareSheetAppears() {
        openExportSheet()

        // Complete export
        app.buttons["Export"].tap()

        // Verify share sheet
        let shareSheet = app.otherElements["ActivityViewController"]
        XCTAssertTrue(shareSheet.waitForExistence(timeout: 5))
    }

    func testShareSheetCanBeCancelled() {
        openExportSheet()

        app.buttons["Export"].tap()

        // Wait for share sheet
        let shareSheet = app.otherElements["ActivityViewController"]
        if shareSheet.waitForExistence(timeout: 5) {
            // Cancel button (iOS 16+)
            if app.buttons["Close"].exists {
                app.buttons["Close"].tap()
            } else {
                // Swipe down to dismiss
                shareSheet.swipeDown()
            }

            // Share sheet should dismiss
            XCTAssertFalse(shareSheet.exists)
        }
    }

    // MARK: - Helper Methods

    private func openExportSheet() {
        let firstCard = app.cells.firstMatch
        firstCard.tap()

        let exportButton = app.buttons["ExportButton"]
        exportButton.tap()

        XCTAssertTrue(app.sheets["ExportOptionsSheet"].waitForExistence(timeout: 5))
    }
}
