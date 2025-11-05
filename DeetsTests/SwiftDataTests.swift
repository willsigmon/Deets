//
//  SwiftDataTests.swift
//  DeetsTests
//
//  Tests for SwiftData model operations
//  Tests CRUD operations, queries, sorting, and filtering
//

import XCTest
import SwiftData
@testable import Deets

@MainActor
final class SwiftDataTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory container for testing
        let schema = Schema([BusinessCard.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
        try await super.tearDown()
    }

    // MARK: - Model Creation Tests

    func testCreateBusinessCard() {
        let card = BusinessCard(
            fullName: "Test Person",
            email: "test@example.com",
            rawText: "Test Person\ntest@example.com"
        )

        modelContext.insert(card)

        XCTAssertNotNil(card.id)
        XCTAssertEqual(card.fullName, "Test Person")
        XCTAssertEqual(card.email, "test@example.com")
        XCTAssertFalse(card.savedToContacts)
        XCTAssertFalse(card.isFavorite)
    }

    func testBusinessCardDefaultValues() {
        let card = BusinessCard(
            fullName: "John Doe",
            rawText: "John Doe"
        )

        XCTAssertNotNil(card.id)
        XCTAssertNotNil(card.dateScanned)
        XCTAssertNotNil(card.dateModified)
        XCTAssertEqual(card.savedToContacts, false)
        XCTAssertEqual(card.isFavorite, false)
        XCTAssertTrue(card.tags.isEmpty)
        XCTAssertTrue(card.isLocalOnly)
    }

    // MARK: - CRUD Operations Tests

    func testInsertCard() throws {
        let card = BusinessCard(
            fullName: "Insert Test",
            rawText: "Insert Test"
        )

        modelContext.insert(card)
        try modelContext.save()

        // Fetch to verify
        let descriptor = FetchDescriptor<BusinessCard>()
        let cards = try modelContext.fetch(descriptor)

        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards.first?.fullName, "Insert Test")
    }

    func testUpdateCard() throws {
        let card = BusinessCard(
            fullName: "Original Name",
            rawText: "Original"
        )

        modelContext.insert(card)
        try modelContext.save()

        // Update
        card.fullName = "Updated Name"
        card.dateModified = Date()
        try modelContext.save()

        // Fetch to verify
        let descriptor = FetchDescriptor<BusinessCard>()
        let cards = try modelContext.fetch(descriptor)

        XCTAssertEqual(cards.first?.fullName, "Updated Name")
    }

    func testDeleteCard() throws {
        let card = BusinessCard(
            fullName: "Delete Test",
            rawText: "Delete Test"
        )

        modelContext.insert(card)
        try modelContext.save()

        // Delete
        modelContext.delete(card)
        try modelContext.save()

        // Verify deletion
        let descriptor = FetchDescriptor<BusinessCard>()
        let cards = try modelContext.fetch(descriptor)

        XCTAssertTrue(cards.isEmpty)
    }

    func testBatchInsert() throws {
        let cards = (0..<10).map { index in
            BusinessCard(
                fullName: "Person \(index)",
                rawText: "Person \(index)"
            )
        }

        for card in cards {
            modelContext.insert(card)
        }
        try modelContext.save()

        let descriptor = FetchDescriptor<BusinessCard>()
        let fetchedCards = try modelContext.fetch(descriptor)

        XCTAssertEqual(fetchedCards.count, 10)
    }

    // MARK: - Query Tests

    func testFetchAllCards() throws {
        // Insert test data
        insertTestCards(count: 5)

        let descriptor = FetchDescriptor<BusinessCard>()
        let cards = try modelContext.fetch(descriptor)

        XCTAssertEqual(cards.count, 5)
    }

    func testFetchWithPredicate() throws {
        // Insert test data
        let card1 = BusinessCard(fullName: "Alice Smith", rawText: "Alice")
        let card2 = BusinessCard(fullName: "Bob Jones", rawText: "Bob")
        let card3 = BusinessCard(fullName: "Alice Johnson", rawText: "Alice")

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)
        try modelContext.save()

        // Fetch with predicate
        let predicate = #Predicate<BusinessCard> { card in
            card.fullName.contains("Alice")
        }

        var descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
        let aliceCards = try modelContext.fetch(descriptor)

        XCTAssertEqual(aliceCards.count, 2)
    }

    func testSearchByName() throws {
        insertTestCards(count: 5)

        let searchQuery = "Person 2"
        let predicate = #Predicate<BusinessCard> { card in
            card.fullName.contains(searchQuery)
        }

        let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.fullName, "Person 2")
    }

    func testSearchByEmail() throws {
        let card1 = BusinessCard(
            fullName: "John",
            email: "john@example.com",
            rawText: "John"
        )
        let card2 = BusinessCard(
            fullName: "Jane",
            email: "jane@example.com",
            rawText: "Jane"
        )

        modelContext.insert(card1)
        modelContext.insert(card2)
        try modelContext.save()

        let predicate = #Predicate<BusinessCard> { card in
            (card.email ?? "").contains("john@")
        }

        let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.email, "john@example.com")
    }

    func testSearchByCompany() throws {
        let card1 = BusinessCard(
            fullName: "Employee 1",
            company: "Acme Corp",
            rawText: "Employee 1"
        )
        let card2 = BusinessCard(
            fullName: "Employee 2",
            company: "Tech Inc",
            rawText: "Employee 2"
        )

        modelContext.insert(card1)
        modelContext.insert(card2)
        try modelContext.save()

        let predicate = #Predicate<BusinessCard> { card in
            (card.company ?? "").contains("Acme")
        }

        let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.company, "Acme Corp")
    }

    // MARK: - Sorting Tests

    func testSortByNameAscending() throws {
        let card1 = BusinessCard(fullName: "Charlie", rawText: "Charlie")
        let card2 = BusinessCard(fullName: "Alice", rawText: "Alice")
        let card3 = BusinessCard(fullName: "Bob", rawText: "Bob")

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)
        try modelContext.save()

        let descriptor = FetchDescriptor<BusinessCard>(
            sortBy: [SortDescriptor(\BusinessCard.fullName)]
        )
        let sortedCards = try modelContext.fetch(descriptor)

        XCTAssertEqual(sortedCards[0].fullName, "Alice")
        XCTAssertEqual(sortedCards[1].fullName, "Bob")
        XCTAssertEqual(sortedCards[2].fullName, "Charlie")
    }

    func testSortByNameDescending() throws {
        let card1 = BusinessCard(fullName: "Alice", rawText: "Alice")
        let card2 = BusinessCard(fullName: "Bob", rawText: "Bob")
        let card3 = BusinessCard(fullName: "Charlie", rawText: "Charlie")

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)
        try modelContext.save()

        let descriptor = FetchDescriptor<BusinessCard>(
            sortBy: [SortDescriptor(\BusinessCard.fullName, order: .reverse)]
        )
        let sortedCards = try modelContext.fetch(descriptor)

        XCTAssertEqual(sortedCards[0].fullName, "Charlie")
        XCTAssertEqual(sortedCards[1].fullName, "Bob")
        XCTAssertEqual(sortedCards[2].fullName, "Alice")
    }

    func testSortByDateScanned() throws {
        let now = Date()
        let card1 = BusinessCard(
            fullName: "First",
            rawText: "First",
            dateScanned: now.addingTimeInterval(-3600)
        )
        let card2 = BusinessCard(
            fullName: "Second",
            rawText: "Second",
            dateScanned: now
        )
        let card3 = BusinessCard(
            fullName: "Third",
            rawText: "Third",
            dateScanned: now.addingTimeInterval(-7200)
        )

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)
        try modelContext.save()

        let descriptor = FetchDescriptor<BusinessCard>(
            sortBy: [SortDescriptor(\BusinessCard.dateScanned, order: .reverse)]
        )
        let sortedCards = try modelContext.fetch(descriptor)

        XCTAssertEqual(sortedCards[0].fullName, "Second") // Most recent
        XCTAssertEqual(sortedCards[1].fullName, "First")
        XCTAssertEqual(sortedCards[2].fullName, "Third") // Oldest
    }

    // MARK: - Filter Tests

    func testFilterFavorites() throws {
        let card1 = BusinessCard(fullName: "Fav 1", rawText: "Fav 1", isFavorite: true)
        let card2 = BusinessCard(fullName: "Regular", rawText: "Regular", isFavorite: false)
        let card3 = BusinessCard(fullName: "Fav 2", rawText: "Fav 2", isFavorite: true)

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)
        try modelContext.save()

        let predicate = #Predicate<BusinessCard> { card in
            card.isFavorite == true
        }

        let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
        let favorites = try modelContext.fetch(descriptor)

        XCTAssertEqual(favorites.count, 2)
        XCTAssertTrue(favorites.allSatisfy { $0.isFavorite })
    }

    func testFilterSavedToContacts() throws {
        let card1 = BusinessCard(fullName: "Saved", rawText: "Saved", savedToContacts: true)
        let card2 = BusinessCard(fullName: "Not Saved", rawText: "Not Saved", savedToContacts: false)

        modelContext.insert(card1)
        modelContext.insert(card2)
        try modelContext.save()

        let predicate = #Predicate<BusinessCard> { card in
            card.savedToContacts == true
        }

        let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
        let savedCards = try modelContext.fetch(descriptor)

        XCTAssertEqual(savedCards.count, 1)
        XCTAssertTrue(savedCards.first!.savedToContacts)
    }

    func testFilterByTags() throws {
        let card1 = BusinessCard(
            fullName: "Tagged 1",
            rawText: "Tagged 1",
            tags: ["Client", "Tech"]
        )
        let card2 = BusinessCard(
            fullName: "Tagged 2",
            rawText: "Tagged 2",
            tags: ["Partner"]
        )
        let card3 = BusinessCard(
            fullName: "Tagged 3",
            rawText: "Tagged 3",
            tags: ["Client"]
        )

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)
        try modelContext.save()

        let predicate = #Predicate<BusinessCard> { card in
            card.tags.contains("Client")
        }

        let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
        let clientCards = try modelContext.fetch(descriptor)

        XCTAssertEqual(clientCards.count, 2)
    }

    // MARK: - Computed Properties Tests

    func testDisplayName() {
        let card = BusinessCard(fullName: "John Doe", rawText: "John Doe")
        XCTAssertEqual(card.displayName, "John Doe")

        let emptyCard = BusinessCard(fullName: "", rawText: "")
        XCTAssertEqual(emptyCard.displayName, "Unknown Contact")
    }

    func testDisplaySubtitle() {
        let cardWithCompany = BusinessCard(
            fullName: "John",
            company: "Acme Corp",
            rawText: "John"
        )
        XCTAssertEqual(cardWithCompany.displaySubtitle, "Acme Corp")

        let cardWithTitle = BusinessCard(
            fullName: "Jane",
            jobTitle: "Engineer",
            rawText: "Jane"
        )
        XCTAssertEqual(cardWithTitle.displaySubtitle, "Engineer")

        let cardWithBoth = BusinessCard(
            fullName: "Bob",
            jobTitle: "CEO",
            company: "Tech Inc",
            rawText: "Bob"
        )
        // Company takes precedence
        XCTAssertEqual(cardWithBoth.displaySubtitle, "Tech Inc")
    }

    func testHasContactInfo() {
        let cardWithEmail = BusinessCard(
            fullName: "John",
            email: "john@example.com",
            rawText: "John"
        )
        XCTAssertTrue(cardWithEmail.hasContactInfo)

        let cardWithPhone = BusinessCard(
            fullName: "Jane",
            phoneNumber: "555-1234",
            rawText: "Jane"
        )
        XCTAssertTrue(cardWithPhone.hasContactInfo)

        let cardWithBoth = BusinessCard(
            fullName: "Bob",
            email: "bob@example.com",
            phoneNumber: "555-5678",
            rawText: "Bob"
        )
        XCTAssertTrue(cardWithBoth.hasContactInfo)

        let cardWithNeither = BusinessCard(
            fullName: "Alice",
            rawText: "Alice"
        )
        XCTAssertFalse(cardWithNeither.hasContactInfo)
    }

    func testSearchableText() {
        let card = BusinessCard(
            fullName: "John Smith",
            jobTitle: "Engineer",
            company: "Tech Corp",
            email: "john@tech.com",
            phoneNumber: "555-1234",
            notes: "Met at conference",
            rawText: "John Smith"
        )

        let searchText = card.searchableText

        XCTAssertTrue(searchText.contains("john smith"))
        XCTAssertTrue(searchText.contains("engineer"))
        XCTAssertTrue(searchText.contains("tech corp"))
        XCTAssertTrue(searchText.contains("john@tech.com"))
        XCTAssertTrue(searchText.contains("555-1234"))
        XCTAssertTrue(searchText.contains("met at conference"))
    }

    // MARK: - CloudKit Metadata Tests

    func testCloudKitMetadata() {
        let card = BusinessCard(
            fullName: "Test",
            rawText: "Test"
        )

        // Default values
        XCTAssertTrue(card.isLocalOnly)
        XCTAssertNil(card.cloudKitModificationDate)

        // Update CloudKit metadata
        card.cloudKitModificationDate = Date()
        card.isLocalOnly = false

        XCTAssertNotNil(card.cloudKitModificationDate)
        XCTAssertFalse(card.isLocalOnly)
    }

    // MARK: - Sample Data Tests

    func testSampleData() {
        let samples = BusinessCard.sampleData

        XCTAssertGreaterThan(samples.count, 0)

        for sample in samples {
            XCTAssertFalse(sample.fullName.isEmpty)
            XCTAssertFalse(sample.rawText.isEmpty)
        }
    }

    // MARK: - Complex Query Tests

    func testComplexQuery() throws {
        // Insert diverse test data
        let card1 = BusinessCard(
            fullName: "Alice Johnson",
            company: "Tech Corp",
            email: "alice@tech.com",
            rawText: "Alice",
            isFavorite: true
        )
        let card2 = BusinessCard(
            fullName: "Bob Smith",
            company: "Design Inc",
            email: "bob@design.com",
            rawText: "Bob",
            isFavorite: false
        )
        let card3 = BusinessCard(
            fullName: "Charlie Tech",
            company: "Tech Corp",
            email: "charlie@tech.com",
            rawText: "Charlie",
            isFavorite: true
        )

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)
        try modelContext.save()

        // Complex query: Favorites at Tech Corp
        let predicate = #Predicate<BusinessCard> { card in
            card.isFavorite == true && (card.company ?? "").contains("Tech Corp")
        }

        let descriptor = FetchDescriptor<BusinessCard>(
            predicate: predicate,
            sortBy: [SortDescriptor(\BusinessCard.fullName)]
        )

        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].fullName, "Alice Johnson")
        XCTAssertEqual(results[1].fullName, "Charlie Tech")
    }

    // MARK: - Performance Tests

    func testLargeDatasetPerformance() throws {
        measure {
            // Insert 100 cards
            for i in 0..<100 {
                let card = BusinessCard(
                    fullName: "Person \(i)",
                    rawText: "Person \(i)"
                )
                modelContext.insert(card)
            }

            do {
                try modelContext.save()
            } catch {
                XCTFail("Failed to save: \(error)")
            }
        }
    }

    func testQueryPerformance() throws {
        // Insert test data
        insertTestCards(count: 100)

        measure {
            let descriptor = FetchDescriptor<BusinessCard>(
                sortBy: [SortDescriptor(\BusinessCard.fullName)]
            )

            do {
                _ = try modelContext.fetch(descriptor)
            } catch {
                XCTFail("Failed to fetch: \(error)")
            }
        }
    }

    // MARK: - Helper Methods

    private func insertTestCards(count: Int) {
        for i in 0..<count {
            let card = BusinessCard(
                fullName: "Person \(i)",
                email: "person\(i)@example.com",
                rawText: "Person \(i)"
            )
            modelContext.insert(card)
        }

        do {
            try modelContext.save()
        } catch {
            XCTFail("Failed to insert test cards: \(error)")
        }
    }
}
