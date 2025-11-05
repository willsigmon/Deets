//
//  TextValidator.swift
//  Deets
//
//  Created by IVY (VisionKit & OCR Engineer)
//
//  Text validation and quality scoring for OCR results
//  Filters noise, validates text quality, and categorizes recognized text
//

import Foundation

/// Validates and scores OCR-extracted text for quality and relevance
final class TextValidator {

    // MARK: - Configuration

    struct ValidationRules {
        /// Minimum confidence score to consider text valid (0.0 - 1.0)
        var minimumConfidence: Float = 0.5

        /// Minimum text length to be considered valid
        var minimumLength: Int = 2

        /// Maximum text length (likely noise if exceeded)
        var maximumLength: Int = 500

        /// Whether to filter out single characters
        var filterSingleCharacters: Bool = true

        /// Whether to filter common OCR artifacts
        var filterOCRArtifacts: Bool = true

        /// Whether to require alphanumeric content
        var requireAlphanumeric: Bool = true

        /// Preset for business card scanning
        static var businessCard: ValidationRules {
            var rules = ValidationRules()
            rules.minimumConfidence = 0.6
            rules.minimumLength = 2
            rules.maximumLength = 200
            rules.filterSingleCharacters = true
            rules.filterOCRArtifacts = true
            rules.requireAlphanumeric = true
            return rules
        }

        /// Lenient preset for general document scanning
        static var lenient: ValidationRules {
            var rules = ValidationRules()
            rules.minimumConfidence = 0.4
            rules.minimumLength = 1
            rules.filterSingleCharacters = false
            rules.filterOCRArtifacts = true
            rules.requireAlphanumeric = false
            return rules
        }

        /// Strict preset for high-accuracy requirements
        static var strict: ValidationRules {
            var rules = ValidationRules()
            rules.minimumConfidence = 0.8
            rules.minimumLength = 3
            rules.maximumLength = 100
            rules.filterSingleCharacters = true
            rules.filterOCRArtifacts = true
            rules.requireAlphanumeric = true
            return rules
        }
    }

    // MARK: - Properties

    private let rules: ValidationRules

    /// Common OCR artifacts and noise patterns to filter
    private let ocrArtifacts: Set<String> = [
        "|", "||", "|||",
        "_", "__", "___",
        "-", "--", "---",
        ".", "..", "...",
        "*", "**", "***",
        "~", "~~", "~~~",
        "□", "▫", "▪",
        "•", "◦", "∘"
    ]

    /// Regex patterns for text categorization
    private let patterns = ValidationPatterns()

    // MARK: - Initialization

    init(rules: ValidationRules = .businessCard) {
        self.rules = rules
    }

    // MARK: - Validation

    /// Validate text and confidence score
    /// - Parameters:
    ///   - text: Recognized text to validate
    ///   - confidence: Confidence score from OCR engine
    /// - Returns: Whether the text passes validation
    func validate(text: String, confidence: Float) -> Bool {
        // Check confidence threshold
        guard confidence >= rules.minimumConfidence else {
            return false
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check length constraints
        guard trimmed.count >= rules.minimumLength,
              trimmed.count <= rules.maximumLength else {
            return false
        }

        // Filter single characters if configured
        if rules.filterSingleCharacters && trimmed.count == 1 {
            // Allow single digits or letters
            return trimmed.rangeOfCharacter(from: .alphanumerics) != nil
        }

        // Filter OCR artifacts
        if rules.filterOCRArtifacts && isOCRArtifact(trimmed) {
            return false
        }

        // Require alphanumeric content if configured
        if rules.requireAlphanumeric && !containsAlphanumeric(trimmed) {
            return false
        }

        // Additional noise detection
        if isLikelyNoise(trimmed) {
            return false
        }

        return true
    }

    /// Calculate quality score for text (0.0 - 1.0)
    /// - Parameters:
    ///   - text: Text to score
    ///   - confidence: OCR confidence score
    /// - Returns: Quality score combining multiple factors
    func qualityScore(text: String, confidence: Float) -> Float {
        var score: Float = confidence

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Length factor (penalize very short or very long text)
        let lengthFactor = calculateLengthFactor(trimmed)
        score *= lengthFactor

        // Content quality factor
        let contentFactor = calculateContentFactor(trimmed)
        score *= contentFactor

        // Pattern recognition bonus (if matches known patterns)
        let patternBonus = hasKnownPattern(trimmed) ? 1.1 : 1.0
        score *= patternBonus

        // Clamp to 0.0 - 1.0
        return max(0.0, min(1.0, score))
    }

    // MARK: - Categorization

    /// Attempt to categorize text based on patterns
    /// - Parameter text: Text to categorize
    /// - Returns: Detected category or nil
    func categorizeText(_ text: String) -> TextCategory? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check email pattern
        if patterns.email.matches(trimmed) {
            return .email
        }

        // Check phone pattern
        if patterns.phone.matches(trimmed) {
            return .phone
        }

        // Check website pattern
        if patterns.website.matches(trimmed) {
            return .website
        }

        // Check if it's likely a name (capitalized words, 2-4 words)
        if patterns.name.matches(trimmed) {
            return .name
        }

        // Check for title indicators
        if patterns.title.matches(trimmed) {
            return .title
        }

        // Check for company indicators
        if patterns.company.matches(trimmed) {
            return .company
        }

        // Check for address patterns
        if patterns.address.matches(trimmed) {
            return .address
        }

        return nil
    }

    /// Extract structured data from categorized text
    /// - Parameter text: Text to parse
    /// - Returns: Structured data dictionary
    func extractStructuredData(_ text: String) -> [String: Any] {
        var data: [String: Any] = [:]

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Extract email
        if let email = patterns.email.firstMatch(in: trimmed) {
            data["email"] = email
        }

        // Extract phone
        if let phone = patterns.phone.firstMatch(in: trimmed) {
            data["phone"] = normalizePhoneNumber(phone)
        }

        // Extract website
        if let website = patterns.website.firstMatch(in: trimmed) {
            data["website"] = normalizeURL(website)
        }

        return data
    }

    // MARK: - Private Helpers

    private func isOCRArtifact(_ text: String) -> Bool {
        ocrArtifacts.contains(text)
    }

    private func containsAlphanumeric(_ text: String) -> Bool {
        text.rangeOfCharacter(from: .alphanumerics) != nil
    }

    private func isLikelyNoise(_ text: String) -> Bool {
        // Check for excessive repeated characters
        let uniqueChars = Set(text)
        if text.count > 3 && uniqueChars.count == 1 {
            return true // e.g., "aaaa" or "----"
        }

        // Check for random special character sequences
        let specialCharCount = text.filter { $0.isSymbol || $0.isPunctuation }.count
        let ratio = Float(specialCharCount) / Float(text.count)
        if ratio > 0.5 && text.count > 3 {
            return true // More than 50% special characters
        }

        return false
    }

    private func calculateLengthFactor(_ text: String) -> Float {
        let length = text.count

        // Optimal length range: 5-50 characters
        if length >= 5 && length <= 50 {
            return 1.0
        } else if length < 5 {
            return Float(length) / 5.0
        } else {
            // Penalize very long text
            return max(0.5, 1.0 - (Float(length - 50) / 100.0))
        }
    }

    private func calculateContentFactor(_ text: String) -> Float {
        var factor: Float = 1.0

        // Bonus for mixed case (indicates proper text)
        if text != text.uppercased() && text != text.lowercased() {
            factor *= 1.1
        }

        // Bonus for spaces (indicates words, not noise)
        if text.contains(" ") {
            factor *= 1.05
        }

        // Penalty for excessive numbers
        let digitCount = text.filter { $0.isNumber }.count
        let digitRatio = Float(digitCount) / Float(text.count)
        if digitRatio > 0.7 {
            factor *= 0.9
        }

        return factor
    }

    private func hasKnownPattern(_ text: String) -> Bool {
        patterns.email.matches(text) ||
        patterns.phone.matches(text) ||
        patterns.website.matches(text) ||
        patterns.name.matches(text)
    }

    private func normalizePhoneNumber(_ phone: String) -> String {
        // Remove common separators
        let digits = phone.filter { $0.isNumber }

        // Format as (XXX) XXX-XXXX if 10 digits
        if digits.count == 10 {
            let areaCode = digits.prefix(3)
            let middle = digits.dropFirst(3).prefix(3)
            let last = digits.suffix(4)
            return "(\(areaCode)) \(middle)-\(last)"
        }

        return digits
    }

    private func normalizeURL(_ url: String) -> String {
        var normalized = url.lowercased()

        // Add protocol if missing
        if !normalized.hasPrefix("http://") && !normalized.hasPrefix("https://") {
            normalized = "https://" + normalized
        }

        return normalized
    }
}

// MARK: - Validation Patterns

private struct ValidationPatterns {
    // Email regex (simplified but robust)
    let email = Pattern(
        regex: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
        options: [.caseInsensitive]
    )

    // Phone number (various formats)
    let phone = Pattern(
        regex: #"(?:\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})"#,
        options: [.caseInsensitive]
    )

    // Website/URL
    let website = Pattern(
        regex: #"(?:https?://)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)"#,
        options: [.caseInsensitive]
    )

    // Name pattern (2-4 capitalized words)
    let name = Pattern(
        regex: #"^[A-Z][a-z]+(?:\s[A-Z][a-z]+){1,3}$"#,
        options: []
    )

    // Job title indicators
    let title = Pattern(
        regex: #"(?i)\b(?:CEO|CTO|CFO|COO|VP|Director|Manager|Engineer|Developer|Designer|Analyst|Consultant|Specialist|Coordinator|Lead)\b"#,
        options: [.caseInsensitive]
    )

    // Company indicators (Inc, LLC, Ltd, Corp, etc.)
    let company = Pattern(
        regex: #"(?i)\b(?:Inc\.?|LLC|Ltd\.?|Corp\.?|Corporation|Company|Co\.?|Technologies|Solutions|Group|Associates)\b"#,
        options: [.caseInsensitive]
    )

    // Address patterns (street, city, state, zip)
    let address = Pattern(
        regex: #"(?i)\b(?:\d+\s+[A-Za-z\s]+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Way))\b"#,
        options: [.caseInsensitive]
    )
}

// MARK: - Pattern Helper

private struct Pattern {
    let regex: NSRegularExpression

    init(regex pattern: String, options: NSRegularExpression.Options) {
        self.regex = try! NSRegularExpression(pattern: pattern, options: options)
    }

    func matches(_ text: String) -> Bool {
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }

    func firstMatch(in text: String) -> String? {
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else {
            return nil
        }

        if let matchRange = Range(match.range, in: text) {
            return String(text[matchRange])
        }

        return nil
    }
}

// MARK: - Preview Support

#if DEBUG
extension TextValidator {
    /// Test validator against sample text
    static func test() {
        let validator = TextValidator(rules: .businessCard)

        let samples = [
            ("John Smith", 0.95),
            ("john.smith@email.com", 0.92),
            ("(555) 123-4567", 0.88),
            ("|||", 0.75), // Should be filtered as artifact
            ("a", 0.9), // Should be filtered as single character
            ("Senior Software Engineer", 0.91),
            ("Acme Corp, Inc.", 0.89),
            ("123 Main Street", 0.87)
        ]

        print("=== Text Validator Test Results ===")
        for (text, confidence) in samples {
            let isValid = validator.validate(text: text, confidence: Float(confidence))
            let quality = validator.qualityScore(text: text, confidence: Float(confidence))
            let category = validator.categorizeText(text)

            print("""
                Text: "\(text)"
                Valid: \(isValid)
                Quality: \(String(format: "%.2f", quality))
                Category: \(category?.displayName ?? "None")
                ---
                """)
        }
    }
}
#endif
