//
//  ScanViewModel.swift
//  Deets
//
//  ViewModel for business card scanning
//

import SwiftUI
import VisionKit
import Observation

@Observable
@MainActor
final class ScanViewModel {
    // MARK: - Published State

    /// Whether scanning is currently active
    var isScanning = false

    /// Scanned text result
    var scannedText: String?

    /// Error message if scan fails
    var errorMessage: String?

    /// Whether to show the contact preview
    var showContactPreview = false

    /// Whether data scanner is available
    var isScannerAvailable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    // MARK: - Dependencies

    private let hapticManager = HapticManager.shared

    // MARK: - Public Methods

    /// Start scanning
    func startScanning() {
        guard isScannerAvailable else {
            errorMessage = "Camera scanning is not available on this device"
            return
        }

        isScanning = true
        errorMessage = nil
        hapticManager.scanStarted()
    }

    /// Handle scanned text from VisionKit
    func handleScannedText(_ text: String) {
        guard !text.isEmpty else { return }

        scannedText = text
        isScanning = false
        showContactPreview = true
        hapticManager.scanCompleted()
    }

    /// Handle scan error
    func handleScanError(_ error: Error) {
        errorMessage = error.localizedDescription
        isScanning = false
        hapticManager.scanError()
    }

    /// Cancel scanning
    func cancelScanning() {
        isScanning = false
        scannedText = nil
        errorMessage = nil
    }

    /// Reset state after successful save
    func resetAfterSave() {
        scannedText = nil
        showContactPreview = false
        errorMessage = nil
    }

    /// Retry scan after error
    func retryScan() {
        errorMessage = nil
        startScanning()
    }
}
