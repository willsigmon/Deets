# Deets - Build & Setup Guide

Complete guide to building and running the Deets business card scanner app.

## Quick Start

### Prerequisites

1. **macOS** with Xcode 15.0 or later
2. **iOS 16.0+** device (Simulator won't work for camera scanning)
3. **XcodeGen** (optional, but recommended)

### Installation

```bash
# Install XcodeGen
brew install xcodegen

# Clone the repository
git clone <your-repo-url>
cd Deets

# Generate Xcode project
xcodegen generate

# Open the project
open Deets.xcodeproj
```

## Project Setup

### 1. Configure Signing

1. Open Xcode
2. Select the **Deets** target
3. Go to **Signing & Capabilities**
4. Select your **Team**
5. Update **Bundle Identifier** if needed (default: `com.sharedeets.app`)

### 2. Build Configuration

The project is pre-configured with:
- **Deployment Target**: iOS 16.0
- **Swift Version**: 5.9
- **Strict Concurrency**: Enabled

No additional configuration needed.

### 3. Run on Device

1. Connect your iPhone/iPad (iOS 16+)
2. Select your device in Xcode's device selector
3. Press `Cmd+R` to build and run

**Note**: Camera scanning requires a physical device. Simulator will show "Camera not available" message.

## Project Structure

```
Deets/
├── App/
│   └── DeetsApp.swift              # @main entry point, SwiftData setup, tab navigation
│
├── Models/
│   └── BusinessCard.swift          # SwiftData @Model with sample data
│
├── ViewModels/
│   ├── ScanViewModel.swift         # Scan flow state management
│   ├── ContactPreviewViewModel.swift # Edit & save logic
│   └── CardListViewModel.swift     # List filtering, sorting, search
│
├── Views/
│   ├── ScanView.swift              # Camera scanning UI + VisionKit
│   ├── ContactPreviewView.swift   # Editable contact form
│   ├── CardListView.swift          # Saved cards list
│   ├── CardDetailView.swift        # Individual card detail
│   └── Components/
│       ├── PrimaryButton.swift     # Brand-colored action button
│       ├── SecondaryButton.swift   # Secondary action button
│       ├── CardRowView.swift       # Business card list row
│       ├── ValidatedTextField.swift # Input with validation UI
│       └── EmptyStateView.swift    # Empty state placeholder
│
├── Utilities/
│   └── HapticManager.swift         # Centralized haptic feedback
│
└── Resources/
    ├── Info.plist                  # Privacy permissions
    └── InfoPlistRequirements.md    # Permission documentation
```

## Key Features Implemented

### 1. Business Card Scanning
- **File**: `Views/ScanView.swift`
- **Framework**: VisionKit DataScannerViewController
- **Features**:
  - Real-time text recognition
  - Tap-to-capture interface
  - Auto-capture for substantial text
  - Error handling and retry
  - Haptic feedback

### 2. Contact Preview & Editing
- **File**: `Views/ContactPreviewView.swift`
- **Features**:
  - Smart text parsing
  - Field validation (email, phone, URL)
  - Real-time validation indicators
  - Save to database and/or Contacts
  - Error handling with user feedback

### 3. Card Management
- **Files**: `Views/CardListView.swift`, `Views/CardDetailView.swift`
- **Features**:
  - Search functionality
  - Multiple sort options (date, name, company)
  - Filter by favorites or saved status
  - Swipe actions (delete, favorite, share)
  - Empty states

### 4. Data Persistence
- **File**: `Models/BusinessCard.swift`
- **Framework**: SwiftData
- **Features**:
  - Local storage
  - Automatic relationships
  - Sample data for previews

### 5. Accessibility
All views include:
- VoiceOver labels
- Accessibility hints
- Dynamic Type support
- Semantic element grouping
- Sufficient color contrast

### 6. Design System
- **Color**: Teal (#23C4AE) brand accent
- **Dark Mode**: Full support
- **Typography**: SF Pro with Dynamic Type
- **Icons**: SF Symbols
- **Haptics**: Contextual feedback

## Testing

### SwiftUI Previews

Every view includes previews for rapid development:

```swift
#Preview("Card List") {
    CardListView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
```

To use previews:
1. Open any View file
2. Press `Cmd+Option+Return` to show preview
3. Use sample data to test various states

### Manual Testing Checklist

- [ ] Launch app on device
- [ ] Grant camera permission
- [ ] Tap "Start Scanning" button
- [ ] Point camera at business card
- [ ] Tap on detected text to capture
- [ ] Review extracted fields in preview
- [ ] Edit any incorrect fields
- [ ] Save to database
- [ ] Grant contacts permission
- [ ] Save to Contacts app
- [ ] View card in list
- [ ] Search for card
- [ ] Filter by favorites
- [ ] Sort by different options
- [ ] Swipe to delete
- [ ] View card details
- [ ] Share card

## Troubleshooting

### Camera Not Available

**Problem**: "Camera scanning is not available on this device"

**Solutions**:
- Run on physical iOS device (iOS 16+)
- Check camera permissions in Settings
- Ensure VisionKit is available (DataScannerViewController.isSupported)

### Contacts Permission Denied

**Problem**: Can't save to Contacts app

**Solutions**:
- Go to Settings → Privacy & Security → Contacts
- Enable access for Deets
- Retry save operation

### SwiftData Errors

**Problem**: "Could not create ModelContainer"

**Solutions**:
- Clean build folder (Cmd+Shift+K)
- Delete derived data
- Restart Xcode
- Check iOS deployment target is 16.0+

### Build Errors

**Problem**: Missing frameworks or compilation errors

**Solutions**:
```bash
# Clean and rebuild
cd Deets
rm -rf .build DerivedData
xcodegen generate
open Deets.xcodeproj
# Clean build: Cmd+Shift+K
# Build: Cmd+B
```

## Development Workflow

### Adding New Features

1. **Model Changes**:
   - Update `BusinessCard.swift`
   - Add new properties
   - Update sample data

2. **ViewModels**:
   - Create new @Observable class
   - Add business logic
   - Keep view-agnostic

3. **Views**:
   - Build SwiftUI views
   - Add preview
   - Test with sample data

4. **Components**:
   - Extract reusable UI to `Views/Components/`
   - Document with previews
   - Make accessible

### Code Style

- **SwiftUI**: Declarative, functional
- **ViewModels**: @Observable, @MainActor
- **Models**: SwiftData @Model
- **Formatting**: SwiftFormat (optional)
- **Linting**: SwiftLint (optional)

## Performance Optimization

### Current Optimizations

1. **Lazy Loading**: Lists use lazy stacks
2. **Query Optimization**: SwiftData @Query with filters
3. **Haptic Preparation**: Generators prepared upfront
4. **Image Optimization**: SF Symbols, no custom images
5. **Memory Management**: @Observable, no retain cycles

### Profiling

Use Instruments to profile:
```bash
# Time Profiler
Product → Profile (Cmd+I) → Time Profiler

# Memory Leaks
Product → Profile → Leaks

# SwiftUI Performance
Product → Profile → SwiftUI
```

## Next Steps

### Phase 2 Enhancements

1. **Advanced Parsing**:
   - Natural Language Processing
   - Create ML model training
   - Confidence scoring

2. **Image Storage**:
   - Store original card photos
   - Photo library integration
   - Image cropping/editing

3. **Cloud Sync**:
   - iCloud sync with SwiftData
   - Conflict resolution
   - Offline support

4. **Export/Import**:
   - VCF file export
   - CSV export
   - Batch import

### Contributing

To contribute:
1. Fork the repository
2. Create feature branch
3. Make changes
4. Add tests
5. Submit pull request

## Resources

### Apple Documentation

- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [VisionKit](https://developer.apple.com/documentation/visionkit)
- [Contacts Framework](https://developer.apple.com/documentation/contacts)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)

### Learning Resources

- [SwiftUI by Example](https://www.hackingwithswift.com/quick-start/swiftui)
- [SwiftData Tutorial](https://www.hackingwithswift.com/quick-start/swiftdata)
- [VisionKit Tutorial](https://developer.apple.com/videos/play/wwdc2022/10025/)

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check existing issues first
- Provide detailed reproduction steps

## License

Copyright © 2025. All rights reserved.
