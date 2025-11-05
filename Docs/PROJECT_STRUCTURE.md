# Deets - Project Structure

**Complete folder hierarchy and file organization for the Deets iOS app**

Last Updated: 2025-11-05

---

## Root Directory

```
Deets/
├── App/                          # Application entry point
│   ├── DeetsApp.swift           # @main SwiftUI app
│   ├── ContentView.swift        # Root navigation container
│   └── AppConfiguration.swift   # App-wide configuration
│
├── Views/                        # SwiftUI user interface
│   ├── Scanning/                # Business card scanning
│   │   ├── ScannerView.swift          # VNDocumentCameraViewController wrapper
│   │   ├── PreviewView.swift          # Scanned image preview with edit
│   │   ├── CropView.swift             # Manual crop and adjust tools
│   │   └── ScanningCoordinator.swift  # UIViewControllerRepresentable for VisionKit
│   │
│   ├── Contacts/                # Contact management
│   │   ├── ContactListView.swift      # Main list with search/filter
│   │   ├── ContactRowView.swift       # List row component
│   │   ├── ContactDetailView.swift    # Full contact details
│   │   ├── ContactEditView.swift      # Edit/add contact form
│   │   └── ContactCardView.swift      # Card-style display
│   │
│   ├── Settings/                # App settings and preferences
│   │   ├── SettingsView.swift         # Main settings screen
│   │   ├── PrivacyView.swift          # Privacy controls
│   │   ├── ExportOptionsView.swift    # Export format preferences
│   │   ├── OCRLanguageView.swift      # OCR language selection
│   │   └── AboutView.swift            # App info and credits
│   │
│   └── Shared/                  # Reusable UI components
│       ├── LoadingView.swift          # Loading spinners
│       ├── ErrorView.swift            # Error display with retry
│       ├── EmptyStateView.swift       # Empty list states
│       ├── ConfidenceBadge.swift      # OCR confidence indicator
│       ├── PermissionPromptView.swift # Permission request UI
│       └── ShareSheet.swift           # UIActivityViewController wrapper
│
├── ViewModels/                   # State management and business logic
│   ├── ScannerViewModel.swift         # Scanning flow orchestration
│   ├── ContactListViewModel.swift     # List state, search, filter, sort
│   ├── ContactDetailViewModel.swift   # Single contact operations
│   ├── ContactEditViewModel.swift     # Form validation and save
│   ├── SettingsViewModel.swift        # App settings management
│   └── PermissionViewModel.swift      # Permission status tracking
│
├── Services/                     # Framework integration and complex operations
│   ├── OCR/                     # Optical Character Recognition
│   │   ├── OCRService.swift           # Protocol definition
│   │   ├── OCRServiceImpl.swift       # VisionKit implementation
│   │   ├── OCRParser.swift            # Business card parsing logic
│   │   ├── OCRConfidence.swift        # Confidence scoring algorithms
│   │   └── OCRLanguageConfig.swift    # Language configuration
│   │
│   ├── Database/                # Data persistence
│   │   ├── DatabaseService.swift      # Protocol definition
│   │   ├── SwiftDataService.swift     # SwiftData implementation
│   │   ├── ModelContainer+Ext.swift   # ModelContainer extensions
│   │   └── MigrationManager.swift     # Schema migration handling
│   │
│   ├── Photo/                   # Image storage and management
│   │   ├── PhotoService.swift         # Protocol definition
│   │   ├── PhotoServiceImpl.swift     # Image file operations
│   │   ├── PhotoOptimizer.swift       # Image preprocessing for OCR
│   │   └── ThumbnailGenerator.swift   # Thumbnail creation
│   │
│   └── Export/                  # Contact export functionality
│       ├── ExportService.swift        # Protocol definition
│       ├── ContactsExporter.swift     # Apple Contacts integration
│       ├── VCFExporter.swift          # VCard export
│       ├── CSVExporter.swift          # CSV export
│       └── DuplicateDetector.swift    # Duplicate finding logic
│
├── Models/                       # Data models and structures
│   ├── BusinessCard.swift             # @Model SwiftData entity
│   ├── RecognizedText.swift           # OCR result structure
│   ├── ParsedContact.swift            # Intermediate contact data
│   ├── AppError.swift                 # Typed error definitions
│   ├── PermissionStatus.swift         # Permission state enum
│   └── AppSettings.swift              # User preferences model
│
├── Resources/                    # Assets and resources
│   ├── Assets.xcassets/               # Images, icons, colors
│   │   ├── AppIcon.appiconset/       # App icon
│   │   ├── Colors/                   # Color assets
│   │   └── Images/                   # Image assets
│   ├── Localizable.xcstrings          # Localized strings (iOS 17+)
│   └── Info.plist                     # App configuration
│
├── Docs/                         # Documentation
│   ├── architecture.md                # System architecture (COMPLETE)
│   ├── pipeline.md                    # Data flow pipeline (COMPLETE)
│   ├── PROJECT_STRUCTURE.md           # This file
│   ├── privacy-policy.md              # Privacy policy (App Store)
│   ├── code-review-checklist.md       # Code review standards
│   └── diagrams/                      # Architecture diagrams
│       ├── architecture.png
│       ├── data-flow.png
│       └── class-diagram.png
│
├── Tests/                        # Test suites
│   ├── Unit/                    # Unit tests
│   │   ├── ViewModels/
│   │   │   ├── ScannerViewModelTests.swift
│   │   │   ├── ContactListViewModelTests.swift
│   │   │   └── ContactEditViewModelTests.swift
│   │   ├── Services/
│   │   │   ├── OCRServiceTests.swift
│   │   │   ├── DatabaseServiceTests.swift
│   │   │   ├── PhotoServiceTests.swift
│   │   │   └── ExportServiceTests.swift
│   │   └── Models/
│   │       ├── BusinessCardTests.swift
│   │       └── ParsedContactTests.swift
│   │
│   ├── UI/                      # UI tests
│   │   ├── ScanningFlowTests.swift
│   │   ├── ContactManagementTests.swift
│   │   ├── ExportFlowTests.swift
│   │   └── AccessibilityTests.swift
│   │
│   ├── Integration/             # Integration tests
│   │   ├── OCRPipelineTests.swift
│   │   ├── ExportPipelineTests.swift
│   │   └── PermissionFlowTests.swift
│   │
│   └── Mocks/                   # Mock objects for testing
│       ├── MockOCRService.swift
│       ├── MockDatabaseService.swift
│       ├── MockPhotoService.swift
│       └── MockExportService.swift
│
├── Privacy/                      # Privacy documentation
│   ├── privacy-policy.md              # User-facing policy (COMPLETE)
│   ├── data-handling.md               # Internal guidelines
│   └── permissions.md                 # Permission justifications
│
├── Brand/                        # Brand assets
│   ├── app-icon.png                   # Source app icon
│   ├── app-icon.sketch                # Design file
│   ├── screenshots/                   # App Store screenshots
│   │   ├── iPhone-6.7/               # iPhone 15 Pro Max
│   │   ├── iPhone-6.5/               # iPhone 14 Pro Max
│   │   └── iPad-12.9/                # iPad Pro
│   └── marketing/                     # Marketing materials
│       ├── hero-image.png
│       └── feature-graphics.png
│
├── Config/                       # Configuration files
│   ├── FeatureFlags.swift             # Feature toggle system
│   ├── Constants.swift                # App-wide constants
│   ├── Environment.swift              # Environment configuration
│   └── BuildConfig.swift              # Build-specific settings
│
├── system/                       # Agent coordination
│   ├── context.yaml                   # Shared mission context (COMPLETE)
│   └── agent-roles.md                 # Agent responsibilities
│
├── Package.swift                 # Swift Package Manager manifest (COMPLETE)
├── .gitignore                    # Git ignore patterns (EXISTS)
├── README.md                     # Project overview (EXISTS)
├── OCR_IMPLEMENTATION.md         # OCR implementation guide (EXISTS)
├── QUICKSTART.md                 # Quick start guide (EXISTS)
└── LICENSE                       # MIT License

```

---

## Key File Descriptions

### App Layer

**DeetsApp.swift**
- SwiftUI `@main` entry point
- ModelContainer setup for SwiftData
- Environment object injection
- App lifecycle management

**ContentView.swift**
- Root navigation container (TabView or NavigationSplitView)
- Top-level navigation structure
- Environment setup

### Views Layer

**Scanning/**
- `ScannerView`: VisionKit document camera integration
- `PreviewView`: Review scanned image before processing
- `CropView`: Manual crop tools (if VisionKit auto-crop isn't perfect)
- `ScanningCoordinator`: UIKit/SwiftUI bridge for VNDocumentCameraViewController

**Contacts/**
- `ContactListView`: Main list with `@Query` for SwiftData
- `ContactDetailView`: Full contact card with edit/delete/export
- `ContactEditView`: Form for manual entry or editing parsed data
- All use corresponding ViewModels for state management

**Settings/**
- `SettingsView`: App preferences (iCloud sync, OCR language, etc.)
- `PrivacyView`: Privacy controls and data management
- `ExportOptionsView`: Configure default export format

**Shared/**
- Reusable components used across multiple screens
- Consistent UI patterns (loading, errors, empty states)

### ViewModels Layer

All ViewModels:
- Conform to `ObservableObject`
- Use `@MainActor` for UI-bound state
- Receive services via dependency injection
- Handle async operations with async/await
- Expose `@Published` properties for view binding

Example pattern:
```swift
@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var scannedImage: UIImage?
    @Published var isProcessing = false
    @Published var error: AppError?

    private let ocrService: OCRServiceProtocol
    private let photoService: PhotoServiceProtocol
    private let databaseService: DatabaseServiceProtocol

    init(
        ocrService: OCRServiceProtocol,
        photoService: PhotoServiceProtocol,
        databaseService: DatabaseServiceProtocol
    ) {
        self.ocrService = ocrService
        self.photoService = photoService
        self.databaseService = databaseService
    }

    func processScannedImage(_ image: UIImage) async { ... }
}
```

### Services Layer

All services:
- Have protocol definitions (for mocking in tests)
- Use async/await for async operations
- Return typed errors (never generic `Error`)
- Are injected into ViewModels

**OCR/**
- `OCRService`: VisionKit text recognition
- `OCRParser`: Regex-based business card parsing
- `OCRConfidence`: Scoring algorithms for parsed fields

**Database/**
- `DatabaseService`: CRUD operations for BusinessCard
- `SwiftDataService`: SwiftData implementation
- `MigrationManager`: Handle schema changes

**Photo/**
- `PhotoService`: Save/load/delete business card photos
- `PhotoOptimizer`: Image preprocessing (contrast, rotation, resize)
- `ThumbnailGenerator`: Create thumbnails for list view

**Export/**
- `ContactsExporter`: Apple Contacts framework integration
- `VCFExporter`: vCard file generation
- `CSVExporter`: CSV file generation
- `DuplicateDetector`: Find existing contacts before export

### Models Layer

**BusinessCard** (SwiftData `@Model`):
- Primary data model for persistence
- Contains all contact fields + metadata
- Supports SwiftData queries and iCloud sync

**RecognizedText**:
- Output from VisionKit OCR
- Contains observations, confidence scores, bounding boxes

**ParsedContact**:
- Intermediate model between OCR and BusinessCard
- Used for validation and user review

**AppError**:
- Typed errors for all operations
- User-friendly messages and recovery suggestions

### Tests Layer

**Unit Tests** (90%+ coverage for ViewModels, 85%+ for Services):
- Test business logic in isolation
- Use mock services (dependency injection enables this)
- Fast execution (<1s for entire suite)

**UI Tests** (critical user flows):
- End-to-end user scenarios
- Accessibility validation
- Screenshot tests for regression

**Integration Tests** (pipelines):
- Test entire workflows (scan → OCR → parse → save)
- Use real frameworks (VisionKit, SwiftData) in test environment

---

## File Naming Conventions

### Swift Files
- **PascalCase** for types: `ScannerViewModel.swift`
- **Protocol suffix** for protocols: `OCRServiceProtocol`
- **Impl suffix** for concrete implementations: `OCRServiceImpl`
- **+Ext suffix** for extensions: `String+Validation.swift`
- **Tests suffix** for tests: `ScannerViewModelTests.swift`

### Resource Files
- **kebab-case** for asset names: `app-icon`, `scan-button`
- **Localizable.xcstrings** for strings (iOS 17+ format)
- **Info.plist** for app configuration

### Documentation
- **SCREAMING_SNAKE_CASE** for important docs: `QUICKSTART.md`
- **lowercase.md** for detailed docs: `architecture.md`
- **kebab-case.md** for multi-word docs: `code-review-checklist.md`

---

## Import Organization

Standard import order:
```swift
// 1. Foundation/UIKit/SwiftUI
import SwiftUI
import SwiftData

// 2. Apple frameworks
import VisionKit
import Contacts

// 3. Third-party (none in v1.0)

// 4. Internal modules (if using modules)
@testable import DeetsKit
```

---

## Folder Organization Principles

1. **Layer-Based**: Top-level folders represent architectural layers
2. **Feature Grouping**: Within layers, group by feature (Scanning, Contacts, etc.)
3. **Protocol + Implementation**: Protocols in same folder as implementations
4. **Tests Mirror Source**: Test folder structure mirrors source structure
5. **Resources Centralized**: All assets in Resources/ folder
6. **Docs Separate**: Documentation in dedicated Docs/ folder

---

## Git Ignore Patterns

Key patterns to ignore (already in `.gitignore`):
```
# Xcode
*.xcodeproj
!*.xcodeproj/project.pbxproj
*.xcworkspace
DerivedData/
*.hmap

# Swift Package Manager
.build/
.swiftpm/

# Testing
*.gcov
*.gcda

# Misc
.DS_Store
*.swp
```

---

## Future Structure (v2.0+)

Potential additions:
```
Deets/
├── Analytics/               # Opt-in analytics (if added)
├── ML/                      # CoreML models for parsing
│   ├── BusinessCardClassifier.mlmodel
│   └── TrainingData/
├── Widgets/                 # iOS widgets
│   └── RecentScansWidget.swift
└── Extensions/              # Share extension, etc.
    └── ShareExtension/
```

---

## Cross-Platform (Android - Future)

If/when building Android version, mirror structure:
```
Deets-Android/
├── app/                     # Application module
├── ui/                      # Jetpack Compose screens
├── viewmodels/              # ViewModels (same as iOS)
├── services/                # Services (Kotlin impl of same protocols)
├── models/                  # Data models (Room)
└── tests/                   # Tests
```

**Goal**: Identical architecture, platform-specific implementations

---

## Summary

- **Total Folders**: ~30
- **Estimated Files** (v1.0): ~80-100 source files
- **Test Files**: ~40-50
- **Documentation**: ~10 files
- **Configuration**: ~5 files

**Architecture**: Clean MVVM with protocol-oriented services
**Testability**: High (dependency injection, protocol-based mocks)
**Maintainability**: Clear separation of concerns, easy to navigate
**Scalability**: Well-organized for future features

---

**Version**: 1.0.0
**Last Updated**: 2025-11-05
**Maintained by**: ORION (Chief Architect)
