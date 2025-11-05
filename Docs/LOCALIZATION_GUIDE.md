# Localization Guide

This guide covers how to add new languages, maintain translations, and follow localization best practices for Deets.

## Overview

Deets uses Apple's standard localization system with:
- **Localizable.strings**: All user-facing UI strings
- **InfoPlist.strings**: Permission descriptions
- **LocalizationHelper.swift**: Type-safe string access
- **NSLocalizedString**: Runtime localization

## File Structure

```
Deets/
├── Resources/
│   ├── en.lproj/              # English (base language)
│   │   ├── Localizable.strings
│   │   └── InfoPlist.strings
│   ├── es.lproj/              # Spanish (example)
│   │   ├── Localizable.strings
│   │   └── InfoPlist.strings
│   └── [language].lproj/      # Additional languages
└── Config/
    └── LocalizationHelper.swift   # Type-safe string keys
```

## Adding a New Language

### Step 1: Create Language Directory

1. In Xcode, select `Resources` folder
2. Right-click → New Group
3. Name it `[language-code].lproj` (e.g., `es.lproj` for Spanish, `fr.lproj` for French)

**Common Language Codes:**
- Spanish: `es`
- French: `fr`
- German: `de`
- Italian: `it`
- Portuguese: `pt-BR` (Brazilian), `pt-PT` (European)
- Japanese: `ja`
- Chinese (Simplified): `zh-Hans`
- Chinese (Traditional): `zh-Hant`
- Korean: `ko`
- Arabic: `ar`
- Russian: `ru`

### Step 2: Add Strings Files

1. Create `Localizable.strings` in the new `.lproj` folder
2. Copy English version from `en.lproj/Localizable.strings`
3. Translate the **values** (right side of =), keep **keys** (left side) identical
4. Create `InfoPlist.strings` and translate permission descriptions

**Example:**

```strings
// English (en.lproj/Localizable.strings)
"scan.title" = "Scan";
"scan.header.title" = "Scan Business Card";

// Spanish (es.lproj/Localizable.strings)
"scan.title" = "Escanear";
"scan.header.title" = "Escanear Tarjeta de Negocio";
```

### Step 3: Update Project Configuration

1. Open `project.yml` (if using XcodeGen)
2. Add language to `knownRegions`:

```yaml
options:
  knownRegions:
    - en
    - es  # Add your language code
    - fr
```

3. Regenerate project: `xcodegen generate`

**OR** in Xcode:

1. Select project in Navigator
2. Go to Info tab
3. Click + under Localizations
4. Select language
5. Check `Localizable.strings` and `InfoPlist.strings`

## String Key Naming Conventions

### Structure

Use hierarchical dot notation: `[feature].[component].[specific]`

**Examples:**
```
scan.title
scan.button.start
scan.error.noText
preview.field.fullName
list.empty.title
settings.section.privacy
```

### Categories

1. **Screen/Feature**: `scan.`, `preview.`, `list.`, `detail.`, `settings.`
2. **Component Type**: `.button.`, `.field.`, `.error.`, `.section.`
3. **Specific Use**: `.title`, `.message`, `.placeholder`, `.action`

### Naming Rules

- **Lowercase**: All keys in lowercase
- **Descriptive**: Clear what the string is for
- **Hierarchical**: Grouped by feature
- **Consistent**: Follow existing patterns
- **No abbreviations**: `fullName` not `fName`

**Good:**
```
preview.field.email.placeholder
list.action.favorite
scan.error.timeout
```

**Bad:**
```
emailPH
favAction
timeoutErr
```

## Using Localized Strings in Code

### Option 1: Type-Safe Helper (Recommended)

Use `L10n` enum from `LocalizationHelper.swift`:

```swift
import SwiftUI

struct ScanView: View {
    var body: some View {
        Text(L10n.Scan.headerTitle)

        Button(L10n.Scan.Button.start) {
            // Action
        }

        // With parameters
        Text(L10n.Preview.Success.withContacts("John Doe"))
    }
}
```

**Benefits:**
- Compile-time checking
- Autocomplete support
- Refactoring safety
- Clear organization

### Option 2: String Extension

For dynamic keys or quick access:

```swift
Text("scan.title".localized)

// With parameters
Text("preview.success.withContacts".localized(with: name))
```

### Option 3: NSLocalizedString (Fallback)

Direct Apple API:

```swift
Text(NSLocalizedString("scan.title", comment: "Scan tab title"))
```

## Translation Workflow

### 1. Extract Base Strings

When adding new features:

1. Add English strings to `Resources/en.lproj/Localizable.strings`
2. Update `Config/LocalizationHelper.swift` with new enum cases
3. Use type-safe keys in code: `L10n.Feature.newString`

### 2. Export for Translation

Using `xcodebuild`:

```bash
# Export all strings needing translation
xcodebuild -exportLocalizations -project Deets.xcodeproj -localizationPath ./Localizations

# This creates .xcloc bundles for each language
```

**OR** manually:

1. Copy `en.lproj/Localizable.strings` to translator
2. Provide context about app functionality
3. Request translated files in same format

### 3. Review Translations

Check for:
- **Length**: Ensure text fits in UI (German/French are longer)
- **Formality**: Match brand tone (conversational but clear)
- **Context**: String makes sense in app flow
- **Variables**: `%@` and `%d` placeholders preserved
- **Special characters**: Proper encoding (UTF-8)

### 4. Import Translations

```bash
# Import translated .xcloc bundles
xcodebuild -importLocalizations -project Deets.xcodeproj -localizationPath ./Localizations/es.xcloc
```

**OR** manually:

1. Place translated `Localizable.strings` in `[lang].lproj/`
2. Verify file encoding is UTF-8
3. Build and test

## Testing Localization

### In Simulator/Device

1. **Settings → General → Language & Region → iPhone Language**
2. Select test language
3. Relaunch Deets
4. Verify all strings appear correctly

### In Xcode

1. **Product → Scheme → Edit Scheme**
2. Run → Options → App Language
3. Select language to test
4. Run app

### Command Line

```bash
# Launch simulator in specific language
xcrun simctl launch --console booted com.deets.app -AppleLanguages "(es)"
```

### Check List

- [ ] All strings translated (no English showing)
- [ ] Text fits in buttons/labels (no truncation)
- [ ] Proper formatting of dates, numbers, currencies
- [ ] Permission dialogs show translated text
- [ ] Error messages make sense
- [ ] Navigation titles display correctly
- [ ] Accessibility labels work with VoiceOver

## RTL (Right-to-Left) Languages

For Arabic, Hebrew, and other RTL languages:

### SwiftUI Automatic Support

Most layouts automatically flip:

```swift
HStack {  // Automatically reverses in RTL
    Image(systemName: "star.fill")
    Text("Favorite")
}
```

### Manual RTL Handling

When needed:

```swift
// Check layout direction
@Environment(\.layoutDirection) var layoutDirection

if layoutDirection == .rightToLeft {
    // Custom RTL behavior
}

// Force specific direction
.environment(\.layoutDirection, .leftToRight)
```

### RTL Testing

1. Add Arabic (`ar`) or Hebrew (`he`) localization
2. Test in simulator with RTL language
3. Check for:
   - Navigation flows right-to-left
   - Text alignment (trailing vs leading)
   - Icons and images that need flipping
   - Swipe gestures work correctly

## Common Issues & Solutions

### Missing Translation

**Symptom:** English text appears in localized version

**Solution:**
1. Check key exists in `[lang].lproj/Localizable.strings`
2. Verify key spelling matches exactly (case-sensitive)
3. Rebuild app (Clean Build Folder: Cmd+Shift+K)

### Text Truncation

**Symptom:** Text cut off with "..." in buttons or labels

**Solution:**
1. Use `.fixedSize()` if text should never truncate:
   ```swift
   Text("long.string".localized)
       .fixedSize(horizontal: false, vertical: true)
   ```
2. Abbreviate translation if appropriate
3. Redesign layout to accommodate longer text

### Wrong Language Showing

**Symptom:** App shows wrong language despite device settings

**Solution:**
1. Check `CFBundleDevelopmentRegion` in Info.plist
2. Verify language in `knownRegions` (project.yml or Xcode)
3. Delete app and reinstall
4. Check iOS system language order (first matching language wins)

### Variables Not Replaced

**Symptom:** "%@" or "%d" appears literally in text

**Solution:**
```swift
// Correct: Use String(format:) or localized(with:)
String(format: L10n.Count.cards, 5)
"count.cards".localized(with: 5)

// Wrong: Direct string doesn't replace variables
L10n.Count.cards  // Shows "You have %d cards"
```

## Brand Voice Guidelines

When translating, maintain Deets' brand personality:

### Tone
- **Conversational**: Like talking to a friend, not a manual
- **Confident**: Know what we're doing, no hedging
- **Human**: Real person wrote this, not a corporation
- **Direct**: No jargon, get to the point

### Examples

**Good Translations:**
```
English: "Meet once. Remember always."
Spanish: "Conócelos una vez. Recuérdalos siempre."

English: "Scan your first business card to get started."
French: "Scannez votre première carte de visite pour commencer."
```

**Avoid:**
```
❌ "Please utilize the camera functionality to commence scanning"
✅ "Point your camera at a business card to scan"

❌ "An error has occurred during the scanning process"
✅ "Something went wrong while scanning"
```

## Localization Checklist

Before shipping a new language:

### Strings
- [ ] All `Localizable.strings` entries translated
- [ ] All `InfoPlist.strings` entries translated
- [ ] Format specifiers (`%@`, `%d`) preserved
- [ ] Plurals handled correctly
- [ ] Brand name "Deets" kept consistent

### UI
- [ ] All screens tested in target language
- [ ] Text fits in all UI elements
- [ ] Images with text localized (if any)
- [ ] Date/time formats appropriate
- [ ] Currency formats correct (if used)

### Functionality
- [ ] VoiceOver works in target language
- [ ] Dynamic Type scales properly
- [ ] Search works with localized text
- [ ] Sort order appropriate for language
- [ ] Keyboard input correct (email, phone)

### RTL (if applicable)
- [ ] Layout flows right-to-left
- [ ] Icons mirror appropriately
- [ ] Text alignment correct
- [ ] Navigation intuitive

## Resources

### Apple Documentation
- [Localization Guide](https://developer.apple.com/localization/)
- [Internationalization and Localization Guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/Introduction/Introduction.html)
- [String Format Specifiers](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html)

### Tools
- **Xcode Localization Catalog**: Built-in translation management
- **Localise.biz**: Cloud-based localization platform
- **Crowdin**: Collaborative translation
- **POEditor**: Translation management system

### Translation Services
- **Gengo**: Professional human translation
- **Rev**: Translation and localization
- **DeepL**: High-quality machine translation (for initial draft)

## Need Help?

Questions about localization?

1. Check existing translations in `en.lproj/` for patterns
2. Review `LocalizationHelper.swift` for type-safe API
3. Test in simulator with multiple languages
4. Refer to Apple's Human Interface Guidelines for language-specific design

---

**Last Updated:** 2025-11-05
**Base Language:** English (en)
**Brand:** Deets - "Meet once. Remember always."
