//
//  ViewModelTests.swift
//  DeetsTests
//
//  Comprehensive tests for all ViewModels
//  Tests state transitions, validation logic, and business logic
//

import XCTest
import SwiftData
@testable import Deets

// MARK: - ScanViewModel Tests

@MainActor
final class ScanViewModelTests: XCTestCase {

    var viewModel: ScanViewModel!

    override func setUp() async throws {
        try await super.setUp()
        viewModel = ScanViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(viewModel.isScanning)
        XCTAssertNil(viewModel.scannedText)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showContactPreview)
    }

    func testScannerAvailability() {
        // Test doesn't crash when checking availability
        let isAvailable = viewModel.isScannerAvailable
        XCTAssertNotNil(isAvailable)
    }

    func testStartScanning() {
        viewModel.startScanning()

        // If scanner is available, should set isScanning
        if viewModel.isScannerAvailable {
            XCTAssertTrue(viewModel.isScanning)
            XCTAssertNil(viewModel.errorMessage)
        } else {
            // Should set error message
            XCTAssertNotNil(viewModel.errorMessage)
        }
    }

    func testHandleScannedText() {
        let testText = "John Doe\njohn@example.com\n555-1234"

        viewModel.handleScannedText(testText)

        XCTAssertEqual(viewModel.scannedText, testText)
        XCTAssertFalse(viewModel.isScanning)
        XCTAssertTrue(viewModel.showContactPreview)
    }

    func testHandleEmptyScannedText() {
        let previousText = viewModel.scannedText
        viewModel.handleScannedText("")

        // Should not change state for empty text
        XCTAssertEqual(viewModel.scannedText, previousText)
    }

    func testHandleScanError() {
        let testError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        viewModel.handleScanError(testError)

        XCTAssertEqual(viewModel.errorMessage, "Test error")
        XCTAssertFalse(viewModel.isScanning)
    }

    func testCancelScanning() {
        viewModel.scannedText = "Test"
        viewModel.isScanning = true
        viewModel.errorMessage = "Error"

        viewModel.cancelScanning()

        XCTAssertFalse(viewModel.isScanning)
        XCTAssertNil(viewModel.scannedText)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testResetAfterSave() {
        viewModel.scannedText = "Test"
        viewModel.showContactPreview = true
        viewModel.errorMessage = "Error"

        viewModel.resetAfterSave()

        XCTAssertNil(viewModel.scannedText)
        XCTAssertFalse(viewModel.showContactPreview)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testRetryScan() {
        viewModel.errorMessage = "Previous error"

        viewModel.retryScan()

        XCTAssertNil(viewModel.errorMessage)
        if viewModel.isScannerAvailable {
            XCTAssertTrue(viewModel.isScanning)
        }
    }
}

// MARK: - ContactPreviewViewModel Tests

@MainActor
final class ContactPreviewViewModelTests: XCTestCase {

    var viewModel: ContactPreviewViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory container
        let schema = Schema([BusinessCard.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext

        let testText = """
        John Smith
        Senior Engineer
        Acme Corp
        john.smith@acme.com
        (555) 123-4567
        https://acme.com
        """

        viewModel = ContactPreviewViewModel(scannedText: testText)
        viewModel.setModelContext(modelContext)
    }

    override func tearDown() async throws {
        viewModel = nil
        modelContext = nil
        modelContainer = nil
        try await super.tearDown()
    }

    func testInitialParsing() {
        XCTAssertEqual(viewModel.fullName, "John Smith")
        XCTAssertEqual(viewModel.jobTitle, "Senior Engineer")
        XCTAssertEqual(viewModel.company, "Acme Corp")
        XCTAssertEqual(viewModel.email, "john.smith@acme.com")
        XCTAssertEqual(viewModel.phoneNumber, "(555) 123-4567")
        XCTAssertEqual(viewModel.website, "https://acme.com")
    }

    func testEmailValidation() {
        viewModel.email = "valid@example.com"
        viewModel.validateEmail()
        XCTAssertTrue(viewModel.isValidEmail)

        viewModel.email = "invalid-email"
        viewModel.validateEmail()
        XCTAssertFalse(viewModel.isValidEmail)

        viewModel.email = ""
        viewModel.validateEmail()
        XCTAssertTrue(viewModel.isValidEmail) // Empty is valid
    }

    func testPhoneValidation() {
        viewModel.phoneNumber = "555-123-4567"
        viewModel.validatePhone()
        XCTAssertTrue(viewModel.isValidPhone)

        viewModel.phoneNumber = "+1 (555) 123-4567"
        viewModel.validatePhone()
        XCTAssertTrue(viewModel.isValidPhone)

        viewModel.phoneNumber = "abc"
        viewModel.validatePhone()
        XCTAssertFalse(viewModel.isValidPhone)

        viewModel.phoneNumber = ""
        viewModel.validatePhone()
        XCTAssertTrue(viewModel.isValidPhone) // Empty is valid
    }

    func testWebsiteValidation() {
        viewModel.website = "https://example.com"
        viewModel.validateWebsite()
        XCTAssertTrue(viewModel.isValidWebsite)

        viewModel.website = "http://example.com"
        viewModel.validateWebsite()
        XCTAssertTrue(viewModel.isValidWebsite)

        viewModel.website = "invalid-url"
        viewModel.validateWebsite()
        XCTAssertFalse(viewModel.isValidWebsite)

        viewModel.website = ""
        viewModel.validateWebsite()
        XCTAssertTrue(viewModel.isValidWebsite) // Empty is valid
    }

    func testCanSave() {
        XCTAssertTrue(viewModel.canSave)

        viewModel.fullName = ""
        XCTAssertFalse(viewModel.canSave)

        viewModel.fullName = "John"
        viewModel.email = "invalid"
        viewModel.validateEmail()
        XCTAssertFalse(viewModel.canSave)
    }

    func testHasChanges() {
        XCTAssertTrue(viewModel.hasChanges)

        let emptyViewModel = ContactPreviewViewModel(scannedText: "")
        XCTAssertFalse(emptyViewModel.hasChanges)
    }

    func testSaveToDatabase() async throws {
        try await viewModel.saveToDatabase()

        // Verify card was saved
        let descriptor = FetchDescriptor<BusinessCard>()
        let cards = try modelContext.fetch(descriptor)

        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.fullName, "John Smith")
        XCTAssertEqual(cards.first?.email, "john.smith@acme.com")
        XCTAssertTrue(viewModel.showSuccessAlert)
    }

    func testSaveToDatabaseWithoutContext() async {
        let noContextViewModel = ContactPreviewViewModel(scannedText: "Test")
        noContextViewModel.fullName = "Test"

        do {
            try await noContextViewModel.saveToDatabase()
            XCTFail("Should throw error without context")
        } catch let error as SaveError {
            if case .noContext = error {
                // Expected
            } else {
                XCTFail("Expected noContext error")
            }
        } catch {
            XCTFail("Expected SaveError")
        }
    }

    func testSaveToDatabaseWithInvalidData() async {
        viewModel.fullName = "" // Invalid

        do {
            try await viewModel.saveToDatabase()
            XCTFail("Should throw error for invalid data")
        } catch let error as SaveError {
            if case .invalidData = error {
                // Expected
            } else {
                XCTFail("Expected invalidData error")
            }
        } catch {
            XCTFail("Expected SaveError")
        }
    }
}

// MARK: - CardListViewModel Tests

@MainActor
final class CardListViewModelTests: XCTestCase {

    var viewModel: CardListViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        let schema = Schema([BusinessCard.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext

        viewModel = CardListViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
        modelContext = nil
        modelContainer = nil
        try await super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertEqual(viewModel.sortOption, .dateScannedDescending)
        XCTAssertTrue(viewModel.selectedTags.isEmpty)
        XCTAssertFalse(viewModel.showFavoritesOnly)
        XCTAssertFalse(viewModel.showSavedToContactsOnly)
    }

    func testSortDescriptors() {
        viewModel.sortOption = .nameAscending
        XCTAssertEqual(viewModel.sortDescriptors.count, 1)

        viewModel.sortOption = .companyDescending
        XCTAssertEqual(viewModel.sortDescriptors.count, 1)
    }

    func testFilterPredicateWithSearch() {
        viewModel.searchQuery = "test"

        XCTAssertNotNil(viewModel.filterPredicate)
    }

    func testFilterPredicateWithFavoritesOnly() {
        viewModel.showFavoritesOnly = true

        XCTAssertNotNil(viewModel.filterPredicate)
    }

    func testFilterPredicateWithMultipleFilters() {
        viewModel.searchQuery = "test"
        viewModel.showFavoritesOnly = true
        viewModel.showSavedToContactsOnly = true

        XCTAssertNotNil(viewModel.filterPredicate)
    }

    func testFilterPredicateEmpty() {
        XCTAssertNil(viewModel.filterPredicate)
    }

    func testHasActiveFilters() {
        XCTAssertFalse(viewModel.hasActiveFilters)

        viewModel.searchQuery = "test"
        XCTAssertTrue(viewModel.hasActiveFilters)

        viewModel.searchQuery = ""
        viewModel.showFavoritesOnly = true
        XCTAssertTrue(viewModel.hasActiveFilters)
    }

    func testToggleFavorite() throws {
        let card = BusinessCard(fullName: "Test", rawText: "Test", isFavorite: false)
        modelContext.insert(card)
        try modelContext.save()

        let originalFavorite = card.isFavorite
        viewModel.toggleFavorite(card)

        XCTAssertNotEqual(card.isFavorite, originalFavorite)
    }

    func testDeleteCard() throws {
        let card = BusinessCard(fullName: "Delete Me", rawText: "Delete")
        modelContext.insert(card)
        try modelContext.save()

        viewModel.deleteCard(card, from: modelContext)

        let descriptor = FetchDescriptor<BusinessCard>()
        let cards = try modelContext.fetch(descriptor)

        XCTAssertTrue(cards.isEmpty)
    }

    func testClearFilters() {
        viewModel.searchQuery = "test"
        viewModel.showFavoritesOnly = true
        viewModel.showSavedToContactsOnly = true
        viewModel.selectedTags = ["Tag1", "Tag2"]

        viewModel.clearFilters()

        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertFalse(viewModel.showFavoritesOnly)
        XCTAssertFalse(viewModel.showSavedToContactsOnly)
        XCTAssertTrue(viewModel.selectedTags.isEmpty)
    }

    func testUpdateSearchQuery() {
        viewModel.updateSearchQuery("new query")
        XCTAssertEqual(viewModel.searchQuery, "new query")
    }

    func testUpdateSortOption() {
        viewModel.updateSortOption(.nameAscending)
        XCTAssertEqual(viewModel.sortOption, .nameAscending)
    }

    func testToggleFavoritesFilter() {
        XCTAssertFalse(viewModel.showFavoritesOnly)

        viewModel.toggleFavoritesFilter()
        XCTAssertTrue(viewModel.showFavoritesOnly)

        viewModel.toggleFavoritesFilter()
        XCTAssertFalse(viewModel.showFavoritesOnly)
    }

    func testToggleSavedToContactsFilter() {
        XCTAssertFalse(viewModel.showSavedToContactsOnly)

        viewModel.toggleSavedToContactsFilter()
        XCTAssertTrue(viewModel.showSavedToContactsOnly)

        viewModel.toggleSavedToContactsFilter()
        XCTAssertFalse(viewModel.showSavedToContactsOnly)
    }

    func testExtractTags() {
        let cards = [
            BusinessCard(fullName: "Card 1", rawText: "1", tags: ["Tech", "Client"]),
            BusinessCard(fullName: "Card 2", rawText: "2", tags: ["Client", "Partner"]),
            BusinessCard(fullName: "Card 3", rawText: "3", tags: ["Tech"])
        ]

        let tags = viewModel.extractTags(from: cards)

        XCTAssertEqual(tags.sorted(), ["Client", "Partner", "Tech"])
    }

    func testSortOptionProperties() {
        for option in CardListViewModel.SortOption.allCases {
            XCTAssertFalse(option.id.isEmpty)
            XCTAssertFalse(option.rawValue.isEmpty)
            XCTAssertFalse(option.systemImage.isEmpty)
        }
    }
}

// MARK: - ExportViewModel Tests

@MainActor
final class ExportViewModelTests: XCTestCase {

    var viewModel: ExportViewModel!

    override func setUp() async throws {
        try await super.setUp()
        viewModel = ExportViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.selectedFormat, .vcard)
        XCTAssertTrue(viewModel.selectedCards.isEmpty)
        XCTAssertEqual(viewModel.exportScope, .single)
        XCTAssertFalse(viewModel.showExportOptions)
        XCTAssertFalse(viewModel.showShareSheet)
        XCTAssertNil(viewModel.exportedFileURL)
    }

    func testConfigureSingleCard() {
        let card = BusinessCard(fullName: "Test", rawText: "Test")

        viewModel.configureSingleCard(card)

        XCTAssertEqual(viewModel.exportScope, .single)
        XCTAssertTrue(viewModel.selectedCards.contains(card.id))
        XCTAssertEqual(viewModel.selectedCards.count, 1)
    }

    func testConfigureMultipleCardsAll() {
        let cards = (0..<5).map { i in
            BusinessCard(fullName: "Card \(i)", rawText: "Card \(i)")
        }

        viewModel.configureMultipleCards(cards)

        XCTAssertEqual(viewModel.exportScope, .all)
        XCTAssertEqual(viewModel.selectedCards.count, 5)
    }

    func testConfigureMultipleCardsPreselected() {
        let cards = (0..<5).map { i in
            BusinessCard(fullName: "Card \(i)", rawText: "Card \(i)")
        }

        let preselected: Set<UUID> = [cards[0].id, cards[2].id]
        viewModel.configureMultipleCards(cards, preselected: preselected)

        XCTAssertEqual(viewModel.exportScope, .selected)
        XCTAssertEqual(viewModel.selectedCards.count, 2)
    }

    func testToggleField() {
        let field = CSVExporter.ExportField.email

        // Add field
        viewModel.selectedFields.removeAll()
        viewModel.toggleField(field)
        XCTAssertTrue(viewModel.selectedFields.contains(field))

        // Remove field
        viewModel.toggleField(field)
        XCTAssertFalse(viewModel.selectedFields.contains(field))
    }

    func testToggleFieldFullNameRequired() {
        viewModel.selectedFields = [.fullName, .email]

        // Try to toggle off fullName
        viewModel.toggleField(.fullName)

        // Should still contain fullName (required)
        XCTAssertTrue(viewModel.selectedFields.contains(.fullName))
    }

    func testToggleAllFields() {
        // Select all
        viewModel.selectedFields = []
        viewModel.toggleAllFields()
        XCTAssertEqual(viewModel.selectedFields.count, CSVExporter.allFields.count)

        // Deselect all (except required)
        viewModel.toggleAllFields()
        XCTAssertEqual(viewModel.selectedFields, [.fullName])
    }

    func testIsFieldSelected() {
        viewModel.selectedFields = [.fullName, .email]

        XCTAssertTrue(viewModel.isFieldSelected(.fullName))
        XCTAssertTrue(viewModel.isFieldSelected(.email))
        XCTAssertFalse(viewModel.isFieldSelected(.phoneNumber))
    }

    func testToggleCard() {
        let cardID = UUID()

        viewModel.toggleCard(cardID)
        XCTAssertTrue(viewModel.selectedCards.contains(cardID))

        viewModel.toggleCard(cardID)
        XCTAssertFalse(viewModel.selectedCards.contains(cardID))
    }

    func testSelectAllCards() {
        let cards = (0..<5).map { i in
            BusinessCard(fullName: "Card \(i)", rawText: "Card \(i)")
        }

        viewModel.configureMultipleCards(cards)
        viewModel.selectedCards.removeAll()

        viewModel.selectAllCards()

        XCTAssertEqual(viewModel.selectedCards.count, 5)
    }

    func testDeselectAllCards() {
        let cards = (0..<5).map { i in
            BusinessCard(fullName: "Card \(i)", rawText: "Card \(i)")
        }

        viewModel.configureMultipleCards(cards)

        viewModel.deselectAllCards()

        XCTAssertTrue(viewModel.selectedCards.isEmpty)
    }

    func testIsCardSelected() {
        let cardID = UUID()

        XCTAssertFalse(viewModel.isCardSelected(cardID))

        viewModel.selectedCards.insert(cardID)
        XCTAssertTrue(viewModel.isCardSelected(cardID))
    }

    func testSelectedCardCount() {
        XCTAssertEqual(viewModel.selectedCardCount, 0)

        viewModel.selectedCards = [UUID(), UUID(), UUID()]
        XCTAssertEqual(viewModel.selectedCardCount, 3)
    }

    func testCanExport() {
        // No cards selected
        XCTAssertFalse(viewModel.canExport)

        // With cards selected
        viewModel.selectedCards = [UUID()]
        XCTAssertTrue(viewModel.canExport)

        // CSV with no fields
        viewModel.selectedFormat = .csv
        viewModel.selectedFields.removeAll()
        XCTAssertFalse(viewModel.canExport)
    }

    func testExportButtonTitle() {
        // Single card
        viewModel.exportScope = .single
        XCTAssertTrue(viewModel.exportButtonTitle.contains("Card"))

        // Selected cards
        viewModel.exportScope = .selected
        viewModel.selectedCards = [UUID(), UUID()]
        XCTAssertTrue(viewModel.exportButtonTitle.contains("2"))

        // All cards
        viewModel.exportScope = .all
        XCTAssertTrue(viewModel.exportButtonTitle.contains("All"))
    }

    func testReset() {
        // Set various states
        viewModel.selectedFormat = .csv
        viewModel.exportScope = .all
        viewModel.selectedCards = [UUID()]
        viewModel.showExportOptions = true
        viewModel.showShareSheet = true
        viewModel.exportedFileURL = URL(fileURLWithPath: "/test")
        viewModel.previewText = "Test"
        viewModel.showPreview = true

        viewModel.reset()

        XCTAssertEqual(viewModel.selectedFormat, .vcard)
        XCTAssertEqual(viewModel.exportScope, .single)
        XCTAssertTrue(viewModel.selectedCards.isEmpty)
        XCTAssertFalse(viewModel.showExportOptions)
        XCTAssertFalse(viewModel.showShareSheet)
        XCTAssertNil(viewModel.exportedFileURL)
        XCTAssertEqual(viewModel.previewText, "")
        XCTAssertFalse(viewModel.showPreview)
    }

    func testScopeOptions() {
        let options = ExportViewModel.ScopeOption.allCases

        XCTAssertGreaterThan(options.count, 0)

        for option in options {
            XCTAssertFalse(option.id.isEmpty)
            XCTAssertFalse(option.rawValue.isEmpty)
        }
    }
}
