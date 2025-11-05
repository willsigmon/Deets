//
//  Formatters.swift
//  Deets
//
//  Field formatters for phone numbers, names, addresses
//

import Foundation
import Contacts

// MARK: - Phone Number Formatting

enum PhoneNumberFormatter {
    /// Format phone number to standard display format
    static func format(_ rawNumber: String, countryCode: String = "US") -> String? {
        let digits = rawNumber.filter { $0.isNumber }

        // Handle different lengths
        switch (digits.count, countryCode) {
        case (10, "US"):
            return formatUS10Digit(digits)
        case (11, "US") where digits.hasPrefix("1"):
            return formatUS11Digit(digits)
        case (7, "US"):
            return formatUS7Digit(digits)
        default:
            return formatInternational(digits)
        }
    }

    private static func formatUS10Digit(_ digits: String) -> String {
        let areaCode = digits.prefix(3)
        let prefix = digits.dropFirst(3).prefix(3)
        let lineNumber = digits.suffix(4)
        return "(\(areaCode)) \(prefix)-\(lineNumber)"
    }

    private static func formatUS11Digit(_ digits: String) -> String {
        let withoutCountryCode = String(digits.dropFirst())
        return "+1 " + (formatUS10Digit(withoutCountryCode) ?? withoutCountryCode)
    }

    private static func formatUS7Digit(_ digits: String) -> String {
        let prefix = digits.prefix(3)
        let lineNumber = digits.suffix(4)
        return "\(prefix)-\(lineNumber)"
    }

    private static func formatInternational(_ digits: String) -> String {
        // Basic international formatting
        if digits.count > 11 {
            let countryCode = digits.prefix(2)
            let remainder = digits.dropFirst(2)
            return "+\(countryCode) \(remainder)"
        }
        return digits
    }

    /// Clean phone number to digits only
    static func normalize(_ rawNumber: String) -> String {
        rawNumber.filter { $0.isNumber }
    }

    /// Detect phone number type from format/context
    static func detectLabel(from text: String, number: String) -> CNLabeledValue<CNPhoneNumber>.Label {
        let lowercased = text.lowercased()

        // Check context around the number
        if lowercased.contains("mobile") || lowercased.contains("cell") {
            return CNLabelPhoneNumberMobile
        } else if lowercased.contains("work") || lowercased.contains("office") || lowercased.contains("business") {
            return CNLabelWork
        } else if lowercased.contains("home") {
            return CNLabelHome
        } else if lowercased.contains("main") {
            return CNLabelPhoneNumberMain
        } else if lowercased.contains("fax") {
            return CNLabelPhoneNumberWorkFax
        } else if lowercased.contains("iphone") {
            return CNLabelPhoneNumberiPhone
        }

        // Default to mobile for modern business cards
        return CNLabelPhoneNumberMobile
    }
}

// MARK: - Name Formatting

enum NameFormatter {
    /// Capitalize name components properly
    static func formatName(_ name: String) -> String {
        // Handle special cases
        let specialPrefixes = ["mc", "mac", "o'"]
        let allCapsWords = ["ii", "iii", "iv", "phd", "md", "jr", "sr"]

        let words = name.split(separator: " ")
        let formatted = words.map { word -> String in
            let lowercased = word.lowercased()

            // Check for all-caps suffixes
            if allCapsWords.contains(lowercased) {
                return lowercased.uppercased()
            }

            // Check for special prefixes
            for prefix in specialPrefixes {
                if lowercased.hasPrefix(prefix) {
                    let prefixCapitalized = prefix.prefix(1).uppercased() + prefix.dropFirst()
                    let remainder = String(lowercased.dropFirst(prefix.count))
                    if !remainder.isEmpty {
                        return prefixCapitalized + remainder.prefix(1).uppercased() + remainder.dropFirst()
                    }
                    return prefixCapitalized
                }
            }

            // Standard capitalization
            return word.prefix(1).uppercased() + word.dropFirst().lowercased()
        }

        return formatted.joined(separator: " ")
    }

    /// Parse full name into components
    static func parseComponents(from fullName: String) -> (prefix: String?, given: String?, middle: String?, family: String?, suffix: String?) {
        let prefixes = ["mr", "mrs", "ms", "dr", "prof", "rev"]
        let suffixes = ["jr", "sr", "ii", "iii", "iv", "v", "phd", "md", "esq"]

        var components = fullName.split(separator: " ").map { String($0) }
        guard !components.isEmpty else {
            return (nil, nil, nil, nil, nil)
        }

        var prefix: String?
        var suffix: String?
        var given: String?
        var middle: String?
        var family: String?

        // Extract prefix
        if prefixes.contains(components.first!.lowercased().replacingOccurrences(of: ".", with: "")) {
            prefix = components.removeFirst()
        }

        // Extract suffix
        if let last = components.last,
           suffixes.contains(last.lowercased().replacingOccurrences(of: ".", with: "")) {
            suffix = components.removeLast()
        }

        // Parse remaining components
        switch components.count {
        case 0:
            break
        case 1:
            given = components[0]
        case 2:
            given = components[0]
            family = components[1]
        case 3:
            given = components[0]
            middle = components[1]
            family = components[2]
        default:
            // 4+ names: First name, middle names, last name
            given = components.first
            family = components.last
            middle = components.dropFirst().dropLast().joined(separator: " ")
        }

        return (
            prefix: prefix.map { formatName($0) },
            given: given.map { formatName($0) },
            middle: middle.map { formatName($0) },
            family: family.map { formatName($0) },
            suffix: suffix?.uppercased()
        )
    }
}

// MARK: - Address Formatting

enum AddressFormatter {
    /// Standardize address components
    static func formatStreet(_ street: String) -> String {
        var formatted = street

        // Expand common abbreviations
        let abbreviations = [
            ("st", "Street"),
            ("ave", "Avenue"),
            ("blvd", "Boulevard"),
            ("rd", "Road"),
            ("ln", "Lane"),
            ("dr", "Drive"),
            ("ct", "Court"),
            ("cir", "Circle"),
            ("pl", "Place"),
            ("apt", "Apt"),
            ("ste", "Suite"),
            ("bldg", "Building"),
            ("fl", "Floor")
        ]

        for (abbr, full) in abbreviations {
            // Match word boundaries
            let pattern = "\\b\(abbr)\\.?\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(formatted.startIndex..., in: formatted)
                formatted = regex.stringByReplacingMatches(
                    in: formatted,
                    range: range,
                    withTemplate: full
                )
            }
        }

        return formatted
    }

    /// Format city name
    static func formatCity(_ city: String) -> String {
        NameFormatter.formatName(city)
    }

    /// Format state (convert to 2-letter code if possible)
    static func formatState(_ state: String) -> String {
        // If already 2 letters, uppercase it
        if state.count == 2 {
            return state.uppercased()
        }

        // Try to find matching state code
        let stateMap = [
            "alabama": "AL", "alaska": "AK", "arizona": "AZ", "arkansas": "AR",
            "california": "CA", "colorado": "CO", "connecticut": "CT",
            "delaware": "DE", "florida": "FL", "georgia": "GA", "hawaii": "HI",
            "idaho": "ID", "illinois": "IL", "indiana": "IN", "iowa": "IA",
            "kansas": "KS", "kentucky": "KY", "louisiana": "LA", "maine": "ME",
            "maryland": "MD", "massachusetts": "MA", "michigan": "MI",
            "minnesota": "MN", "mississippi": "MS", "missouri": "MO",
            "montana": "MT", "nebraska": "NE", "nevada": "NV",
            "new hampshire": "NH", "new jersey": "NJ", "new mexico": "NM",
            "new york": "NY", "north carolina": "NC", "north dakota": "ND",
            "ohio": "OH", "oklahoma": "OK", "oregon": "OR", "pennsylvania": "PA",
            "rhode island": "RI", "south carolina": "SC", "south dakota": "SD",
            "tennessee": "TN", "texas": "TX", "utah": "UT", "vermont": "VT",
            "virginia": "VA", "washington": "WA", "west virginia": "WV",
            "wisconsin": "WI", "wyoming": "WY"
        ]

        return stateMap[state.lowercased()] ?? NameFormatter.formatName(state)
    }

    /// Format postal code
    static func formatPostalCode(_ postalCode: String) -> String {
        let digits = postalCode.filter { $0.isNumber }

        // US ZIP code
        if digits.count == 5 {
            return digits
        }

        // US ZIP+4
        if digits.count == 9 {
            let zip = digits.prefix(5)
            let plus4 = digits.suffix(4)
            return "\(zip)-\(plus4)"
        }

        // Return as-is for international codes
        return postalCode
    }

    /// Detect address label from context
    static func detectLabel(from text: String) -> CNLabeledValue<CNPostalAddress>.Label {
        let lowercased = text.lowercased()

        if lowercased.contains("work") || lowercased.contains("office") || lowercased.contains("business") {
            return CNLabelWork
        } else if lowercased.contains("home") {
            return CNLabelHome
        } else {
            return CNLabelWork // Default to work for business cards
        }
    }
}

// MARK: - Email Formatting

enum EmailFormatter {
    /// Normalize email address
    static func normalize(_ email: String) -> String {
        email.lowercased().trimmingCharacters(in: .whitespaces)
    }

    /// Detect email label from context
    static func detectLabel(from text: String, email: String) -> CNLabeledValue<NSString>.Label {
        let lowercased = text.lowercased()
        let emailLower = email.lowercased()

        // Check domain for hints
        if emailLower.contains("@gmail") || emailLower.contains("@yahoo") ||
           emailLower.contains("@hotmail") || emailLower.contains("@outlook") ||
           emailLower.contains("@icloud") || emailLower.contains("@me.com") {
            return CNLabelHome
        }

        // Check context
        if lowercased.contains("personal") || lowercased.contains("home") {
            return CNLabelHome
        } else if lowercased.contains("work") || lowercased.contains("office") || lowercased.contains("business") {
            return CNLabelWork
        }

        // Default to work for business cards
        return CNLabelWork
    }
}

// MARK: - URL Formatting

enum URLFormatter {
    /// Normalize URL (add scheme if missing)
    static func normalize(_ url: String) -> String {
        var normalized = url.trimmingCharacters(in: .whitespaces)

        // Add https:// if no scheme present
        if !normalized.lowercased().hasPrefix("http://") &&
           !normalized.lowercased().hasPrefix("https://") {
            normalized = "https://" + normalized
        }

        return normalized
    }

    /// Detect URL type
    static func detectType(from url: String) -> ParsedURL.URLType {
        let lowercased = url.lowercased()

        if lowercased.contains("linkedin.com") {
            return .linkedin
        } else if lowercased.contains("twitter.com") || lowercased.contains("x.com") {
            return .twitter
        } else if lowercased.contains("facebook.com") {
            return .facebook
        } else if lowercased.contains("instagram.com") {
            return .instagram
        } else {
            return .website
        }
    }

    /// Detect URL label from type
    static func detectLabel(type: ParsedURL.URLType) -> CNLabeledValue<NSString>.Label {
        switch type {
        case .website:
            return CNLabelURLAddressHomePage
        case .linkedin, .twitter, .facebook, .instagram:
            return "Social"
        case .other:
            return CNLabelOther
        }
    }
}

// MARK: - Company/Job Title Formatting

enum OrganizationFormatter {
    /// Format company name
    static func formatCompany(_ company: String) -> String {
        var formatted = company.trimmingCharacters(in: .whitespaces)

        // Don't change all-caps company names (like IBM, NASA)
        if formatted.uppercased() == formatted && formatted.count <= 5 {
            return formatted
        }

        // Otherwise apply title case
        return formatted.split(separator: " ").map { word in
            String(word.prefix(1).uppercased() + word.dropFirst().lowercased())
        }.joined(separator: " ")
    }

    /// Format job title
    static func formatJobTitle(_ title: String) -> String {
        // Title case for job titles
        title.split(separator: " ").map { word in
            let lowercased = word.lowercased()

            // Keep some words lowercase
            let lowercase = ["of", "and", "the", "for", "in", "at", "to"]
            if lowercase.contains(lowercased) {
                return lowercased
            }

            return String(word.prefix(1).uppercased() + word.dropFirst().lowercased())
        }.joined(separator: " ")
    }
}
