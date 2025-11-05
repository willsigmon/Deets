//
//  CardListViewModel.swift
//  Deets
//
//  ViewModel for business card list management
//

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
final class CardListViewModel {
    // MARK: - Published State

    /// Search query
    var searchQuery = ""

    /// Selected sort option
    var sortOption: SortOption = .dateScannedDescending

    /// Selected filter tags
    var selectedTags: Set<String> = []

    /// Whether to show favorites only
    var showFavoritesOnly = false

    /// Whether to show saved to contacts only
    var showSavedToContactsOnly = false

    // MARK: - Dependencies

    private let hapticManager = HapticManager.shared

    // MARK: - Sort Options

    enum SortOption: String, CaseIterable, Identifiable {
        case dateScannedDescending = "Recently Scanned"
        case dateScannedAscending = "Oldest First"
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case companyAscending = "Company (A-Z)"
        case companyDescending = "Company (Z-A)"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .dateScannedDescending:
                return "calendar.badge.clock"
            case .dateScannedAscending:
                return "calendar"
            case .nameAscending, .nameDescending:
                return "textformat.abc"
            case .companyAscending, .companyDescending:
                return "building.2"
            }
        }
    }

    // MARK: - Computed Properties

    /// Sort descriptors for SwiftData query
    var sortDescriptors: [SortDescriptor<BusinessCard>] {
        switch sortOption {
        case .dateScannedDescending:
            return [SortDescriptor(\BusinessCard.dateScanned, order: .reverse)]
        case .dateScannedAscending:
            return [SortDescriptor(\BusinessCard.dateScanned)]
        case .nameAscending:
            return [SortDescriptor(\BusinessCard.fullName)]
        case .nameDescending:
            return [SortDescriptor(\BusinessCard.fullName, order: .reverse)]
        case .companyAscending:
            return [SortDescriptor(\BusinessCard.company)]
        case .companyDescending:
            return [SortDescriptor(\BusinessCard.company, order: .reverse)]
        }
    }

    /// Predicate for filtering cards
    var filterPredicate: Predicate<BusinessCard>? {
        var predicates: [Predicate<BusinessCard>] = []

        // Search query filter
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            predicates.append(#Predicate<BusinessCard> { card in
                card.fullName.lowercased().contains(query) ||
                (card.company?.lowercased().contains(query) ?? false) ||
                (card.email?.lowercased().contains(query) ?? false) ||
                (card.jobTitle?.lowercased().contains(query) ?? false)
            })
        }

        // Favorites filter
        if showFavoritesOnly {
            predicates.append(#Predicate<BusinessCard> { card in
                card.isFavorite == true
            })
        }

        // Saved to contacts filter
        if showSavedToContactsOnly {
            predicates.append(#Predicate<BusinessCard> { card in
                card.savedToContacts == true
            })
        }

        // Combine predicates
        if predicates.isEmpty {
            return nil
        } else if predicates.count == 1 {
            return predicates[0]
        } else {
            return predicates.reduce(predicates[0]) { result, predicate in
                #Predicate<BusinessCard> { card in
                    result.evaluate(card) && predicate.evaluate(card)
                }
            }
        }
    }

    /// Whether any filters are active
    var hasActiveFilters: Bool {
        !searchQuery.isEmpty || showFavoritesOnly || showSavedToContactsOnly || !selectedTags.isEmpty
    }

    // MARK: - Actions

    /// Toggle favorite status
    func toggleFavorite(_ card: BusinessCard) {
        card.isFavorite.toggle()
        card.dateModified = Date()
        hapticManager.toggle()
    }

    /// Delete card
    func deleteCard(_ card: BusinessCard, from context: ModelContext) {
        context.delete(card)
        do {
            try context.save()
            hapticManager.deleted()
        } catch {
            print("Failed to delete card: \(error)")
        }
    }

    /// Clear all filters
    func clearFilters() {
        searchQuery = ""
        selectedTags.removeAll()
        showFavoritesOnly = false
        showSavedToContactsOnly = false
        hapticManager.buttonTap()
    }

    /// Update search query
    func updateSearchQuery(_ query: String) {
        searchQuery = query
    }

    /// Update sort option
    func updateSortOption(_ option: SortOption) {
        sortOption = option
        hapticManager.selectionChanged()
    }

    /// Toggle favorites filter
    func toggleFavoritesFilter() {
        showFavoritesOnly.toggle()
        hapticManager.toggle()
    }

    /// Toggle saved to contacts filter
    func toggleSavedToContactsFilter() {
        showSavedToContactsOnly.toggle()
        hapticManager.toggle()
    }

    /// Get all unique tags from cards
    func extractTags(from cards: [BusinessCard]) -> [String] {
        let allTags = cards.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }
}
