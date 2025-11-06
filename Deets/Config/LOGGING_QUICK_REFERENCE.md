# Logging Quick Reference - Deets

## TL;DR

**Never use `print()` in this codebase. Always use `AppLogger` with privacy annotations.**

---

## Quick Start

```swift
import OSLog // Not needed - AppLogger is globally available

// Log non-sensitive info
AppLogger.ui.info("Scanning started")

// Log with PII (will show as <private> in Console.app)
AppLogger.database.info("Saved contact: \(contact.name, privacy: .private)")

// Log counts and metrics (visible in logs)
AppLogger.ocr.info("Captured \(count, privacy: .public) items")

// Log errors
AppLogger.error.error("Operation failed: \(error.localizedDescription, privacy: .public)")
```

---

## Available Loggers

| Logger | Use For | Example |
|--------|---------|---------|
| `AppLogger.ocr` | OCR operations | `AppLogger.ocr.info("Recognition completed")` |
| `AppLogger.database` | SwiftData/CRUD | `AppLogger.database.info("Saved card")` |
| `AppLogger.sync` | CloudKit sync | `AppLogger.sync.notice("Sync started")` |
| `AppLogger.export` | Export operations | `AppLogger.export.info("Generated VCard")` |
| `AppLogger.parser` | Contact parsing | `AppLogger.parser.debug("Parsing field")` |
| `AppLogger.photo` | Face detection | `AppLogger.photo.info("Face detected")` |
| `AppLogger.ui` | UI interactions | `AppLogger.ui.debug("View appeared")` |
| `AppLogger.auth` | Permissions | `AppLogger.auth.notice("Camera authorized")` |
| `AppLogger.performance` | Performance | `AppLogger.performance.info("Took \(ms)ms")` |
| `AppLogger.error` | Error tracking | `AppLogger.error.error("Failed")` |

---

## Privacy Annotations Cheat Sheet

### `.private` (Default to this when in doubt)

**Always use for PII**:
```swift
// Contact data
AppLogger.database.info("Name: \(name, privacy: .private)")
AppLogger.database.info("Email: \(email, privacy: .private)")
AppLogger.database.info("Phone: \(phone, privacy: .private)")
AppLogger.database.info("Company: \(company, privacy: .private)")

// Recognized text
AppLogger.ocr.debug("Recognized: \(text, privacy: .private)")

// User content
AppLogger.database.info("Notes: \(notes, privacy: .private)")
```

**Console output**: `Name: <private>`

---

### `.public` (Use for metrics and counts)

**Safe for non-sensitive data**:
```swift
// Counts
AppLogger.ocr.info("Processed \(count, privacy: .public) items")

// States
AppLogger.ui.info("Current state: \(state, privacy: .public)")

// Metrics
AppLogger.performance.info("Confidence: \(score, privacy: .public)")

// Categories (not actual data)
AppLogger.parser.debug("Field type: \(category, privacy: .public)")
```

**Console output**: `Processed 5 items`

---

### `.hash` (Use for unique identifiers)

**For correlation without exposing IDs**:
```swift
// Record IDs
AppLogger.sync.debug("Syncing: \(recordID, privacy: .hash)")

// UUIDs
AppLogger.database.debug("Card ID: \(uuid, privacy: .hash)")
```

**Console output**: `Syncing: <hash:ab3d8f92>`

---

## Log Levels

| Level | When | Example |
|-------|------|---------|
| `.debug` | **Development only** - Detailed traces | `AppLogger.parser.debug("Validating \(field, privacy: .private)")` |
| `.info` | **Normal events** - Successful operations | `AppLogger.database.info("Saved successfully")` |
| `.notice` | **Significant events** - Worth noting but not errors | `AppLogger.sync.notice("Sync completed")` |
| `.error` | **Errors** - Something failed but recoverable | `AppLogger.database.error("Save failed: \(error, privacy: .public)")` |
| `.fault` | **Critical failures** - App cannot continue | `AppLogger.database.fault("Data corruption detected")` |

---

## Common Patterns

### Pattern: Log Operation Completion

```swift
func saveCard(_ card: BusinessCard) {
    do {
        try context.save()
        AppLogger.database.info("Saved card: \(card.id, privacy: .hash)")
    } catch {
        AppLogger.database.error("Failed to save: \(error.localizedDescription, privacy: .public)")
    }
}
```

### Pattern: Log OCR Results

```swift
func processRecognizedText(_ items: [ScannedText]) {
    AppLogger.ocr.info("Recognized \(items.count, privacy: .public) items")

    for item in items {
        AppLogger.ocr.debug("""
            Item: \(item.text, privacy: .private)
            Category: \(item.category, privacy: .public)
            Confidence: \(item.confidence, privacy: .public)
        """)
    }
}
```

### Pattern: Log User Actions

```swift
func didTapExport() {
    AppLogger.ui.info("User initiated export")
    // Don't log which contact was exported (PII)
}
```

### Pattern: Log Performance

```swift
let start = Date()
performExpensiveOperation()
let duration = Date().timeIntervalSince(start)
AppLogger.performance.info("Operation took \(duration, privacy: .public)s")
```

---

## What NOT to Log

❌ **Full objects** (may contain PII):
```swift
// DON'T
AppLogger.database.debug("Contact: \(contact)")
```

❌ **Passwords/Tokens** (even with .private):
```swift
// DON'T
AppLogger.auth.debug("Token: \(token, privacy: .private)")
```

❌ **Excessive detail in production**:
```swift
// DON'T (in production)
AppLogger.ui.debug("Frame: \(view.frame)")
```

---

## Viewing Logs

### Xcode Console
- Logs appear automatically when running from Xcode
- Filter by category: Type category name in search bar

### Console.app (macOS)
1. Open Console.app
2. Filter by subsystem: `com.sharedeets.app`
3. Filter by category: Select category from sidebar
4. Verify privacy: PII should show as `<private>`

### Command Line
```bash
# Show all logs from Deets
log show --predicate 'subsystem == "com.sharedeets.app"' --last 1h

# Show only errors
log show --predicate 'subsystem == "com.sharedeets.app" AND eventType == error' --last 1h

# Show specific category
log show --predicate 'subsystem == "com.sharedeets.app" AND category == "OCR"' --last 5m

# Show with private data (only on your device)
log show --predicate 'subsystem == "com.sharedeets.app"' --info --debug --last 1h
```

---

## Migration from print()

### Before:
```swift
print("Saved contact: \(contact.name)")
print("Error: \(error)")
print("Processing...")
```

### After:
```swift
AppLogger.database.info("Saved contact: \(contact.name, privacy: .private)")
AppLogger.error.error("Error: \(error.localizedDescription, privacy: .public)")
AppLogger.ui.debug("Processing started")
```

---

## Rules to Remember

1. **Never use `print()`** - It leaks PII to system logs
2. **Default to `.private`** - When in doubt, mark as private
3. **Log actions, not data** - "Saved contact" vs "Saved John Smith"
4. **Use appropriate levels** - `.debug` for dev, `.info` for prod
5. **Test in Console.app** - Verify PII shows as `<private>`

---

## Need Help?

- **Full documentation**: See `/LOGGING_POLICY.md`
- **Implementation**: See `/Deets/Config/Logging.swift`
- **Apple docs**: [Unified Logging](https://developer.apple.com/documentation/os/logging)

---

**Remember**: Logging is for debugging and monitoring, not for storing user data. When in doubt, log less or mark it `.private`.
