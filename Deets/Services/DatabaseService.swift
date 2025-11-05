//
//  DatabaseService.swift
//  Deets
//
//  Centralized database service for BusinessCard CRUD operations
//  Provides transaction management, error handling, and query builders
//

import Foundation
import SwiftData
import OSLog

/// Thread-safe database service for managing BusinessCard persistence
/// All operations are performed on the main actor for SwiftUI compatibility
@MainActor
final class DatabaseService {

    // MARK: - Properties

    /// SwiftData model context
    private let modelContext: ModelContext

    /// Performance tracking for query optimization
    private let performanceLogger = AppLogger.performance

    // MARK: - Initialization

    /// Initialize database service with a model context
    /// - Parameter modelContext: The SwiftData context to use for operations
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        AppLogger.database.info("DatabaseService initialized")
    }

    // MARK: - Create Operations

    /// Save a new business card to the database
    /// - Parameter card: The business card to save
    /// - Throws: DatabaseError if save fails
    func save(card: BusinessCard) async throws {
        let startTime = CFAbsoluteTimeGetCurrent()

        do {
            modelContext.insert(card)
            try modelContext.save()

            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            performanceLogger.debug("Saved card in \(elapsed, privacy: .public)s")
            AppLogger.database.info("Saved card: \(card.id, privacy: .hash)")
        } catch {
            AppLogger.database.error("Failed to save card: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.saveFailed(underlying: error)
        }
    }

    /// Save multiple business cards in a single transaction
    /// - Parameter cards: Array of business cards to save
    /// - Throws: DatabaseError if batch save fails
    func batchSave(_ cards: [BusinessCard]) async throws {
        guard !cards.isEmpty else {
            AppLogger.database.warning("Attempted batch save with empty array")
            return
        }

        let startTime = CFAbsoluteTimeGetCurrent()

        do {
            // Insert all cards
            for card in cards {
                modelContext.insert(card)
            }

            // Save in single transaction
            try modelContext.save()

            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            performanceLogger.debug("Batch saved \(cards.count, privacy: .public) cards in \(elapsed, privacy: .public)s")
            AppLogger.database.info("Batch saved \(cards.count, privacy: .public) cards")
        } catch {
            AppLogger.database.error("Failed to batch save cards: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.batchSaveFailed(underlying: error)
        }
    }

    // MARK: - Read Operations

    /// Fetch all business cards
    /// - Returns: Array of all business cards, sorted by date scanned descending
    func fetchAll() async throws -> [BusinessCard] {
        let descriptor = FetchDescriptor<BusinessCard>(
            sortBy: [SortDescriptor(\BusinessCard.dateScanned, order: .reverse)]
        )

        do {
            let cards = try modelContext.fetch(descriptor)
            AppLogger.database.debug("Fetched \(cards.count, privacy: .public) cards")
            return cards
        } catch {
            AppLogger.database.error("Failed to fetch cards: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.fetchFailed(underlying: error)
        }
    }

    /// Fetch business cards with custom predicate and sorting
    /// - Parameters:
    ///   - predicate: Optional predicate to filter cards
    ///   - sortBy: Array of sort descriptors (default: date scanned descending)
    ///   - limit: Maximum number of results to return (default: no limit)
    /// - Returns: Array of matching business cards
    func fetch(
        predicate: Predicate<BusinessCard>? = nil,
        sortBy: [SortDescriptor<BusinessCard>] = [SortDescriptor(\BusinessCard.dateScanned, order: .reverse)],
        limit: Int? = nil
    ) async throws -> [BusinessCard] {
        var descriptor = FetchDescriptor<BusinessCard>(
            predicate: predicate,
            sortBy: sortBy
        )

        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        do {
            let cards = try modelContext.fetch(descriptor)
            AppLogger.database.debug("Fetched \(cards.count, privacy: .public) cards with predicate")
            return cards
        } catch {
            AppLogger.database.error("Failed to fetch cards with predicate: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.fetchFailed(underlying: error)
        }
    }

    /// Fetch a single business card by ID
    /// - Parameter id: The unique identifier of the card
    /// - Returns: The business card if found
    /// - Throws: DatabaseError.notFound if card doesn't exist
    func fetchByID(_ id: UUID) async throws -> BusinessCard {
        let predicate = #Predicate<BusinessCard> { card in
            card.id == id
        }

        let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)

        do {
            let cards = try modelContext.fetch(descriptor)
            guard let card = cards.first else {
                throw DatabaseError.notFound(id: id)
            }
            return card
        } catch let error as DatabaseError {
            throw error
        } catch {
            AppLogger.database.error("Failed to fetch card by ID: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.fetchFailed(underlying: error)
        }
    }

    /// Search business cards by text query across multiple fields
    /// - Parameters:
    ///   - query: Search text (searches name, company, email, job title, notes)
    ///   - sortBy: Sort descriptors (default: relevance via date scanned)
    /// - Returns: Array of matching business cards
    func search(
        query: String,
        sortBy: [SortDescriptor<BusinessCard>] = [SortDescriptor(\BusinessCard.dateScanned, order: .reverse)]
    ) async throws -> [BusinessCard] {
        guard !query.isEmpty else {
            return try await fetchAll()
        }

        let lowercasedQuery = query.lowercased()
        let predicate = #Predicate<BusinessCard> { card in
            card.fullName.lowercased().contains(lowercasedQuery) ||
            (card.company?.lowercased().contains(lowercasedQuery) ?? false) ||
            (card.email?.lowercased().contains(lowercasedQuery) ?? false) ||
            (card.jobTitle?.lowercased().contains(lowercasedQuery) ?? false) ||
            (card.notes?.lowercased().contains(lowercasedQuery) ?? false)
        }

        return try await fetch(predicate: predicate, sortBy: sortBy)
    }

    /// Fetch favorite business cards
    /// - Returns: Array of favorited cards
    func fetchFavorites() async throws -> [BusinessCard] {
        let predicate = #Predicate<BusinessCard> { card in
            card.isFavorite == true
        }
        return try await fetch(predicate: predicate)
    }

    /// Fetch cards saved to contacts
    /// - Returns: Array of cards marked as saved to contacts
    func fetchSavedToContacts() async throws -> [BusinessCard] {
        let predicate = #Predicate<BusinessCard> { card in
            card.savedToContacts == true
        }
        return try await fetch(predicate: predicate)
    }

    /// Fetch cards with specific tags
    /// - Parameter tags: Tags to filter by
    /// - Returns: Array of cards containing any of the specified tags
    func fetchWithTags(_ tags: Set<String>) async throws -> [BusinessCard] {
        guard !tags.isEmpty else {
            return []
        }

        // Note: SwiftData doesn't support array contains predicates yet
        // So we fetch all and filter in memory
        let allCards = try await fetchAll()
        return allCards.filter { card in
            !Set(card.tags).isDisjoint(with: tags)
        }
    }

    // MARK: - Update Operations

    /// Update an existing business card
    /// - Parameter card: The business card to update (must already exist in context)
    /// - Throws: DatabaseError if update fails
    func update(card: BusinessCard) async throws {
        do {
            card.dateModified = Date()
            try modelContext.save()
            AppLogger.database.info("Updated card: \(card.id, privacy: .hash)")
        } catch {
            AppLogger.database.error("Failed to update card: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.updateFailed(underlying: error)
        }
    }

    /// Toggle favorite status for a card
    /// - Parameter card: The card to toggle
    func toggleFavorite(_ card: BusinessCard) async throws {
        card.isFavorite.toggle()
        try await update(card: card)
        AppLogger.database.debug("Toggled favorite status for card: \(card.id, privacy: .hash)")
    }

    /// Update multiple cards in a single transaction
    /// - Parameter cards: Array of cards to update
    /// - Throws: DatabaseError if batch update fails
    func batchUpdate(_ cards: [BusinessCard]) async throws {
        guard !cards.isEmpty else {
            AppLogger.database.warning("Attempted batch update with empty array")
            return
        }

        do {
            for card in cards {
                card.dateModified = Date()
            }
            try modelContext.save()
            AppLogger.database.info("Batch updated \(cards.count, privacy: .public) cards")
        } catch {
            AppLogger.database.error("Failed to batch update: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.batchUpdateFailed(underlying: error)
        }
    }

    // MARK: - Delete Operations

    /// Delete a business card
    /// - Parameter card: The card to delete
    /// - Throws: DatabaseError if delete fails
    func delete(card: BusinessCard) async throws {
        do {
            modelContext.delete(card)
            try modelContext.save()
            AppLogger.database.info("Deleted card: \(card.id, privacy: .hash)")
        } catch {
            AppLogger.database.error("Failed to delete card: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.deleteFailed(underlying: error)
        }
    }

    /// Delete multiple cards in a single transaction
    /// - Parameter cards: Array of cards to delete
    /// - Throws: DatabaseError if batch delete fails
    func batchDelete(_ cards: [BusinessCard]) async throws {
        guard !cards.isEmpty else {
            AppLogger.database.warning("Attempted batch delete with empty array")
            return
        }

        do {
            for card in cards {
                modelContext.delete(card)
            }
            try modelContext.save()
            AppLogger.database.info("Batch deleted \(cards.count, privacy: .public) cards")
        } catch {
            AppLogger.database.error("Failed to batch delete: \(error.localizedDescription, privacy: .public)")
            throw DatabaseError.batchDeleteFailed(underlying: error)
        }
    }

    /// Delete all cards (use with caution)
    /// - Throws: DatabaseError if operation fails
    func deleteAll() async throws {
        let allCards = try await fetchAll()
        try await batchDelete(allCards)
        AppLogger.database.notice("Deleted all \(allCards.count, privacy: .public) cards from database")
    }

    // MARK: - Transaction Management

    /// Execute multiple operations in a single transaction
    /// - Parameter operations: Closure containing database operations
    /// - Throws: DatabaseError if transaction fails
    func transaction(_ operations: @escaping () throws -> Void) async throws {
        do {
            try operations()
            try modelContext.save()
            AppLogger.database.debug("Transaction completed successfully")
        } catch {
            AppLogger.database.error("Transaction failed: \(error.localizedDescription, privacy: .public)")
            modelContext.rollback()
            throw DatabaseError.transactionFailed(underlying: error)
        }
    }

    // MARK: - Statistics

    /// Get database statistics
    /// - Returns: DatabaseStatistics struct with counts and metadata
    func statistics() async throws -> DatabaseStatistics {
        let allCards = try await fetchAll()
        let favorites = allCards.filter { $0.isFavorite }
        let savedToContacts = allCards.filter { $0.savedToContacts }
        let allTags = Set(allCards.flatMap { $0.tags })

        return DatabaseStatistics(
            totalCards: allCards.count,
            favoriteCards: favorites.count,
            savedToContactsCards: savedToContacts.count,
            uniqueTags: allTags.count,
            lastModified: allCards.map { $0.dateModified }.max()
        )
    }

    // MARK: - Query Builder Helpers

    /// Create a compound predicate combining multiple conditions with AND logic
    /// - Parameter predicates: Array of predicates to combine
    /// - Returns: Combined predicate
    static func and(_ predicates: [Predicate<BusinessCard>]) -> Predicate<BusinessCard>? {
        guard !predicates.isEmpty else { return nil }
        guard predicates.count > 1 else { return predicates.first }

        return predicates.reduce(predicates[0]) { result, predicate in
            #Predicate<BusinessCard> { card in
                result.evaluate(card) && predicate.evaluate(card)
            }
        }
    }

    /// Create a compound predicate combining multiple conditions with OR logic
    /// - Parameter predicates: Array of predicates to combine
    /// - Returns: Combined predicate
    static func or(_ predicates: [Predicate<BusinessCard>]) -> Predicate<BusinessCard>? {
        guard !predicates.isEmpty else { return nil }
        guard predicates.count > 1 else { return predicates.first }

        return predicates.reduce(predicates[0]) { result, predicate in
            #Predicate<BusinessCard> { card in
                result.evaluate(card) || predicate.evaluate(card)
            }
        }
    }
}

// MARK: - Database Statistics

/// Statistics about the database
struct DatabaseStatistics {
    let totalCards: Int
    let favoriteCards: Int
    let savedToContactsCards: Int
    let uniqueTags: Int
    let lastModified: Date?

    var formattedSummary: String {
        """
        Total Cards: \(totalCards)
        Favorites: \(favoriteCards)
        Saved to Contacts: \(savedToContactsCards)
        Unique Tags: \(uniqueTags)
        Last Modified: \(lastModified?.formatted() ?? "Never")
        """
    }
}

// MARK: - Error Types

/// Errors that can occur during database operations
enum DatabaseError: LocalizedError, Identifiable {
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case updateFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case batchSaveFailed(underlying: Error)
    case batchUpdateFailed(underlying: Error)
    case batchDeleteFailed(underlying: Error)
    case transactionFailed(underlying: Error)
    case notFound(id: UUID)
    case invalidData(reason: String)

    var id: String {
        switch self {
        case .saveFailed:
            return "save_failed"
        case .fetchFailed:
            return "fetch_failed"
        case .updateFailed:
            return "update_failed"
        case .deleteFailed:
            return "delete_failed"
        case .batchSaveFailed:
            return "batch_save_failed"
        case .batchUpdateFailed:
            return "batch_update_failed"
        case .batchDeleteFailed:
            return "batch_delete_failed"
        case .transactionFailed:
            return "transaction_failed"
        case .notFound(let id):
            return "not_found_\(id.uuidString)"
        case .invalidData:
            return "invalid_data"
        }
    }

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save card: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch cards: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update card: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete card: \(error.localizedDescription)"
        case .batchSaveFailed(let error):
            return "Failed to save multiple cards: \(error.localizedDescription)"
        case .batchUpdateFailed(let error):
            return "Failed to update multiple cards: \(error.localizedDescription)"
        case .batchDeleteFailed(let error):
            return "Failed to delete multiple cards: \(error.localizedDescription)"
        case .transactionFailed(let error):
            return "Database transaction failed: \(error.localizedDescription)"
        case .notFound(let id):
            return "Card not found with ID: \(id.uuidString)"
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .updateFailed, .deleteFailed,
             .batchSaveFailed, .batchUpdateFailed, .batchDeleteFailed,
             .transactionFailed:
            return "Please try again. If the problem persists, restart the app."
        case .fetchFailed:
            return "Unable to retrieve cards. Please check your data and try again."
        case .notFound:
            return "The card may have been deleted. Please refresh your list."
        case .invalidData:
            return "Please check the data and try again."
        }
    }
}
