# Deets - Business Card Scanner

A modern iOS app for scanning, managing, and exporting business cards using VisionKit and SwiftData.

## Features

### Phase 1 (Current)
- **Camera Scanning**: Use VisionKit DataScanner to capture business card text
- **Smart Parsing**: Automatically extract name, title, company, email, phone, website
- **Editable Preview**: Review and correct extracted information before saving
- **SwiftData Storage**: Persistent local storage of business cards
- **Contacts Integration**: Save cards directly to iOS Contacts app
- **Search & Filter**: Find cards quickly with search and filtering options
- **Favorites**: Mark important contacts as favorites
- **Share**: Export contact information via share sheet

## Tech Stack

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Apple's latest data persistence framework
- **VisionKit**: DataScannerViewController for text recognition
- **Contacts Framework**: iOS Contacts integration
- **Observation Framework**: Modern state management with @Observable

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Device with camera (not supported in Simulator for scanning)

## Project Structure

```
Deets/
├── App/
│   └── DeetsApp.swift              # Main app entry point
├── Models/
│   └── BusinessCard.swift          # SwiftData model
├── Views/
│   ├── ScanView.swift              # Camera scanning interface
│   ├── ContactPreviewView.swift   # Edit scanned contact
│   ├── CardListView.swift          # List of saved cards
│   ├── CardDetailView.swift        # Card detail view
│   └── Components/
│       ├── PrimaryButton.swift     # Reusable button components
│       ├── CardRowView.swift       # Card list row
│       ├── ValidatedTextField.swift # Form input with validation
│       └── EmptyStateView.swift    # Empty state placeholder
├── ViewModels/
│   ├── ScanViewModel.swift         # Scan flow logic
│   ├── ContactPreviewViewModel.swift # Edit & save logic
│   └── CardListViewModel.swift     # List filtering & sorting
├── Utilities/
│   └── HapticManager.swift         # Centralized haptics
└── Resources/
    ├── Info.plist                  # App configuration
    └── InfoPlistRequirements.md    # Privacy permission docs
```

## Setup

### Option 1: XcodeGen (Recommended)

1. Install XcodeGen:
```bash
brew install xcodegen
```

2. Generate Xcode project:
```bash
xcodegen generate
```

3. Open the generated project:
```bash
open Deets.xcodeproj
```

### Option 2: Manual Xcode Project

1. Create a new iOS App project in Xcode
2. Set minimum deployment target to iOS 16.0
3. Add all files from the `Deets/` directory
4. Ensure Info.plist is properly configured (see `Resources/InfoPlistRequirements.md`)

## Configuration

### Required Permissions

Add these to your Info.plist:

- **NSCameraUsageDescription**: Camera access for scanning business cards
- **NSContactsUsageDescription**: Contacts access for saving cards

See `Deets/Resources/InfoPlistRequirements.md` for complete setup instructions.

### App Configuration

1. Set your development team in project settings
2. Update bundle identifier if needed (default: `com.deets.app`)
3. Build and run on a physical device (camera scanning not available in Simulator)

## Design Guidelines

### Colors
- **Primary**: Teal (#23C4AE) - Used for brand accent
- **System Colors**: iOS default colors for light/dark mode support

### Typography
- System fonts with Dynamic Type support
- Font weights: Regular, Medium, Semibold, Bold

### Accessibility
- VoiceOver labels on all interactive elements
- Dynamic Type support throughout
- Sufficient color contrast ratios
- Semantic HTML structure

### Haptics
- Button taps: Light impact
- Scan complete: Success notification
- Toggle actions: Light impact
- Delete actions: Medium impact
- Errors: Error notification

## Architecture

### SwiftUI + Observation
Modern reactive architecture using Swift's Observation framework:
- `@Observable` classes for ViewModels
- `@State` and `@Bindable` for view state
- `@Environment` for dependency injection

### SwiftData
- `@Model` macro for business card entity
- `@Query` for reactive data fetching
- ModelContainer configured in app entry point

### Separation of Concerns
- **Views**: Pure SwiftUI, minimal logic
- **ViewModels**: Business logic and state management
- **Models**: Data structures and persistence
- **Utilities**: Shared helpers (haptics, extensions)

## Testing

### Preview Support
All views include SwiftUI previews for rapid development:
```swift
#Preview("Card List") {
    CardListView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
```

### Test Data
Sample business cards available in `BusinessCard.sampleData`

## Roadmap

### Phase 2 (Planned)
- Advanced NLP parsing with Create ML
- Business card image storage
- Tags and categorization
- Custom fields
- Import/export VCF files
- iCloud sync

### Phase 3 (Future)
- Multiple scans at once
- Batch operations
- Smart suggestions
- CRM integrations
- Analytics and insights

## Contributing

This is a personal project but suggestions are welcome. Open an issue for bugs or feature requests.

## License

Copyright © 2025. All rights reserved.

## Acknowledgments

Built with:
- SwiftUI for UI
- VisionKit for text recognition
- SwiftData for persistence
- iOS Human Interface Guidelines for design
