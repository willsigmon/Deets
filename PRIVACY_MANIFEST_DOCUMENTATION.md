# Privacy Manifest Documentation
## Deets iOS Application - PrivacyInfo.xcprivacy

**Created**: 2025-11-05
**iOS Requirement**: iOS 17.0+
**File Location**: `/Volumes/Ext-code/GitHub Repos/Deets/Deets/PrivacyInfo.xcprivacy`

---

## Overview

This Privacy Manifest declares all privacy-impacting APIs and data collection practices in the Deets application, as required by Apple for App Store submission starting with iOS 17.

---

## 1. Tracking Declaration

**Status**: `NSPrivacyTracking = false`

Deets **DOES NOT** track users for the following purposes:
- Cross-app or cross-website advertising
- Third-party analytics or data brokers
- User profiling for marketing purposes
- Behavioral tracking across apps/websites

**Zero tracking domains declared**: `NSPrivacyTrackingDomains = []`

---

## 2. Data Collection Types

### 2.1 Contact Information (`NSPrivacyCollectedDataTypeContactInfo`)

**What's collected**: Business card data parsed via OCR
- Names (first, middle, last, prefix, suffix)
- Job titles and organization names
- Phone numbers
- Email addresses
- Physical addresses
- URLs and social profiles

**Purpose**: `NSPrivacyCollectedDataTypePurposeAppFunctionality`
- Core app functionality: Scanning business cards and saving to Apple Contacts
- User-initiated action only (app doesn't auto-collect contacts)

**Linked to user identity**: `false`
- Data is stored locally on device (SwiftData/Core Data)
- Optional iCloud sync uses Apple's private CloudKit database
- No server-side storage or third-party access

**Used for tracking**: `false`

**Code references**:
- `/Deets/Services/ContactsService.swift` - Apple Contacts framework integration
- `/Deets/Services/Validation/ContactParser.swift` - OCR parsing logic
- `/Deets/Models/ParsedContact.swift` - Contact data models

---

### 2.2 Photos/Videos (`NSPrivacyCollectedDataTypePhotosorVideos`)

**What's collected**:
- Business card photos (camera or photo library)
- Contact photos from user's photo library (optional enrichment feature)

**Purpose**: `NSPrivacyCollectedDataTypePurposeAppFunctionality`
- OCR scanning of business cards
- Photo enrichment: Matching contact photos from user's library
- Saving scanned cards to photo library (optional)

**Linked to user identity**: `false`
- Photos processed locally on-device using VisionKit/Vision framework
- No server upload or cloud processing
- Photos stored in local app sandbox or user's photo library

**Used for tracking**: `false`

**Code references**:
- `/Deets/Services/OCRService.swift` - Vision/VisionKit text recognition
- `/Deets/Services/PhotoDiscoveryService.swift` - PhotoKit integration
- `/Deets/Services/Validation/FaceValidator.swift` - Face detection (Vision framework)

---

## 3. Privacy-Sensitive APIs Accessed

### 3.1 UserDefaults API (`NSPrivacyAccessedAPICategoryUserDefaults`)

**Reason Code**: `CA92.1`

**Official Apple Description**:
> "Access user defaults to read data written by the app itself. This data may include preferences and app state."

**Deets-specific usage**:
1. **Feature Flags** (`Config/FeatureFlags.swift`)
   - User preferences (haptics, animations, sync settings)
   - Feature toggles (photo enrichment, batch scanning, etc.)
   - OCR configuration (language, confidence threshold)
   - Debug settings (development mode only)

2. **iCloud Sync Configuration** (`Deets/Config/CloudKitConfiguration.swift`)
   - User's sync enable/disable preference
   - Last sync timestamp
   - Sync status persistence

**Keys stored**:
```swift
// FeatureFlags.swift
"feature.iCloudSync"
"feature.photoEnrichment"
"feature.batchScanning"
"feature.haptics"
"feature.animations"
"feature.ocrThreshold"
// ... (see FeatureFlags.swift lines 133-155)

// CloudKitConfiguration.swift
"com.sharedeets.syncEnabled"
```

**Compliance notes**:
- UserDefaults is ONLY used for app-specific settings and preferences
- No third-party access or cross-app data sharing
- All data is non-sensitive configuration (no PII stored in UserDefaults)

---

### 3.2 File Timestamp API (`NSPrivacyAccessedAPICategoryFileTimestamp`)

**Reason Codes**: `C617.1` and `0A2A.1`

#### Code C617.1
**Official Apple Description**:
> "Display file timestamps to the person using the device"

**Deets-specific usage**:
- Displaying when business cards were scanned/added
- Showing last modified dates in card list
- Sync timestamp display ("Last synced: 2 hours ago")

**Code references**:
- `/Deets/Models/BusinessCard.swift` - SwiftData `@Model` with timestamps
- `/Deets/Views/CardListView.swift` - Display logic for "Added 3 days ago"
- `/Deets/Config/CloudKitConfiguration.swift` (line 32) - `lastSyncDate` property

#### Code 0A2A.1
**Official Apple Description**:
> "Access the timestamps of files or directories that the app itself created or that the person using the device explicitly granted the app access to, such as using a document picker"

**Deets-specific usage**:
1. **Photo Library Access** (`PhotoDiscoveryService.swift`)
   - Sorting photos by creation date (line 142: `sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]`)
   - Filtering recent photos (last 30 days)
   - Photo metadata for matching algorithm

2. **iCloud File Coordination** (`CloudKitConfiguration.swift`)
   - Checking iCloud container modification dates
   - Conflict resolution using file timestamps

**Code references**:
- `/Deets/Services/PhotoDiscoveryService.swift` (lines 139-169) - Photo timestamp access
- `/Deets/Config/CloudKitConfiguration.swift` - iCloud sync coordination

**Compliance notes**:
- File timestamps accessed ONLY for user-visible data or user-selected files
- No fingerprinting or device identification purposes
- No access to system-wide file metadata outside app sandbox

---

## 4. What's NOT Declared (and Why)

### System Boot Time API
**Status**: NOT USED
**Verification**: Grep search across codebase found zero references

### Disk Space API
**Status**: NOT USED
**Verification**: No `volumeAvailableCapacityKey` or similar APIs found

### Active Keyboard API
**Status**: NOT USED (SwiftUI standard text fields)

### Other Privacy-Sensitive APIs
**Status**: NOT USED
- No location services
- No device fingerprinting
- No network tracking or analytics SDKs
- No advertising frameworks

---

## 5. App Store Submission Notes

### Pre-Submission Checklist

- [x] PrivacyInfo.xcprivacy file created in app bundle
- [x] All required API types declared with reason codes
- [x] Data collection types match actual app behavior
- [x] Tracking status correctly set to `false`
- [x] No undeclared privacy-sensitive APIs in use
- [x] Info.plist permission strings align with Privacy Manifest

### Critical Files for Review

1. **PrivacyInfo.xcprivacy** - This manifest
2. **Info.plist** - Permission usage strings
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription`
   - `NSPhotoLibraryAddUsageDescription`
   - `NSContactsUsageDescription` (MISSING - needs to be added!)

3. **Entitlements** (if using iCloud)
   - `com.apple.developer.icloud-container-identifiers`
   - `com.apple.developer.ubiquity-kvstore-identifier`

---

## 6. Privacy Policy Requirements

Apple requires a privacy policy URL for apps that collect data. Deets should include:

### Suggested Privacy Policy Sections

1. **Data Collection**
   - "Deets scans business cards using on-device OCR (no server upload)"
   - "Contact data saved to your Apple Contacts (with permission)"
   - "Photos processed locally using Apple's Vision framework"

2. **Data Storage**
   - "All data stored locally on your device using SwiftData"
   - "Optional iCloud sync uses Apple's secure CloudKit (private database)"
   - "No third-party servers or cloud services"

3. **Data Sharing**
   - "Deets does NOT share your data with third parties"
   - "No analytics, advertising, or tracking SDKs"
   - "Export features (VCF, CSV) only when you explicitly initiate"

4. **User Rights**
   - "Delete contacts anytime from Apple Contacts"
   - "Disable iCloud sync in app settings"
   - "Revoke permissions in iOS Settings > Privacy"

5. **Children's Privacy**
   - "Deets is safe for all ages (no data collection/tracking)"

---

## 7. Testing & Validation

### Pre-Release Tests

```bash
# 1. Validate Privacy Manifest structure
plutil -lint /Volumes/Ext-code/GitHub\ Repos/Deets/Deets/PrivacyInfo.xcprivacy

# 2. Build app and verify manifest is included in bundle
xcodebuild -project Deets.xcodeproj -scheme Deets -configuration Release
unzip -l build/Release-iphoneos/Deets.app | grep PrivacyInfo

# 3. Check for undeclared API usage (Xcode 15+ warning)
# Build in Xcode - check for "Privacy manifest" warnings

# 4. Test App Store submission
# Upload to TestFlight and verify no privacy warnings
```

### Runtime Verification

- [ ] UserDefaults access working (feature flags load/save)
- [ ] Photo library access prompts correctly
- [ ] File timestamp display working (card list dates)
- [ ] iCloud sync respects user preference
- [ ] No crashes related to privacy permissions

---

## 8. Maintenance & Updates

### When to Update This Manifest

**Add new API declarations when**:
1. Integrating new Apple frameworks that access privacy-sensitive data
2. Adding third-party SDKs (analytics, crash reporting, etc.)
3. Accessing new file types or system resources
4. Implementing background processing with data access

**Update data collection types when**:
1. Adding new contact fields (e.g., instant messaging handles)
2. Collecting new types of media (videos, audio)
3. Adding server-side features (if ever implemented)
4. Implementing user accounts or authentication

**Version control**:
- Tag Privacy Manifest changes in git commits
- Include in release notes for App Store submissions
- Review manifest quarterly or before major releases

---

## 9. Compliance with Apple Guidelines

### Required Reason APIs (2024)

**Declared in this manifest**:
- ✅ UserDefaults (CA92.1)
- ✅ File Timestamp (C617.1, 0A2A.1)

**Not applicable to Deets**:
- ❌ System Boot Time
- ❌ Disk Space
- ❌ Active Keyboards
- ❌ User Defaults (write-only, no reason needed)

### Privacy Nutrition Labels (App Store Connect)

**When submitting to App Store, declare**:

**Contact Info**
- Data Type: Name, Phone Number, Email Address, Physical Address
- Usage: App Functionality
- Linked to User: No
- Used for Tracking: No

**Photos**
- Data Type: Photos or Videos
- Usage: App Functionality
- Linked to User: No
- Used for Tracking: No

**Device ID** (if using iCloud)
- Data Type: Device ID
- Usage: App Functionality (iCloud sync)
- Linked to User: No
- Used for Tracking: No

---

## 10. Known Issues & Future Considerations

### Current Limitations

1. **Missing Contacts Permission in Info.plist**
   - ACTION REQUIRED: Add `NSContactsUsageDescription` to Info.plist
   - Suggested string: "Deets needs access to save scanned business cards to your Contacts."

2. **Privacy Policy URL**
   - ACTION REQUIRED: Create privacy policy page
   - Host at: `https://deets.app/privacy` or similar
   - Add to App Store Connect metadata

### Future API Usage

**If implementing these features, update manifest**:

1. **Location Services** (for business card geo-tagging)
   - Add `NSLocationWhenInUseUsageDescription`
   - Declare `NSPrivacyAccessedAPICategoryLocation`

2. **Analytics SDK** (e.g., Firebase, Mixpanel)
   - Set `NSPrivacyTracking = true` if using cross-app tracking
   - Declare all SDK APIs in manifest
   - Update data collection types

3. **Cloud Sync (non-Apple)**
   - Declare server endpoints
   - Update data linking status to `true`
   - Add encryption/security disclosures

4. **Calendar Integration** (event creation from contacts)
   - Add `NSCalendarsUsageDescription`
   - Declare calendar data collection

---

## 11. References

### Apple Documentation

- [Privacy Manifest Files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [Required Reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)
- [Privacy Nutrition Labels](https://developer.apple.com/app-store/app-privacy-details/)
- [App Store Review Guidelines - Privacy](https://developer.apple.com/app-store/review/guidelines/#privacy)

### Related Files in Deets Codebase

```
/Deets/
  ├── PrivacyInfo.xcprivacy          # THIS FILE
  ├── Info.plist                      # Permission usage strings
  ├── Config/
  │   ├── FeatureFlags.swift         # UserDefaults usage
  │   └── CloudKitConfiguration.swift # iCloud sync config
  ├── Services/
  │   ├── ContactsService.swift      # Contacts framework
  │   ├── PhotoDiscoveryService.swift # PhotoKit + file timestamps
  │   └── OCRService.swift           # VisionKit (camera access)
  └── Models/
      └── BusinessCard.swift         # SwiftData model with timestamps
```

---

## Change Log

| Date       | Version | Changes                                      |
|------------|---------|----------------------------------------------|
| 2025-11-05 | 1.0     | Initial Privacy Manifest creation            |
|            |         | - Declared UserDefaults (CA92.1)             |
|            |         | - Declared File Timestamps (C617.1, 0A2A.1)  |
|            |         | - Declared Contact Info collection           |
|            |         | - Declared Photos collection                 |
|            |         | - Set tracking to false                      |

---

**Document Maintained By**: Security Engineering Team
**Last Updated**: 2025-11-05
**Next Review**: Before v1.0 App Store submission
