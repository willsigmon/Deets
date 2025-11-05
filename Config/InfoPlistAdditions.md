# Info.plist Privacy Permissions

**For Deets iOS App**
**Required for App Store Submission**

## Overview

Apple requires all iOS apps to include usage descriptions for sensitive permissions in the `Info.plist` file. These descriptions appear in system permission prompts when your app requests access to device capabilities.

**Critical:** Apps submitted without proper usage descriptions will be rejected by App Store Review.

---

## Required Info.plist Entries

### 1. Camera Access (Required - Phase 1)

**Key:** `NSCameraUsageDescription`

**Description:**
```
Deets needs camera access to scan business cards and contact information. Photos are processed on your device and never sent to external servers.
```

**XML Entry:**
```xml
<key>NSCameraUsageDescription</key>
<string>Deets needs camera access to scan business cards and contact information. Photos are processed on your device and never sent to external servers.</string>
```

**When Triggered:**
- User taps "Scan New Contact" or camera button
- First time app attempts to access camera
- Prompt appears: "Deets Would Like to Access the Camera"

**User Experience:**
- Clear explanation of why camera is needed (scan business cards)
- Privacy reassurance (processed locally, not sent to servers)
- Concise and user-friendly language

---

### 2. Contacts Access (Required - Phase 1)

**Key:** `NSContactsUsageDescription`

**Description:**
```
Deets needs access to your Contacts to save scanned contact information and help you manage your network. All data stays on your device.
```

**XML Entry:**
```xml
<key>NSContactsUsageDescription</key>
<string>Deets needs access to your Contacts to save scanned contact information and help you manage your network. All data stays on your device.</string>
```

**When Triggered:**
- User attempts to save a scanned contact
- App tries to read existing contacts for merging/deduplication
- First time app accesses Contacts framework
- Prompt appears: "Deets Would Like to Access Your Contacts"

**User Experience:**
- Explains core functionality (save scanned contacts)
- Privacy reassurance (data stays on device)
- Builds trust before granting sensitive permission

---

### 3. Photo Library Access (Optional - Phase 2)

**Key:** `NSPhotoLibraryUsageDescription`

**Description:**
```
Deets can import existing photos of business cards from your Photo Library. You choose which photos to import, and they are processed locally on your device.
```

**XML Entry:**
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Deets can import existing photos of business cards from your Photo Library. You choose which photos to import, and they are processed locally on your device.</string>
```

**When Triggered (Phase 2):**
- User selects "Import from Photos" feature
- App attempts to access photo library
- Prompt appears: "Deets Would Like to Access Your Photos"

**User Experience:**
- Clarifies user has control (choose which photos)
- Privacy reassurance (processed locally)
- Optional feature, not required for core functionality

**Note:** If implementing limited photo library access (iOS 14+), use:
```xml
<key>PHPhotoLibraryPreventAutomaticLimitedAccessAlert</key>
<true/>
```
This prevents the system from automatically prompting users to grant full access when limited access is selected.

---

### 4. Photo Library Add-Only Access (Optional - Phase 2+)

**Key:** `NSPhotoLibraryAddUsageDescription`

**Description:**
```
Deets can save scanned business card photos to your Photo Library for backup and archiving purposes.
```

**XML Entry:**
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Deets can save scanned business card photos to your Photo Library for backup and archiving purposes.</string>
```

**When Triggered (Future Feature):**
- User selects "Save to Photos" after scanning
- App attempts to save image to photo library
- Prompt appears: "Deets Would Like to Add Photos"

**User Experience:**
- Explains export/backup functionality
- Less invasive than full photo library access
- Recommended for write-only operations

---

## Complete Info.plist Template

### Minimal Configuration (Phase 1)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Information -->
    <key>CFBundleName</key>
    <string>Deets</string>

    <key>CFBundleDisplayName</key>
    <string>Deets</string>

    <key>CFBundleIdentifier</key>
    <string>com.yourcompany.deets</string>

    <key>CFBundleVersion</key>
    <string>1</string>

    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>

    <!-- REQUIRED PRIVACY PERMISSIONS -->

    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>Deets needs camera access to scan business cards and contact information. Photos are processed on your device and never sent to external servers.</string>

    <!-- Contacts Permission -->
    <key>NSContactsUsageDescription</key>
    <string>Deets needs access to your Contacts to save scanned contact information and help you manage your network. All data stays on your device.</string>

    <!-- Supported Interface Orientations -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

### Full Configuration (Phase 2 - with Photo Library)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Information -->
    <key>CFBundleName</key>
    <string>Deets</string>

    <key>CFBundleDisplayName</key>
    <string>Deets</string>

    <key>CFBundleIdentifier</key>
    <string>com.yourcompany.deets</string>

    <key>CFBundleVersion</key>
    <string>1</string>

    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>

    <!-- REQUIRED PRIVACY PERMISSIONS -->

    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>Deets needs camera access to scan business cards and contact information. Photos are processed on your device and never sent to external servers.</string>

    <!-- Contacts Permission -->
    <key>NSContactsUsageDescription</key>
    <string>Deets needs access to your Contacts to save scanned contact information and help you manage your network. All data stays on your device.</string>

    <!-- Photo Library Read Permission (Phase 2) -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Deets can import existing photos of business cards from your Photo Library. You choose which photos to import, and they are processed locally on your device.</string>

    <!-- Photo Library Write Permission (Phase 2) -->
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Deets can save scanned business card photos to your Photo Library for backup and archiving purposes.</string>

    <!-- Prevent automatic limited access prompt (iOS 14+) -->
    <key>PHPhotoLibraryPreventAutomaticLimitedAccessAlert</key>
    <true/>

    <!-- Supported Interface Orientations -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

---

## SwiftUI Project Configuration

If using Xcode's project settings UI instead of directly editing Info.plist:

### Camera Permission
1. Open Xcode project
2. Select app target
3. Go to **Info** tab
4. Click **+** next to "Custom iOS Target Properties"
5. Add key: **Privacy - Camera Usage Description**
6. Set value: `Deets needs camera access to scan business cards and contact information. Photos are processed on your device and never sent to external servers.`

### Contacts Permission
1. Click **+** again
2. Add key: **Privacy - Contacts Usage Description**
3. Set value: `Deets needs access to your Contacts to save scanned contact information and help you manage your network. All data stays on your device.`

### Photo Library Permission (Phase 2)
1. Click **+** again
2. Add key: **Privacy - Photo Library Usage Description**
3. Set value: `Deets can import existing photos of business cards from your Photo Library. You choose which photos to import, and they are processed locally on your device.`

4. Click **+** again
5. Add key: **Privacy - Photo Library Additions Usage Description**
6. Set value: `Deets can save scanned business card photos to your Photo Library for backup and archiving purposes.`

---

## Permission Request Code Examples

### Requesting Camera Access (Swift/SwiftUI)

```swift
import AVFoundation

func requestCameraAccess(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        // Already authorized
        completion(true)

    case .notDetermined:
        // Request permission
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }

    case .denied, .restricted:
        // Permission denied - show settings alert
        completion(false)

    @unknown default:
        completion(false)
    }
}
```

### Requesting Contacts Access (Swift)

```swift
import Contacts

func requestContactsAccess(completion: @escaping (Bool) -> Void) {
    let store = CNContactStore()

    switch CNContactStore.authorizationStatus(for: .contacts) {
    case .authorized:
        // Already authorized
        completion(true)

    case .notDetermined:
        // Request permission
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }

    case .denied, .restricted:
        // Permission denied - show settings alert
        completion(false)

    @unknown default:
        completion(false)
    }
}
```

### Requesting Photo Library Access (Swift - Phase 2)

```swift
import Photos

func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized, .limited:
        // Authorized (full or limited)
        completion(true)

    case .notDetermined:
        // Request permission
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }

    case .denied, .restricted:
        // Permission denied - show settings alert
        completion(false)

    @unknown default:
        completion(false)
    }
}
```

---

## User-Friendly Permission Alerts

### Pre-Permission Education

Before requesting sensitive permissions, show a custom alert explaining why:

```swift
func showCameraPermissionEducation() {
    let alert = UIAlertController(
        title: "Camera Access",
        message: "Deets uses your camera to scan business cards and extract contact information. All processing happens on your device—no data is sent to servers.",
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
        self.requestCameraAccess { granted in
            // Handle result
        }
    })

    alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))

    present(alert, animated: true)
}
```

### Permission Denied - Settings Redirect

When permission is denied, guide users to Settings:

```swift
func showSettingsAlert(for permission: String) {
    let alert = UIAlertController(
        title: "\(permission) Access Required",
        message: "Deets needs \(permission.lowercased()) access to function properly. You can enable this in Settings.",
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    })

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    present(alert, animated: true)
}
```

---

## App Store Review Considerations

### Common Rejection Reasons

**Guideline 5.1.1(i) - Data Collection and Storage:**
- ❌ **Rejection:** Missing or vague usage description
- ✅ **Fix:** Provide clear, specific, user-friendly descriptions

**Guideline 2.1 - App Completeness:**
- ❌ **Rejection:** App crashes when permission is denied
- ✅ **Fix:** Gracefully handle denied permissions with informative messages

**Guideline 5.1.1(v) - Privacy - Location Services:**
- ❌ **Rejection:** Requesting permissions not used by the app
- ✅ **Fix:** Only include permissions for actually-used features

### Best Practices

1. **Request Permissions Just-In-Time:**
   - Don't ask for all permissions on first launch
   - Request camera permission when user taps "Scan Contact"
   - Request contacts permission when user taps "Save Contact"

2. **Provide Context Before Requesting:**
   - Show custom alert explaining why permission is needed
   - THEN request system permission
   - Increases grant rate and builds trust

3. **Handle Denied Permissions Gracefully:**
   - Don't show system permission prompt repeatedly (iOS prevents this)
   - Show custom alert with "Open Settings" button
   - Provide fallback functionality where possible

4. **Test Permission Flows:**
   - Test first-time request flow
   - Test denied permission flow
   - Test settings redirect flow
   - Test limited photo library access (iOS 14+)

5. **Clear, Honest Language:**
   - Avoid technical jargon ("OCR", "framework", "API")
   - Explain user benefit ("scan business cards")
   - Reassure privacy ("processed on your device")

---

## Permission Testing Checklist

Before App Store submission, verify:

- [ ] All usage descriptions are present in Info.plist
- [ ] Descriptions are clear, concise, and user-friendly
- [ ] Descriptions accurately reflect app behavior
- [ ] App requests permissions at appropriate times (not all at launch)
- [ ] App handles denied permissions gracefully (no crashes)
- [ ] Custom permission education alerts are shown before system prompts
- [ ] Settings redirect works when permission is denied
- [ ] App functions correctly with limited photo library access (Phase 2)
- [ ] No permissions are requested that aren't actually used
- [ ] Permission descriptions match Privacy Policy and Privacy Nutrition Label

### Testing on Simulator

**Reset Permissions:**
```bash
# Reset all permissions for app
xcrun simctl privacy booted reset all com.yourcompany.deets

# Reset specific permission
xcrun simctl privacy booted reset camera com.yourcompany.deets
xcrun simctl privacy booted reset contacts com.yourcompany.deets
xcrun simctl privacy booted reset photos com.yourcompany.deets
```

**Grant Permission (for testing granted state):**
```bash
xcrun simctl privacy booted grant camera com.yourcompany.deets
xcrun simctl privacy booted grant contacts com.yourcompany.deets
xcrun simctl privacy booted grant photos com.yourcompany.deets
```

**Revoke Permission (for testing denied state):**
```bash
xcrun simctl privacy booted revoke camera com.yourcompany.deets
xcrun simctl privacy booted revoke contacts com.yourcompany.deets
xcrun simctl privacy booted revoke photos com.yourcompany.deets
```

---

## Localization Considerations

If localizing Deets for multiple languages, localize usage descriptions:

### Info.plist Localization

1. Create `InfoPlist.strings` file for each language:
   - `en.lproj/InfoPlist.strings` (English)
   - `es.lproj/InfoPlist.strings` (Spanish)
   - `fr.lproj/InfoPlist.strings` (French)
   - etc.

2. Add localized usage descriptions:

**en.lproj/InfoPlist.strings:**
```
"NSCameraUsageDescription" = "Deets needs camera access to scan business cards and contact information. Photos are processed on your device and never sent to external servers.";
"NSContactsUsageDescription" = "Deets needs access to your Contacts to save scanned contact information and help you manage your network. All data stays on your device.";
```

**es.lproj/InfoPlist.strings:**
```
"NSCameraUsageDescription" = "Deets necesita acceso a la cámara para escanear tarjetas de presentación e información de contacto. Las fotos se procesan en su dispositivo y nunca se envían a servidores externos.";
"NSContactsUsageDescription" = "Deets necesita acceso a sus Contactos para guardar la información de contacto escaneada y ayudarle a gestionar su red. Todos los datos permanecen en su dispositivo.";
```

---

## Additional Privacy Keys (Reference)

**Not needed for Deets Phase 1, but included for reference:**

### Location Services
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Description of why you need location</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Description of why you need always-on location</string>
```

### Microphone
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Description of why you need microphone</string>
```

### Bluetooth
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Description of why you need Bluetooth</string>
```

### Motion & Fitness
```xml
<key>NSMotionUsageDescription</key>
<string>Description of why you need motion data</string>
```

### Calendar & Reminders
```xml
<key>NSCalendarsUsageDescription</key>
<string>Description of why you need calendar access</string>

<key>NSRemindersUsageDescription</key>
<string>Description of why you need reminders access</string>
```

---

## Legal Compliance Notes

### GDPR Considerations
- Usage descriptions should align with "lawful basis for processing" (consent)
- Clear, specific language is required (avoid vague or misleading descriptions)
- Users must be able to withdraw consent (deny permission, delete app)

### CCPA Considerations
- Usage descriptions constitute notice of data collection
- Must accurately describe data practices
- Cannot be misleading or deceptive

### Children's Privacy (COPPA)
- If app is directed at children under 13, additional restrictions apply
- Deets is not directed at children (general audience app)
- Do not use language that appeals to children

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | 2025-11-05 | Initial Info.plist documentation | MIRA |

---

## Related Documentation

- [Privacy Policy](../Privacy/policy.md)
- [App Store Privacy Nutrition Label](../Privacy/app-store-privacy-nutrition.md)
- [Data Handling Guide](../Privacy/data-handling-guide.md)

---

## Apple Official Resources

- [Requesting Access to Protected Resources](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy/requesting_access_to_protected_resources)
- [Purpose String Keys](https://developer.apple.com/documentation/bundleresources/information_property_list/protected_resources)
- [App Store Review Guidelines - Privacy](https://developer.apple.com/app-store/review/guidelines/#privacy)

---

**Document ID:** DEETS-INFOPLIST-PRIVACY-2025
**Review Cycle:** Before each major release
**Last Audit:** 2025-11-05

---

**End of Info.plist Privacy Permissions Documentation**
