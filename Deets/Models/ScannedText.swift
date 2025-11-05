//
//  ScannedText.swift
//  Deets
//
//  Created by IVY (VisionKit & OCR Engineer)
//

import Foundation
import VisionKit

/// Represents a single piece of text extracted via OCR with positioning and confidence metadata
struct ScannedText: Identifiable, Equatable {
    /// Unique identifier for this text fragment
    let id: UUID

    /// The recognized text content
    let text: String

    /// Confidence score from VisionKit (0.0 - 1.0)
    /// Higher values indicate more accurate recognition
    let confidence: Float

    /// Bounding rectangle in normalized coordinates (0.0 - 1.0)
    /// Origin is top-left, follows iOS coordinate system
    let boundingBox: BoundingBox

    /// Timestamp when this text was captured
    let timestamp: Date

    /// Whether this text passed validation checks
    let isValid: Bool

    /// Optional metadata for categorization (email, phone, name, etc.)
    var category: TextCategory?

    init(
        id: UUID = UUID(),
        text: String,
        confidence: Float,
        boundingBox: BoundingBox,
        timestamp: Date = Date(),
        isValid: Bool = true,
        category: TextCategory? = nil
    ) {
        self.id = id
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.timestamp = timestamp
        self.isValid = isValid
        self.category = category
    }
}

/// Normalized bounding box with origin at top-left
struct BoundingBox: Equatable, Codable {
    /// X position (0.0 = left edge, 1.0 = right edge)
    let x: CGFloat

    /// Y position (0.0 = top edge, 1.0 = bottom edge)
    let y: CGFloat

    /// Width as percentage of total width
    let width: CGFloat

    /// Height as percentage of total height
    let height: CGFloat

    /// Convert to CGRect for rendering
    func toCGRect(in size: CGSize) -> CGRect {
        CGRect(
            x: x * size.width,
            y: y * size.height,
            width: width * size.width,
            height: height * size.height
        )
    }

    /// Create from VisionKit's RecognizedItem bounds
    init(from bounds: CGRect, imageSize: CGSize) {
        self.x = bounds.minX / imageSize.width
        self.y = bounds.minY / imageSize.height
        self.width = bounds.width / imageSize.width
        self.height = bounds.height / imageSize.height
    }

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

/// Categorization hints for recognized text
enum TextCategory: String, Codable, CaseIterable {
    case email
    case phone
    case website
    case name
    case title
    case company
    case address
    case other

    var displayName: String {
        switch self {
        case .email: return "Email"
        case .phone: return "Phone"
        case .website: return "Website"
        case .name: return "Name"
        case .title: return "Title"
        case .company: return "Company"
        case .address: return "Address"
        case .other: return "Other"
        }
    }
}

/// Collection of scanned text from a single scan session
struct ScanResult: Identifiable {
    let id: UUID
    let items: [ScannedText]
    let captureDate: Date
    let imageData: Data?

    /// All valid text items sorted by confidence (highest first)
    var validItems: [ScannedText] {
        items
            .filter { $0.isValid }
            .sorted { $0.confidence > $1.confidence }
    }

    /// Average confidence across all items
    var averageConfidence: Float {
        guard !items.isEmpty else { return 0 }
        let sum = items.reduce(0) { $0 + $1.confidence }
        return sum / Float(items.count)
    }

    /// Text grouped by category
    var itemsByCategory: [TextCategory: [ScannedText]] {
        Dictionary(grouping: validItems) { item in
            item.category ?? .other
        }
    }

    init(
        id: UUID = UUID(),
        items: [ScannedText],
        captureDate: Date = Date(),
        imageData: Data? = nil
    ) {
        self.id = id
        self.items = items
        self.captureDate = captureDate
        self.imageData = imageData
    }
}

// MARK: - Convenience Extensions

extension ScannedText {
    /// Create from VisionKit RecognizedItem
    static func from(
        recognizedItem: RecognizedItem,
        imageSize: CGSize,
        validator: TextValidator? = nil
    ) -> ScannedText? {
        guard case .text(let observation) = recognizedItem else {
            return nil
        }

        let text = observation.transcript
        let confidence = observation.confidence
        let boundingBox = BoundingBox(from: observation.bounds, imageSize: imageSize)

        // Run validation if validator provided
        let isValid = validator?.validate(text: text, confidence: confidence) ?? true

        return ScannedText(
            text: text,
            confidence: confidence,
            boundingBox: boundingBox,
            isValid: isValid
        )
    }
}

extension Array where Element == ScannedText {
    /// Filter by minimum confidence threshold
    func withMinimumConfidence(_ threshold: Float) -> [ScannedText] {
        filter { $0.confidence >= threshold }
    }

    /// Sort by vertical position (top to bottom)
    func sortedByPosition() -> [ScannedText] {
        sorted { $0.boundingBox.y < $1.boundingBox.y }
    }

    /// Combine all text into single string
    func combinedText(separator: String = "\n") -> String {
        map { $0.text }.joined(separator: separator)
    }
}
