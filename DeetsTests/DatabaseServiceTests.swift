//
//  DatabaseServiceTests.swift
//  DeetsTests
//
//  Unit tests for DatabaseService
//

import XCTest
import SwiftData
@testable import Deets

@MainActor
final class DatabaseServiceTests: XCTestCase {

    // MARK: - Properties

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var databaseService: DatabaseService!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory container for testing
        let schema = Schema([BusinessCard.self])
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)

        // Initialize database service
        databaseService = DatabaseService(modelContext: modelContext)
    }

    override func tearDown() async throws {
        // Clean up
        try await databaseService.deleteAll()
        databaseService = nil
        modelContext = nil
        modelContainer = nil

        try await super.tearDown()
    }

    // MARK: - Create Tests

    func testSaveCard() async throws {
        // Given
        let card = createSampleCard(name: "John Doe")

        // When
        try await databaseService.save(card: card)

        // Then
        let fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 1)
        XCTAssertEqual(fetchedCards.first?.fullName, "John Doe")
    }

    func testBatchSave() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob"),
            createSampleCard(name: "Charlie")
        ]

        // When
        try await databaseService.batchSave(cards)

        // Then
        let fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 3)
    }

    func testBatchSaveEmptyArray() async throws {
        // Given
        let emptyArray: [BusinessCard] = []

        // When/Then - Should not throw
        try await databaseService.batchSave(emptyArray)

        let fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 0)
    }

    // MARK: - Read Tests

    func testFetchAll() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob")
        ]
        try await databaseService.batchSave(cards)

        // When
        let fetchedCards = try await databaseService.fetchAll()

        // Then
        XCTAssertEqual(fetchedCards.count, 2)
    }

    func testFetchByID() async throws {
        // Given
        let card = createSampleCard(name: "John Doe")
        try await databaseService.save(card: card)

        // When
        let fetchedCard = try await databaseService.fetchByID(card.id)

        // Then
        XCTAssertEqual(fetchedCard.id, card.id)
        XCTAssertEqual(fetchedCard.fullName, "John Doe")
    }

    func testFetchByIDNotFound() async throws {
        // Given
        let nonExistentID = UUID()

        // When/Then
        do {
            _ = try await databaseService.fetchByID(nonExistentID)
            XCTFail("Expected DatabaseError.notFound to be thrown")
        } catch let error as DatabaseError {
            if case .notFound(let id) = error {
                XCTAssertEqual(id, nonExistentID)
            } else {
                XCTFail("Expected DatabaseError.notFound, got \(error)")
            }
        }
    }

    func testFetchWithPredicate() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice", company: "Acme Inc"),
            createSampleCard(name: "Bob", company: "TechCorp"),
            createSampleCard(name: "Charlie", company: "Acme Inc")
        ]
        try await databaseService.batchSave(cards)

        // When
        let predicate = #Predicate<BusinessCard> { card in
            card.company == "Acme Inc"
        }
        let fetchedCards = try await databaseService.fetch(predicate: predicate)

        // Then
        XCTAssertEqual(fetchedCards.count, 2)
        XCTAssertTrue(fetchedCards.allSatisfy { $0.company == "Acme Inc" })
    }

    func testFetchWithLimit() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob"),
            createSampleCard(name: "Charlie"),
            createSampleCard(name: "David"),
            createSampleCard(name: "Eve")
        ]
        try await databaseService.batchSave(cards)

        // When
        let fetchedCards = try await databaseService.fetch(limit: 3)

        // Then
        XCTAssertEqual(fetchedCards.count, 3)
    }

    func testSearch() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice Johnson", email: "alice@example.com"),
            createSampleCard(name: "Bob Smith", company: "Acme Inc"),
            createSampleCard(name: "Charlie Brown", jobTitle: "Developer")
        ]
        try await databaseService.batchSave(cards)

        // When - Search by name
        let nameResults = try await databaseService.search(query: "alice")
        XCTAssertEqual(nameResults.count, 1)
        XCTAssertEqual(nameResults.first?.fullName, "Alice Johnson")

        // When - Search by company
        let companyResults = try await databaseService.search(query: "acme")
        XCTAssertEqual(companyResults.count, 1)
        XCTAssertEqual(companyResults.first?.fullName, "Bob Smith")

        // When - Search by job title
        let jobResults = try await databaseService.search(query: "developer")
        XCTAssertEqual(jobResults.count, 1)
        XCTAssertEqual(jobResults.first?.fullName, "Charlie Brown")
    }

    func testSearchEmptyQuery() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob")
        ]
        try await databaseService.batchSave(cards)

        // When - Empty query should return all
        let results = try await databaseService.search(query: "")

        // Then
        XCTAssertEqual(results.count, 2)
    }

    func testFetchFavorites() async throws {
        // Given
        let card1 = createSampleCard(name: "Alice")
        card1.isFavorite = true
        let card2 = createSampleCard(name: "Bob")
        card2.isFavorite = false
        let card3 = createSampleCard(name: "Charlie")
        card3.isFavorite = true

        try await databaseService.batchSave([card1, card2, card3])

        // When
        let favorites = try await databaseService.fetchFavorites()

        // Then
        XCTAssertEqual(favorites.count, 2)
        XCTAssertTrue(favorites.allSatisfy { $0.isFavorite })
    }

    func testFetchSavedToContacts() async throws {
        // Given
        let card1 = createSampleCard(name: "Alice")
        card1.savedToContacts = true
        let card2 = createSampleCard(name: "Bob")
        card2.savedToContacts = false
        let card3 = createSampleCard(name: "Charlie")
        card3.savedToContacts = true

        try await databaseService.batchSave([card1, card2, card3])

        // When
        let savedCards = try await databaseService.fetchSavedToContacts()

        // Then
        XCTAssertEqual(savedCards.count, 2)
        XCTAssertTrue(savedCards.allSatisfy { $0.savedToContacts })
    }

    func testFetchWithTags() async throws {
        // Given
        let card1 = createSampleCard(name: "Alice")
        card1.tags = ["client", "vip"]
        let card2 = createSampleCard(name: "Bob")
        card2.tags = ["colleague", "engineering"]
        let card3 = createSampleCard(name: "Charlie")
        card3.tags = ["client", "engineering"]

        try await databaseService.batchSave([card1, card2, card3])

        // When
        let clientCards = try await databaseService.fetchWithTags(["client"])
        let engineeringCards = try await databaseService.fetchWithTags(["engineering"])

        // Then
        XCTAssertEqual(clientCards.count, 2)
        XCTAssertEqual(engineeringCards.count, 2)
    }

    func testFetchWithEmptyTags() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob")
        ]
        try await databaseService.batchSave(cards)

        // When
        let results = try await databaseService.fetchWithTags([])

        // Then
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Update Tests

    func testUpdateCard() async throws {
        // Given
        let card = createSampleCard(name: "John Doe")
        try await databaseService.save(card: card)

        // When
        card.fullName = "Jane Doe"
        card.company = "Updated Corp"
        try await databaseService.update(card: card)

        // Then
        let fetchedCard = try await databaseService.fetchByID(card.id)
        XCTAssertEqual(fetchedCard.fullName, "Jane Doe")
        XCTAssertEqual(fetchedCard.company, "Updated Corp")
    }

    func testToggleFavorite() async throws {
        // Given
        let card = createSampleCard(name: "John Doe")
        card.isFavorite = false
        try await databaseService.save(card: card)

        // When - Toggle on
        try await databaseService.toggleFavorite(card)
        var fetchedCard = try await databaseService.fetchByID(card.id)
        XCTAssertTrue(fetchedCard.isFavorite)

        // When - Toggle off
        try await databaseService.toggleFavorite(fetchedCard)
        fetchedCard = try await databaseService.fetchByID(card.id)
        XCTAssertFalse(fetchedCard.isFavorite)
    }

    func testBatchUpdate() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob"),
            createSampleCard(name: "Charlie")
        ]
        try await databaseService.batchSave(cards)

        // When
        for card in cards {
            card.company = "Same Company"
        }
        try await databaseService.batchUpdate(cards)

        // Then
        let fetchedCards = try await databaseService.fetchAll()
        XCTAssertTrue(fetchedCards.allSatisfy { $0.company == "Same Company" })
    }

    func testBatchUpdateEmptyArray() async throws {
        // When/Then - Should not throw
        try await databaseService.batchUpdate([])
    }

    // MARK: - Delete Tests

    func testDeleteCard() async throws {
        // Given
        let card = createSampleCard(name: "John Doe")
        try await databaseService.save(card: card)
        var fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 1)

        // When
        try await databaseService.delete(card: card)

        // Then
        fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 0)
    }

    func testBatchDelete() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob"),
            createSampleCard(name: "Charlie")
        ]
        try await databaseService.batchSave(cards)

        // When - Delete two cards
        try await databaseService.batchDelete([cards[0], cards[1]])

        // Then
        let fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 1)
        XCTAssertEqual(fetchedCards.first?.fullName, "Charlie")
    }

    func testBatchDeleteEmptyArray() async throws {
        // When/Then - Should not throw
        try await databaseService.batchDelete([])
    }

    func testDeleteAll() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob"),
            createSampleCard(name: "Charlie")
        ]
        try await databaseService.batchSave(cards)
        var fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 3)

        // When
        try await databaseService.deleteAll()

        // Then
        fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 0)
    }

    // MARK: - Transaction Tests

    func testTransaction() async throws {
        // Given
        let card1 = createSampleCard(name: "Alice")
        let card2 = createSampleCard(name: "Bob")

        // When
        try await databaseService.transaction {
            modelContext.insert(card1)
            modelContext.insert(card2)
        }

        // Then
        let fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 2)
    }

    func testTransactionRollback() async throws {
        // Given
        let card = createSampleCard(name: "Alice")
        try await databaseService.save(card: card)

        // When - Transaction that throws
        do {
            try await databaseService.transaction {
                let newCard = createSampleCard(name: "Bob")
                modelContext.insert(newCard)
                throw NSError(domain: "test", code: 1)
            }
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected
        }

        // Then - Only original card should exist
        let fetchedCards = try await databaseService.fetchAll()
        XCTAssertEqual(fetchedCards.count, 1)
        XCTAssertEqual(fetchedCards.first?.fullName, "Alice")
    }

    // MARK: - Statistics Tests

    func testStatistics() async throws {
        // Given
        let card1 = createSampleCard(name: "Alice")
        card1.isFavorite = true
        card1.savedToContacts = true
        card1.tags = ["client", "vip"]

        let card2 = createSampleCard(name: "Bob")
        card2.isFavorite = true
        card2.tags = ["colleague"]

        let card3 = createSampleCard(name: "Charlie")
        card3.savedToContacts = true
        card3.tags = ["client"]

        try await databaseService.batchSave([card1, card2, card3])

        // When
        let stats = try await databaseService.statistics()

        // Then
        XCTAssertEqual(stats.totalCards, 3)
        XCTAssertEqual(stats.favoriteCards, 2)
        XCTAssertEqual(stats.savedToContactsCards, 2)
        XCTAssertEqual(stats.uniqueTags, 3) // client, vip, colleague
        XCTAssertNotNil(stats.lastModified)
    }

    func testStatisticsEmptyDatabase() async throws {
        // When
        let stats = try await databaseService.statistics()

        // Then
        XCTAssertEqual(stats.totalCards, 0)
        XCTAssertEqual(stats.favoriteCards, 0)
        XCTAssertEqual(stats.savedToContactsCards, 0)
        XCTAssertEqual(stats.uniqueTags, 0)
        XCTAssertNil(stats.lastModified)
    }

    // MARK: - Query Builder Tests

    func testAndPredicate() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice", company: "Acme Inc"),
            createSampleCard(name: "Bob", company: "Acme Inc"),
            createSampleCard(name: "Charlie", company: "TechCorp")
        ]
        cards[0].isFavorite = true
        cards[1].isFavorite = false
        cards[2].isFavorite = true

        try await databaseService.batchSave(cards)

        // When
        let companyPredicate = #Predicate<BusinessCard> { $0.company == "Acme Inc" }
        let favoritePredicate = #Predicate<BusinessCard> { $0.isFavorite == true }

        if let combinedPredicate = DatabaseService.and([companyPredicate, favoritePredicate]) {
            let results = try await databaseService.fetch(predicate: combinedPredicate)

            // Then - Only Alice matches both conditions
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first?.fullName, "Alice")
        } else {
            XCTFail("Expected combined predicate")
        }
    }

    func testAndPredicateEmpty() {
        // When
        let result = DatabaseService.and([])

        // Then
        XCTAssertNil(result)
    }

    func testOrPredicate() async throws {
        // Given
        let cards = [
            createSampleCard(name: "Alice"),
            createSampleCard(name: "Bob"),
            createSampleCard(name: "Charlie")
        ]
        cards[0].isFavorite = true
        cards[1].savedToContacts = true
        cards[2].isFavorite = false

        try await databaseService.batchSave(cards)

        // When
        let favoritePredicate = #Predicate<BusinessCard> { $0.isFavorite == true }
        let savedPredicate = #Predicate<BusinessCard> { $0.savedToContacts == true }

        if let combinedPredicate = DatabaseService.or([favoritePredicate, savedPredicate]) {
            let results = try await databaseService.fetch(predicate: combinedPredicate)

            // Then - Alice and Bob match (Alice is favorite, Bob is saved)
            XCTAssertEqual(results.count, 2)
        } else {
            XCTFail("Expected combined predicate")
        }
    }

    func testOrPredicateEmpty() {
        // When
        let result = DatabaseService.or([])

        // Then
        XCTAssertNil(result)
    }

    // MARK: - Performance Tests

    func testBatchSavePerformance() async throws {
        // Given
        let cards = (0..<100).map { i in
            createSampleCard(name: "Person \(i)")
        }

        // When
        let start = CFAbsoluteTimeGetCurrent()
        try await databaseService.batchSave(cards)
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        // Then
        print("Batch saved 100 cards in \(elapsed) seconds")
        XCTAssertLessThan(elapsed, 2.0) // Should complete in under 2 seconds
    }

    func testSearchPerformance() async throws {
        // Given - Create 100 cards
        let cards = (0..<100).map { i in
            createSampleCard(
                name: "Person \(i)",
                company: i % 3 == 0 ? "Acme Inc" : "TechCorp",
                email: "person\(i)@example.com"
            )
        }
        try await databaseService.batchSave(cards)

        // When
        let start = CFAbsoluteTimeGetCurrent()
        let results = try await databaseService.search(query: "acme")
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        // Then
        print("Searched 100 cards in \(elapsed) seconds, found \(results.count)")
        XCTAssertLessThan(elapsed, 0.5) // Should complete in under 0.5 seconds
    }

    // MARK: - Helper Methods

    private func createSampleCard(
        name: String,
        company: String? = nil,
        email: String? = nil,
        jobTitle: String? = nil
    ) -> BusinessCard {
        BusinessCard(
            fullName: name,
            jobTitle: jobTitle,
            company: company,
            email: email,
            rawText: "Sample raw text"
        )
    }
}
