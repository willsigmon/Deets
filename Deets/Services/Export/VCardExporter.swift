//
//  VCardExporter.swift
//  Deets
//
//  vCard 4.0 (RFC 6350) export functionality
//  Converts BusinessCard and ParsedContact to vCard format
//

import Foundation
import Contacts

/// Exports contacts to vCard 4.0 format (RFC 6350)
struct VCardExporter {

    // MARK: - Public Interface

    /// Export a single BusinessCard to vCard format
    static func exportCard(_ card: BusinessCard) -> String {
        var vcard = beginVCard()

        // Name (required field)
        let fullName = (card.fullName?.isEmpty == false ? card.fullName : nil) ?? card.displayName
        vcard += formatName(fullName: fullName)
        vcard += formatFormattedName(fullName)

        // Organization
        if let company = card.company {
            vcard += "ORG:\(escape(company))\n"
        }

        if let jobTitle = card.jobTitle {
            vcard += "TITLE:\(escape(jobTitle))\n"
        }

        // Contact methods
        if let email = card.email {
            vcard += "EMAIL;TYPE=WORK:\(escape(email))\n"
        }

        if let phone = card.phoneNumber {
            vcard += formatPhoneNumber(phone, type: "WORK")
        }

        if let website = card.website {
            vcard += "URL;TYPE=WORK:\(escape(website))\n"
        }

        // Address
        if let address = card.address {
            vcard += formatAddress(address)
        }

        // Notes
        if let notes = card.notes {
            vcard += "NOTE:\(escape(notes))\n"
        }

        // Metadata
        vcard += "REV:\(formatRevision(card.dateModified))\n"
        vcard += "PRODID:-//Deets//Business Card Scanner//EN\n"

        vcard += endVCard()
        return vcard
    }

    /// Export a ParsedContact to vCard format
    static func exportParsedContact(_ contact: ParsedContact) -> String {
        var vcard = beginVCard()

        // Name components
        vcard += formatStructuredName(
            prefix: contact.namePrefix,
            given: contact.givenName,
            middle: contact.middleName,
            family: contact.familyName,
            suffix: contact.nameSuffix
        )

        // Formatted name (required)
        let formattedName = buildFullName(from: contact)
        vcard += "FN:\(escape(formattedName))\n"

        // Nickname
        if let nickname = contact.nickname {
            vcard += "NICKNAME:\(escape(nickname))\n"
        }

        // Organization
        if let org = contact.organizationName {
            vcard += "ORG:\(escape(org))"
            if let dept = contact.department {
                vcard += ";\(escape(dept))"
            }
            vcard += "\n"
        }

        if let title = contact.jobTitle {
            vcard += "TITLE:\(escape(title))\n"
        }

        // Phone numbers
        for phone in contact.phoneNumbers where phone.isValid {
            vcard += formatPhoneNumber(phone.number, type: labelToType(phone.label))
        }

        // Email addresses
        for email in contact.emailAddresses where email.isValid {
            let type = labelToType(email.label)
            vcard += "EMAIL;TYPE=\(type):\(escape(email.address))\n"
        }

        // URLs
        for url in contact.urls where url.isValid {
            let type = labelToType(url.label)
            vcard += "URL;TYPE=\(type):\(escape(url.url))\n"
        }

        // Addresses
        for address in contact.postalAddresses where address.isValid {
            vcard += formatStructuredAddress(address)
        }

        // Social profiles
        for profile in contact.socialProfiles {
            vcard += formatSocialProfile(profile)
        }

        // Birthday
        if let birthday = contact.birthday,
           let year = birthday.year,
           let month = birthday.month,
           let day = birthday.day {
            vcard += "BDAY:\(String(format: "%04d%02d%02d", year, month, day))\n"
        }

        // Note
        if let note = contact.note {
            vcard += "NOTE:\(escape(note))\n"
        }

        // Metadata
        vcard += "REV:\(formatRevision(contact.parseDate))\n"
        vcard += "PRODID:-//Deets//Business Card Scanner//EN\n"

        vcard += endVCard()
        return vcard
    }

    /// Export multiple cards to a single vCard file
    static func exportMultipleCards(_ cards: [BusinessCard]) -> String {
        cards.map { exportCard($0) }.joined(separator: "\n")
    }

    /// Export multiple parsed contacts to a single vCard file
    static func exportMultipleParsedContacts(_ contacts: [ParsedContact]) -> String {
        contacts.map { exportParsedContact($0) }.joined(separator: "\n")
    }

    // MARK: - vCard Structure

    private static func beginVCard() -> String {
        """
        BEGIN:VCARD
        VERSION:4.0

        """
    }

    private static func endVCard() -> String {
        "END:VCARD\n"
    }

    // MARK: - Field Formatters

    private static func formatName(fullName: String) -> String {
        let parts = fullName.components(separatedBy: " ")
        let family = parts.count > 1 ? parts.dropFirst().joined(separator: " ") : ""
        let given = parts.first ?? ""

        return "N:\(escape(family));\(escape(given));;;\n"
    }

    private static func formatFormattedName(_ name: String) -> String {
        "FN:\(escape(name))\n"
    }

    private static func formatStructuredName(
        prefix: String?,
        given: String?,
        middle: String?,
        family: String?,
        suffix: String?
    ) -> String {
        let prefixStr = escape(prefix ?? "")
        let givenStr = escape(given ?? "")
        let middleStr = escape(middle ?? "")
        let familyStr = escape(family ?? "")
        let suffixStr = escape(suffix ?? "")

        return "N:\(familyStr);\(givenStr);\(middleStr);\(prefixStr);\(suffixStr)\n"
    }

    private static func formatPhoneNumber(_ number: String, type: String) -> String {
        let cleanNumber = number.filter { $0.isNumber || $0 == "+" }
        return "TEL;TYPE=\(type):\(cleanNumber)\n"
    }

    private static func formatAddress(_ address: String) -> String {
        // Simple address format (street only)
        // Format: ADR;TYPE=WORK:;;street;city;state;postal;country
        return "ADR;TYPE=WORK:;;\(escape(address));;;;\n"
    }

    private static func formatStructuredAddress(_ address: ParsedAddress) -> String {
        let type = labelToType(address.label)
        let street = escape(address.street ?? "")
        let city = escape(address.city ?? "")
        let state = escape(address.state ?? "")
        let postal = escape(address.postalCode ?? "")
        let country = escape(address.country ?? "")

        // Format: ADR;TYPE=X:po-box;extended;street;city;state;postal;country
        return "ADR;TYPE=\(type):;;\(street);\(city);\(state);\(postal);\(country)\n"
    }

    private static func formatSocialProfile(_ profile: ParsedSocialProfile) -> String {
        // Use X-SOCIALPROFILE extension for compatibility
        let service = escape(profile.service.uppercased())
        let username = escape(profile.username)

        if let url = profile.url {
            return "X-SOCIALPROFILE;TYPE=\(service):\(escape(url))\n"
        } else {
            return "X-SOCIALPROFILE;TYPE=\(service):\(username)\n"
        }
    }

    private static func formatRevision(_ date: Date?) -> String {
        guard let date else {
            return ISO8601DateFormatter().string(from: Date())
        }

        // ISO 8601 format: 20231105T143022Z
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }

    // MARK: - Utilities

    /// Escape special characters in vCard values
    private static func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    /// Convert CNLabel to vCard TYPE parameter
    private static func labelToType(_ label: String?) -> String {
        guard let label = label else { return "WORK" }

        switch label {
        case CNLabelHome:
            return "HOME"
        case CNLabelWork:
            return "WORK"
        case CNLabelPhoneNumberMobile, CNLabelPhoneNumberiPhone:
            return "CELL"
        case CNLabelPhoneNumberMain:
            return "VOICE"
        case CNLabelPhoneNumberHomeFax, CNLabelPhoneNumberWorkFax:
            return "FAX"
        default:
            return "WORK"
        }
    }

    /// Build full name from ParsedContact components
    private static func buildFullName(from contact: ParsedContact) -> String {
        var parts: [String] = []

        if let prefix = contact.namePrefix {
            parts.append(prefix)
        }
        if let given = contact.givenName {
            parts.append(given)
        }
        if let middle = contact.middleName {
            parts.append(middle)
        }
        if let family = contact.familyName {
            parts.append(family)
        }
        if let suffix = contact.nameSuffix {
            parts.append(suffix)
        }

        let fullName = parts.joined(separator: " ")
        return fullName.isEmpty ? "Unknown" : fullName
    }

    // MARK: - File Generation

    /// Generate filename for vCard export
    static func generateFilename(for card: BusinessCard) -> String {
        let rawName = (card.fullName?.isEmpty == false ? card.fullName : nil) ?? card.displayName
        let name = sanitizeFilename(rawName)
        return "\(name).vcf"
    }

    /// Generate filename for multiple cards
    static func generateFilename(count: Int) -> String {
        let timestamp = Date().formatted(date: .abbreviated, time: .omitted)
        return "Deets Export - \(count) contacts - \(timestamp).vcf"
    }

    /// Generate filename for ParsedContact
    static func generateFilename(for contact: ParsedContact) -> String {
        let name = buildFullName(from: contact)
        let sanitized = sanitizeFilename(name)
        return "\(sanitized).vcf"
    }

    private static func sanitizeFilename(_ name: String) -> String {
        // Remove invalid filename characters
        let invalid = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalid).joined(separator: "-")
    }
}
