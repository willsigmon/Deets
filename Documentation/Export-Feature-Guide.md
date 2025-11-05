# Export Feature Guide

## Overview

The Deets export feature allows users to export business card data in two industry-standard formats:
- **vCard (.vcf)** - Universal contact format compatible with all devices
- **CSV (.csv)** - Spreadsheet format for Excel, Google Sheets, etc.

## Architecture

### Core Components

#### 1. **VCardExporter** (`Services/Export/VCardExporter.swift`)
- Exports contacts to vCard 4.0 format (RFC 6350 compliant)
- Supports both `BusinessCard` and `ParsedContact` models
- Handles proper escaping of special characters
- Includes metadata (revision date, product ID)
- Supports batch export (multiple contacts in single file)

**Features:**
- Full name (structured and formatted)
- Organization and job title
- Phone numbers (with type labels)
- Email addresses (with type labels)
- URLs/websites (with type labels)
- Postal addresses (structured format)
- Social profiles (X-SOCIALPROFILE extension)
- Birthday
- Notes
- Revision date

#### 2. **CSVExporter** (`Services/Export/CSVExporter.swift`)
- Exports business cards to CSV format
- Customizable field selection
- Proper CSV escaping (quotes, commas, newlines)
- ISO 8601 date formatting
- Preview generation

**Available Fields:**
- Full Name (required)
- First Name / Last Name (extracted from full name)
- Job Title
- Company
- Email
- Phone Number
- Website
- Address
- Notes
- Date Scanned
- Date Modified
- Tags
- Favorite status
- Saved to Contacts status

#### 3. **ExportService** (`Services/Export/ExportService.swift`)
- Unified export interface
- Handles file creation and temporary storage
- Progress tracking
- Error handling
- Share sheet integration

#### 4. **ExportViewModel** (`ViewModels/ExportViewModel.swift`)
- Manages export UI state
- Format selection
- Field customization (CSV)
- Card selection (single, multiple, all)
- Preview generation

#### 5. **ExportOptionsView** (`Views/ExportOptionsView.swift`)
- Export configuration UI
- Format picker (vCard/CSV)
- Field selection for CSV
- Preview functionality
- Share sheet presentation

## Usage Examples

### Single Card Export

#### From Card Detail View
```swift
struct CardDetailView: View {
    let card: BusinessCard
    @StateObject private var exportViewModel = ExportViewModel()

    var body: some View {
        VStack {
            // ... card content ...

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

#### Quick Export (No Options)
```swift
QuickExportButton(card: card)
```

### Multiple Cards Export

```swift
struct CardListView: View {
    let cards: [BusinessCard]
    @StateObject private var exportViewModel = ExportViewModel()

    var body: some View {
        List(cards) { card in
            CardRow(card: card)
        }
        .toolbar {
            Button("Export All") {
                exportViewModel.configureMultipleCards(cards)
                exportViewModel.showExportOptions = true
            }
        }
        .sheet(isPresented: $exportViewModel.showExportOptions) {
            ExportOptionsView(viewModel: exportViewModel)
        }
    }
}
```

### Programmatic Export

```swift
class DataManager {
    private let exportService = ExportService()

    func exportToVCard(_ cards: [BusinessCard]) async -> URL? {
        let result = await exportService.exportCards(cards, format: .vcard)

        switch result {
        case .success(let url):
            return url
        case .failure(let error):
            print("Export failed: \\(error)")
            return nil
        }
    }

    func exportToCSV(_ cards: [BusinessCard], fields: [CSVExporter.ExportField]) async -> URL? {
        let result = await exportService.exportCards(cards, format: .csv, fields: fields)

        switch result {
        case .success(let url):
            return url
        case .failure(let error):
            print("Export failed: \\(error)")
            return nil
        }
    }
}
```

## vCard Format Details

### Example vCard Output

```
BEGIN:VCARD
VERSION:4.0
N:Doe;John;;;
FN:John Doe
ORG:Tech Corp
TITLE:Software Engineer
EMAIL;TYPE=WORK:john.doe@techcorp.com
TEL;TYPE=WORK:+15551234567
URL;TYPE=WORK:https://techcorp.com
ADR;TYPE=WORK:;;123 Main St;San Francisco;CA;94102;USA
NOTE:Met at conference
REV:2024-11-05T14:30:22Z
PRODID:-//Deets//Business Card Scanner//EN
END:VCARD
```

### Character Escaping

vCard format requires escaping of special characters:
- Comma (`,`) → `\\,`
- Semicolon (`;`) → `\\;`
- Newline (`\\n`) → `\\\\n`
- Backslash (`\\`) → `\\\\`

### Type Labels

Phone and email types are converted from CNLabel to vCard TYPE:
- `CNLabelHome` → `HOME`
- `CNLabelWork` → `WORK`
- `CNLabelPhoneNumberMobile` → `CELL`
- `CNLabelPhoneNumberMain` → `VOICE`
- `CNLabelPhoneNumberHomeFax` → `FAX`

## CSV Format Details

### Example CSV Output

```csv
Full Name,Job Title,Company,Email,Phone Number,Website,Address
John Doe,Software Engineer,Tech Corp,john.doe@techcorp.com,+1 (555) 123-4567,https://techcorp.com,"123 Main St, San Francisco, CA 94102"
Jane Smith,Product Designer,Design Co,jane@designco.com,+1 (555) 987-6543,https://designco.com,
```

### Character Escaping

CSV format requires:
- Values containing commas, quotes, or newlines are wrapped in double quotes
- Double quotes within values are escaped by doubling them (`"` → `""`)

Example:
```
Input:  Company, Inc
Output: "Company, Inc"

Input:  He said "Hello"
Output: "He said ""Hello"""
```

### Field Customization

Users can select which fields to include:
```swift
let fields: [CSVExporter.ExportField] = [
    .fullName,
    .email,
    .phoneNumber,
    .company
]

let csv = CSVExporter.exportCard(card, fields: fields)
```

Default fields (used if not specified):
- Full Name
- Job Title
- Company
- Email
- Phone Number
- Website
- Address

## File Generation

### Filename Patterns

**Single Card:**
- vCard: `{Name}.vcf` (e.g., "John Doe.vcf")
- CSV: `{Name}.csv` (e.g., "John Doe.csv")

**Multiple Cards:**
- vCard: `Deets Export - {count} contacts - {date}.vcf`
- CSV: `Deets Export - {count} contacts - {date}.csv`

### Temporary Files

Export files are created in the system temporary directory:
```swift
FileManager.default.temporaryDirectory
```

Files are automatically cleaned up by the system.

## Share Sheet Integration

The export service integrates with iOS share sheet (UIActivityViewController):

```swift
ExportShareSheet(fileURL: exportedFileURL) {
    // Called when share sheet dismisses
}
```

Available share options:
- AirDrop
- Messages
- Mail
- Files app
- Third-party apps (Dropbox, Google Drive, etc.)

## Error Handling

Export operations can fail with these errors:

```swift
enum ExportError: LocalizedError {
    case noCards           // No cards selected
    case invalidFormat     // Invalid export format
    case fileCreationFailed // File system error
    case encodingFailed    // UTF-8 encoding error
}
```

Error handling example:
```swift
let result = await exportService.exportCards(cards, format: .vcard)

switch result {
case .success(let url):
    // Show share sheet
    showShareSheet(url: url)

case .failure(let error):
    // Show error alert
    showAlert(error.localizedDescription)
}
```

## Testing

Comprehensive test suite available in `DeetsTests/ExportTests.swift`:

- vCard export validation
- CSV export validation
- Character escaping tests
- Multiple card export tests
- Filename generation tests
- Integration tests

Run tests:
```bash
swift test --filter ExportTests
```

## Performance Considerations

### Memory Usage
- Exports are generated in-memory as strings
- For large exports (1000+ cards), consider batching
- Temporary files are cleaned up automatically

### Optimization Tips
1. Use appropriate field selection for CSV exports
2. Consider preview before large exports
3. Export progress tracking available via `ExportService.exportProgress`

### Recommended Limits
- Single export: No practical limit
- Batch export: Up to 5,000 cards recommended
- CSV preview: First 5 rows by default

## Accessibility

Export feature is fully accessible:
- VoiceOver labels on all controls
- Accessibility hints for interactive elements
- Proper grouping of related controls
- Dynamic Type support

## Future Enhancements

Potential future additions:
- [ ] PDF export format
- [ ] QR code generation
- [ ] Custom export templates
- [ ] Scheduled/automated exports
- [ ] Cloud backup integration
- [ ] Export to specific contacts apps
- [ ] Advanced filtering for batch exports
- [ ] Export statistics/analytics

## Related Documentation

- [vCard 4.0 Specification (RFC 6350)](https://datatracker.ietf.org/doc/html/rfc6350)
- [CSV Format (RFC 4180)](https://datatracker.ietf.org/doc/html/rfc4180)
- Apple Contacts Framework Documentation
- iOS Share Sheet Best Practices

## Support

For issues or questions:
- Check test cases in `ExportTests.swift`
- Review examples in `Examples/ExportExamples.swift`
- See inline documentation in source files
