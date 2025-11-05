# Export Feature Quick Reference

## Quick Start

### Export a Single Card

```swift
// In your view
@StateObject private var exportViewModel = ExportViewModel()

// Configure
exportViewModel.configureSingleCard(card)

// Show options
exportViewModel.showExportOptions = true

// Present sheet
.sheet(isPresented: $exportViewModel.showExportOptions) {
    ExportOptionsView(viewModel: exportViewModel)
}
```

### Export Multiple Cards

```swift
// Configure with all cards
exportViewModel.configureMultipleCards(cards)

// Or with preselected cards
let selectedIDs: Set<UUID> = [card1.id, card2.id]
exportViewModel.configureMultipleCards(allCards, preselected: selectedIDs)

// Show options
exportViewModel.showExportOptions = true
```

### Quick Export (No UI)

```swift
// Use QuickExportButton component
QuickExportButton(card: card)

// Or programmatically
let service = ExportService()
let result = await service.exportCard(card, format: .vcard)

switch result {
case .success(let url):
    // Present share sheet with url
case .failure(let error):
    // Show error
}
```

## API Reference

### VCardExporter

```swift
// Export single card
let vcard = VCardExporter.exportCard(businessCard)

// Export multiple cards
let vcard = VCardExporter.exportMultipleCards([card1, card2])

// Export ParsedContact
let vcard = VCardExporter.exportParsedContact(parsedContact)

// Generate filename
let filename = VCardExporter.generateFilename(for: card)
// Returns: "John Doe.vcf"
```

### CSVExporter

```swift
// Export with default fields
let csv = CSVExporter.exportCard(card)

// Export with custom fields
let fields: [CSVExporter.ExportField] = [.fullName, .email, .phoneNumber]
let csv = CSVExporter.exportCard(card, fields: fields)

// Export all fields
let csv = CSVExporter.exportCardsComplete([card1, card2])

// Generate preview
let preview = CSVExporter.generatePreview(cards, maxRows: 5)
```

### ExportService

```swift
@MainActor
class MyClass {
    private let exportService = ExportService()

    func exportCards() async {
        // Export to vCard
        let result = await exportService.exportCards(
            cards,
            format: .vcard
        )

        // Export to CSV with custom fields
        let result = await exportService.exportCards(
            cards,
            format: .csv,
            fields: [.fullName, .email]
        )

        // Handle result
        switch result {
        case .success(let url):
            showShareSheet(url: url)
        case .failure(let error):
            showError(error)
        }
    }
}
```

### ExportViewModel

```swift
@StateObject private var viewModel = ExportViewModel()

// Single card
viewModel.configureSingleCard(card)

// Multiple cards
viewModel.configureMultipleCards(cards)

// Customize
viewModel.selectedFormat = .csv
viewModel.selectedFields = [.fullName, .email, .phoneNumber]

// Export
Task {
    await viewModel.performExport()
}

// Generate preview
viewModel.generatePreview()

// Check if can export
if viewModel.canExport {
    // Export button enabled
}
```

## Field Reference

### CSV Fields

```swift
enum ExportField {
    case fullName           // Required
    case givenName          // First name
    case familyName         // Last name
    case jobTitle
    case company
    case email
    case phoneNumber
    case website
    case address
    case notes
    case dateScanned
    case dateModified
    case tags               // Semicolon-separated
    case isFavorite         // Yes/No
    case savedToContacts    // Yes/No
}
```

### Default Fields

```swift
CSVExporter.defaultFields = [
    .fullName,
    .jobTitle,
    .company,
    .email,
    .phoneNumber,
    .website,
    .address
]
```

## Format Reference

### vCard 4.0

```
BEGIN:VCARD
VERSION:4.0
N:Doe;John;;;
FN:John Doe
ORG:Company Name
TITLE:Job Title
EMAIL;TYPE=WORK:email@example.com
TEL;TYPE=CELL:+15551234567
URL;TYPE=WORK:https://example.com
ADR;TYPE=WORK:;;Street;City;State;12345;Country
NOTE:Notes here
REV:2024-11-05T14:30:00Z
PRODID:-//Deets//Business Card Scanner//EN
END:VCARD
```

### CSV

```csv
Full Name,Job Title,Company,Email,Phone Number
John Doe,Engineer,Tech Corp,john@tech.com,+15551234567
Jane Smith,Designer,Design Co,jane@design.com,+15559876543
```

## Error Handling

### Error Types

```swift
enum ExportError: LocalizedError, Equatable {
    case noCards            // No cards selected
    case invalidFormat      // Invalid export format
    case fileCreationFailed // File system error
    case encodingFailed     // UTF-8 encoding error
}
```

### Error Messages

```swift
switch error {
case .noCards:
    // "No cards selected for export"
case .invalidFormat:
    // "Invalid export format"
case .fileCreationFailed:
    // "Failed to create export file"
case .encodingFailed:
    // "Failed to encode export data"
}
```

## Common Patterns

### Pattern 1: Export Button in Detail View

```swift
struct CardDetailView: View {
    let card: BusinessCard
    @StateObject private var exportViewModel = ExportViewModel()

    var body: some View {
        VStack {
            // Card content

            Button("Export") {
                exportViewModel.configureSingleCard(card)
                exportViewModel.showExportOptions = true
            }
        }
        .sheet(isPresented: $exportViewModel.showExportOptions) {
            ExportOptionsView(viewModel: exportViewModel)
        }
    }
}
```

### Pattern 2: Export Menu in List View

```swift
struct CardListView: View {
    let cards: [BusinessCard]
    @StateObject private var exportViewModel = ExportViewModel()

    var body: some View {
        List(cards) { card in
            CardRow(card: card)
        }
        .toolbar {
            Menu {
                Button("Export All") {
                    exportViewModel.configureMultipleCards(cards)
                    exportViewModel.showExportOptions = true
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .sheet(isPresented: $exportViewModel.showExportOptions) {
            ExportOptionsView(viewModel: exportViewModel)
        }
    }
}
```

### Pattern 3: Programmatic Export

```swift
class DataExporter {
    private let exportService = ExportService()

    func exportToVCard(_ cards: [BusinessCard]) async -> URL? {
        let result = await exportService.exportCards(
            cards,
            format: .vcard
        )

        if case .success(let url) = result {
            return url
        }
        return nil
    }
}
```

### Pattern 4: Custom Field Selection

```swift
struct CustomExportView: View {
    @StateObject private var exportViewModel = ExportViewModel()

    var body: some View {
        VStack {
            // Setup
            .onAppear {
                exportViewModel.selectedFormat = .csv
                exportViewModel.selectedFields = [
                    .fullName,
                    .email,
                    .phoneNumber,
                    .company
                ]
            }

            Button("Export Custom") {
                Task {
                    await exportViewModel.performExport()
                }
            }
        }
        .sheet(isPresented: $exportViewModel.showShareSheet) {
            if let url = exportViewModel.exportedFileURL {
                ExportShareSheet(fileURL: url, onDismiss: nil)
            }
        }
    }
}
```

## File Locations

```
Services/Export/
├── VCardExporter.swift    # vCard export engine
├── CSVExporter.swift      # CSV export engine
└── ExportService.swift    # Unified export service

ViewModels/
└── ExportViewModel.swift  # Export UI state

Views/
└── ExportOptionsView.swift # Export configuration UI

DeetsTests/
└── ExportTests.swift      # Test suite

Examples/
└── ExportExamples.swift   # Usage examples
```

## Testing

### Run Tests

```bash
swift test --filter ExportTests
```

### Individual Test Categories

```bash
# vCard tests
swift test --filter ExportTests.testVCard

# CSV tests
swift test --filter ExportTests.testCSV

# Integration tests
swift test --filter ExportTests.testExportService
```

## Debugging

### Enable Debug Output

```swift
// In VCardExporter
print("vCard output:")
print(vcard)

// In CSVExporter
print("CSV output:")
print(csv)

// In ExportService
print("Export progress: \\(exportService.exportProgress)")
print("Export error: \\(exportService.lastExportError)")
```

### Common Issues

**Issue:** Export button disabled
- Check: `viewModel.canExport` (requires selected cards and fields)

**Issue:** Share sheet not appearing
- Check: `exportViewModel.showShareSheet` is true
- Check: `exportViewModel.exportedFileURL` is not nil

**Issue:** Character encoding issues
- Solution: All exporters use UTF-8 encoding
- Check: Special characters are properly escaped

**Issue:** Missing fields in CSV
- Check: Field is in `selectedFields` set
- Check: Field has non-empty value in card

## Performance Tips

1. **Preview before large exports**
   ```swift
   viewModel.generatePreview() // Shows first 5 rows
   ```

2. **Use appropriate fields for CSV**
   ```swift
   // Only export what you need
   let fields: [CSVExporter.ExportField] = [.fullName, .email]
   ```

3. **Monitor progress**
   ```swift
   exportService.exportProgress // 0.0 to 1.0
   ```

4. **Batch exports**
   - Recommended limit: 5,000 cards
   - Consider splitting larger exports

## Accessibility

All components support:
- ✅ VoiceOver
- ✅ Dynamic Type
- ✅ Accessibility labels
- ✅ Accessibility hints
- ✅ Semantic structure

Example:
```swift
Button("Export") { }
    .accessibilityLabel("Export business card")
    .accessibilityHint("Opens export options with format selection")
```

## See Also

- [Export Feature Guide](Export-Feature-Guide.md) - Complete documentation
- [ExportExamples.swift](../Examples/ExportExamples.swift) - Code examples
- [ExportTests.swift](../DeetsTests/ExportTests.swift) - Test examples
- [RFC 6350](https://datatracker.ietf.org/doc/html/rfc6350) - vCard specification
- [RFC 4180](https://datatracker.ietf.org/doc/html/rfc4180) - CSV specification
