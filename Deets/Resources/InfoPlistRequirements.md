# Info.plist Requirements for Deets

## Required Privacy Permissions

Add these keys to your Info.plist file to enable all features:

### Camera Access (Required)
```xml
<key>NSCameraUsageDescription</key>
<string>Deets needs camera access to scan business cards and extract contact information</string>
```

**Why**: VisionKit's DataScannerViewController requires camera permission to capture and analyze business cards.

### Contacts Access (Required)
```xml
<key>NSContactsUsageDescription</key>
<string>Deets saves scanned business cards to your contacts for easy access</string>
```

**Why**: Required to save extracted contact information to the iOS Contacts app.

## Additional Recommended Settings

### Supported Device Orientations
```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
</array>
```

**Why**: Business card scanning works best in portrait mode.

### Minimum iOS Version
Ensure your deployment target is **iOS 16.0 or later** for VisionKit DataScanner support.

### Required Device Capabilities
```xml
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>camera-flash</string>
    <string>still-camera</string>
</array>
```

**Why**: App requires camera hardware for scanning functionality.

## Usage Instructions

1. **Xcode Project**:
   - Open your project in Xcode
   - Select the target → Info tab
   - Add the privacy descriptions as custom keys

2. **project.yml** (if using XcodeGen):
   - Add these settings to the `info` section of your target
   - See project.yml in root directory for full configuration

3. **Testing**:
   - First launch will prompt for camera permission
   - First save to contacts will prompt for contacts permission
   - Both permissions can be reset in Settings → Privacy & Security

## Privacy Best Practices

- Clear descriptions explain why each permission is needed
- Permissions are requested only when needed (not on app launch)
- Camera access: requested when user taps "Start Scanning"
- Contacts access: requested when user saves a contact
- Users can deny permissions and still use limited features
