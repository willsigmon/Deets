//
//  HapticManager.swift
//  Deets
//
//  Centralized haptic feedback management
//

import UIKit

/// Manages haptic feedback throughout the app
@MainActor
final class HapticManager {
    // MARK: - Singleton

    static let shared = HapticManager()

    // MARK: - Generators

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    // MARK: - Initialization

    private init() {
        // Prepare generators for reduced latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    // MARK: - Public Methods

    /// Trigger haptic for scan start
    func scanStarted() {
        impactMedium.impactOccurred()
    }

    /// Trigger haptic for successful scan completion
    func scanCompleted() {
        notification.notificationOccurred(.success)
    }

    /// Trigger haptic for scan error
    func scanError() {
        notification.notificationOccurred(.error)
    }

    /// Trigger haptic for button tap
    func buttonTap() {
        impactLight.impactOccurred()
    }

    /// Trigger haptic for selection change
    func selectionChanged() {
        selection.selectionChanged()
    }

    /// Trigger haptic for save action
    func saved() {
        notification.notificationOccurred(.success)
    }

    /// Trigger haptic for delete action
    func deleted() {
        impactMedium.impactOccurred()
    }

    /// Trigger haptic for warning
    func warning() {
        notification.notificationOccurred(.warning)
    }

    /// Trigger haptic for toggle switch
    func toggle() {
        impactLight.impactOccurred()
    }

    /// Trigger heavy haptic for important actions
    func heavyImpact() {
        impactHeavy.impactOccurred()
    }
}
