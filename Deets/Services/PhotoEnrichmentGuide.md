# Photo Enrichment System - Technical Guide

## Overview

The Photo Enrichment system enables users to optionally add photos to scanned business card contacts by intelligently searching their Photos library and detecting faces using the Vision framework.

## Architecture

### Components

1. **PhotoCandidate.swift** - Data model for photo candidates with quality metadata
2. **PhotoDiscoveryService.swift** - PhotoKit integration for library search
3. **FaceValidator.swift** - Vision framework face detection and quality assessment
4. **PhotoCropperView.swift** - Interactive cropping interface
5. **PhotoSelectionView.swift** - Candidate selection and permission flow

### Data Flow

```
User scans business card
        ↓
Contact data extracted (ParsedContact)
        ↓
User optionally chooses "Add Photo"
        ↓
PhotoSelectionView requests permission
        ↓
PhotoDiscoveryService searches library
  → Strategy 1: People album (name match)
  → Strategy 2: Recent photos (30 days)
  → Strategy 3: Library scan (face detection)
        ↓
FaceValidator detects faces & scores quality
        ↓
Candidates displayed sorted by quality
        ↓
User selects candidate
        ↓
PhotoCropperView shows face-aware crop
        ↓
User adjusts crop & saves
        ↓
Cropped image attached to CNContact
```

## Privacy Design

### Permissions Required

- **NSPhotoLibraryUsageDescription** (already in Info.plist)
- User can skip photo enrichment entirely
- No photos uploaded to server (100% on-device)

### Privacy-First Features

- Opt-in flow with clear explanation
- Works with Limited Photo Library Access (iOS 14+)
- Photos never leave device
- No analytics on photo usage
- Graceful degradation if permission denied

## PhotoKit Integration

### Photo Discovery Strategies

#### 1. People Album Search
```swift
// Highest confidence match (0.8)
// Searches Photos' People album for matching name
// Uses fuzzy name matching:
//   - Exact match: "John Doe" == "John Doe"
//   - Contains: "John Doe" matches "John"
//   - Component: "John Smith" matches "John Doe" (first name)
```

#### 2. Recent Photos
```swift
// Medium confidence (0.3)
// Last 30 days, image assets only
// Face detection applied to all
// Fallback when People album has no matches
```

#### 3. Library Scan
```swift
// Low confidence (0.1)
// Full library search with face filter
// Most computationally expensive
// Only used if other strategies fail
```

### Performance Optimization

- **Image Size**: 1024x1024 max for face detection
- **Async Loading**: All PHAsset operations async
- **Batch Limits**: Max 12 candidates displayed
- **Network Access**: Enabled for iCloud Photo Library

## Vision Framework Face Detection

### Detection Requests

```swift
// Basic face detection (faster)
VNDetectFaceRectanglesRequest
  - Revision 3 (latest)
  - Returns bounding boxes
  - ~50ms per image

// Landmarks detection (slower, more accurate)
VNDetectFaceLandmarksRequest
  - Revision 3
  - Returns eyes, nose, mouth points
  - ~150ms per image
  - Currently not used (future enhancement)
```

### Quality Scoring Algorithm

```swift
FaceQualityScore = weighted average of:
  - Confidence (30%): VNFaceObservation.confidence
  - Face Size (25%): Percentage of image area
  - Angle (20%): Roll, yaw, pitch deviation from frontal
  - Resolution (15%): Pixel dimensions of face region
  - Sharpness (5%): Laplacian variance (future)
  - Lighting (5%): Brightness statistics (future)
```

### Quality Rating Thresholds

- **Excellent**: 0.8 - 1.0 (green star)
- **Good**: 0.6 - 0.8 (blue half-star)
- **Fair**: 0.4 - 0.6 (orange outline star)
- **Poor**: 0.0 - 0.4 (red warning triangle)

## Face-Aware Cropping

### Auto-Crop Strategy

1. **Primary Face Detection**
   - Use highest confidence face
   - Calculate bounding box in normalized coordinates

2. **Padding Addition**
   - Default: 30% padding around face
   - Adjustable in PhotoCropperView

3. **Bounds Clamping**
   - Ensure crop stays within image bounds
   - Maintain aspect ratio

4. **Coordinate Conversion**
   - Vision: Bottom-left origin (0,0 = bottom-left)
   - UIKit/CGImage: Top-left origin (0,0 = top-left)
   - Always convert before cropping

### Manual Adjustments

- **Crop Scale Slider**: 0.3 - 1.0 (30% to full image)
- **Face Selector**: Switch between detected faces
- **Reset**: Return to auto-suggested crop
- **Live Preview**: Real-time crop preview

## Integration with Contact Flow

### In ContactPreviewView

```swift
// Add optional photo button
if FeatureFlags.shared.photoEnrichmentEnabled {
    Button("Add Photo") {
        showPhotoSelection = true
    }
    .sheet(isPresented: $showPhotoSelection) {
        PhotoSelectionView(contact: parsedContact) { image in
            contactPhoto = image
        }
    }
}
```

### Attaching Photo to CNContact

```swift
extension CNMutableContact {
    func setPhoto(_ image: UIImage) {
        self.imageData = image.jpegData(compressionQuality: 0.8)
    }
}
```

## Error Handling

### Photo Discovery Errors

```swift
enum PhotoDiscoveryError: LocalizedError {
    case noPermission        // User denied access
    case imageLoadFailed     // PHAsset load failed
    case cropFailed          // Image cropping failed
    case noCandidatesFound   // No matching photos
    case processingFailed    // Vision framework error
}
```

### User-Facing Messages

- **No Permission**: "Grant photo library access in Settings"
- **No Candidates**: "Try adding the person to your People album"
- **Load Failed**: "Please try again or select a different photo"

### Graceful Degradation

1. No permission → Show manual picker only
2. No candidates → Offer manual photo selection
3. Face detection fails → Allow manual crop
4. All fails → Skip photo (contact still saves)

## Performance Benchmarks

### Expected Timings (iPhone 13 Pro)

- **Permission Request**: <100ms
- **People Album Search**: 200-500ms (10 photos)
- **Face Detection**: ~50ms per photo
- **Quality Scoring**: ~10ms per face
- **Image Crop**: ~20ms
- **Total Flow**: 1-2 seconds typical

### Memory Usage

- **Per Candidate**: ~2MB (1024x1024 image)
- **12 Candidates**: ~24MB total
- **Face Detection**: +5MB temporary
- **Cropping**: +2MB temporary

### Optimization Strategies

1. **Lazy Loading**: Only load images when needed
2. **Image Caching**: PHImageManager handles caching
3. **Async Operations**: All I/O async/await
4. **Early Exit**: Stop searching when enough candidates found
5. **Result Limiting**: Max 12 candidates displayed

## Feature Flags

```swift
// Enable/disable entire photo enrichment system
FeatureFlags.shared.photoEnrichmentEnabled = true

// Usage in views
@Environment(\.featureFlags) var flags

if flags.photoEnrichmentEnabled {
    // Show photo enrichment UI
}
```

## Testing Strategies

### Unit Tests

- FaceQualityScore calculation
- Name matching fuzzy logic
- Coordinate conversion accuracy
- Error handling paths

### Integration Tests

- PhotoKit authorization flow
- Vision framework face detection
- Image cropping accuracy
- End-to-end candidate discovery

### Manual Testing

1. **Permission States**: Not determined, denied, authorized, limited
2. **Photo Scenarios**: No photos, no faces, multiple faces, low quality
3. **Name Matching**: Exact, partial, no match
4. **Edge Cases**: Very large images, portrait/landscape, corrupted images

## Future Enhancements

### Phase 1 (Current)
- ✅ Basic face detection
- ✅ Quality scoring
- ✅ Manual cropping
- ✅ People album search

### Phase 2 (Planned)
- ⏳ Face landmarks detection
- ⏳ Advanced sharpness analysis (Laplacian)
- ⏳ Lighting quality scoring
- ⏳ Multiple photo comparison side-by-side

### Phase 3 (Future)
- 🔮 Face recognition for matching
- 🔮 CoreML-based quality assessment
- 🔮 Auto-enhance before saving
- 🔮 Duplicate face detection across contacts

## Accessibility

### VoiceOver Support

- All buttons labeled
- Image quality announced
- Face count announced
- Crop controls accessible

### Dynamic Type

- All text respects user font size
- Layouts adapt to large text

### Reduced Motion

- Animations respect accessibility settings
- No essential info in animations

## Localization Ready

All user-facing strings use SwiftUI Text() and LocalizedStringKey:

```swift
Text("Add Photo")  // Auto-localizable
.accessibilityLabel("Add contact photo")  // Custom label
```

## Code Organization

```
Deets/
├── Models/
│   └── PhotoCandidate.swift          # Data model
├── Services/
│   ├── PhotoDiscoveryService.swift   # PhotoKit integration
│   └── Validation/
│       └── FaceValidator.swift       # Vision framework
├── Views/
│   ├── PhotoSelectionView.swift      # Main entry point
│   └── PhotoCropperView.swift        # Cropping UI
└── Config/
    └── FeatureFlags.swift            # photoEnrichmentEnabled flag
```

## Dependencies

- **PhotoKit** (iOS 16+)
- **Vision** (iOS 16+)
- **SwiftUI** (iOS 16+)
- **UIKit** (for UIImagePickerController)

No third-party dependencies required.

## Known Limitations

1. **People Album Accuracy**: Depends on Photos app face recognition
2. **Name Matching**: English only (future: multi-language)
3. **Face Detection**: Frontal faces work best
4. **iCloud Photos**: Requires network for non-cached images
5. **Limited Library**: Only shows user-selected photos (iOS 14+)

## Security Considerations

- No photo data leaves device
- No face biometric data stored
- Photos permission scoped to minimum necessary
- Works with Limited Photo Library Access
- Respects user's privacy choices

## Support & Troubleshooting

### Common Issues

**Q: No photos found despite having many photos**
A: Check if person is tagged in People album, or use manual picker

**Q: Face detection not working**
A: Ensure good lighting, frontal face, high resolution

**Q: Slow performance on older devices**
A: Reduce candidate limit, simplify quality scoring

**Q: Permission request not appearing**
A: Check Info.plist for NSPhotoLibraryUsageDescription

### Debug Mode

```swift
#if DEBUG
// Enable verbose logging
PhotoDiscoveryService.enableDebugLogging = true
FaceValidator.showDetectionOverlay = true
#endif
```

---

**Version**: 1.0
**Last Updated**: 2024-11-05
**Author**: LYRA - Photo Discovery & Face Validation Engineer
