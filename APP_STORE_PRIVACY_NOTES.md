# App Store Submission - Privacy Checklist
## Deets Business Card Scanner

**Submission Date**: [To be filled]
**App Version**: 1.0
**iOS Target**: 17.0+

---

## ✅ Pre-Submission Checklist

### 1. Privacy Manifest File
- [x] **PrivacyInfo.xcprivacy created** at `/Deets/PrivacyInfo.xcprivacy`
- [x] **UserDefaults API declared** with reason code CA92.1
- [x] **File Timestamp API declared** with reason codes C617.1 and 0A2A.1
- [x] **Tracking status set to false** (no tracking)
- [x] **Data collection types declared** (Contact Info, Photos)
- [ ] **File included in Xcode project** - ACTION REQUIRED: Add to Xcode target

### 2. Info.plist Permissions
- [x] `NSCameraUsageDescription` - "Deets needs camera access to scan business cards..."
- [x] `NSPhotoLibraryUsageDescription` - "Deets can scan business cards from your photo library..."
- [x] `NSPhotoLibraryAddUsageDescription` - "Deets can save scanned business card images..."
- [ ] **`NSContactsUsageDescription` MISSING** - ACTION REQUIRED: Add before submission

**Required Addition to Info.plist**:
```xml
<!-- Contacts Usage - Required for saving to Apple Contacts -->
<key>NSContactsUsageDescription</key>
<string>Deets needs access to save scanned business cards to your Contacts.</string>
```

### 3. Privacy Policy
- [ ] **Privacy policy URL** - ACTION REQUIRED: Create and host
- [ ] **Privacy policy linked in App Store Connect**
- [ ] **Privacy policy accessible in app** (Settings > Privacy Policy)

**Suggested Privacy Policy Content**: See `PRIVACY_MANIFEST_DOCUMENTATION.md` Section 6

---

## 📋 App Store Connect Privacy Questions

### Data Collection & Usage

**Q1: Does this app collect data from users?**
- **Answer**: YES
- **Explanation**: Collects business card data (contacts) and photos for app functionality

**Q2: Is any data linked to the user's identity?**
- **Answer**: NO
- **Explanation**: All data stored locally or in user's private iCloud (not linked to identity)

**Q3: Is any data used to track the user?**
- **Answer**: NO
- **Explanation**: Zero tracking, analytics, or advertising

---

### Privacy Nutrition Labels Configuration

#### Contact Info
**Data Type**: Contact Info
- [x] Name
- [x] Email Address
- [x] Phone Number
- [x] Physical Address
- [ ] Other Contact Info

**Usage**:
- [x] App Functionality
- [ ] Analytics
- [ ] Product Personalization
- [ ] Advertising
- [ ] Other

**Linked to User**: NO
**Used for Tracking**: NO

---

#### Photos or Videos
**Data Type**: Photos or Videos
- [x] Photos
- [ ] Videos
- [ ] Other Media

**Usage**:
- [x] App Functionality (OCR scanning, contact photo enrichment)
- [ ] Analytics
- [ ] Product Personalization
- [ ] Advertising

**Linked to User**: NO
**Used for Tracking**: NO

---

#### Device ID (Optional - Only if iCloud Sync is enabled by default)
**Data Type**: Device ID
- [ ] Device ID

**Usage**:
- [x] App Functionality (iCloud sync coordination)
- [ ] Analytics
- [ ] Advertising

**Linked to User**: NO
**Used for Tracking**: NO

**NOTE**: Only declare if iCloud sync is enabled by default. If user opt-in, this may not be required.

---

## 🔒 App Store Review Guidelines Compliance

### 5.1.1 Data Collection and Storage
✅ **Compliant**: All data stored locally or in user's private iCloud
✅ **Compliant**: No unauthorized data collection
✅ **Compliant**: User explicitly grants permissions (Camera, Photos, Contacts)

### 5.1.2 Data Use and Sharing
✅ **Compliant**: Data ONLY used for core app functionality
✅ **Compliant**: No third-party data sharing
✅ **Compliant**: No advertising or analytics SDKs

### 5.1.3 Health and Health Research
❌ **Not Applicable**: No health data collected

### 5.1.4 Kids Apps
⚠️ **Consideration**: If targeting kids category:
- Ensure no third-party analytics (already compliant)
- No ads or IAP (verify this)
- Parental gate required for external links

### 5.1.5 Location Services
❌ **Not Applicable**: No location services used

---

## 🛠️ Required Actions Before Submission

### CRITICAL (App will be rejected without these)

1. **Add PrivacyInfo.xcprivacy to Xcode Project**
   ```
   - Open Deets.xcodeproj in Xcode
   - Drag PrivacyInfo.xcprivacy into project navigator
   - Ensure "Copy items if needed" is checked
   - Select "Deets" target
   - Verify file appears in "Copy Bundle Resources" build phase
   ```

2. **Add NSContactsUsageDescription to Info.plist**
   ```
   Open /Deets/Info.plist
   Add between lines 17-18 (after Photo Library Add Usage):

   <key>NSContactsUsageDescription</key>
   <string>Deets needs access to save scanned business cards to your Contacts.</string>
   ```

3. **Create Privacy Policy**
   - Host at public URL (e.g., https://deets.app/privacy)
   - Include sections from PRIVACY_MANIFEST_DOCUMENTATION.md
   - Add URL to App Store Connect

### RECOMMENDED (Improves user trust)

4. **Add Privacy Policy Link in App**
   - Create "Privacy Policy" button in Settings view
   - Open Safari/in-app web view to privacy policy URL

5. **Add Data Deletion Instructions**
   - Document how users can delete their data
   - (Currently: Delete contacts from Apple Contacts, disable iCloud sync)

6. **Test All Permission Flows**
   - Fresh install on physical device
   - Verify all permission prompts show correct strings
   - Test denial scenarios (graceful degradation)

---

## 🧪 Testing Procedure

### Pre-Submission Build Test

```bash
# 1. Clean build
cd "/Volumes/Ext-code/GitHub Repos/Deets"
xcodebuild clean -project Deets.xcodeproj -scheme Deets

# 2. Archive for App Store
xcodebuild archive \
  -project Deets.xcodeproj \
  -scheme Deets \
  -archivePath ./build/Deets.xcarchive

# 3. Verify Privacy Manifest is included
unzip -l ./build/Deets.xcarchive/Products/Applications/Deets.app.zip | grep PrivacyInfo
# Expected output: PrivacyInfo.xcprivacy

# 4. Validate manifest XML
plutil -lint ./Deets/PrivacyInfo.xcprivacy
# Expected output: OK

# 5. Export for App Store
xcodebuild -exportArchive \
  -archivePath ./build/Deets.xcarchive \
  -exportOptionsPlist exportOptions.plist \
  -exportPath ./build/Export
```

### Runtime Testing Checklist

**Permission Prompts**:
- [ ] Camera permission shows correct string
- [ ] Photo Library read permission shows correct string
- [ ] Photo Library write permission shows correct string
- [ ] Contacts permission shows correct string (AFTER adding to Info.plist)

**Feature Testing**:
- [ ] UserDefaults (feature flags load/save correctly)
- [ ] File timestamps display correctly in card list
- [ ] Photo library access works (photo enrichment)
- [ ] Contact saving works (export to Apple Contacts)
- [ ] iCloud sync toggle works (if enabled)

**Privacy Validation**:
- [ ] No Xcode privacy warnings during build
- [ ] No crashes on permission denial
- [ ] App works in "deny all permissions" mode (gracefully degrades)

---

## 📱 TestFlight Pre-Release

Before public App Store submission, test via TestFlight:

### TestFlight Privacy Review
1. Upload build to TestFlight
2. Verify no Apple warnings about missing privacy declarations
3. Test on fresh device (no previous app data)
4. Invite 5-10 beta testers
5. Collect feedback on permission prompts (are they clear?)

### Expected TestFlight Warnings
**None expected** if all actions above completed.

**If you see warnings**:
- "Missing privacy manifest" → Verify file is in app bundle
- "Undeclared API usage" → Check for new frameworks/APIs not in manifest
- "Missing usage description" → Add to Info.plist

---

## 🚀 App Store Connect Configuration

### App Information
**Privacy Policy URL**: [TO BE ADDED]
**Support URL**: [TO BE ADDED]
**Marketing URL**: [OPTIONAL]

### App Privacy
**Privacy Policy**: Link to hosted privacy policy
**Privacy Nutrition Labels**: Configure as per section above

### Age Rating
**Suggested Rating**: 4+ (No restricted content)

**Content Descriptors**:
- None (business productivity app)

**Restrictions**:
- [ ] Unrestricted Web Access (if in-app browser for privacy policy)

---

## 🔍 Common Rejection Reasons & Solutions

### Rejection: "Missing privacy manifest"
**Solution**: Ensure PrivacyInfo.xcprivacy is added to Xcode target and included in bundle

### Rejection: "Undeclared API usage"
**Solution**: Review build logs for privacy warnings, add missing APIs to manifest

### Rejection: "Inconsistent privacy declarations"
**Solution**: Ensure Info.plist strings match Privacy Manifest declarations

### Rejection: "Missing privacy policy"
**Solution**: Host privacy policy at public URL, add to App Store Connect

### Rejection: "Insufficient usage description"
**Solution**: Expand permission strings to clearly explain WHY permission is needed

---

## 📊 Privacy Manifest API Reason Codes Reference

### UserDefaults (CA92.1)
**When to use**: Reading/writing app-specific settings and preferences
**Deets usage**: Feature flags, sync settings, user preferences
**Compliant**: ✅ Only accessing app's own UserDefaults

### File Timestamp (C617.1)
**When to use**: Displaying file timestamps to user
**Deets usage**: "Added 3 days ago" in card list, "Last synced" status
**Compliant**: ✅ Only displaying user-visible dates

### File Timestamp (0A2A.1)
**When to use**: Accessing timestamps of app-created or user-selected files
**Deets usage**: Photo creation dates for sorting/filtering
**Compliant**: ✅ Only accessing photos user granted access to

---

## 📞 Support Contacts for App Review

**Developer Contact**: [TO BE ADDED]
**Support Email**: [TO BE ADDED]
**Review Notes**:

```
Test Account (if needed): N/A - No login required
Demo Video: [OPTIONAL - Link to video showing features]

Notes for Apple Reviewer:
- To test scanning: Grant camera permission, scan any business card or printed text
- To test contacts export: Grant contacts permission, tap "Save to Contacts" after scan
- To test photo enrichment: Grant photo library permission, scan a contact, tap "Add Photo"
- To test iCloud sync: Enable in Settings (requires reviewer's iCloud account)

All features work without any permissions - app gracefully handles denied permissions.
No server/API keys required - all processing happens on-device.
```

---

## ✅ Final Pre-Submission Checklist

**Code & Build**:
- [ ] PrivacyInfo.xcprivacy added to Xcode project
- [ ] NSContactsUsageDescription added to Info.plist
- [ ] No Xcode warnings related to privacy
- [ ] Archive builds successfully
- [ ] Privacy Manifest included in .ipa bundle

**Documentation**:
- [ ] Privacy policy created and hosted
- [ ] Privacy policy URL added to App Store Connect
- [ ] Support URL configured
- [ ] Review notes prepared

**Testing**:
- [ ] All permission prompts tested on physical device
- [ ] TestFlight build uploaded and tested
- [ ] No crashes on permission denial
- [ ] Privacy Nutrition Labels configured in App Store Connect

**Legal**:
- [ ] Privacy policy reviewed by legal (if required)
- [ ] Terms of service created (if applicable)
- [ ] GDPR compliance verified (if targeting EU)
- [ ] COPPA compliance verified (if targeting children)

---

## 📅 Timeline

**Estimated App Review Time**: 24-48 hours (Apple standard)
**Privacy Review Time**: +12-24 hours (for first submission with Privacy Manifest)
**Total Estimate**: 2-4 business days

**Expedited Review**: Available if critical bug fix (not applicable for new app)

---

## 🎯 Success Criteria

**Approved When**:
✅ Privacy Manifest correctly declares all API usage
✅ Privacy Nutrition Labels match actual data collection
✅ All permission prompts clear and accurate
✅ Privacy policy accessible and comprehensive
✅ No privacy warnings in Xcode or TestFlight
✅ App functions correctly with denied permissions

---

**Document Version**: 1.0
**Last Updated**: 2025-11-05
**Next Review**: After first App Store submission feedback
