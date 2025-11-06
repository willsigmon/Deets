//
//  ExportViewModel.swift
//  Deets
//
//  Manages export UI state and options
//

import Foundation
import SwiftUI

@MainActor
class ExportViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Selected export format
    @Published var selectedFormat: ExportFormat = .vcard

    /// Selected cards for export
    @Published var selectedCards: Set<UUID> = []

    /// Export scope selection
    @Published var exportScope: ScopeOption = .single

    /// CSV field selection
    @Published var selectedFields: Set<CSVExporter.ExportField> = Set(CSVExporter.defaultFields)

    /// Show/hide export options sheet
    @Published var showExportOptions = false

    /// Show/hide share sheet
    @Published var showShareSheet = false

    /// Export service
    @Published var exportService = ExportService()

    /// Current export result URL
    @Published var exportedFileURL: URL?

    /// Preview text
    @Published var previewText: String = ""

    /// Show preview
    @Published var showPreview = false

    // MARK: - Scope Options

    enum ScopeOption: String, CaseIterable, Identifiable {
        case single = "Single Card"
        case selected = "Selected Cards"
        case all = "All Cards"

        var id: String { rawValue }
    }

    // MARK: - Properties

    private var allCards: [BusinessCard] = []
    private var currentCard: BusinessCard?

    // MARK: - Initialization

    init() {
        // Default to all CSV fields selected
        selectedFields = Set(CSVExporter.allFields)
    }

    // MARK: - Configuration

    /// Configure for single card export
    func configureSingleCard(_ card: BusinessCard) {
        currentCard = card
        exportScope = .single
        allCards = [card]

        if let id = card.id {
            selectedCards = [id]
        } else {
            selectedCards.removeAll()
        }
    }

    /// Configure for multiple cards export
    func configureMultipleCards(_ cards: [BusinessCard], preselected: Set<UUID> = []) {
        allCards = cards
        exportScope = preselected.isEmpty ? .all : .selected
        if preselected.isEmpty {
            selectedCards = Set(cards.compactMap(\.id))
        } else {
            selectedCards = preselected
        }
    }

    // MARK: - Export Actions

    /// Perform export with current settings
    func performExport() async {
        let cards = getCardsToExport()

        guard !cards.isEmpty else {
            exportService.lastExportError = .noCards
            return
        }

        let result: ExportResult

        if cards.count == 1, let card = cards.first {
            result = await exportService.exportCard(
                card,
                format: selectedFormat,
                fields: Array(selectedFields)
            )
        } else {
            result = await exportService.exportCards(
                cards,
                format: selectedFormat,
                fields: Array(selectedFields)
            )
        }

        switch result {
        case .success(let url):
            exportedFileURL = url
            showShareSheet = true

        case .failure:
            // Error is stored in exportService.lastExportError
            break
        }
    }

    /// Generate preview of export
    func generatePreview() {
        let cards = getCardsToExport()

        guard !cards.isEmpty else {
            previewText = "No cards selected"
            return
        }

        previewText = exportService.generatePreview(
            cards: cards,
            format: selectedFormat,
            fields: Array(selectedFields),
            maxRows: 5
        )
    }

    // MARK: - Field Selection

    /// Toggle all CSV fields
    func toggleAllFields() {
        if selectedFields.count == CSVExporter.allFields.count {
            // Deselect all except required fields
            selectedFields = Set([.fullName])
        } else {
            // Select all
            selectedFields = Set(CSVExporter.allFields)
        }
    }

    /// Toggle a specific field
    func toggleField(_ field: CSVExporter.ExportField) {
        if selectedFields.contains(field) {
            // Don't allow deselecting fullName (required field)
            if field != .fullName {
                selectedFields.remove(field)
            }
        } else {
            selectedFields.insert(field)
        }
    }

    /// Check if field is selected
    func isFieldSelected(_ field: CSVExporter.ExportField) -> Bool {
        selectedFields.contains(field)
    }

    // MARK: - Card Selection

    /// Toggle card selection
    func toggleCard(_ cardID: UUID) {
        if selectedCards.contains(cardID) {
            selectedCards.remove(cardID)
        } else {
            selectedCards.insert(cardID)
        }
    }

    /// Select all cards
    func selectAllCards() {
        selectedCards = Set(allCards.compactMap(\.id))
    }

    /// Deselect all cards
    func deselectAllCards() {
        selectedCards.removeAll()
    }

    /// Check if card is selected
    func isCardSelected(_ cardID: UUID) -> Bool {
        selectedCards.contains(cardID)
    }

    // MARK: - Computed Properties

    var selectedCardCount: Int {
        switch exportScope {
        case .single:
            return currentCard == nil ? 0 : 1
        case .selected:
            return allCards.filter { card in
                guard let id = card.id else { return false }
                return selectedCards.contains(id)
            }.count
        case .all:
            return allCards.count
        }
    }

    var canExport: Bool {
        let cards = getCardsToExport()
        return !cards.isEmpty && (selectedFormat != .csv || !selectedFields.isEmpty)
    }

    var exportButtonTitle: String {
        switch exportScope {
        case .single:
            return "Export Card"
        case .selected:
            return "Export \(selectedCardCount) Card\(selectedCardCount == 1 ? "" : "s")"
        case .all:
            return "Export All Cards"
        }
    }

    // MARK: - Helper Methods

    private func getCardsToExport() -> [BusinessCard] {
        switch exportScope {
        case .single:
            return currentCard.map { [$0] } ?? []

        case .selected:
            return allCards.filter { card in
                guard let id = card.id else { return false }
                return selectedCards.contains(id)
            }

        case .all:
            return allCards
        }
    }

    // MARK: - Reset

    /// Reset to default state
    func reset() {
        selectedFormat = .vcard
        exportScope = .single
        selectedFields = Set(CSVExporter.defaultFields)
        selectedCards.removeAll()
        showExportOptions = false
        showShareSheet = false
        exportedFileURL = nil
        previewText = ""
        showPreview = false
    }
}

// MARK: - Format Helpers

extension ExportFormat {
    var icon: String {
        switch self {
        case .vcard: return "person.text.rectangle"
        case .csv: return "tablecells"
        }
    }

    var description: String {
        switch self {
        case .vcard:
            return "Universal contact format compatible with all devices"
        case .csv:
            return "Spreadsheet format for Excel, Google Sheets, etc."
        }
    }
}
