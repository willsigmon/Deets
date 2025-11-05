# Deets - Data Flow Pipeline

## Overview

This document details the complete data flow pipeline for Deets, from business card capture to export. Every step is designed for privacy, performance, and reliability.

---

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      CAPTURE PHASE                               │
├─────────────────────────────────────────────────────────────────┤
│ 1. Camera Capture (VisionKit)                                    │
│    └─> VNDocumentCameraViewController                            │
│        ├─> Auto-detection of card boundaries                     │
│        ├─> Auto-crop and perspective correction                  │
│        └─> Output: UIImage (high-res, normalized)                │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PREPROCESSING PHASE                           │
├─────────────────────────────────────────────────────────────────┤
│ 2. Image Optimization (PhotoService)                             │
│    └─> Input: Raw UIImage from camera                            │
│        ├─> Resize if > 2048px (performance)                      │
│        ├─> Contrast enhancement (better OCR accuracy)            │
│        ├─> Rotation normalization (text upright)                 │
│        └─> Output: Optimized UIImage                             │
│                                                                   │
│ 3. Photo Storage (PhotoService)                                  │
│    └─> Save to Documents/BusinessCards/{UUID}.jpg                │
│        ├─> JPEG compression (quality: 0.8)                       │
│        ├─> Generate thumbnail (150x150, for list view)           │
│        └─> Output: photoPath (String)                            │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                        OCR PHASE                                 │
├─────────────────────────────────────────────────────────────────┤
│ 4. Text Recognition (OCRService)                                 │
│    └─> VNRecognizeTextRequest (VisionKit)                        │
│        ├─> Recognition level: accurate (not fast)                │
│        ├─> Languages: [en-US] (configurable)                     │
│        ├─> Custom words: common business terms                   │
│        └─> Output: RecognizedText                                │
│            ├─> observations: [VNRecognizedTextObservation]       │
│            ├─> confidence scores per word                        │
│            └─> bounding boxes (for UI visualization)             │
│                                                                   │
│ 5. Text Parsing (OCRService.Parser)                              │
│    └─> Input: RecognizedText                                     │
│        ├─> Extract patterns via RegEx + Heuristics               │
│        │   ├─> Email: RFC 5322 pattern                           │
│        │   ├─> Phone: E.164 + local formats                      │
│        │   ├─> URL: http(s):// or www. patterns                  │
│        │   ├─> Name: Title case, first observations              │
│        │   ├─> Company: Usually second line, all-caps hints      │
│        │   └─> Address: Multi-line, zip code anchors             │
│        │                                                          │
│        ├─> Confidence Scoring                                    │
│        │   ├─> High (>0.9): Auto-fill field                      │
│        │   ├─> Medium (0.7-0.9): Suggest with warning            │
│        │   └─> Low (<0.7): Show as optional, highlight           │
│        │                                                          │
│        └─> Output: ParsedBusinessCard                            │
│            ├─> fields: [String: String?]                         │
│            ├─> confidence: [String: Double]                      │
│            └─> rawText: String (for debugging)                   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    VALIDATION PHASE                              │
├─────────────────────────────────────────────────────────────────┤
│ 6. User Review & Editing (ContactEditView)                       │
│    └─> Present parsed data to user                               │
│        ├─> Highlight low-confidence fields (yellow)              │
│        ├─> Allow manual corrections                              │
│        ├─> Validate email format                                 │
│        ├─> Validate phone format                                 │
│        └─> Mark as isManuallyEdited if user changes anything     │
│                                                                   │
│ 7. Data Validation (ViewModel)                                   │
│    └─> Pre-save validation                                       │
│        ├─> At least one of: name, company, email, phone          │
│        ├─> Valid email format (if provided)                      │
│        ├─> Valid phone format (if provided)                      │
│        ├─> Valid URL format (if provided)                        │
│        └─> Trim whitespace, normalize formatting                 │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PERSISTENCE PHASE                             │
├─────────────────────────────────────────────────────────────────┤
│ 8. Model Creation (DatabaseService)                              │
│    └─> Create BusinessCard model                                 │
│        ├─> id: UUID()                                            │
│        ├─> createdAt: Date()                                     │
│        ├─> updatedAt: Date()                                     │
│        ├─> photoPath: String (from step 3)                       │
│        ├─> rawOCRText: String (from step 5)                      │
│        ├─> ocrConfidence: Double (average)                       │
│        ├─> isManuallyEdited: Bool                                │
│        └─> All parsed fields                                     │
│                                                                   │
│ 9. SwiftData Persistence (DatabaseService)                       │
│    └─> Save to modelContext                                      │
│        ├─> Insert BusinessCard into context                      │
│        ├─> context.save() → persistent store                     │
│        ├─> If iCloud enabled: sync to CloudKit                   │
│        └─> Output: Saved BusinessCard (with persistent ID)       │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      RETRIEVAL PHASE                             │
├─────────────────────────────────────────────────────────────────┤
│ 10. Query & Display (ContactListView)                            │
│     └─> @Query(sort: \BusinessCard.createdAt, order: .reverse)   │
│         ├─> Real-time updates (SwiftData auto-refresh)           │
│         ├─> Search filtering (name, company, email)              │
│         ├─> Tag filtering (optional)                             │
│         └─> Lazy loading of photos (thumbnails)                  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                       EXPORT PHASE                               │
├─────────────────────────────────────────────────────────────────┤
│ 11. Export to Apple Contacts (ExportService)                     │
│     └─> Input: [BusinessCard]                                    │
│         ├─> Request CNContactStore authorization                 │
│         ├─> Convert BusinessCard → CNMutableContact              │
│         │   ├─> givenName, familyName (parse fullName)           │
│         │   ├─> organizationName (company)                       │
│         │   ├─> jobTitle                                         │
│         │   ├─> emailAddresses: [CNLabeledValue]                 │
│         │   ├─> phoneNumbers: [CNLabeledValue]                   │
│         │   ├─> urlAddresses: [CNLabeledValue]                   │
│         │   └─> postalAddresses: [CNLabeledValue]                │
│         │                                                         │
│         ├─> Duplicate Detection                                  │
│         │   ├─> Search by email (exact match)                    │
│         │   ├─> Search by phone (normalized match)               │
│         │   └─> Prompt user: merge, skip, or create new          │
│         │                                                         │
│         ├─> Batch Save (CNSaveRequest)                           │
│         │   ├─> saveRequest.add(contact, toContainerWithID: nil) │
│         │   └─> try contactStore.execute(saveRequest)            │
│         │                                                         │
│         └─> Update BusinessCard.isExportedToContacts = true      │
│             └─> Save back to SwiftData                           │
│                                                                   │
│ 12. Export to VCF (ExportService)                                │
│     └─> Input: [BusinessCard]                                    │
│         ├─> Convert BusinessCard → CNContact (same as above)     │
│         ├─> Serialize to vCard format                            │
│         │   └─> CNContactVCardSerialization.data(...)            │
│         ├─> Write to temp file                                   │
│         │   └─> FileManager.temporaryDirectory/export.vcf        │
│         └─> Output: URL (for ShareSheet)                         │
│                                                                   │
│ 13. Export to CSV (ExportService)                                │
│     └─> Input: [BusinessCard]                                    │
│         ├─> Generate CSV header row                              │
│         │   └─> "Name,Company,Title,Email,Phone,Website,..."     │
│         ├─> Generate CSV data rows                               │
│         │   ├─> Escape commas, quotes                            │
│         │   └─> UTF-8 encoding                                   │
│         ├─> Write to temp file                                   │
│         │   └─> FileManager.temporaryDirectory/export.csv        │
│         └─> Output: URL (for ShareSheet)                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Detailed Pipeline Stages

### Stage 1: Capture

**Entry Point**: User taps "Scan Card" button

**Technology**: VisionKit's `VNDocumentCameraViewController`

**Process**:
1. Present camera interface
2. User positions business card in frame
3. VisionKit auto-detects document boundaries
4. User taps capture button (or auto-capture triggers)
5. VisionKit applies perspective correction
6. Output: Cropped, normalized UIImage

**Error Handling**:
- Camera permission denied → Show permission prompt
- Camera unavailable → Fallback to photo picker
- User cancels → Return to previous screen

**Performance**: <1s from capture to preview

---

### Stage 2: Preprocessing

**Purpose**: Optimize image for OCR accuracy

**PhotoService.optimizeForOCR(image: UIImage) -> UIImage**

```swift
1. Check image dimensions
   ├─> If width/height > 2048px: resize proportionally
   └─> Maintain aspect ratio

2. Convert to grayscale
   └─> Better OCR accuracy for text detection

3. Enhance contrast
   ├─> Apply adaptive histogram equalization
   └─> Improve text/background separation

4. Normalize rotation
   ├─> Detect text orientation via VisionKit
   └─> Rotate to upright position

5. Return optimized image
```

**Storage**:
```swift
PhotoService.savePhoto(image: UIImage, contactID: UUID) -> String

1. Generate file path
   └─> Documents/BusinessCards/{contactID}.jpg

2. Compress to JPEG (quality: 0.8)
   └─> Balance quality vs storage

3. Write to disk
   └─> FileManager.default.write(imageData, to: url)

4. Generate thumbnail (async)
   ├─> Resize to 150x150px
   └─> Save to Documents/BusinessCards/Thumbnails/{contactID}.jpg

5. Return photoPath: "BusinessCards/{contactID}.jpg"
```

**Performance**: <500ms for save + thumbnail generation

---

### Stage 3: OCR & Parsing

**OCRService.recognizeText(from image: UIImage) -> RecognizedText**

```swift
1. Create VNRecognizeTextRequest
   ├─> recognitionLevel = .accurate (not .fast)
   ├─> recognitionLanguages = ["en-US"] // TODO: Support more
   ├─> usesLanguageCorrection = true
   └─> customWords = ["LinkedIn", "CEO", "CFO", ...] // Common business terms

2. Create request handler
   └─> VNImageRequestHandler(cgImage: image.cgImage)

3. Perform request
   └─> try handler.perform([request])

4. Extract observations
   └─> request.results as? [VNRecognizedTextObservation]

5. Map to RecognizedText
   └─> struct RecognizedText {
           let observations: [VNRecognizedTextObservation]
           let fullText: String // All text concatenated
           let lines: [String]  // Grouped by line
       }

6. Return RecognizedText
```

**OCRService.parseBusinessCard(from text: RecognizedText) -> BusinessCard**

```swift
1. Initialize empty BusinessCard

2. Parse Email
   ├─> Regex: [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}
   ├─> Confidence: observation.topCandidates(1).first?.confidence
   └─> businessCard.email = extractedEmail

3. Parse Phone
   ├─> Regex: Multiple patterns (US, international, with/without formatting)
   ├─> Normalize to E.164 format (+1234567890)
   └─> businessCard.phone = extractedPhone

4. Parse URL/Website
   ├─> Regex: (https?://)?(www\.)?[a-z0-9]+\.[a-z]{2,}
   └─> businessCard.website = extractedURL

5. Parse Name (Heuristic)
   ├─> Usually first line or largest text
   ├─> Title case (not all caps)
   └─> businessCard.fullName = extractedName

6. Parse Company (Heuristic)
   ├─> Often second line
   ├─> May be all caps or bold (detect via font in future)
   └─> businessCard.company = extractedCompany

7. Parse Job Title (Heuristic)
   ├─> Contains keywords: CEO, Manager, Director, Engineer, etc.
   ├─> Usually near name
   └─> businessCard.jobTitle = extractedTitle

8. Parse Address (Heuristic)
   ├─> Multi-line text containing zip code pattern
   ├─> Split into street, city, state, zip
   └─> businessCard.address = extractedAddress

9. Store metadata
   ├─> businessCard.rawOCRText = text.fullText
   ├─> businessCard.ocrConfidence = averageConfidence
   └─> businessCard.isManuallyEdited = false

10. Return BusinessCard
```

**Confidence Scoring**:
```
High confidence (>0.9): Green indicator, auto-filled
Medium confidence (0.7-0.9): Yellow indicator, review suggested
Low confidence (<0.7): Red indicator, manual entry recommended
```

**Performance**:
- OCR: 1-3s depending on image complexity
- Parsing: <100ms

---

### Stage 4: Validation & User Review

**ContactEditView Presentation**

```swift
1. Display parsed data in editable form
   ├─> Name field (with confidence indicator)
   ├─> Company field
   ├─> Job Title field
   ├─> Email field (with format validation)
   ├─> Phone field (with format validation)
   ├─> Website field
   ├─> Address fields
   └─> Notes field (optional)

2. Real-time validation
   ├─> Email: RFC 5322 regex
   ├─> Phone: E.164 pattern
   ├─> URL: Valid URL format
   └─> Show inline errors if invalid

3. Confidence visualization
   ├─> Green checkmark: High confidence
   ├─> Yellow warning: Medium confidence
   ├─> Red exclamation: Low confidence
   └─> Tap to see OCR raw text for that field

4. User edits
   └─> Set isManuallyEdited = true on any change

5. Save button enabled when:
   └─> At least one of: name, company, email, phone is filled
```

**ViewModel Validation**:
```swift
ContactEditViewModel.validateBeforeSave() -> Bool

1. Check required fields
   └─> At least one of: fullName, company, email, phone

2. Validate email format (if provided)
   └─> Use NSDataDetector or regex

3. Validate phone format (if provided)
   └─> Use NSDataDetector

4. Validate URL format (if provided)
   └─> Use URLComponents validation

5. Trim whitespace from all fields

6. Return true if valid, false + show error if not
```

---

### Stage 5: Persistence

**DatabaseService.save(_ contact: BusinessCard) -> BusinessCard**

```swift
1. Set timestamps
   ├─> contact.createdAt = Date()
   └─> contact.updatedAt = Date()

2. Insert into ModelContext
   └─> modelContext.insert(contact)

3. Save context
   └─> try modelContext.save()

4. If iCloud sync enabled
   ├─> SwiftData automatically syncs to CloudKit
   └─> No additional code needed

5. Return saved contact (with persistent ID)
```

**Error Handling**:
```swift
do {
    try modelContext.save()
} catch {
    if let swiftDataError = error as? SwiftDataError {
        switch swiftDataError {
        case .uniqueConstraintViolation:
            throw AppError.duplicateContact
        case .invalidData:
            throw AppError.invalidContactData
        default:
            throw AppError.saveFailed(underlying: error)
        }
    }
}
```

**Performance**: <50ms for single contact save

---

### Stage 6: Retrieval & Display

**ContactListView Query**

```swift
@Query(
    sort: \BusinessCard.updatedAt,
    order: .reverse
) var contacts: [BusinessCard]
```

**Search Implementation**:
```swift
ContactListViewModel.search(query: String) -> [BusinessCard]

1. If query.isEmpty: return all contacts

2. Filter by multiple fields
   └─> contacts.filter { contact in
           contact.fullName?.localizedCaseInsensitiveContains(query) == true ||
           contact.company?.localizedCaseInsensitiveContains(query) == true ||
           contact.email?.localizedCaseInsensitiveContains(query) == true ||
           contact.jobTitle?.localizedCaseInsensitiveContains(query) == true
       }

3. Return filtered results
```

**Lazy Photo Loading**:
```swift
// In list row view
AsyncImage(url: thumbnailURL) { image in
    image.resizable()
} placeholder: {
    ProgressView()
}
```

**Performance**:
- List rendering: <16ms per row (60fps)
- Search: <100ms for 1000 contacts

---

### Stage 7: Export

#### Export to Apple Contacts

**ExportService.exportToContacts(_ cards: [BusinessCard]) -> ExportResult**

```swift
1. Request authorization
   └─> CNContactStore.requestAccess(for: .contacts)

2. For each BusinessCard:
   a. Convert to CNMutableContact
      ├─> Parse fullName into givenName + familyName
      │   └─> Split on space, handle middle names
      ├─> Set organizationName = company
      ├─> Set jobTitle
      ├─> Add email: CNLabeledValue(label: CNLabelWork, value: email)
      ├─> Add phone: CNLabeledValue(label: CNLabelWork, value: phone)
      ├─> Add URL: CNLabeledValue(label: CNLabelWork, value: website)
      └─> Add postal address (if available)

   b. Check for duplicates
      ├─> Search existing contacts by email
      ├─> Search existing contacts by phone
      └─> If found:
          ├─> Prompt user: "Contact exists. Merge, Skip, or Create New?"
          └─> Handle user choice

   c. Add to save request
      └─> saveRequest.add(contact, toContainerWithID: nil)

3. Execute batch save
   └─> try contactStore.execute(saveRequest)

4. Update BusinessCard records
   ├─> Set isExportedToContacts = true
   ├─> Set lastExportedAt = Date()
   └─> Save to SwiftData

5. Return ExportResult
   └─> struct ExportResult {
           let successCount: Int
           let failureCount: Int
           let duplicatesSkipped: Int
           let errors: [Error]
       }
```

**Duplicate Detection Logic**:
```swift
func findDuplicates(for card: BusinessCard) -> [CNContact] {
    var predicates: [NSPredicate] = []

    // Search by email
    if let email = card.email {
        let emailPredicate = CNContact.predicateForContacts(
            matchingEmailAddress: email
        )
        predicates.append(emailPredicate)
    }

    // Search by phone
    if let phone = card.phone {
        let phonePredicate = CNContact.predicateForContacts(
            matching: CNPhoneNumber(stringValue: phone)
        )
        predicates.append(phonePredicate)
    }

    // Fetch matching contacts
    let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    let contacts = try? contactStore.unifiedContacts(matching: compoundPredicate, keysToFetch: [])

    return contacts ?? []
}
```

**Performance**:
- Single contact: <100ms
- Batch (100 contacts): <5s

#### Export to VCF

**ExportService.exportToVCF(_ cards: [BusinessCard]) -> URL**

```swift
1. Convert all BusinessCards to [CNContact]
   └─> Use same conversion as Contacts export

2. Serialize to vCard data
   └─> let data = try CNContactVCardSerialization.data(
           with: cnContacts
       )

3. Write to temporary file
   ├─> let url = FileManager.default.temporaryDirectory
                   .appendingPathComponent("deets-export.vcf")
   └─> try data.write(to: url)

4. Return URL for sharing
   └─> Present via UIActivityViewController
```

**Performance**: <1s for 100 contacts

#### Export to CSV

**ExportService.exportToCSV(_ cards: [BusinessCard]) -> URL**

```swift
1. Generate CSV header
   └─> "Name,Company,Job Title,Email,Phone,Website,Address,City,State,Zip,Country,Notes\n"

2. For each BusinessCard, generate row
   ├─> Escape commas with quotes
   ├─> Escape quotes by doubling them
   └─> Example: "John \"Johnny\" Doe","Acme, Inc","CEO",..."

3. Combine into single string

4. Convert to Data (UTF-8)
   └─> let data = csvString.data(using: .utf8)

5. Write to temporary file
   ├─> let url = FileManager.default.temporaryDirectory
                   .appendingPathComponent("deets-export.csv")
   └─> try data.write(to: url)

6. Return URL for sharing
```

**Performance**: <500ms for 100 contacts

---

## Error Recovery Strategies

### OCR Failures

**Scenario**: VisionKit fails to recognize text

**Recovery**:
1. Show error: "Unable to read card. Try again with better lighting?"
2. Offer manual entry option
3. Keep photo saved for later retry

### Duplicate Contacts

**Scenario**: Contact already exists in Apple Contacts

**Recovery**:
1. Show duplicate detection UI
2. Options:
   - **Merge**: Update existing contact with new data
   - **Skip**: Don't export this one
   - **Create New**: Create duplicate anyway
3. Remember user preference for batch exports

### Export Permission Denied

**Scenario**: User denies Contacts access

**Recovery**:
1. Show explanation: "Deets needs Contacts access to export"
2. Offer alternative: "Export to VCF instead"
3. Deep link to Settings app

### iCloud Sync Conflicts

**Scenario**: Same contact edited on two devices

**Recovery**:
1. SwiftData automatic conflict resolution (last-write-wins)
2. For critical conflicts, show merge UI
3. Keep conflict history for user review

---

## Performance Benchmarks

| Operation | Target | Acceptable | Unacceptable |
|-----------|--------|------------|--------------|
| Scan capture | <1s | <2s | >3s |
| OCR processing | <2s | <5s | >10s |
| Save contact | <50ms | <200ms | >500ms |
| Load 100 contacts | <100ms | <300ms | >1s |
| Search 1000 contacts | <100ms | <300ms | >1s |
| Export to Contacts (100) | <5s | <10s | >20s |
| Export to VCF (100) | <1s | <3s | >5s |

---

## Privacy Guarantees

### Data Flow Privacy Checkpoints

1. **Capture**: Camera permission requested only when scanning
2. **Storage**: Photos stored in app's sandboxed Documents (user-accessible)
3. **OCR**: 100% on-device via VisionKit (no cloud API calls)
4. **Persistence**: SwiftData stores locally (iCloud opt-in only)
5. **Export**: Contacts permission requested only when exporting

### No Data Leaves Device Unless:

- ✅ User enables iCloud sync (SwiftData → CloudKit)
- ✅ User exports to Apple Contacts (explicit action)
- ✅ User shares VCF/CSV via ShareSheet (explicit action)

### Data Deletion

**User deletes contact**:
1. Delete BusinessCard from SwiftData → cascades to iCloud if synced
2. Delete photo file from Documents/BusinessCards/
3. Overwrite photo data before deletion (security)
4. If exported to Contacts, prompt: "Also delete from Contacts app?"

---

## Future Enhancements

### Batch Scanning (v1.1)

```
Pipeline Addition:
- Scan multiple cards in one session
- Queue for background OCR processing
- Progress indicator for batch
- Review all before saving
```

### QR Code Detection (v1.2)

```
Pipeline Addition (after step 4):
- Detect QR codes on cards (VisionKit)
- Parse vCard QR codes directly
- Skip OCR if QR contains full data
```

### AI-Powered Parsing (v2.0)

```
Pipeline Enhancement (step 5):
- Replace regex with CoreML model
- Train on business card dataset
- Higher accuracy for edge cases
- Support more languages
```

### LinkedIn Integration (v2.0)

```
Pipeline Addition (after step 6):
- Search LinkedIn by name + company
- Auto-fill missing fields (with permission)
- Link to LinkedIn profile
```

---

## Summary

The Deets pipeline is optimized for:

1. **Privacy**: On-device processing, explicit permissions
2. **Performance**: <5s from scan to save in typical case
3. **Accuracy**: VisionKit OCR + smart heuristics
4. **Reliability**: Comprehensive error handling
5. **User Control**: Review before save, manual editing

**Total Time: Scan → Save → Export**
- Best case: ~8s (fast scan + high confidence + no review)
- Typical case: ~20s (scan + review + minor edits)
- Worst case: ~60s (re-scan + low confidence + full manual entry)

---

**Version**: 1.0.0
**Last Updated**: 2025-11-05
**Author**: ORION (Chief Architect)
