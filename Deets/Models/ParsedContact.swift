//
//  ParsedContact.swift
//  Deets
//
//  Intermediate model between OCR text and CNMutableContact
//  Includes validation flags and confidence scores
//

import Foundation
import Contacts

/// Represents a contact parsed from OCR text with validation metadata
struct ParsedContact {
    // MARK: - Name Components
    var namePrefix: String?
    var givenName: String?
    var middleName: String?
    var familyName: String?
    var nameSuffix: String?
    var nickname: String?

    // MARK: - Organization
    var organizationName: String?
    var jobTitle: String?
    var department: String?

    // MARK: - Contact Methods
    var phoneNumbers: [ParsedPhoneNumber] = []
    var emailAddresses: [ParsedEmail] = []
    var urls: [ParsedURL] = []

    // MARK: - Addresses
    var postalAddresses: [ParsedAddress] = []

    // MARK: - Social
    var socialProfiles: [ParsedSocialProfile] = []

    // MARK: - Additional
    var note: String?
    var birthday: DateComponents?

    // MARK: - Metadata
    var confidenceScores: ConfidenceScores
    var validationFlags: ValidationFlags
    var rawText: String
    var parseDate: Date

    init(rawText: String) {
        self.rawText = rawText
        self.parseDate = Date()
        self.confidenceScores = ConfidenceScores()
        self.validationFlags = ValidationFlags()
    }

    // MARK: - Confidence Tracking
    struct ConfidenceScores {
        var name: Double = 0.0
        var phone: Double = 0.0
        var email: Double = 0.0
        var address: Double = 0.0
        var organization: Double = 0.0
        var overall: Double = 0.0

        mutating func calculateOverall() {
            let scores = [name, phone, email, address, organization]
            let validScores = scores.filter { $0 > 0 }
            overall = validScores.isEmpty ? 0 : validScores.reduce(0, +) / Double(validScores.count)
        }
    }

    // MARK: - Validation Flags
    struct ValidationFlags {
        var hasValidName: Bool = false
        var hasValidPhone: Bool = false
        var hasValidEmail: Bool = false
        var hasValidAddress: Bool = false
        var hasMinimumData: Bool = false
        var hasPotentialDuplicates: Bool = false

        mutating func updateMinimumData(hasName: Bool, hasPhone: Bool, hasEmail: Bool) {
            // Minimum data: name + (phone OR email)
            hasMinimumData = hasName && (hasPhone || hasEmail)
        }
    }
}

// MARK: - Parsed Field Types

struct ParsedPhoneNumber: Identifiable {
    let id = UUID()
    let number: String
    let label: CNLabeledValue<CNPhoneNumber>.Label
    let formattedNumber: String?
    let confidence: Double
    let isValid: Bool

    init(number: String, label: CNLabeledValue<CNPhoneNumber>.Label = CNLabelPhoneNumberMain, confidence: Double = 1.0) {
        self.number = number
        self.label = label
        self.confidence = confidence
        self.formattedNumber = PhoneNumberFormatter.format(number)
        self.isValid = PhoneNumberValidator.isValid(number)
    }
}

struct ParsedEmail: Identifiable {
    let id = UUID()
    let address: String
    let label: CNLabeledValue<NSString>.Label
    let confidence: Double
    let isValid: Bool

    init(address: String, label: CNLabeledValue<NSString>.Label = CNLabelWork, confidence: Double = 1.0) {
        self.address = address.lowercased()
        self.label = label
        self.confidence = confidence
        self.isValid = EmailValidator.isValid(address)
    }
}

struct ParsedURL: Identifiable {
    let id = UUID()
    let url: String
    let label: CNLabeledValue<NSString>.Label
    let type: URLType
    let confidence: Double
    let isValid: Bool

    enum URLType {
        case website
        case linkedin
        case twitter
        case facebook
        case instagram
        case other
    }

    init(url: String, label: CNLabeledValue<NSString>.Label = CNLabelURLAddressHomePage, type: URLType = .website, confidence: Double = 1.0) {
        self.url = url
        self.label = label
        self.type = type
        self.confidence = confidence
        self.isValid = URLValidator.isValid(url)
    }
}

struct ParsedAddress: Identifiable {
    let id = UUID()
    var street: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var label: CNLabeledValue<CNPostalAddress>.Label
    var confidence: Double
    var isValid: Bool

    init(street: String? = nil,
         city: String? = nil,
         state: String? = nil,
         postalCode: String? = nil,
         country: String? = nil,
         label: CNLabeledValue<CNPostalAddress>.Label = CNLabelWork,
         confidence: Double = 1.0) {
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.label = label
        self.confidence = confidence
        self.isValid = AddressValidator.isValid(street: street, city: city, state: state, postalCode: postalCode)
    }

    var hasMinimumData: Bool {
        (street != nil || city != nil) && (state != nil || postalCode != nil)
    }
}

struct ParsedSocialProfile: Identifiable {
    let id = UUID()
    let username: String
    let service: String
    let url: String?
    let confidence: Double

    init(username: String, service: String, url: String? = nil, confidence: Double = 1.0) {
        self.username = username
        self.service = service
        self.url = url
        self.confidence = confidence
    }
}

// MARK: - Extensions

extension ParsedContact {
    /// Converts ParsedContact to CNMutableContact
    func toCNMutableContact() -> CNMutableContact {
        let contact = CNMutableContact()

        // Name components
        contact.namePrefix = namePrefix ?? ""
        contact.givenName = givenName ?? ""
        contact.middleName = middleName ?? ""
        contact.familyName = familyName ?? ""
        contact.nameSuffix = nameSuffix ?? ""
        contact.nickname = nickname ?? ""

        // Organization
        contact.organizationName = organizationName ?? ""
        contact.jobTitle = jobTitle ?? ""
        contact.departmentName = department ?? ""

        // Phone numbers
        contact.phoneNumbers = phoneNumbers.filter { $0.isValid }.map { parsed in
            CNLabeledValue(
                label: parsed.label,
                value: CNPhoneNumber(stringValue: parsed.number)
            )
        }

        // Email addresses
        contact.emailAddresses = emailAddresses.filter { $0.isValid }.map { parsed in
            CNLabeledValue(
                label: parsed.label,
                value: parsed.address as NSString
            )
        }

        // URLs
        contact.urlAddresses = urls.filter { $0.isValid }.map { parsed in
            CNLabeledValue(
                label: parsed.label,
                value: parsed.url as NSString
            )
        }

        // Postal addresses
        contact.postalAddresses = postalAddresses.filter { $0.isValid }.map { parsed in
            let address = CNMutablePostalAddress()
            address.street = parsed.street ?? ""
            address.city = parsed.city ?? ""
            address.state = parsed.state ?? ""
            address.postalCode = parsed.postalCode ?? ""
            address.country = parsed.country ?? ""

            return CNLabeledValue(
                label: parsed.label,
                value: address as CNPostalAddress
            )
        }

        // Social profiles
        contact.socialProfiles = socialProfiles.map { parsed in
            let profile = CNSocialProfile(
                urlString: parsed.url,
                username: parsed.username,
                userIdentifier: nil,
                service: parsed.service
            )
            return CNLabeledValue(
                label: parsed.service,
                value: profile
            )
        }

        // Note (include parsing metadata)
        var noteText = note ?? ""
        if !noteText.isEmpty {
            noteText += "\n\n"
        }
        noteText += "Imported via Deets on \(parseDate.formatted(date: .abbreviated, time: .shortened))"
        noteText += "\nConfidence: \(String(format: "%.0f%%", confidenceScores.overall * 100))"
        contact.note = noteText

        // Birthday
        if let birthday = birthday {
            contact.birthday = birthday
        }

        return contact
    }

    /// Quick validation check
    var isValidForSaving: Bool {
        validationFlags.hasMinimumData &&
        (validationFlags.hasValidName || validationFlags.hasValidPhone || validationFlags.hasValidEmail)
    }

    /// Human-readable summary
    var summary: String {
        var parts: [String] = []

        if let name = givenName {
            parts.append(name)
        }
        if let family = familyName {
            parts.append(family)
        }
        if let org = organizationName {
            parts.append("(\(org))")
        }

        let contactMethods = [
            phoneNumbers.isEmpty ? nil : "\(phoneNumbers.count) phone",
            emailAddresses.isEmpty ? nil : "\(emailAddresses.count) email",
            urls.isEmpty ? nil : "\(urls.count) URL"
        ].compactMap { $0 }.joined(separator: ", ")

        if !contactMethods.isEmpty {
            parts.append("- \(contactMethods)")
        }

        return parts.joined(separator: " ")
    }
}

// MARK: - Simple Validators (referenced by init methods)

private enum PhoneNumberValidator {
    static func isValid(_ number: String) -> Bool {
        let digits = number.filter { $0.isNumber }
        return digits.count >= 10 && digits.count <= 15
    }
}

private enum EmailValidator {
    static func isValid(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

private enum URLValidator {
    static func isValid(_ url: String) -> Bool {
        guard let url = URL(string: url) else { return false }
        return url.scheme != nil && url.host != nil
    }
}

private enum AddressValidator {
    static func isValid(street: String?, city: String?, state: String?, postalCode: String?) -> Bool {
        // At minimum need street+city OR city+state OR street+zip
        let hasStreet = !(street?.isEmpty ?? true)
        let hasCity = !(city?.isEmpty ?? true)
        let hasState = !(state?.isEmpty ?? true)
        let hasZip = !(postalCode?.isEmpty ?? true)

        return (hasStreet && hasCity) || (hasCity && hasState) || (hasStreet && hasZip)
    }
}

// Placeholder for formatter (will be implemented in Formatters.swift)
private enum PhoneNumberFormatter {
    static func format(_ number: String) -> String? {
        let digits = number.filter { $0.isNumber }
        guard digits.count == 10 else { return nil }

        let areaCode = digits.prefix(3)
        let prefix = digits.dropFirst(3).prefix(3)
        let lineNumber = digits.suffix(4)

        return "(\(areaCode)) \(prefix)-\(lineNumber)"
    }
}
