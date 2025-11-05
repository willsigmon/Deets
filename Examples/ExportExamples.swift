//
//  ExportExamples.swift
//  Deets
//
//  Example usage of export functionality
//

import Foundation

// MARK: - vCard Export Examples

func exportSingleCardToVCard() {
    let card = BusinessCard(
        fullName: "Sarah Chen",
        jobTitle: "Senior Product Designer",
        company: "Acme Design Co",
        email: "sarah.chen@acme.design",
        phoneNumber: "+1 (555) 123-4567",
        website: "https://acme.design",
        address: "123 Design Street, San Francisco, CA 94102",
        notes: "Met at DesignConf 2024",
        rawText: "Sarah Chen\\nSenior Product Designer",
        tags: ["Design", "Client"],
        isFavorite: true
    )

    let vcardContent = VCardExporter.exportCard(card)

    print("=== vCard Export Example ===")
    print(vcardContent)
    print()
}

func exportMultipleCardsToVCard() {
    let cards = [
        BusinessCard(
            fullName: "John Smith",
            company: "Tech Corp",
            email: "john@techcorp.com",
            rawText: "John Smith"
        ),
        BusinessCard(
            fullName: "Jane Doe",
            company: "Design Studio",
            email: "jane@designstudio.com",
            rawText: "Jane Doe"
        )
    ]

    let vcardContent = VCardExporter.exportMultipleCards(cards)

    print("=== Multiple vCards Export ===")
    print(vcardContent)
    print()
}

// MARK: - CSV Export Examples

func exportSingleCardToCSV() {
    let card = BusinessCard(
        fullName: "Sarah Chen",
        jobTitle: "Senior Product Designer",
        company: "Acme Design Co",
        email: "sarah.chen@acme.design",
        phoneNumber: "+1 (555) 123-4567",
        website: "https://acme.design",
        rawText: "Sarah Chen"
    )

    let csvContent = CSVExporter.exportCard(card)

    print("=== CSV Export Example (Default Fields) ===")
    print(csvContent)
    print()
}

func exportMultipleCardsToCSV() {
    let cards = BusinessCard.sampleData

    let csvContent = CSVExporter.exportCards(cards)

    print("=== Multiple Cards CSV Export ===")
    print(csvContent)
    print()
}

func exportWithCustomFields() {
    let card = BusinessCard(
        fullName: "Sarah Chen",
        jobTitle: "Senior Product Designer",
        company: "Acme Design Co",
        email: "sarah.chen@acme.design",
        phoneNumber: "+1 (555) 123-4567",
        rawText: "Sarah Chen",
        tags: ["Design", "Client"],
        isFavorite: true
    )

    // Custom field selection
    let fields: [CSVExporter.ExportField] = [
        .fullName,
        .email,
        .phoneNumber,
        .tags,
        .isFavorite
    ]

    let csvContent = CSVExporter.exportCard(card, fields: fields)

    print("=== CSV Export with Custom Fields ===")
    print(csvContent)
    print()
}

func exportAllFieldsCSV() {
    let card = BusinessCard(
        fullName: "Sarah Chen",
        jobTitle: "Senior Product Designer",
        company: "Acme Design Co",
        email: "sarah.chen@acme.design",
        phoneNumber: "+1 (555) 123-4567",
        website: "https://acme.design",
        address: "123 Design Street, SF, CA",
        notes: "Met at conference",
        rawText: "Sarah Chen",
        tags: ["Design", "VIP"],
        isFavorite: true
    )

    let csvContent = CSVExporter.exportCardsComplete([card])

    print("=== CSV Export with All Fields ===")
    print(csvContent)
    print()
}

// MARK: - Filename Generation Examples

func filenameExamples() {
    let card = BusinessCard(
        fullName: "Sarah Chen",
        rawText: "Sarah Chen"
    )

    print("=== Filename Generation Examples ===")
    print("vCard single:", VCardExporter.generateFilename(for: card))
    print("vCard multiple:", VCardExporter.generateFilename(count: 5))
    print("CSV single:", CSVExporter.generateFilename(for: card))
    print("CSV multiple:", CSVExporter.generateFilename(count: 10))
    print()
}

// MARK: - Preview Examples

func previewExample() {
    let cards = (1...10).map { i in
        BusinessCard(
            fullName: "Person \\(i)",
            company: "Company \\(i)",
            email: "person\\(i)@example.com",
            phoneNumber: "+1555000000\\(i)",
            rawText: "Person \\(i)"
        )
    }

    let preview = CSVExporter.generatePreview(cards, maxRows: 3)

    print("=== CSV Preview (first 3 of 10) ===")
    print(preview)
    print()
}

// MARK: - Special Character Escaping Examples

func escapingExamples() {
    // vCard escaping
    let vcardCard = BusinessCard(
        fullName: "Test, User",
        company: "Company;Name",
        notes: "Line 1\\nLine 2",
        rawText: "Test"
    )

    let vcard = VCardExporter.exportCard(vcardCard)
    print("=== vCard Escaping Example ===")
    print(vcard)
    print()

    // CSV escaping
    let csvCard = BusinessCard(
        fullName: "Test User",
        company: "Company, Inc",
        notes: "Quote: \\"Hello\\"",
        rawText: "Test"
    )

    let csv = CSVExporter.exportCard(csvCard, fields: [.fullName, .company, .notes])
    print("=== CSV Escaping Example ===")
    print(csv)
    print()
}

// MARK: - Main Example Runner

func runAllExportExamples() {
    print("====================================")
    print("   Deets Export Examples")
    print("====================================")
    print()

    exportSingleCardToVCard()
    exportMultipleCardsToVCard()
    exportSingleCardToCSV()
    exportMultipleCardsToCSV()
    exportWithCustomFields()
    exportAllFieldsCSV()
    filenameExamples()
    previewExample()
    escapingExamples()

    print("====================================")
    print("   Examples Complete")
    print("====================================")
}

// MARK: - SwiftUI Integration Examples

/*
 Usage in SwiftUI views:

 1. Single Card Export with Options:

 struct CardView: View {
     let card: BusinessCard
     @StateObject private var exportViewModel = ExportViewModel()

     var body: some View {
         Button("Export") {
             exportViewModel.configureSingleCard(card)
             exportViewModel.showExportOptions = true
         }
         .sheet(isPresented: $exportViewModel.showExportOptions) {
             ExportOptionsView(viewModel: exportViewModel)
         }
     }
 }

 2. Quick Export (no options):

 struct QuickExportExample: View {
     let card: BusinessCard

     var body: some View {
         QuickExportButton(card: card)
     }
 }

 3. Multiple Cards Export:

 struct CardListView: View {
     let cards: [BusinessCard]
     @State private var selectedCards: Set<UUID> = []
     @StateObject private var exportViewModel = ExportViewModel()

     var body: some View {
         List {
             ForEach(cards) { card in
                 CardRow(card: card, isSelected: selectedCards.contains(card.id))
                     .onTapGesture {
                         if selectedCards.contains(card.id) {
                             selectedCards.remove(card.id)
                         } else {
                             selectedCards.insert(card.id)
                         }
                     }
             }
         }
         .toolbar {
             Button("Export Selected") {
                 exportViewModel.configureMultipleCards(cards, preselected: selectedCards)
                 exportViewModel.showExportOptions = true
             }
             .disabled(selectedCards.isEmpty)
         }
         .sheet(isPresented: $exportViewModel.showExportOptions) {
             ExportOptionsView(viewModel: exportViewModel)
         }
     }
 }

 4. Export All Cards:

 struct ExportAllExample: View {
     let allCards: [BusinessCard]
     @StateObject private var exportViewModel = ExportViewModel()

     var body: some View {
         Button("Export All") {
             exportViewModel.configureMultipleCards(allCards)
             exportViewModel.showExportOptions = true
         }
         .sheet(isPresented: $exportViewModel.showExportOptions) {
             ExportOptionsView(viewModel: exportViewModel)
         }
     }
 }

 5. Programmatic Export (no UI):

 class DataExporter {
     private let exportService = ExportService()

     func exportCardsToFile(_ cards: [BusinessCard], format: ExportFormat) async -> URL? {
         let result = await exportService.exportCards(cards, format: format)

         switch result {
         case .success(let url):
             return url
         case .failure(let error):
             print("Export failed: \\(error)")
             return nil
         }
     }
 }
 */
