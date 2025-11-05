# Deets Contacts Integration - Quick Reference

## One-Liner Usage

```swift
try await ContactsService().saveContact(ContactParser.parse(ocrText))
```

## Core API

### Parse OCR Text

```swift
let parsed = ContactParser.parse(ocrText)
```

**Returns**: `ParsedContact` with extracted fields and confidence scores

### Save to Contacts

```swift
let service = ContactsService()
try await service.requestAccess()
let id = try await service.saveContact(parsed, checkDuplicates: true)
```

### Find Duplicates

```swift
if let duplicates = try await service.findDuplicates(for: parsed) {
    // Handle duplicates
}
```

### Update Existing Contact

```swift
try await service.updateContact(identifier: existingID, with: parsed)
```

## Data Model

```swift
struct ParsedContact {
    // Name
    var givenName: String?
    var familyName: String?
    var middleName: String?

    // Organization
    var organizationName: String?
    var jobTitle: String?

    // Contact methods
    var phoneNumbers: [ParsedPhoneNumber]
    var emailAddresses: [ParsedEmail]
    var urls: [ParsedURL]
    var postalAddresses: [ParsedAddress]

    // Metadata
    var confidenceScores: ConfidenceScores
    var validationFlags: ValidationFlags

    // Validation
    var isValidForSaving: Bool
}
```

## Parsing Support

### Phone Numbers
- `(555) 123-4567` - US standard
- `555-123-4567` - Dashed
- `+1 (555) 123-4567` - International
- `555-1234` - 7-digit local

### Emails
- RFC-compliant pattern
- Case normalization
- Work/home label detection

### URLs
- `https://example.com`
- `www.example.com` (auto-adds https)
- `example.com`
- Social media: LinkedIn, Twitter, Facebook, Instagram

### Addresses
- `123 Main Street`
- `San Francisco, CA 94102`
- Multi-line parsing
- State code normalization (California → CA)

### Names
- `John Smith`
- `Dr. John Michael Smith Jr.`
- Handles: O'Brien, McDonald, hyphenated names

## Formatters

```swift
// Phone
PhoneNumberFormatter.format("5551234567") // "(555) 123-4567"

// Name
NameFormatter.formatName("JOHN SMITH") // "John Smith"

// Address
AddressFormatter.formatStreet("123 main st") // "123 Main Street"

// Email
EmailFormatter.normalize("John@EXAMPLE.COM") // "john@example.com"

// URL
URLFormatter.normalize("example.com") // "https://example.com"
```

## Error Handling

```swift
do {
    try await service.saveContact(parsed)
} catch ContactsError.accessDenied {
    // Show permission settings
} catch ContactsError.duplicateFound(let contacts) {
    // Show duplicate resolution UI
} catch ContactsError.insufficientData {
    // Show edit form
} catch {
    // Handle other errors
}
```

## Validation

```swift
// Check if valid
if parsed.isValidForSaving { ... }

// Check confidence
if parsed.confidenceScores.overall > 0.7 { ... }

// Check specific fields
if parsed.validationFlags.hasValidName { ... }
if parsed.validationFlags.hasValidPhone { ... }
```

## Permission Setup

Add to `Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>Save business cards to your contacts.</string>
```

## SwiftUI Integration

```swift
@StateObject private var service = ContactsService()
@State private var parsed: ParsedContact?

Button("Save") {
    Task {
        await save()
    }
}

func save() async {
    guard let contact = parsed else { return }
    do {
        try await service.requestAccess()
        try await service.saveContact(contact)
    } catch {
        // Handle error
    }
}
```

## Duplicate Detection Strictness

```swift
// Strict: Name + contact method must match
contact.matches(parsed, strictness: .strict)

// Medium: Name OR contact method
contact.matches(parsed, strictness: .medium)

// Loose: Partial name OR contact method
contact.matches(parsed, strictness: .loose)
```

## Batch Processing

```swift
let texts = [ocrText1, ocrText2, ocrText3]
let parsed = texts.map { ContactParser.parse($0) }
let identifiers = try await service.saveContacts(parsed, checkDuplicates: true)
```

## Testing

```swift
func testParsing() {
    let text = "John Smith\njohn@example.com\n(555) 123-4567"
    let parsed = ContactParser.parse(text)

    XCTAssertEqual(parsed.givenName, "John")
    XCTAssertEqual(parsed.familyName, "Smith")
    XCTAssertTrue(parsed.isValidForSaving)
}
```

## Performance Tips

1. **Parse off main thread**:
   ```swift
   let parsed = await Task.detached {
       ContactParser.parse(ocrText)
   }.value
   ```

2. **Cache duplicate checks** for repeated operations

3. **Batch process in chunks** of 10-20 contacts

4. **Check confidence before auto-save**:
   ```swift
   if parsed.confidenceScores.overall > 0.8 {
       // Auto-save
   } else {
       // Show review UI
   }
   ```

## Common Patterns

### Parse → Validate → Save

```swift
let parsed = ContactParser.parse(ocrText)
guard parsed.isValidForSaving else { return }
try await service.saveContact(parsed)
```

### Check Duplicates → Resolve → Save

```swift
if let duplicates = try await service.findDuplicates(for: parsed) {
    let action = await showDuplicateDialog(duplicates)
    switch action {
    case .update(let id):
        try await service.updateContact(identifier: id, with: parsed)
    case .saveNew:
        try await service.saveContact(parsed, checkDuplicates: false)
    case .skip:
        return
    }
} else {
    try await service.saveContact(parsed, checkDuplicates: false)
}
```

### Batch with Progress

```swift
for (index, text) in ocrTexts.enumerated() {
    let parsed = ContactParser.parse(text)
    try await service.saveContact(parsed)
    progress = Double(index + 1) / Double(ocrTexts.count)
}
```

## Files Reference

| File | Purpose |
|------|---------|
| `ParsedContact.swift` | Data model with validation |
| `ContactParser.swift` | OCR text parsing engine |
| `Formatters.swift` | Field formatting utilities |
| `ContactsService.swift` | Contacts framework wrapper |
| `ContactParserTests.swift` | Test suite |

## Links

- **Full Documentation**: `README.md`
- **Integration Guide**: `Docs/INTEGRATION_GUIDE.md`
- **Examples**: `Examples/ContactParsingExamples.swift`
- **Tests**: `DeetsTests/ContactParserTests.swift`

---

**Version**: 1.0.0
**Last Updated**: 2025-11-05
