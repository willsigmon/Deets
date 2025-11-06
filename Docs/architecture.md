# Deets - Architecture Documentation

## Executive Summary

Deets is a privacy-first, offline-capable business card scanning app for iOS. It leverages native Apple frameworks (VisionKit, SwiftData, Contacts) to provide fast, secure, and reliable business card digitization without requiring cloud services.

**Core Principles:**
- Privacy First: All processing happens on-device
- Offline First: Full functionality without internet
- Native Performance: SwiftUI + SwiftData for modern iOS experience
- Data Ownership: User controls all exports and integrations

---

## Architecture Overview

### Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────────────────┐
│                          SwiftUI Views                       │
│  (Scanning, Contact List, Detail, Settings)                 │
└────────────────────┬────────────────────────────────────────┘
                     │ @ObservedObject / @StateObject
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                         ViewModels                           │
│  (Business Logic, State Management, Validation)              │
└────────────────────┬────────────────────────────────────────┘
                     │ Async/Await Calls
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                         Services Layer                       │
│  ┌──────────┬──────────┬──────────┬──────────┐              │
│  │   OCR    │ Database │  Photo   │  Export  │              │
│  │ Service  │ Service  │ Service  │ Service  │              │
│  └──────────┴──────────┴──────────┴──────────┘              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data & Frameworks                         │
│  SwiftData Models  |  VisionKit  |  PhotoKit  |  Contacts   │
└─────────────────────────────────────────────────────────────┘
```

### Why MVVM?

1. **SwiftUI Native**: Perfect fit for SwiftUI's declarative paradigm
2. **Testability**: ViewModels can be unit tested without UI
3. **Separation of Concerns**: Business logic separate from UI
4. **Reusability**: ViewModels can support multiple views
5. **State Management**: Clear ownership of state and mutations

---

## Layer Breakdown

### 1. Views Layer (SwiftUI)

**Responsibility**: Render UI, capture user input, display data

**Structure:**
```
Views/
├── Scanning/
│   ├── ScannerView.swift          # VisionKit document scanner
│   ├── PreviewView.swift          # Scanned image preview
│   └── CropView.swift             # Manual crop/adjust
├── Contacts/
│   ├── ContactListView.swift      # Main list of saved cards
│   ├── ContactDetailView.swift    # Individual contact details
│   └── ContactEditView.swift      # Edit parsed data
├── Settings/
│   ├── SettingsView.swift         # App preferences
│   ├── PrivacyView.swift          # Privacy controls
│   └── ExportOptionsView.swift    # Export configurations
└── Shared/
    ├── LoadingView.swift          # Reusable loading states
    ├── ErrorView.swift            # Error presentation
    └── EmptyStateView.swift       # Empty list states
```

**Principles:**
- Views are dumb: no business logic
- Use `@StateObject` for ViewModel ownership
- Use `@ObservedObject` for passed ViewModels
- Environment objects for app-wide state
- Accessibility labels on all interactive elements

---

### 2. ViewModels Layer

**Responsibility**: Business logic, validation, state management, coordinate services

**Structure:**
```
ViewModels/
├── ScannerViewModel.swift         # Scanning flow orchestration
├── ContactListViewModel.swift     # List filtering, sorting, search
├── ContactDetailViewModel.swift   # Single contact operations
└── SettingsViewModel.swift        # App configuration
```

**Pattern:**
```swift
@MainActor
final class ScannerViewModel: ObservableObject {
    // Published state
    @Published var scannedImage: UIImage?
    @Published var parsedContact: BusinessCard?
    @Published var isProcessing = false
    @Published var error: AppError?

    // Service dependencies (injected)
    private let ocrService: OCRServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    private let photoService: PhotoServiceProtocol

    // Public API
    func processScannedImage(_ image: UIImage) async
    func saveContact() async throws
    func retryOCR() async
}
```

**Principles:**
- All ViewModels conform to `ObservableObject`
- Use `@MainActor` for UI-bound ViewModels
- Dependency injection for services (testability)
- Clear error handling with typed errors
- Async/await for all async operations

---

### 3. Services Layer

**Responsibility**: Encapsulate complex operations, interact with frameworks, provide clean APIs

#### 3.1 OCRService

**Purpose**: Extract text from business card images using VisionKit

```swift
protocol OCRServiceProtocol {
    func recognizeText(from image: UIImage) async throws -> RecognizedText
    func parseBusinessCard(from text: RecognizedText) async throws -> BusinessCard
}

final class OCRService: OCRServiceProtocol {
    // Uses VisionKit's VNDocumentCameraViewController
    // Text recognition via VNRecognizeTextRequest
    // Smart parsing with RegEx + ML heuristics
}
```

**Features:**
- Multi-language support (configure via Settings)
- Confidence scoring for parsed fields
- Fallback to manual entry if confidence low
- Caching of recognition results

#### 3.2 DatabaseService

**Purpose**: Manage SwiftData persistence layer

```swift
protocol DatabaseServiceProtocol {
    func save(_ contact: BusinessCard) async throws
    func fetch(id: UUID) async throws -> BusinessCard?
    func fetchAll() async throws -> [BusinessCard]
    func update(_ contact: BusinessCard) async throws
    func delete(_ contact: BusinessCard) async throws
    func search(query: String) async throws -> [BusinessCard]
}

final class DatabaseService: DatabaseServiceProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    // SwiftData operations
    // Background context for heavy operations
    // Automatic conflict resolution
}
```

**Features:**
- SwiftData for modern persistence (iOS 17+)
- Background context for bulk operations
- Automatic iCloud sync (opt-in via Settings)
- Migration support for schema changes

#### 3.3 PhotoService

**Purpose**: Manage business card photos with privacy controls

```swift
protocol PhotoServiceProtocol {
    func savePhoto(_ image: UIImage, for contactID: UUID) async throws -> String
    func loadPhoto(path: String) async throws -> UIImage
    func deletePhoto(path: String) async throws
    func exportPhotos(for contacts: [BusinessCard]) async throws -> [URL]
}

final class PhotoService: PhotoServiceProtocol {
    // Stores in app's Documents directory (user-accessible)
    // Compression optimization for storage
    // Secure deletion with overwrite
}
```

**Features:**
- Local storage only (no cloud by default)
- Optimized compression (JPEG quality: 0.8)
- Secure deletion
- PhotoKit integration for user photo library export

#### 3.4 ExportService

**Purpose**: Export contacts to Apple Contacts, VCF, CSV

```swift
protocol ExportServiceProtocol {
    func exportToContacts(_ cards: [BusinessCard]) async throws -> ExportResult
    func exportToVCF(_ cards: [BusinessCard]) async throws -> URL
    func exportToCSV(_ cards: [BusinessCard]) async throws -> URL
}

final class ExportService: ExportServiceProtocol {
    private let contactStore: CNContactStore

    // CNContact conversion
    // Batch operations
    // Duplicate detection
}
```

**Features:**
- Apple Contacts framework integration
- Duplicate detection before export
- Batch export for performance
- ShareSheet integration for VCF/CSV

---

### 4. Models Layer (SwiftData)

**Responsibility**: Data models, persistence schema

```swift
@Model
final class BusinessCard {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    // Core fields
    var fullName: String?
    var company: String?
    var jobTitle: String?

    // Contact info
    var email: String?
    var phone: String?
    var website: String?

    // Address
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?

    // Metadata
    var photoPath: String?
    var notes: String?
    var tags: [String]

    // OCR metadata
    var ocrConfidence: Double?
    var rawOCRText: String?
    var isManuallyEdited: Bool

    // Privacy
    var isExportedToContacts: Bool
    var lastExportedAt: Date?

    init(id: UUID = UUID()) {
        self.id = id
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = []
        self.isManuallyEdited = false
        self.isExportedToContacts = false
    }
}
```

**Principles:**
- Immutable IDs (UUID)
- Timestamps for audit trail
- Optional fields (not all cards have all info)
- Metadata for confidence scoring
- Privacy tracking (export status)

---

## Data Flow Pipeline

### Scanning Flow

```
1. User taps "Scan Card"
   ↓
2. ScannerView presents VNDocumentCameraViewController
   ↓
3. User captures image → PreviewView
   ↓
4. ScannerViewModel.processScannedImage(image)
   ↓
5. PhotoService.savePhoto(image) → path
   ↓
6. OCRService.recognizeText(image) → RecognizedText
   ↓
7. OCRService.parseBusinessCard(text) → BusinessCard
   ↓
8. Present ContactEditView (allow manual corrections)
   ↓
9. User confirms → ScannerViewModel.saveContact()
   ↓
10. DatabaseService.save(contact)
    ↓
11. Navigate to ContactDetailView
```

### Export Flow

```
1. User selects contacts in ContactListView
   ↓
2. Taps "Export to Contacts"
   ↓
3. ContactListViewModel.exportToContacts(selected)
   ↓
4. ExportService.exportToContacts(cards)
   ↓
5. Request CNContactStore authorization
   ↓
6. Convert BusinessCard → CNContact
   ↓
7. Duplicate detection
   ↓
8. Batch save to Contacts
   ↓
9. Update BusinessCard.isExportedToContacts = true
   ↓
10. Show success/failure toast
```

---

## Privacy-First Architecture

### Principles

1. **Local Processing**: All OCR happens on-device via VisionKit
2. **User Data Ownership**: Data stored in app's Documents directory
3. **No Analytics**: Zero telemetry unless user opts in
4. **Explicit Permissions**: Request camera, contacts, photos only when needed
5. **Data Portability**: Easy export to standard formats (VCF, CSV)
6. **Secure Deletion**: Overwrite files on deletion
7. **Optional iCloud**: Sync only if user enables in Settings

### Permission Management

```swift
enum PermissionType {
    case camera          // VisionKit scanning
    case contacts        // Export to Apple Contacts
    case photoLibrary    // Save scanned cards to Photos
}

@MainActor
final class PermissionManager: ObservableObject {
    @Published var cameraStatus: PermissionStatus = .notDetermined
    @Published var contactsStatus: PermissionStatus = .notDetermined
    @Published var photosStatus: PermissionStatus = .notDetermined

    func requestPermission(_ type: PermissionType) async -> Bool
    func checkPermission(_ type: PermissionType) -> PermissionStatus
}
```

### Privacy Manifest (Info.plist)

Required usage descriptions:
- `NSCameraUsageDescription`: "Scan business cards using your camera"
- `NSContactsUsageDescription`: "Export business cards to your Contacts"
- `NSPhotoLibraryAddUsageDescription`: "Save business card images to Photos"

---

## Offline-First Strategy

### Core Capabilities (No Internet Required)

- ✅ Scan business cards (VisionKit is on-device)
- ✅ OCR text recognition (VisionKit is on-device)
- ✅ Save contacts (SwiftData is local)
- ✅ Edit contacts
- ✅ Export to Contacts, VCF, CSV
- ✅ Search and filter

### Optional Online Features (Opt-In)

- ☁️ iCloud sync (via SwiftData CloudKit integration)
- ☁️ Photo library sync (via iCloud Photos)

### Sync Strategy (If iCloud Enabled)

```swift
final class SyncService {
    private let modelContainer: ModelContainer

    // SwiftData handles sync automatically when configured with:
    // modelContainer.cloudKitContainer = "iCloud.com.sharedeets.app"

    func enableiCloudSync() async throws
    func disableiCloudSync() async throws
    func resolveConflicts(_ conflicts: [NSManagedObject]) async throws
}
```

**Conflict Resolution:**
- Last-write-wins for most fields
- Manual review for high-value conflicts (user chooses)

---

## Performance Considerations

### OCR Optimization

- **Background Processing**: Run OCR on background thread
- **Image Preprocessing**: Normalize image before OCR (contrast, rotation)
- **Caching**: Cache OCR results to avoid reprocessing
- **Progressive Enhancement**: Show low-confidence fields as suggestions

### Database Performance

- **Indexing**: Index frequently queried fields (name, company, email)
- **Batch Operations**: Use batch inserts/updates for imports
- **Lazy Loading**: Load photos on-demand, not with contact list
- **Background Context**: Use background context for heavy writes

### UI Performance

- **List Virtualization**: Use `LazyVStack` for contact list
- **Image Thumbnails**: Generate thumbnails for list view
- **Debounced Search**: Debounce search queries (300ms)
- **Optimistic Updates**: Update UI immediately, sync later

---

## Testing Strategy

### Unit Tests (Models, ViewModels, Services)

```
Tests/Unit/
├── ViewModels/
│   ├── ScannerViewModelTests.swift
│   ├── ContactListViewModelTests.swift
│   └── ContactDetailViewModelTests.swift
├── Services/
│   ├── OCRServiceTests.swift
│   ├── DatabaseServiceTests.swift
│   ├── PhotoServiceTests.swift
│   └── ExportServiceTests.swift
└── Models/
    └── BusinessCardTests.swift
```

**Coverage Goals:**
- ViewModels: 90%+
- Services: 85%+
- Models: 80%+

### UI Tests (User Flows)

```
Tests/UI/
├── ScanningFlowTests.swift      # End-to-end scanning
├── ContactManagementTests.swift # CRUD operations
├── ExportFlowTests.swift        # Export workflows
└── AccessibilityTests.swift     # VoiceOver compatibility
```

**Key Scenarios:**
- Scan card → Save → Verify in list
- Edit contact → Save → Verify changes
- Export to Contacts → Verify in Contacts app
- VoiceOver navigation

### Integration Tests

```
Tests/Integration/
├── OCRPipelineTests.swift       # VisionKit → Parser → SwiftData
└── ExportPipelineTests.swift    # SwiftData → Contacts framework
```

---

## Error Handling

### Typed Errors

```swift
enum AppError: LocalizedError {
    // OCR Errors
    case ocrFailed(underlying: Error)
    case lowConfidence(fields: [String])
    case unsupportedLanguage

    // Database Errors
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case duplicateContact

    // Export Errors
    case exportPermissionDenied
    case contactsExportFailed(underlying: Error)
    case fileExportFailed(underlying: Error)

    // Photo Errors
    case photoSaveFailed
    case photoLoadFailed
    case photoDeleteFailed

    var errorDescription: String? {
        // User-friendly messages
    }

    var recoverySuggestion: String? {
        // Actionable next steps
    }
}
```

### Error Presentation

```swift
@MainActor
final class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError = false

    func handle(_ error: Error) {
        // Convert to AppError
        // Log to console (never to remote)
        // Present to user with recovery options
    }
}
```

---

## Security Considerations

### Data Security

1. **Encryption at Rest**: SwiftData uses iOS file encryption
2. **Secure Deletion**: Overwrite photo files before deletion
3. **No Third-Party SDKs**: Avoid tracking/analytics SDKs
4. **Minimal Permissions**: Request only necessary permissions
5. **No Cloud by Default**: User must opt-in to iCloud sync

### Code Security

1. **No Hardcoded Secrets**: Use Keychain for sensitive data
2. **Input Validation**: Sanitize all user inputs
3. **Safe String Parsing**: Guard against injection in OCR parsing
4. **Dependency Auditing**: Minimal external dependencies

---

## Scalability & Future Considerations

### Planned Features (v1.x)

- Batch scanning (multi-card import)
- QR code detection on cards
- LinkedIn profile auto-fill
- AI-powered duplicate detection
- Custom fields/tags
- Export to CRM systems (Salesforce, HubSpot)

### Technical Debt Prevention

1. **Protocol-Oriented Design**: All services have protocols (easy to mock/swap)
2. **Dependency Injection**: ViewModels receive services via initializer
3. **Avoid Singletons**: Except for truly global state (PermissionManager)
4. **Clear Module Boundaries**: No cross-layer imports (View → ViewModel → Service)
5. **Documentation**: Inline docs for all public APIs

### Android Considerations

When building Android version:
- Kotlin + Jetpack Compose (mirrors SwiftUI architecture)
- Room for persistence (equivalent to SwiftData)
- ML Kit for OCR (Google's VisionKit equivalent)
- Contacts Provider API for export
- Same MVVM pattern for code consistency

---

## Development Workflow

### Git Strategy

- `main` branch: Production-ready code
- `develop` branch: Integration branch
- Feature branches: `feature/scanner-ui`, `feature/ocr-parser`
- Release branches: `release/1.0.0`

### Code Review Checklist

- [ ] All services have protocol definitions
- [ ] ViewModels use dependency injection
- [ ] Error handling for all async operations
- [ ] Accessibility labels on UI elements
- [ ] Unit tests for new business logic
- [ ] No force-unwraps in production code
- [ ] Privacy permissions properly requested
- [ ] No retention cycles (use `[weak self]`)

### CI/CD Pipeline

```yaml
# .github/workflows/ios-ci.yml
- Build with Xcode 15.4+
- Run unit tests
- Run UI tests on simulator
- SwiftLint validation
- Test coverage report (>80% required)
- Archive for TestFlight (on release branch)
```

---

## Deployment

### Minimum Requirements

- iOS 17.0+ (SwiftData requirement)
- Xcode 15.4+
- Swift 5.10+

### App Store Metadata

**Privacy Nutrition Label:**
- Data Not Collected (default config)
- Data Used to Track You: No
- Data Linked to You: Only if iCloud enabled

**Keywords:**
- Business card scanner
- Contact management
- OCR
- Networking
- Card reader

---

## Appendix: Key Dependencies

### Apple Frameworks

- **SwiftUI**: UI framework (iOS 17+)
- **SwiftData**: Persistence layer (iOS 17+)
- **VisionKit**: Document scanning + OCR
- **Contacts**: Export to Apple Contacts
- **PhotoKit**: Photo library integration
- **Combine**: Reactive programming (for complex streams)

### Third-Party Dependencies

**None planned for v1.0** - maximizes privacy, minimizes maintenance

Potential future additions:
- SwiftLint (code quality, dev-only)
- SnapshotTesting (UI regression tests, dev-only)

---

## Summary

Deets is architected for:
- **Privacy**: On-device processing, local storage, no tracking
- **Performance**: Native frameworks, optimized data flow
- **Maintainability**: Clear separation of concerns, testable code
- **Scalability**: Protocol-oriented design, easy to extend
- **User Trust**: Transparent permissions, data ownership

**Next Steps:**
1. Implement OCRService (VisionKit integration)
2. Build SwiftData models and DatabaseService
3. Create ScannerView + ScannerViewModel
4. Integrate ExportService with Contacts framework
5. Build comprehensive test suite

---

**Version**: 1.0.0
**Last Updated**: 2025-11-05
**Author**: ORION (Chief Architect)
