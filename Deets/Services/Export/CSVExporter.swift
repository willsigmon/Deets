//
//  CSVExporter.swift
//  Deets
//
//  CSV export functionality with customizable field selection
//  Exports BusinessCard data to CSV format with proper escaping
//

import Foundation

/// Exports business cards to CSV format
struct CSVExporter {

    // MARK: - Field Selection

    /// Available fields for CSV export
    enum ExportField: String, CaseIterable, Identifiable {
        case fullName = "Full Name"
        case givenName = "First Name"
        case familyName = "Last Name"
        case jobTitle = "Job Title"
        case company = "Company"
        case email = "Email"
        case phoneNumber = "Phone Number"
        case website = "Website"
        case address = "Address"
        case notes = "Notes"
        case dateScanned = "Date Scanned"
        case dateModified = "Date Modified"
        case tags = "Tags"
        case isFavorite = "Favorite"
        case savedToContacts = "Saved to Contacts"

        var id: String { rawValue }
    }

    /// Default fields for export (most commonly used)
    static let defaultFields: [ExportField] = [
        .fullName,
        .jobTitle,
        .company,
        .email,
        .phoneNumber,
        .website,
        .address
    ]

    /// All available fields
    static let allFields: [ExportField] = ExportField.allCases

    // MARK: - Export Methods

    /// Export a single card with selected fields
    static func exportCard(_ card: BusinessCard, fields: [ExportField] = defaultFields) -> String {
        let header = generateHeader(fields: fields)
        let row = generateRow(for: card, fields: fields)
        return "\(header)\n\(row)"
    }

    /// Export multiple cards with selected fields
    static func exportCards(_ cards: [BusinessCard], fields: [ExportField] = defaultFields) -> String {
        guard !cards.isEmpty else { return "" }

        let header = generateHeader(fields: fields)
        let rows = cards.map { generateRow(for: $0, fields: fields) }

        return ([header] + rows).joined(separator: "\n")
    }

    /// Export all cards with all fields
    static func exportCardsComplete(_ cards: [BusinessCard]) -> String {
        exportCards(cards, fields: allFields)
    }

    // MARK: - Header Generation

    private static func generateHeader(fields: [ExportField]) -> String {
        fields.map { escapeCSV($0.rawValue) }.joined(separator: ",")
    }

    // MARK: - Row Generation

    private static func generateRow(for card: BusinessCard, fields: [ExportField]) -> String {
        let values = fields.map { field -> String in
            extractValue(from: card, field: field)
        }
        return values.map { escapeCSV($0) }.joined(separator: ",")
    }

    private static func extractValue(from card: BusinessCard, field: ExportField) -> String {
        switch field {
        case .fullName:
            return card.fullName

        case .givenName:
            // Extract first name from fullName
            let parts = card.fullName.components(separatedBy: " ")
            return parts.first ?? ""

        case .familyName:
            // Extract last name from fullName
            let parts = card.fullName.components(separatedBy: " ")
            return parts.count > 1 ? parts.dropFirst().joined(separator: " ") : ""

        case .jobTitle:
            return card.jobTitle ?? ""

        case .company:
            return card.company ?? ""

        case .email:
            return card.email ?? ""

        case .phoneNumber:
            return card.phoneNumber ?? ""

        case .website:
            return card.website ?? ""

        case .address:
            return card.address ?? ""

        case .notes:
            return card.notes ?? ""

        case .dateScanned:
            return formatDate(card.dateScanned)

        case .dateModified:
            return formatDate(card.dateModified)

        case .tags:
            return card.tags.joined(separator: "; ")

        case .isFavorite:
            return card.isFavorite ? "Yes" : "No"

        case .savedToContacts:
            return card.savedToContacts ? "Yes" : "No"
        }
    }

    // MARK: - CSV Escaping

    /// Sanitize value to prevent CSV formula injection attacks
    /// - Prepends single quote to values starting with formula indicators: = + - @ \t \r
    /// - Prevents code execution when CSV is opened in Excel, Google Sheets, LibreOffice
    /// - Parameter value: Raw cell value (potentially from untrusted OCR input)
    /// - Returns: Sanitized value safe for CSV export
    private static func sanitizeFormulaInjection(_ value: String) -> String {
        guard !value.isEmpty else { return value }

        // Formula injection indicators per OWASP CSV Injection guidelines
        let dangerousChars: Set<Character> = ["=", "+", "-", "@", "\t", "\r"]

        // Check if first character is a formula indicator
        if let firstChar = value.first, dangerousChars.contains(firstChar) {
            // Prepend single quote to neutralize formula execution
            // Excel/Sheets will treat this as text, not a formula
            return "'\(value)"
        }

        return value
    }

    /// Escape a value for CSV format with formula injection protection
    /// - Sanitizes formula injection attacks (= + - @ \t \r prefixes)
    /// - Wraps in quotes if contains comma, newline, or quote
    /// - Escapes quotes by doubling them
    /// - Parameter value: Raw cell value to export
    /// - Returns: Safe CSV cell value
    private static func escapeCSV(_ value: String) -> String {
        // SECURITY: Sanitize formula injection FIRST before CSV escaping
        let sanitized = sanitizeFormulaInjection(value)

        // Check if CSV structural escaping is needed
        let needsEscaping = sanitized.contains(",") || sanitized.contains("\"") || sanitized.contains("\n") || sanitized.contains("\r")

        if needsEscaping {
            // Escape quotes by doubling them per CSV RFC 4180
            let escaped = sanitized.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        } else {
            return sanitized
        }
    }

    // MARK: - Utilities

    private static func formatDate(_ date: Date) -> String {
        // ISO 8601 format for compatibility
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

    // MARK: - File Generation

    /// Generate filename for CSV export
    static func generateFilename(for card: BusinessCard) -> String {
        let name = card.fullName.isEmpty ? "Contact" : sanitizeFilename(card.fullName)
        return "\(name).csv"
    }

    /// Generate filename for multiple cards
    static func generateFilename(count: Int) -> String {
        let timestamp = Date().formatted(date: .abbreviated, time: .omitted)
        return "Deets Export - \(count) contacts - \(timestamp).csv"
    }

    private static func sanitizeFilename(_ name: String) -> String {
        // Remove invalid filename characters
        let invalid = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalid).joined(separator: "-")
    }
}

// MARK: - Preview/Testing Helper

extension CSVExporter {
    /// Generate a preview of the CSV export (first few rows)
    static func generatePreview(_ cards: [BusinessCard], fields: [ExportField] = defaultFields, maxRows: Int = 5) -> String {
        let previewCards = Array(cards.prefix(maxRows))
        let csv = exportCards(previewCards, fields: fields)

        if cards.count > maxRows {
            return csv + "\n... (\(cards.count - maxRows) more contacts)"
        } else {
            return csv
        }
    }
}
