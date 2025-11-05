# VisionKit OCR System Implementation

**Created by:** IVY (VisionKit & OCR Engineer)
**Date:** 2025-11-05
**Status:** Production-Ready

## Overview

Complete OCR scanning system for Deets using Apple's VisionKit framework. Optimized for business card scanning with real-time text recognition, validation, and categorization.

## Architecture

```
Deets/
├── Models/
│   └── ScannedText.swift          # Data models for OCR results
├── Services/
│   ├── OCRService.swift           # VisionKit wrapper & coordinator
│   └── Validation/
│       └── TextValidator.swift    # Quality scoring & categorization
├── OCRScannerView.swift           # Example SwiftUI integration
└── Info.plist                     # Camera permissions config
```

## Components

### 1. ScannedText.swift - Data Models

**Core Models:**
- `ScannedText` - Individual recognized text with metadata
- `BoundingBox` - Normalized positioning (0.0-1.0 coordinates)
- `ScanResult` - Collection of scanned items from single session
- `TextCategory` - Classification enum (email, phone, name, etc.)

**Features:**
- Unique identifiers for tracking
- Confidence scores (0.0-1.0)
- Timestamp tracking
- Validation state
- Category hints
- Convenience extensions for filtering/sorting

**Key Methods:**
```swift
// Create from VisionKit item
ScannedText.from(recognizedItem: item, imageSize: size)

// Filter by confidence
items.withMinimumConfidence(0.7)

// Sort by position
items.sortedByPosition()

// Combine text
items.combinedText(separator: "\n")
```

### 2. OCRService.swift - VisionKit Integration

**Responsibilities:**
- DataScannerViewController lifecycle management
- Real-time text recognition
- Static image processing
- Camera permission handling
- Error management

**Features:**
- ✅ Real-time scanning with DataScannerViewController
- ✅ Static image processing with Vision framework
- ✅ Business card optimization preset
- ✅ Image preprocessing (contrast, sharpening)
- ✅ SwiftUI integration via UIViewControllerRepresentable
- ✅ Device capability checks
- ✅ Async/await patterns throughout
- ✅ Comprehensive error handling

**Configuration Presets:**
```swift
// Business card optimized
OCRService.ScanConfiguration.businessCard
// - Multiple items recognition
// - English language priority
// - 0.6 minimum confidence
// - Accurate quality level

// Lenient scanning
OCRService.ScanConfiguration.lenient
// - Lower confidence threshold
// - Broader text acceptance

// Strict scanning
OCRService.ScanConfiguration.strict
// - Higher confidence requirement
// - Tighter validation
```

**Usage Example:**
```swift
// Initialize service
let ocrService = OCRService()

// Check device support
guard OCRService.isSupported else {
    // Handle unsupported device
    return
}

// Request camera access
let granted = await ocrService.requestCameraAccess()

// Create scanner
let scanner = try ocrService.createScanner(
    configuration: .businessCard
)

// Start scanning
try ocrService.startScanning()

// Access recognized items
for item in ocrService.recognizedItems {
    print("\(item.text) - \(item.confidence)")
}

// Process static image
let result = try await ocrService.processImage(image)
```

**Device Requirements:**
- iOS 16.0+
- A12 Bionic chip or newer (iPhone XS and later)
- Camera access authorization

### 3. TextValidator.swift - Quality & Categorization

**Responsibilities:**
- Text quality validation
- Confidence scoring
- Pattern-based categorization
- Noise filtering
- Data extraction

**Validation Rules:**
Three presets available:
- `.businessCard` - Balanced (default)
- `.lenient` - Permissive for general docs
- `.strict` - High accuracy requirements

**Features:**
- ✅ Confidence threshold filtering
- ✅ Length constraints
- ✅ OCR artifact detection (|||, ---, etc.)
- ✅ Noise pattern filtering
- ✅ Quality scoring algorithm
- ✅ Pattern-based categorization
- ✅ Structured data extraction

**Categorization Patterns:**
- Email: RFC-compliant email regex
- Phone: Multiple formats (US-centric)
- Website: URL detection with/without protocol
- Name: Capitalized word patterns
- Title: Job title keywords (CEO, Director, etc.)
- Company: Business entity suffixes (Inc, LLC, etc.)
- Address: Street address patterns

**Usage Example:**
```swift
let validator = TextValidator(rules: .businessCard)

// Validate text
let isValid = validator.validate(
    text: "john@email.com",
    confidence: 0.85
)

// Calculate quality score
let score = validator.qualityScore(
    text: "John Smith",
    confidence: 0.92
)

// Categorize text
let category = validator.categorizeText("john@email.com")
// Returns: .email

// Extract structured data
let data = validator.extractStructuredData(text)
// Returns: ["email": "john@email.com", "phone": "(555) 123-4567"]
```

### 4. OCRScannerView.swift - SwiftUI Integration

**Example implementation showing:**
- Camera preview integration
- Permission handling flow
- Real-time text overlay
- Recognized item display
- Capture functionality
- Error handling UI

**Features:**
- Material design overlays
- Category-based icons and colors
- Confidence badges
- Sorted item display
- Haptic feedback
- Navigation integration

## Info.plist Configuration

**Required Permissions:**
```xml
<!-- Camera access for scanning -->
<key>NSCameraUsageDescription</key>
<string>Deets needs camera access to scan business cards...</string>

<!-- Photo library access (optional) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Deets can scan business cards from your photo library...</string>

<!-- Save to photo library (optional) -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Deets can save scanned business card images...</string>
```

**Device Requirements:**
```xml
<key>MinimumOSVersion</key>
<string>16.0</string>

<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>camera</string>
</array>
```

## Integration Guide

### Step 1: Add to Xcode Project
1. Add all `.swift` files to your project
2. Update `Info.plist` with camera permissions
3. Ensure iOS 16.0+ deployment target

### Step 2: Basic Integration
```swift
import SwiftUI

@main
struct DeetsApp: App {
    var body: some Scene {
        WindowGroup {
            OCRScannerView()
        }
    }
}
```

### Step 3: Custom Integration
```swift
struct CustomScanView: View {
    @StateObject private var ocrService = OCRService()

    var body: some View {
        VStack {
            // Your custom UI
            if let scanner = try? ocrService.createScanner() {
                DataScannerView(scanner: scanner)
            }

            // Display results
            ForEach(ocrService.recognizedItems) { item in
                Text(item.text)
            }
        }
        .task {
            try? ocrService.startScanning()
        }
    }
}
```

## Performance Optimizations

### Real-Time Scanning
- ✅ High frame rate tracking enabled
- ✅ Debounced item updates
- ✅ Efficient delegate callbacks
- ✅ Main actor isolation

### Static Image Processing
- ✅ Image preprocessing filters
- ✅ Contrast enhancement
- ✅ Sharpening for clarity
- ✅ Async processing

### Memory Management
- ✅ Proper cleanup on deinit
- ✅ Task cancellation
- ✅ Weak references where appropriate
- ✅ Image compression for storage

## Error Handling

**Error Types:**
```swift
enum OCRError: LocalizedError {
    case deviceNotSupported
    case cameraAccessDenied
    case cameraUnavailable
    case scannerNotInitialized
    case scanningFailed(String)
    case invalidImage
    case recognitionFailed(String)
    case noTextFound
    case unknownError
}
```

**Each error includes:**
- Localized description
- Recovery suggestions
- User-friendly messaging

## Testing

### Unit Testing
```swift
// Test validation
let validator = TextValidator(rules: .businessCard)
XCTAssertTrue(validator.validate(text: "valid@email.com", confidence: 0.9))
XCTAssertFalse(validator.validate(text: "|||", confidence: 0.5))

// Test categorization
let category = validator.categorizeText("(555) 123-4567")
XCTAssertEqual(category, .phone)
```

### Preview Testing
```swift
#if DEBUG
let mockService = OCRService.mock
// Pre-populated with sample data
#endif
```

### Device Testing
- Test on A12+ devices (iPhone XS and later)
- Test camera permissions flow
- Test in various lighting conditions
- Test business card dimensions/orientations

## Troubleshooting

### Scanner Not Working
1. Check device support: `OCRService.isSupported`
2. Verify iOS 16.0+ and A12+ chip
3. Confirm camera permissions granted
4. Check Info.plist has usage descriptions

### Low Recognition Quality
1. Ensure good lighting
2. Hold camera steady
3. Adjust camera distance
4. Try image preprocessing
5. Lower confidence threshold
6. Use `.accurate` quality level

### Permission Issues
1. Check `authorizationStatus` property
2. Call `requestCameraAccess()`
3. Guide user to Settings if denied
4. Handle `.notDetermined` state

## Best Practices

### For Business Cards
- Use `.businessCard` configuration preset
- Enable multiple item recognition
- Set minimum confidence to 0.6+
- Enable text categorization
- Provide visual feedback for recognized items

### For Performance
- Stop scanning when not visible
- Cleanup scanner on view disappear
- Process images on background queue
- Compress images before storage

### For UX
- Show permission rationale before requesting
- Provide clear error messages
- Display confidence indicators
- Group items by category
- Enable manual correction/editing

## Future Enhancements

**Potential additions:**
- [ ] Multi-language support
- [ ] Barcode/QR code scanning
- [ ] Document boundary detection
- [ ] Batch processing mode
- [ ] Cloud backup integration
- [ ] Contact deduplication
- [ ] ML-based data correction
- [ ] Export to vCard format

## Technical Notes

### VisionKit vs Vision Framework
- **DataScannerViewController** (VisionKit): Real-time, requires A12+, iOS 16+
- **VNRecognizeTextRequest** (Vision): Static images, wider device support, iOS 13+
- Service uses both: DataScanner for live, Vision for static images

### Coordinate Systems
- Bounding boxes use normalized coordinates (0.0-1.0)
- Origin at top-left (standard iOS)
- Convert to CGRect: `boundingBox.toCGRect(in: size)`

### Thread Safety
- OCRService marked @MainActor
- All state updates on main thread
- Delegate callbacks dispatched to MainActor
- Task-based async patterns throughout

## Dependencies

**System Frameworks:**
- VisionKit (iOS 16.0+)
- Vision (iOS 13.0+)
- AVFoundation (Camera access)
- SwiftUI (UI layer)
- CoreImage (Image processing)

**No third-party dependencies required.**

## Support

**Device Support Matrix:**
| Device | iOS Version | Support Level |
|--------|-------------|---------------|
| iPhone XS+ | 16.0+ | Full support |
| iPhone X and older | 16.0+ | Static image only |
| iPad Pro 2018+ | 16.0+ | Full support |
| iPad 2017 and older | 16.0+ | Static image only |

**Questions or issues?**
Review error logs and check device compatibility first.

---

**Implementation complete.** All files are production-ready and extensively documented.
