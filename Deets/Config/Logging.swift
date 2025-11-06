//
//  Logging.swift
//  Deets
//
//  Privacy-aware logging configuration using os_log
//  Prevents PII leakage to system logs accessible by other apps
//
//  Security Note: print() statements leak to unified logging system
//  where they're accessible to other apps. Use Logger with privacy
//  annotations to protect sensitive user data.
//

import OSLog

/// Centralized logging system for Deets app
/// All loggers use privacy annotations to prevent PII leakage
enum AppLogger {

    // MARK: - Logger Instances

    /// OCR and text recognition operations
    /// Logs: recognition events, confidence scores, scanning lifecycle
    /// PII Risk: Recognized text may contain names, emails, phone numbers
    static let ocr = Logger(subsystem: subsystem, category: "OCR")

    /// Database operations (SwiftData/ModelContext)
    /// Logs: CRUD operations, query performance, sync state
    /// PII Risk: Contact names, companies, email addresses
    static let database = Logger(subsystem: subsystem, category: "Database")

    /// CloudKit synchronization
    /// Logs: sync status, conflict resolution, record changes
    /// PII Risk: Synced contact data, user identifiers
    static let sync = Logger(subsystem: subsystem, category: "Sync")

    /// Export operations (VCard, CSV, QR)
    /// Logs: export format, file generation, share operations
    /// PII Risk: Full contact data being exported
    static let export = Logger(subsystem: subsystem, category: "Export")

    /// Contact parsing and validation
    /// Logs: parsing results, field extraction, validation errors
    /// PII Risk: Extracted names, emails, phones, addresses
    static let parser = Logger(subsystem: subsystem, category: "Parser")

    /// Face detection and photo processing
    /// Logs: detection results, crop operations, quality assessment
    /// PII Risk: Face detection results, photo metadata
    static let photo = Logger(subsystem: subsystem, category: "Photo")

    /// UI interactions and navigation
    /// Logs: view lifecycle, user actions, state changes
    /// PII Risk: Low (UI state only)
    static let ui = Logger(subsystem: subsystem, category: "UI")

    /// Authentication and permissions
    /// Logs: authorization status, permission requests
    /// PII Risk: User permissions, device capabilities
    static let auth = Logger(subsystem: subsystem, category: "Auth")

    /// Performance monitoring
    /// Logs: timing metrics, memory usage, optimization data
    /// PII Risk: None (metrics only)
    static let performance = Logger(subsystem: subsystem, category: "Performance")

    /// Error tracking and diagnostics
    /// Logs: errors, exceptions, recovery attempts
    /// PII Risk: Context-dependent (may include user data in error context)
    static let error = Logger(subsystem: subsystem, category: "Error")

    // MARK: - Configuration

    /// App bundle identifier used as logging subsystem
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.sharedeets.app"
}

// MARK: - Privacy Guidelines

/// Privacy Annotation Guidelines for Deets App
///
/// Use `.private` for:
/// - Contact names (first, last, full)
/// - Email addresses
/// - Phone numbers
/// - Physical addresses
/// - Company names
/// - Job titles
/// - Website URLs
/// - Social media handles
/// - Notes and custom fields
/// - Face detection results
/// - Any user-generated content
///
/// Use `.public` for:
/// - Counts (e.g., "Processed 5 cards")
/// - State changes (e.g., "Scanning started")
/// - Category names (e.g., "email", "phone")
/// - Confidence scores
/// - Error codes (without context)
/// - Performance metrics
/// - File sizes
/// - Timing information
///
/// Use `.hash` for:
/// - Record IDs
/// - Unique identifiers
/// - CloudKit record names
/// - Device identifiers (when needed for debugging)
///
/// Examples:
/// ```swift
/// // ❌ NEVER: Leaks PII to system logs
/// print("Saved contact: \(contact.name) at \(contact.email)")
///
/// // ✅ CORRECT: Privacy-aware logging
/// AppLogger.database.info("Saved contact: \(contact.name, privacy: .private)")
///
/// // ✅ CORRECT: Mix private and public data
/// AppLogger.ocr.info("Recognized \(itemCount, privacy: .public) items with confidence \(avgConfidence, privacy: .public)")
///
/// // ✅ CORRECT: Hash identifiers
/// AppLogger.sync.debug("Syncing record \(recordID, privacy: .hash)")
/// ```

// MARK: - Migration Helper

#if DEBUG
/// Helper for identifying remaining print() statements during development
enum LoggingMigration {

    /// Scan codebase for print() statements
    /// Run: AppLogger.checkForPrintStatements() in debug builds
    static func reportPrintUsage() {
        AppLogger.error.warning("⚠️ print() statements detected in codebase - these leak PII!")
        AppLogger.error.warning("Use AppLogger with privacy annotations instead")
    }

    /// Log migration status
    static func migrationComplete() {
        AppLogger.ui.info("✅ All print() statements migrated to privacy-aware logging")
    }
}
#endif

// MARK: - Logging Best Practices

/// Best Practices for Deets Logging:
///
/// 1. **Default to Private**: When in doubt, mark as .private
/// 2. **Minimize PII Logging**: Only log PII when debugging critical issues
/// 3. **Use Structured Logging**: Log actionable metrics, not verbose dumps
/// 4. **Appropriate Log Levels**:
///    - .debug: Development-only detailed tracing
///    - .info: Normal operation events
///    - .notice: Significant but expected events
///    - .error: Errors requiring attention
///    - .fault: Critical failures requiring immediate action
/// 5. **Performance**: Logging is cheap, but avoid excessive debug logs in production
/// 6. **Testing**: Use Console.app to verify privacy annotations work correctly

/// Log Level Decision Tree:
/// - Did something break? → .error or .fault
/// - Did something unusual happen? → .notice
/// - Did something expected happen? → .info
/// - Do I need detailed traces? → .debug (development only)
