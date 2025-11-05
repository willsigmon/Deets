//
//  CardListView.swift
//  Deets
//
//  List view for all saved business cards with search and filters
//

import SwiftUI
import SwiftData

struct CardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query private var cards: [BusinessCard]
    @State private var viewModel: CardListViewModel?
    @State private var selectedCard: BusinessCard?
    @State private var showSortMenu = false
    @State private var showFilterMenu = false
    @StateObject private var exportViewModel = ExportViewModel()

    init() {
        // Initialize with default sort
        _cards = Query(sort: \BusinessCard.dateScanned, order: .reverse)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel, filteredCards.isEmpty {
                    if cards.isEmpty {
                        // No cards at all
                        EmptyStateView(
                            systemImage: "rectangle.stack.badge.plus",
                            title: "No Business Cards Yet",
                            message: "Scan your first business card to get started. It only takes a moment!",
                            actionTitle: "Scan First Card"
                        ) {
                            // Navigation handled by tab bar
                        }
                    } else {
                        // Has cards but filtered out
                        EmptyStateView(
                            systemImage: "magnifyingglass",
                            title: "No Results Found",
                            message: "Try adjusting your search or filters to find what you're looking for.",
                            actionTitle: "Clear Filters"
                        ) {
                            viewModel.clearFilters()
                        }
                    }
                } else if let viewModel = viewModel {
                    // Card list
                    List {
                        ForEach(filteredCards) { card in
                            Button {
                                HapticManager.shared.selectionChanged()
                                selectedCard = card
                            } label: {
                                CardRowView(card: card)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteCard(card)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    Task {
                                        await viewModel.toggleFavorite(card)
                                    }
                                } label: {
                                    Label(
                                        card.isFavorite ? "Unfavorite" : "Favorite",
                                        systemImage: card.isFavorite ? "star.slash" : "star.fill"
                                    )
                                }
                                .tint(.yellow)
                            }
                            .swipeActions(edge: .leading) {
                                ShareLink(item: formatCardText(card)) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .searchable(
                        text: $viewModel.searchQuery,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search cards..."
                    )
                    .accessibilityLabel("Business cards list")
                }
            }
            .navigationTitle("Cards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SyncStatusButton()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        // Export options
                        Button {
                            exportViewModel.configureMultipleCards(filteredCards)
                            exportViewModel.showExportOptions = true
                        } label: {
                            Label("Export All Cards", systemImage: "square.and.arrow.up")
                        }
                        .disabled(filteredCards.isEmpty)

                        Divider()

                        sortMenuContent

                        Divider()

                        filterMenuContent
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
                }
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card)
            }
            .sheet(isPresented: $exportViewModel.showExportOptions) {
                ExportOptionsView(viewModel: exportViewModel)
            }
            .onAppear {
                if viewModel == nil {
                    let databaseService = DatabaseService(modelContext: modelContext)
                    viewModel = CardListViewModel(databaseService: databaseService)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredCards: [BusinessCard] {
        guard let viewModel = viewModel else { return [] }

        var filtered = cards

        // Apply search filter
        if !viewModel.searchQuery.isEmpty {
            let query = viewModel.searchQuery.lowercased()
            filtered = filtered.filter { card in
                card.searchableText.contains(query)
            }
        }

        // Apply favorites filter
        if viewModel.showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }

        // Apply saved to contacts filter
        if viewModel.showSavedToContactsOnly {
            filtered = filtered.filter { $0.savedToContacts }
        }

        // Apply tag filters
        if !viewModel.selectedTags.isEmpty {
            filtered = filtered.filter { card in
                !Set(card.tags).isDisjoint(with: viewModel.selectedTags)
            }
        }

        // Apply sort
        return sortCards(filtered)
    }

    private func sortCards(_ cards: [BusinessCard]) -> [BusinessCard] {
        guard let viewModel = viewModel else { return cards }

        switch viewModel.sortOption {
        case .dateScannedDescending:
            return cards.sorted { $0.dateScanned > $1.dateScanned }
        case .dateScannedAscending:
            return cards.sorted { $0.dateScanned < $1.dateScanned }
        case .nameAscending:
            return cards.sorted { $0.fullName < $1.fullName }
        case .nameDescending:
            return cards.sorted { $0.fullName > $1.fullName }
        case .companyAscending:
            return cards.sorted { ($0.company ?? "") < ($1.company ?? "") }
        case .companyDescending:
            return cards.sorted { ($0.company ?? "") > ($1.company ?? "") }
        }
    }

    // MARK: - Menu Content

    @ViewBuilder
    private var sortMenuContent: some View {
        ForEach(CardListViewModel.SortOption.allCases) { option in
            Button {
                viewModel.updateSortOption(option)
            } label: {
                Label(
                    option.rawValue,
                    systemImage: viewModel.sortOption == option ? "checkmark" : option.systemImage
                )
            }
        }
    }

    @ViewBuilder
    private var filterMenuContent: some View {
        Section("Quick Filters") {
            Toggle(isOn: $viewModel.showFavoritesOnly) {
                Label("Favorites Only", systemImage: "star.fill")
            }
            .onChange(of: viewModel.showFavoritesOnly) {
                HapticManager.shared.toggle()
            }

            Toggle(isOn: $viewModel.showSavedToContactsOnly) {
                Label("Saved to Contacts", systemImage: "person.crop.circle.badge.checkmark")
            }
            .onChange(of: viewModel.showSavedToContactsOnly) {
                HapticManager.shared.toggle()
            }
        }

        if viewModel.hasActiveFilters {
            Button(role: .destructive) {
                viewModel.clearFilters()
            } label: {
                Label("Clear All Filters", systemImage: "xmark.circle")
            }
        }
    }

    // MARK: - Actions

    private func deleteCard(_ card: BusinessCard) {
        Task {
            withAnimation(reduceMotion ? .none : .default) {
                await viewModel?.deleteCard(card)
            }
        }
    }

    private func formatCardText(_ card: BusinessCard) -> String {
        var text = card.fullName

        if let jobTitle = card.jobTitle {
            text += "\\n\(jobTitle)"
        }

        if let company = card.company {
            text += "\\n\(company)"
        }

        if let email = card.email {
            text += "\\n\(email)"
        }

        if let phone = card.phoneNumber {
            text += "\\n\(phone)"
        }

        if let website = card.website {
            text += "\\n\(website)"
        }

        return text
    }
}

// MARK: - Preview

#Preview("Card List - With Data") {
    CardListView()
        .modelContainer(for: BusinessCard.self, inMemory: true) { result in
            if case .success(let container) = result {
                let context = container.mainContext
                for card in BusinessCard.sampleData {
                    context.insert(card)
                }
            }
        }
}

#Preview("Card List - Empty") {
    CardListView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
