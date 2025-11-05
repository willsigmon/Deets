// FeatureFlags.swift
// Deets - Feature Toggle System
//
// Centralized feature flag management for gradual rollout,
// A/B testing, and development features.

import Foundation

/// Feature flags for controlling app functionality
@MainActor
final class FeatureFlags: ObservableObject {

    // MARK: - Singleton

    static let shared = FeatureFlags()

    private init() {
        // Load from UserDefaults or remote config
        loadFlags()
    }

    // MARK: - Core Features (v1.0)

    /// Enable business card scanning
    @Published var scanningEnabled = true

    /// Enable OCR text recognition
    @Published var ocrEnabled = true

    /// Enable export to Apple Contacts
    @Published var contactsExportEnabled = true

    /// Enable VCF export
    @Published var vcfExportEnabled = true

    /// Enable CSV export
    @Published var csvExportEnabled = true

    // MARK: - Privacy & Sync

    /// Enable optional iCloud sync
    @Published var iCloudSyncEnabled = true

    /// Enable photo library export
    @Published var photoLibraryExportEnabled = true

    // MARK: - Advanced Features (v1.1+)

    /// Enable photo enrichment (discover contact photos from library)
    @Published var photoEnrichmentEnabled = true

    /// Enable batch scanning (multiple cards in one session)
    @Published var batchScanningEnabled = false

    /// Enable QR code detection on business cards
    @Published var qrCodeDetectionEnabled = false

    /// Enable custom tags and categories
    @Published var customTagsEnabled = false

    /// Enable advanced duplicate detection (AI-powered)
    @Published var advancedDuplicateDetectionEnabled = false

    // MARK: - Experimental Features

    /// Enable CoreML-powered parsing (vs regex)
    @Published var mlParsingEnabled = false

    /// Enable LinkedIn profile auto-fill
    @Published var linkedInIntegrationEnabled = false

    /// Enable CRM exports (Salesforce, HubSpot)
    @Published var crmExportEnabled = false

    // MARK: - UI Enhancements

    /// Enable card-style contact view (vs list)
    @Published var cardViewEnabled = false

    /// Enable dark mode override (vs system)
    @Published var darkModeOverride = false

    /// Enable haptic feedback
    @Published var hapticFeedbackEnabled = true

    /// Enable animation effects
    @Published var animationsEnabled = true

    // MARK: - Development Features

    #if DEBUG
    /// Show debug overlay with OCR confidence scores
    @Published var debugOverlayEnabled = false

    /// Enable mock data for testing
    @Published var useMockData = false

    /// Enable performance profiling
    @Published var performanceProfilingEnabled = false

    /// Enable verbose logging
    @Published var verboseLoggingEnabled = false
    #endif

    // MARK: - OCR Configuration

    /// Supported OCR languages (v1.0 = English only)
    let supportedOCRLanguages = ["en-US"]

    /// Enable multi-language OCR (v1.1+)
    @Published var multiLanguageOCREnabled = false

    /// OCR confidence threshold (0.0 - 1.0)
    /// Fields below this threshold are flagged for review
    @Published var ocrConfidenceThreshold: Double = 0.7

    // MARK: - Performance

    /// Maximum image size for OCR (pixels)
    let maxImageSize: CGFloat = 2048

    /// JPEG compression quality for photo storage (0.0 - 1.0)
    let photoCompressionQuality: CGFloat = 0.8

    /// Thumbnail size (points)
    let thumbnailSize: CGFloat = 150

    /// Enable lazy loading of photos in list
    @Published var lazyPhotoLoadingEnabled = true

    // MARK: - Persistence

    private enum Keys {
        static let iCloudSync = "feature.iCloudSync"
        static let photoEnrichment = "feature.photoEnrichment"
        static let batchScanning = "feature.batchScanning"
        static let qrCodeDetection = "feature.qrCodeDetection"
        static let customTags = "feature.customTags"
        static let advancedDuplicates = "feature.advancedDuplicates"
        static let mlParsing = "feature.mlParsing"
        static let linkedIn = "feature.linkedIn"
        static let crmExport = "feature.crmExport"
        static let cardView = "feature.cardView"
        static let haptics = "feature.haptics"
        static let animations = "feature.animations"
        static let multiLanguageOCR = "feature.multiLanguageOCR"
        static let ocrThreshold = "feature.ocrThreshold"

        #if DEBUG
        static let debugOverlay = "debug.overlay"
        static let mockData = "debug.mockData"
        static let profiling = "debug.profiling"
        static let verboseLogging = "debug.verboseLogging"
        #endif
    }

    private func loadFlags() {
        let defaults = UserDefaults.standard

        // Load user-configurable flags
        iCloudSyncEnabled = defaults.bool(forKey: Keys.iCloudSync)
        photoEnrichmentEnabled = defaults.bool(forKey: Keys.photoEnrichment)
        batchScanningEnabled = defaults.bool(forKey: Keys.batchScanning)
        qrCodeDetectionEnabled = defaults.bool(forKey: Keys.qrCodeDetection)
        customTagsEnabled = defaults.bool(forKey: Keys.customTags)
        advancedDuplicateDetectionEnabled = defaults.bool(forKey: Keys.advancedDuplicates)
        mlParsingEnabled = defaults.bool(forKey: Keys.mlParsing)
        linkedInIntegrationEnabled = defaults.bool(forKey: Keys.linkedIn)
        crmExportEnabled = defaults.bool(forKey: Keys.crmExport)
        cardViewEnabled = defaults.bool(forKey: Keys.cardView)
        hapticFeedbackEnabled = defaults.bool(forKey: Keys.haptics)
        animationsEnabled = defaults.bool(forKey: Keys.animations)
        multiLanguageOCREnabled = defaults.bool(forKey: Keys.multiLanguageOCR)

        if defaults.object(forKey: Keys.ocrThreshold) != nil {
            ocrConfidenceThreshold = defaults.double(forKey: Keys.ocrThreshold)
        }

        #if DEBUG
        debugOverlayEnabled = defaults.bool(forKey: Keys.debugOverlay)
        useMockData = defaults.bool(forKey: Keys.mockData)
        performanceProfilingEnabled = defaults.bool(forKey: Keys.profiling)
        verboseLoggingEnabled = defaults.bool(forKey: Keys.verboseLogging)
        #endif
    }

    func saveFlags() {
        let defaults = UserDefaults.standard

        defaults.set(iCloudSyncEnabled, forKey: Keys.iCloudSync)
        defaults.set(photoEnrichmentEnabled, forKey: Keys.photoEnrichment)
        defaults.set(batchScanningEnabled, forKey: Keys.batchScanning)
        defaults.set(qrCodeDetectionEnabled, forKey: Keys.qrCodeDetection)
        defaults.set(customTagsEnabled, forKey: Keys.customTags)
        defaults.set(advancedDuplicateDetectionEnabled, forKey: Keys.advancedDuplicates)
        defaults.set(mlParsingEnabled, forKey: Keys.mlParsing)
        defaults.set(linkedInIntegrationEnabled, forKey: Keys.linkedIn)
        defaults.set(crmExportEnabled, forKey: Keys.crmExport)
        defaults.set(cardViewEnabled, forKey: Keys.cardView)
        defaults.set(hapticFeedbackEnabled, forKey: Keys.haptics)
        defaults.set(animationsEnabled, forKey: Keys.animations)
        defaults.set(multiLanguageOCREnabled, forKey: Keys.multiLanguageOCR)
        defaults.set(ocrConfidenceThreshold, forKey: Keys.ocrThreshold)

        #if DEBUG
        defaults.set(debugOverlayEnabled, forKey: Keys.debugOverlay)
        defaults.set(useMockData, forKey: Keys.mockData)
        defaults.set(performanceProfilingEnabled, forKey: Keys.profiling)
        defaults.set(verboseLoggingEnabled, forKey: Keys.verboseLogging)
        #endif
    }

    // MARK: - Remote Config (Future)

    /// Fetch feature flags from remote server (future enhancement)
    /// Allows for gradual rollout and A/B testing without app updates
    func fetchRemoteFlags() async {
        // TODO: Implement remote config fetch
        // Could use Firebase Remote Config, LaunchDarkly, or custom backend
        // For v1.0, all flags are local
    }

    // MARK: - Debug Helpers

    #if DEBUG
    /// Reset all flags to defaults (for testing)
    func resetToDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.iCloudSync)
        defaults.removeObject(forKey: Keys.photoEnrichment)
        defaults.removeObject(forKey: Keys.batchScanning)
        defaults.removeObject(forKey: Keys.qrCodeDetection)
        defaults.removeObject(forKey: Keys.customTags)
        defaults.removeObject(forKey: Keys.advancedDuplicates)
        defaults.removeObject(forKey: Keys.mlParsing)
        defaults.removeObject(forKey: Keys.linkedIn)
        defaults.removeObject(forKey: Keys.crmExport)
        defaults.removeObject(forKey: Keys.cardView)
        defaults.removeObject(forKey: Keys.haptics)
        defaults.removeObject(forKey: Keys.animations)
        defaults.removeObject(forKey: Keys.multiLanguageOCR)
        defaults.removeObject(forKey: Keys.ocrThreshold)
        defaults.removeObject(forKey: Keys.debugOverlay)
        defaults.removeObject(forKey: Keys.mockData)
        defaults.removeObject(forKey: Keys.profiling)
        defaults.removeObject(forKey: Keys.verboseLogging)

        loadFlags()
    }

    /// Print all flag values (debugging)
    func printAllFlags() {
        print("=== Feature Flags ===")
        print("Scanning: \(scanningEnabled)")
        print("OCR: \(ocrEnabled)")
        print("iCloud Sync: \(iCloudSyncEnabled)")
        print("Batch Scanning: \(batchScanningEnabled)")
        print("QR Detection: \(qrCodeDetectionEnabled)")
        print("Custom Tags: \(customTagsEnabled)")
        print("Advanced Duplicates: \(advancedDuplicateDetectionEnabled)")
        print("ML Parsing: \(mlParsingEnabled)")
        print("LinkedIn: \(linkedInIntegrationEnabled)")
        print("CRM Export: \(crmExportEnabled)")
        print("Card View: \(cardViewEnabled)")
        print("Haptics: \(hapticFeedbackEnabled)")
        print("Animations: \(animationsEnabled)")
        print("Multi-language OCR: \(multiLanguageOCREnabled)")
        print("OCR Threshold: \(ocrConfidenceThreshold)")
        print("Debug Overlay: \(debugOverlayEnabled)")
        print("Mock Data: \(useMockData)")
        print("Profiling: \(performanceProfilingEnabled)")
        print("Verbose Logging: \(verboseLoggingEnabled)")
        print("=====================")
    }
    #endif
}

// MARK: - SwiftUI Environment

import SwiftUI

extension EnvironmentValues {
    var featureFlags: FeatureFlags {
        get { self[FeatureFlagsKey.self] }
        set { self[FeatureFlagsKey.self] = newValue }
    }
}

private struct FeatureFlagsKey: EnvironmentKey {
    static let defaultValue = FeatureFlags.shared
}

// MARK: - Usage Examples

/*

 // In DeetsApp.swift:
 @main
 struct DeetsApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environment(\.featureFlags, FeatureFlags.shared)
         }
     }
 }

 // In any View:
 struct ScannerView: View {
     @Environment(\.featureFlags) var flags

     var body: some View {
         if flags.scanningEnabled {
             // Show scanner
         } else {
             // Show disabled message
         }
     }
 }

 // In ViewModel:
 @MainActor
 class ScannerViewModel: ObservableObject {
     private let flags = FeatureFlags.shared

     func scan() async {
         guard flags.scanningEnabled else { return }

         if flags.qrCodeDetectionEnabled {
             // Try QR detection first
         }

         if flags.mlParsingEnabled {
             // Use ML parsing
         } else {
             // Use regex parsing
         }
     }
 }

 */
