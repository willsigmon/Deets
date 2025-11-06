# Xcode Build Settings Reference

## Critical Build Settings to Verify

These settings MUST be configured correctly in your Xcode project for the build to succeed.

### Access Build Settings
1. Open project in Xcode
2. Select **Deets** project in navigator
3. Select **Deets** target
4. Click **Build Settings** tab
5. Set filter to "All" and "Combined"

---

## Required Settings

### Product Configuration

| Setting | Search Term | Required Value | Purpose |
|---------|-------------|----------------|---------|
| **Product Name** | `PRODUCT_NAME` | `Deets` or `$(TARGET_NAME)` | Defines the app name |
| **Product Module Name** | `PRODUCT_MODULE_NAME` | `Deets` or `$(TARGET_NAME)` | Swift module identifier |
| **Product Bundle Identifier** | `PRODUCT_BUNDLE_IDENTIFIER` | `com.yourteam.Deets` | Unique app identifier |
| **Info.plist File** | `INFOPLIST_FILE` | `Deets/Info.plist` | Path to Info.plist |

### Asset Catalog

| Setting | Search Term | Required Value | Purpose |
|---------|-------------|----------------|---------|
| **Asset Catalog Compiler - App Icon** | `ASSETCATALOG_COMPILER_APPICON_NAME` | `AppIcon` | Names the app icon set |
| **Asset Catalog Compiler - Global Accent Color** | `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME` | (Optional) | Sets accent color |

### Swift Compiler

| Setting | Search Term | Required Value | Purpose |
|---------|-------------|----------------|---------|
| **Swift Language Version** | `SWIFT_VERSION` | `5.0` | Swift version to use |

### Deployment

| Setting | Search Term | Required Value | Purpose |
|---------|-------------|----------------|---------|
| **iOS Deployment Target** | `IPHONEOS_DEPLOYMENT_TARGET` | `16.0` or later | Minimum iOS version |

### Code Signing

| Setting | Search Term | Required Value | Purpose |
|---------|-------------|----------------|---------|
| **Code Signing Identity** | `CODE_SIGN_IDENTITY` | `Apple Development` | For development builds |
| **Development Team** | `DEVELOPMENT_TEAM` | Your Team ID | Your developer account |

---

## How to Set These Values

### Method 1: Using Build Settings UI (Recommended)

1. In Xcode, select your target
2. Go to **Build Settings**
3. Use the search box to find each setting
4. Double-click the value column to edit
5. Enter the required value
6. Press Enter to save

### Method 2: Using project.pbxproj (Advanced)

If you're comfortable editing the project file directly:

1. Close Xcode
2. Open `Deets.xcodeproj/project.pbxproj` in a text editor
3. Find the `XCBuildConfiguration` section for your target
4. Add or update these lines:

```
PRODUCT_NAME = Deets;
PRODUCT_MODULE_NAME = Deets;
PRODUCT_BUNDLE_IDENTIFIER = com.yourteam.Deets;
INFOPLIST_FILE = Deets/Info.plist;
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
SWIFT_VERSION = 5.0;
IPHONEOS_DEPLOYMENT_TARGET = 16.0;
```

5. Save and reopen in Xcode

---

## Verification Script

Use this script to check your settings from Terminal:

```bash
# Run from your project directory
xcodebuild -target Deets -showBuildSettings | grep -E "(PRODUCT_NAME|PRODUCT_MODULE_NAME|PRODUCT_BUNDLE_IDENTIFIER|INFOPLIST_FILE|ASSETCATALOG_COMPILER_APPICON_NAME)"
```

Expected output should show:
```
PRODUCT_NAME = Deets
PRODUCT_MODULE_NAME = Deets
PRODUCT_BUNDLE_IDENTIFIER = com.yourteam.Deets
INFOPLIST_FILE = Deets/Info.plist
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
```

---

## Common Issues and Solutions

### ❌ Module name is empty

**Problem:** `PRODUCT_MODULE_NAME` is not set or is empty

**Solution:** Set to `Deets` or `$(TARGET_NAME)`

**In Build Settings:**
1. Search: "Product Module Name"
2. Double-click the value
3. Type: `Deets`
4. Press Enter

---

### ❌ Multiple commands produce

**Problem:** Duplicate targets or build phases

**Solution:** 
1. Check Targets list - should only have ONE "Deets" target
2. Select target → Build Phases → Copy Bundle Resources
3. Remove any duplicate file entries
4. Check that Info.plist is NOT in Copy Bundle Resources

---

### ❌ AppIcon not found

**Problem:** Asset catalog or app icon not configured

**Solution:**
1. Set `ASSETCATALOG_COMPILER_APPICON_NAME` to `AppIcon`
2. Ensure AppIcon.appiconset exists in Assets.xcassets
3. Verify Assets.xcassets is added to target

---

### ❌ Info.plist not found

**Problem:** `INFOPLIST_FILE` path is incorrect

**Solution:**
1. Verify Info.plist location in project navigator
2. If it's in root: set `INFOPLIST_FILE` to `Info.plist`
3. If in Deets folder: set to `Deets/Info.plist`
4. Path should be relative to project root

---

## Build Settings by Configuration

Your project may have different configurations (Debug, Release). Make sure settings are correct for ALL configurations:

1. In Build Settings, click on a setting name
2. Check the disclosure triangle (▸) next to it
3. Expand to see Debug and Release values
4. Set both to the same value for consistency

**Common configurations:**
- Debug
- Release
- (Optional) Staging, Testing, etc.

---

## Target vs Project Settings

Settings can be defined at two levels:

1. **Project Level:** Applies to all targets
2. **Target Level:** Overrides project settings (shown in bold)

**Best practice:** Set critical settings at the Target level for clarity.

To see which level a setting is defined:
- **Bold text** = Target level (overrides project)
- Normal text = Project level (inherited)

---

## Minimum Configuration Checklist

Before building, verify these are all set:

```
☐ PRODUCT_NAME = "Deets"
☐ PRODUCT_MODULE_NAME = "Deets"  
☐ PRODUCT_BUNDLE_IDENTIFIER = "com.yourteam.Deets"
☐ INFOPLIST_FILE = "Deets/Info.plist" (or correct path)
☐ ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon"
☐ IPHONEOS_DEPLOYMENT_TARGET = "16.0" or higher
☐ SWIFT_VERSION = "5.0"
☐ Only ONE target named "Deets" exists
☐ Info.plist file exists at the specified path
☐ Assets.xcassets contains AppIcon.appiconset
☐ No duplicate files in Copy Bundle Resources
```

After verifying all items:
1. Clean Build Folder (⇧⌘K)
2. Build (⌘B)
3. Run (⌘R)

---

## Need Help?

If you're still having issues:

1. **Check Xcode version:** Requires Xcode 14+ for iOS 16
2. **Check macOS version:** Xcode 14+ requires macOS 12.5+
3. **Verify file paths:** Use relative paths from project root
4. **Review build log:** Product → Show Build Output
5. **Reset package cache:** File → Packages → Reset Package Cache
6. **Restart Xcode:** Sometimes helps with indexing issues

---

## Additional Resources

- [BUILD_FIX_INSTRUCTIONS.md](BUILD_FIX_INSTRUCTIONS.md) - Detailed setup guide
- [QUICK_FIX.md](QUICK_FIX.md) - Fast reference card
- `verify-build-setup.sh` - Automated verification script

---

**Pro tip:** After fixing settings, always clean the build folder before building!
