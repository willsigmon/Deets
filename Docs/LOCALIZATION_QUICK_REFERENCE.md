# Localization Quick Reference

Quick guide for using localized strings in Deets.

## Basic Usage

### Text Labels

```swift
// Navigation title
.navigationTitle(L10n.Scan.title)

// Body text
Text(L10n.Scan.headerMessage)

// Button label
Button(L10n.Scan.Button.start) { }
```

### Form Fields

```swift
ValidatedTextField(
    title: L10n.Preview.Field.email,
    placeholder: L10n.Preview.Field.emailPlaceholder,
    text: $email,
    errorMessage: L10n.Preview.Validation.emailInvalid
)
```

### Alerts

```swift
.alert(L10n.Scan.Error.title, isPresented: $showError) {
    Button(L10n.Action.retry) { }
    Button(L10n.Action.cancel, role: .cancel) { }
} message: {
    Text(L10n.Scan.Error.noText)
}
```

## With Parameters

### Format Strings

```swift
// Single parameter
Text(L10n.Preview.Success.withContacts("Sarah Chen"))

// Multiple parameters
Text(L10n.List.DeleteConfirm.message(contactName))

// Numbers
Text(L10n.Count.cards(42))
Text(L10n.Date.daysAgo(3))
```

## String Categories

### Scan
```swift
L10n.Scan.title                    // "Scan"
L10n.Scan.headerTitle             // "Scan Business Card"
L10n.Scan.Button.start            // "Start Scanning"
L10n.Scan.Error.noText            // Error message
```

### Preview (Contact Editing)
```swift
L10n.Preview.title                // "New Contact"
L10n.Preview.Field.fullName       // "Full Name"
L10n.Preview.Button.saveBoth      // "Save to Database & Contacts"
L10n.Preview.Validation.emailInvalid  // Validation error
```

### List (Card List)
```swift
L10n.List.title                   // "Cards"
L10n.List.searchPlaceholder       // "Search cards..."
L10n.List.Empty.title             // "No Business Cards Yet"
L10n.List.Sort.dateNewest         // "Newest First"
L10n.List.Filter.favorites        // "Favorites Only"
```

### Detail (Card Detail)
```swift
L10n.Detail.title                 // "Contact Details"
L10n.Detail.Label.name            // "Name"
L10n.Detail.Action.call           // "Call"
L10n.Detail.Empty.email           // "No email"
```

### Settings
```swift
L10n.Settings.title               // "Settings"
L10n.Settings.Section.privacy     // "Privacy"
L10n.Settings.Scanning.autoSave   // "Auto-save After Scan"
```

### Generic
```swift
L10n.Action.save                  // "Save"
L10n.Action.cancel                // "Cancel"
L10n.Action.delete                // "Delete"
L10n.Message.loading              // "Loading..."
```

### Accessibility
```swift
L10n.Accessibility.scannerCancel
L10n.Accessibility.scannerCancelHint
L10n.Accessibility.cardsList
```

## Common Patterns

### Empty States

```swift
EmptyStateView(
    systemImage: "rectangle.stack.badge.plus",
    title: L10n.List.Empty.title,
    message: L10n.List.Empty.message,
    actionTitle: L10n.List.Empty.action
)
```

### Search

```swift
.searchable(
    text: $searchQuery,
    prompt: L10n.List.searchPlaceholder
)
```

### Toolbars

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Menu {
            // Menu items
        } label: {
            Label(L10n.List.Sort.title, systemImage: "arrow.up.arrow.down")
        }
        .accessibilityLabel(L10n.Accessibility.sortOptions)
    }
}
```

### Swipe Actions

```swift
.swipeActions(edge: .trailing) {
    Button(role: .destructive) {
        deleteCard()
    } label: {
        Label(L10n.List.Action.delete, systemImage: "trash")
    }
}
```

## Alternative: String Extension

If you need dynamic keys:

```swift
// Direct localization
Text("scan.title".localized)

// With parameters
Text("preview.success.withContacts".localized(with: name))
```

**Note:** L10n enum is preferred for type-safety and autocomplete.

## Adding New Strings

1. Add to `Resources/en.lproj/Localizable.strings`:
   ```strings
   "feature.new.string" = "My New String";
   ```

2. Add to `Config/LocalizationHelper.swift`:
   ```swift
   enum Feature {
       static let newString = localized("feature.new.string")
   }
   ```

3. Use in code:
   ```swift
   Text(L10n.Feature.newString)
   ```

## Naming Convention

Format: `[feature].[component].[specific]`

Examples:
- `scan.button.start`
- `preview.field.email.placeholder`
- `list.empty.title`
- `settings.section.privacy`

## String Parameters

### Format Specifiers
- `%@` - String
- `%d` - Integer
- `%f` - Float
- `%%` - Literal %

### Example in Localizable.strings
```strings
"preview.success.withContacts" = "%@ has been saved to your database and Contacts app.";
"count.cards.many" = "%d cards";
```

### Usage
```swift
L10n.Preview.Success.withContacts("John Doe")
// "John Doe has been saved to your database and Contacts app."

L10n.Count.cards(5)
// "5 cards"
```

## Testing Different Languages

### In Simulator
1. Settings → General → Language & Region
2. Select language
3. Relaunch app

### In Xcode Scheme
1. Product → Scheme → Edit Scheme
2. Run → Options → App Language
3. Select test language

## Troubleshooting

### String Shows as Key
**Problem:** See "scan.title" instead of "Scan"

**Solutions:**
- Check key exists in Localizable.strings
- Verify spelling (case-sensitive)
- Clean build (Cmd+Shift+K)
- Rebuild project

### Parameters Not Replaced
**Problem:** See "%@" in text

**Solution:**
```swift
// ❌ Wrong
L10n.Preview.Success.withContacts

// ✅ Correct
L10n.Preview.Success.withContacts("Name")
```

### Text Truncated
**Problem:** Text cut off with "..."

**Solution:**
```swift
Text(L10n.Feature.longString)
    .fixedSize(horizontal: false, vertical: true)
```

## Quick Migration Steps

1. Find hard-coded string
2. Look up equivalent in L10n
3. Replace: `"Text"` → `L10n.Category.property`
4. Test display
5. Repeat

## Resources

- **Full Guide:** `Docs/LOCALIZATION_GUIDE.md`
- **Examples:** `Examples/LocalizationIntegrationExample.swift`
- **String Keys:** `Config/LocalizationHelper.swift`
- **Strings File:** `Resources/en.lproj/Localizable.strings`

---

**Remember:** Always use L10n for type-safety and autocomplete!
