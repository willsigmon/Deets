# Deets OCR System - Quick Start Guide

**5-minute setup for developers new to the codebase**

## What You Got

A complete VisionKit-based OCR system for scanning business cards. Real-time camera scanning + static image processing, all production-ready.

## File Structure

```
Deets/
├── Models/
│   └── ScannedText.swift          # Data models
├── Services/
│   ├── OCRService.swift           # Main OCR engine
│   └── Validation/
│       └── TextValidator.swift    # Text validation & categorization
├── OCRScannerView.swift           # Example UI (SwiftUI)
└── Info.plist                     # Camera permissions
```

## Requirements

- iOS 16.0+ deployment target
- iPhone XS or newer (A12 Bionic chip) for live scanning
- Camera access permission

## Integration (Copy-Paste Ready)

### Option 1: Use the Example View

```swift
import SwiftUI

@main
struct DeetsApp: App {
    var body: some Scene {
        WindowGroup {
            OCRScannerView() // Drop-in ready
        }
    }
}
```

### Option 2: Custom Integration

```swift
import SwiftUI

struct MyView: View {
    @StateObject private var ocrService = OCRService()

    var body: some View {
        VStack {
            // Show camera scanner
            if let scanner = try? ocrService.createScanner() {
                DataScannerView(scanner: scanner)
                    .ignoresSafeArea()
            }

            // Display results
            ScrollView {
                ForEach(ocrService.recognizedItems) { item in
                    VStack(alignment: .leading) {
                        Text(item.text)
                            .font(.body)
                        Text(item.category?.displayName ?? "Unknown")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .task {
            // Request permission & start scanning
            if await ocrService.requestCameraAccess() {
                try? ocrService.startScanning()
            }
        }
        .onDisappear {
            ocrService.stopScanning()
        }
    }
}
```

### Option 3: Static Image Processing

```swift
let ocrService = OCRService()
let image = UIImage(named: "business-card")!

Task {
    let result = try await ocrService.processImage(image)

    for item in result.items {
        print("\(item.text) - Category: \(item.category?.displayName ?? "N/A")")
    }
}
```

## Common Patterns

### Check Device Support
```swift
guard OCRService.isSupported else {
    // Show "Device not supported" message
    return
}
```

### Handle Permissions
```swift
// Check current status
ocrService.checkCameraAuthorization()

// Request access
let granted = await ocrService.requestCameraAccess()

// Monitor status
if ocrService.authorizationStatus != .authorized {
    // Show permission prompt
}
```

### Filter Results
```swift
// Only high confidence items
let goodItems = ocrService.recognizedItems
    .withMinimumConfidence(0.8)

// Only emails
let emails = ocrService.recognizedItems
    .filter { $0.category == .email }

// Sorted top to bottom
let sorted = ocrService.recognizedItems
    .sortedByPosition()
```

### Customize Validation
```swift
// Strict validation
let validator = TextValidator(rules: .strict)
let ocrService = OCRService(validator: validator)

// Custom rules
var rules = TextValidator.ValidationRules()
rules.minimumConfidence = 0.7
rules.filterSingleCharacters = false
let validator = TextValidator(rules: rules)
```

## Categories Detected

The system auto-categorizes recognized text:

- `.email` - Email addresses
- `.phone` - Phone numbers (various formats)
- `.website` - URLs
- `.name` - People names (capitalized)
- `.title` - Job titles (CEO, Director, etc.)
- `.company` - Company names (Inc, LLC, etc.)
- `.address` - Street addresses
- `.other` - Uncategorized text

## Configuration Presets

```swift
// Business cards (default)
OCRService.ScanConfiguration.businessCard

// General documents (lenient)
OCRService.ScanConfiguration.lenient

// High accuracy (strict)
OCRService.ScanConfiguration.strict

// Custom config
var config = OCRService.ScanConfiguration()
config.minimumConfidence = 0.75
config.qualityLevel = .accurate
let scanner = try ocrService.createScanner(configuration: config)
```

## Troubleshooting

### "Scanner not working"
1. Check: `OCRService.isSupported` returns `true`
2. Verify: iOS 16+ and iPhone XS or newer
3. Confirm: Camera permission granted

### "Low quality results"
```swift
// Use accurate quality level
var config = OCRService.ScanConfiguration.businessCard
config.qualityLevel = .accurate

// Or preprocess images
if let enhanced = ocrService.preprocessImage(originalImage) {
    let result = try await ocrService.processImage(enhanced)
}
```

### "Permission denied"
```swift
// Guide user to Settings
if let url = URL(string: UIApplication.openSettingsURLString) {
    UIApplication.shared.open(url)
}
```

## What Each File Does

**ScannedText.swift**
- Data models for OCR results
- Bounding boxes, confidence scores, categories
- Helper methods for filtering/sorting

**OCRService.swift**
- Wraps VisionKit's DataScannerViewController
- Handles camera, permissions, scanning lifecycle
- Processes static images via Vision framework
- @Published properties for SwiftUI binding

**TextValidator.swift**
- Validates text quality (confidence, length, noise)
- Categorizes text (email, phone, name, etc.)
- Filters OCR artifacts (|||, ---, etc.)
- Extracts structured data

**OCRScannerView.swift**
- Example SwiftUI implementation
- Shows permission flow, camera view, results overlay
- Copy as starting point for your UI

**Info.plist**
- Camera permission descriptions
- Minimum iOS version
- Device capabilities

## Next Steps

1. **Test on device** - Simulator doesn't support camera
2. **Customize validation** - Adjust confidence thresholds
3. **Build your UI** - Use OCRScannerView as reference
4. **Add persistence** - Save scanned contacts
5. **Export contacts** - vCard, CSV, etc.

## Performance Tips

- Stop scanning when view disappears
- Use `.businessCard` preset for best results
- Filter by confidence > 0.7 for quality
- Preprocess images in poor lighting
- Cleanup on deinit (handled automatically)

## Questions?

Read `OCR_IMPLEMENTATION.md` for deep dive documentation.

---

**You're ready to scan!** Drop `OCRScannerView()` into your app or build custom UI using `OCRService`.
