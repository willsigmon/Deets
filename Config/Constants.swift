// Constants.swift
// Deets - App-Wide Constants
//
// Centralized constants for configuration, URLs, dimensions, etc.
// Import this file wherever you need consistent values.

import Foundation
import SwiftUI

/// App-wide constants
enum Constants {

    // MARK: - App Info

    enum App {
        static let name = "Deets"
        static let bundleIdentifier = "com.deets.app"
        static let version = "1.0.0"
        static let buildNumber = "1"

        /// App Store URL (replace with actual when published)
        static let appStoreURL = URL(string: "https://apps.apple.com/app/id...")!

        /// Support email
        static let supportEmail = "support@deets.app"

        /// Privacy policy URL
        static let privacyPolicyURL = URL(string: "https://deets.app/privacy")!

        /// Terms of service URL
        static let termsURL = URL(string: "https://deets.app/terms")!
    }

    // MARK: - Minimum Requirements

    enum Requirements {
        static let minimumIOSVersion = "17.0"
        static let minimumSwiftVersion = "5.10"
        static let minimumXcodeVersion = "15.4"
    }

    // MARK: - File Paths

    enum FilePaths {
        /// Business card photos directory
        static let photosDirectory = "BusinessCards"

        /// Thumbnails subdirectory
        static let thumbnailsDirectory = "BusinessCards/Thumbnails"

        /// Exports temporary directory
        static let exportsDirectory = "Exports"

        /// Photo file extension
        static let photoExtension = "jpg"

        /// Thumbnail suffix
        static let thumbnailSuffix = "_thumb"
    }

    // MARK: - Image Processing

    enum ImageProcessing {
        /// Maximum image dimension for OCR (pixels)
        /// Larger images are resized to improve performance
        static let maxImageSize: CGFloat = 2048

        /// Minimum image dimension (pixels)
        /// Smaller images may have poor OCR quality
        static let minImageSize: CGFloat = 480

        /// JPEG compression quality (0.0 - 1.0)
        static let compressionQuality: CGFloat = 0.8

        /// Thumbnail size (points)
        static let thumbnailSize: CGSize = CGSize(width: 150, height: 150)

        /// Thumbnail compression quality
        static let thumbnailCompressionQuality: CGFloat = 0.6
    }

    // MARK: - OCR Configuration

    enum OCR {
        /// Default recognition language
        static let defaultLanguage = "en-US"

        /// Supported languages (v1.0 = English only)
        static let supportedLanguages = ["en-US"]

        /// Recognition level: .accurate or .fast
        static let recognitionLevel = "accurate" // VNRequestTextRecognitionLevel.accurate

        /// Minimum confidence threshold (0.0 - 1.0)
        /// Fields below this are flagged for user review
        static let minConfidence: Double = 0.7

        /// High confidence threshold
        /// Fields above this are considered highly reliable
        static let highConfidence: Double = 0.9

        /// Enable language correction (auto-correct spelling)
        static let useLanguageCorrection = true

        /// Custom OCR dictionary (business terms)
        static let customWords = [
            "CEO", "CFO", "CTO", "COO", "VP",
            "Director", "Manager", "Engineer", "Designer",
            "LinkedIn", "Twitter", "Facebook", "Instagram",
            "Inc", "LLC", "Corp", "Ltd", "Co",
        ]
    }

    // MARK: - Parsing

    enum Parsing {
        /// Maximum lines to consider for name (usually first 3 lines)
        static let maxNameSearchLines = 3

        /// Maximum lines to consider for company (usually first 5 lines)
        static let maxCompanySearchLines = 5

        /// Common job titles for detection
        static let commonJobTitles = [
            "CEO", "Chief Executive Officer",
            "CFO", "Chief Financial Officer",
            "CTO", "Chief Technology Officer",
            "COO", "Chief Operating Officer",
            "VP", "Vice President",
            "Director", "Manager", "Lead",
            "Engineer", "Developer", "Designer",
            "Consultant", "Analyst", "Specialist",
            "President", "Founder", "Co-Founder",
        ]
    }

    // MARK: - Validation

    enum Validation {
        /// Minimum phone number length (digits only)
        static let minPhoneLength = 7

        /// Maximum phone number length (digits only)
        static let maxPhoneLength = 15

        /// Email regex pattern (RFC 5322 simplified)
        static let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        /// URL pattern
        static let urlPattern = "(?:https?://)?(?:www\\.)?[a-zA-Z0-9-]+\\.[a-zA-Z]{2,}"

        /// Zip code patterns (US)
        static let zipCodePattern = "\\d{5}(-\\d{4})?"

        /// Phone number pattern (flexible, for initial detection)
        static let phonePattern = "(?:\\+?1[-.]?)?(\\(?\\d{3}\\)?[-.]?\\d{3}[-.]?\\d{4})"
    }

    // MARK: - UI Dimensions

    enum UI {
        /// Standard padding
        static let padding: CGFloat = 16

        /// Small padding
        static let paddingSmall: CGFloat = 8

        /// Large padding
        static let paddingLarge: CGFloat = 24

        /// Corner radius for cards
        static let cornerRadius: CGFloat = 12

        /// Small corner radius
        static let cornerRadiusSmall: CGFloat = 8

        /// Button height
        static let buttonHeight: CGFloat = 50

        /// List row height (contact list)
        static let rowHeight: CGFloat = 80

        /// Contact card width (iPad)
        static let cardWidth: CGFloat = 360

        /// Maximum content width (iPad)
        static let maxContentWidth: CGFloat = 680

        /// Animation duration (standard)
        static let animationDuration: TimeInterval = 0.3

        /// Animation duration (fast)
        static let animationDurationFast: TimeInterval = 0.15
    }

    // MARK: - Colors

    enum Colors {
        /// Primary brand color
        static let primary = Color("Primary") // Define in Assets.xcassets

        /// Secondary brand color
        static let secondary = Color("Secondary")

        /// Accent color (for CTAs)
        static let accent = Color.blue

        /// Success color (high confidence)
        static let success = Color.green

        /// Warning color (medium confidence)
        static let warning = Color.orange

        /// Error color (low confidence, errors)
        static let error = Color.red

        /// Background colors
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)

        /// Text colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let tertiaryText = Color(uiColor: .tertiaryLabel)
    }

    // MARK: - Typography

    enum Typography {
        /// Large title (contact name)
        static let largeTitle: Font = .largeTitle

        /// Title (section headers)
        static let title: Font = .title

        /// Headline (row titles)
        static let headline: Font = .headline

        /// Body (main content)
        static let body: Font = .body

        /// Subheadline (secondary info)
        static let subheadline: Font = .subheadline

        /// Caption (metadata)
        static let caption: Font = .caption

        /// Font weights
        enum Weight {
            static let regular = Font.Weight.regular
            static let medium = Font.Weight.medium
            static let semibold = Font.Weight.semibold
            static let bold = Font.Weight.bold
        }
    }

    // MARK: - Export

    enum Export {
        /// Default VCF file name
        static let vcfFileName = "deets-export.vcf"

        /// Default CSV file name
        static let csvFileName = "deets-export.csv"

        /// CSV delimiter
        static let csvDelimiter = ","

        /// CSV header row
        static let csvHeader = [
            "Name", "Company", "Job Title", "Email", "Phone",
            "Website", "Street", "City", "State", "Zip", "Country", "Notes",
        ].joined(separator: csvDelimiter)

        /// Batch export limit (contacts per operation)
        static let batchExportLimit = 100
    }

    // MARK: - Database

    enum Database {
        /// SwiftData model container name
        static let containerName = "DeetsModel"

        /// iCloud container identifier
        static let iCloudContainerIdentifier = "iCloud.com.deets.app"

        /// Default sort order for contacts
        static let defaultSortOrder = "updatedAt" // KeyPath string

        /// Batch fetch limit
        static let batchFetchLimit = 50
    }

    // MARK: - Permissions

    enum Permissions {
        /// Camera usage description (Info.plist key: NSCameraUsageDescription)
        static let cameraUsageDescription = "Scan business cards using your camera"

        /// Contacts usage description (Info.plist key: NSContactsUsageDescription)
        static let contactsUsageDescription = "Export business cards to your Contacts"

        /// Photo library usage description (Info.plist key: NSPhotoLibraryAddUsageDescription)
        static let photoLibraryUsageDescription = "Save business card images to Photos"
    }

    // MARK: - Performance

    enum Performance {
        /// Maximum concurrent OCR operations
        static let maxConcurrentOCR = 3

        /// Debounce time for search (seconds)
        static let searchDebounceTime: TimeInterval = 0.3

        /// Cache size for thumbnails (MB)
        static let thumbnailCacheSize: Int = 100

        /// Image cache expiration (seconds)
        static let imageCacheExpiration: TimeInterval = 3600 // 1 hour
    }

    // MARK: - Analytics (v1.0 = disabled, future use)

    enum Analytics {
        /// Enable analytics (always false for privacy-first v1.0)
        static let enabled = false

        /// Analytics events (for future use if user opts in)
        enum Event {
            static let scanCard = "scan_card"
            static let saveContact = "save_contact"
            static let exportContacts = "export_contacts"
            static let enableiCloudSync = "enable_icloud_sync"
        }
    }

    // MARK: - Testing

    #if DEBUG
    enum Testing {
        /// Use mock data in previews
        static let useMockData = true

        /// Mock contact count
        static let mockContactCount = 20

        /// Show debug overlay
        static let showDebugOverlay = false

        /// Enable performance profiling
        static let enableProfiling = false
    }
    #endif

    // MARK: - Regex Patterns (Compiled)

    enum Regex {
        /// Email regex (compiled)
        static let email = try? NSRegularExpression(
            pattern: Validation.emailPattern,
            options: [.caseInsensitive]
        )

        /// URL regex (compiled)
        static let url = try? NSRegularExpression(
            pattern: Validation.urlPattern,
            options: [.caseInsensitive]
        )

        /// Phone regex (compiled)
        static let phone = try? NSRegularExpression(
            pattern: Validation.phonePattern,
            options: []
        )

        /// Zip code regex (compiled)
        static let zipCode = try? NSRegularExpression(
            pattern: Validation.zipCodePattern,
            options: []
        )
    }

    // MARK: - Accessibility

    enum Accessibility {
        /// Minimum touch target size (points)
        static let minTouchTargetSize: CGFloat = 44

        /// Voice over hints
        enum VoiceOver {
            static let scanButton = "Double tap to open camera and scan a business card"
            static let contactRow = "Double tap to view contact details"
            static let exportButton = "Double tap to export contacts"
            static let deleteButton = "Double tap to delete this contact"
        }
    }

    // MARK: - Notifications (Local)

    enum Notifications {
        /// Notification identifiers
        enum Identifier {
            static let scanComplete = "com.deets.notification.scanComplete"
            static let exportComplete = "com.deets.notification.exportComplete"
        }

        /// Notification categories
        enum Category {
            static let scanning = "com.deets.category.scanning"
            static let export = "com.deets.category.export"
        }
    }

    // MARK: - UserDefaults Keys

    enum UserDefaultsKeys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let iCloudSyncEnabled = "iCloudSyncEnabled"
        static let preferredExportFormat = "preferredExportFormat"
        static let ocrLanguage = "ocrLanguage"
        static let lastAppVersion = "lastAppVersion"
    }

    // MARK: - Error Messages

    enum ErrorMessage {
        static let ocrFailed = "Unable to read business card. Please try again with better lighting."
        static let saveFailed = "Failed to save contact. Please try again."
        static let exportFailed = "Failed to export contacts. Please check permissions."
        static let permissionDenied = "Permission denied. Please enable access in Settings."
        static let duplicateContact = "This contact already exists in your Contacts."
        static let insufficientData = "Please add at least a name and contact method."
        static let networkError = "Network connection required for this feature."
    }
}

// MARK: - Convenience Extensions

extension Constants.UI {
    /// Standard padding EdgeInsets
    static var paddingInsets: EdgeInsets {
        EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
    }

    /// Small padding EdgeInsets
    static var paddingInsetsSmall: EdgeInsets {
        EdgeInsets(top: paddingSmall, leading: paddingSmall, bottom: paddingSmall, trailing: paddingSmall)
    }
}

// MARK: - Usage Examples

/*

 import Constants

 // In any file:
 let primaryColor = Constants.Colors.primary
 let padding = Constants.UI.padding
 let minConfidence = Constants.OCR.minConfidence

 // Regex validation:
 if let emailRegex = Constants.Regex.email {
     let matches = emailRegex.matches(in: text, range: NSRange(text.startIndex..., in: text))
 }

 // Error messages:
 Text(Constants.ErrorMessage.ocrFailed)
     .foregroundColor(Constants.Colors.error)

 // File paths:
 let photoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
     .appendingPathComponent(Constants.FilePaths.photosDirectory)

 */
