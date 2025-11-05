//
//  ContactParser.swift
//  Deets
//
//  Parse raw OCR text into structured contact data
//

import Foundation
import Contacts

enum ContactParser {
    // MARK: - Main Parser

    /// Parse raw OCR text into a structured ParsedContact
    static func parse(_ rawText: String) -> ParsedContact {
        var contact = ParsedContact(rawText: rawText)

        // Parse different components
        contact = parseName(from: rawText, into: contact)
        contact = parsePhoneNumbers(from: rawText, into: contact)
        contact = parseEmails(from: rawText, into: contact)
        contact = parseURLs(from: rawText, into: contact)
        contact = parseAddresses(from: rawText, into: contact)
        contact = parseOrganization(from: rawText, into: contact)

        // Calculate confidence scores
        updateConfidenceScores(&contact)

        // Update validation flags
        updateValidationFlags(&contact)

        return contact
    }

    // MARK: - Name Parsing

    private static func parseName(from text: String, into contact: ParsedContact) -> ParsedContact {
        var contact = contact
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }

        // Strategy 1: Look for name on first line (most common)
        if let firstLine = lines.first {
            let nameComponents = NameFormatter.parseComponents(from: firstLine)

            // If we found a reasonable name (has given + family), use it
            if nameComponents.given != nil && nameComponents.family != nil {
                contact.namePrefix = nameComponents.prefix
                contact.givenName = nameComponents.given
                contact.middleName = nameComponents.middle
                contact.familyName = nameComponents.family
                contact.nameSuffix = nameComponents.suffix
                return contact
            }
        }

        // Strategy 2: Look for lines with "name" keyword
        for line in lines {
            let lowercased = line.lowercased()
            if lowercased.contains("name:") {
                let nameText = line.replacingOccurrences(of: "(?i)name:", with: "", options: .regularExpression)
                let nameComponents = NameFormatter.parseComponents(from: nameText)
                contact.namePrefix = nameComponents.prefix
                contact.givenName = nameComponents.given
                contact.middleName = nameComponents.middle
                contact.familyName = nameComponents.family
                contact.nameSuffix = nameComponents.suffix
                return contact
            }
        }

        // Strategy 3: Heuristic - find line with 2-3 capitalized words (likely a name)
        for line in lines.prefix(5) { // Check first 5 lines
            let words = line.split(separator: " ")
            if words.count >= 2 && words.count <= 4 {
                let capitalizedWords = words.filter { word in
                    word.first?.isUppercase == true
                }

                if capitalizedWords.count >= 2 {
                    // This might be a name
                    let nameComponents = NameFormatter.parseComponents(from: line)
                    if nameComponents.given != nil {
                        contact.namePrefix = nameComponents.prefix
                        contact.givenName = nameComponents.given
                        contact.middleName = nameComponents.middle
                        contact.familyName = nameComponents.family
                        contact.nameSuffix = nameComponents.suffix
                        return contact
                    }
                }
            }
        }

        return contact
    }

    // MARK: - Phone Number Parsing

    private static func parsePhoneNumbers(from text: String, into contact: ParsedContact) -> ParsedContact {
        var contact = contact

        // Regex patterns for various phone formats
        let patterns = [
            // US formats
            #"\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}"#,  // (123) 456-7890, 123-456-7890
            #"\+?1[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}"#,  // +1 (123) 456-7890
            #"\d{3}[-.\s]?\d{4}"#,  // 123-4567 (7-digit)
            // International
            #"\+\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}"#  // +44 20 1234 5678
        ]

        var foundNumbers: [String] = []
        var numberContexts: [String: String] = [:] // Number -> surrounding context

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let nsText = text as NSString
                let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

                for match in matches {
                    let number = nsText.substring(with: match.range)
                    let normalized = PhoneNumberFormatter.normalize(number)

                    // Avoid duplicates
                    if !foundNumbers.contains(normalized) {
                        foundNumbers.append(normalized)

                        // Capture context (30 chars before and after)
                        let contextStart = max(0, match.range.location - 30)
                        let contextLength = min(60 + match.range.length, nsText.length - contextStart)
                        let contextRange = NSRange(location: contextStart, length: contextLength)
                        numberContexts[normalized] = nsText.substring(with: contextRange)
                    }
                }
            }
        }

        // Convert to ParsedPhoneNumber
        for number in foundNumbers {
            let context = numberContexts[number] ?? ""
            let label = PhoneNumberFormatter.detectLabel(from: context, number: number)
            let confidence = calculatePhoneConfidence(number: number, context: context)

            let parsed = ParsedPhoneNumber(
                number: number,
                label: label,
                confidence: confidence
            )

            contact.phoneNumbers.append(parsed)
        }

        return contact
    }

    // MARK: - Email Parsing

    private static func parseEmails(from text: String, into contact: ParsedContact) -> ParsedContact {
        var contact = contact

        // Email regex pattern
        let pattern = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return contact
        }

        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

        var foundEmails: Set<String> = []

        for match in matches {
            let email = nsText.substring(with: match.range)
            let normalized = EmailFormatter.normalize(email)

            // Avoid duplicates
            if !foundEmails.contains(normalized) {
                foundEmails.insert(normalized)

                // Capture context
                let contextStart = max(0, match.range.location - 30)
                let contextLength = min(60 + match.range.length, nsText.length - contextStart)
                let contextRange = NSRange(location: contextStart, length: contextLength)
                let context = nsText.substring(with: contextRange)

                let label = EmailFormatter.detectLabel(from: context, email: normalized)
                let confidence = calculateEmailConfidence(email: normalized, context: context)

                let parsed = ParsedEmail(
                    address: normalized,
                    label: label,
                    confidence: confidence
                )

                contact.emailAddresses.append(parsed)
            }
        }

        return contact
    }

    // MARK: - URL Parsing

    private static func parseURLs(from text: String, into contact: ParsedContact) -> ParsedContact {
        var contact = contact

        // URL regex patterns
        let patterns = [
            #"https?://[A-Za-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+"#,  // Full URLs
            #"www\.[A-Za-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+"#,  // www. URLs
            #"[A-Za-z0-9\-]+\.(com|net|org|io|co|edu|gov)(?:/[A-Za-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]*)?"#  // Domain.com
        ]

        var foundURLs: Set<String> = []

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                continue
            }

            let nsText = text as NSString
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

            for match in matches {
                let url = nsText.substring(with: match.range)
                let normalized = URLFormatter.normalize(url)

                // Avoid duplicates and email addresses
                if !foundURLs.contains(normalized) && !normalized.contains("@") {
                    foundURLs.insert(normalized)

                    let type = URLFormatter.detectType(from: normalized)
                    let label = URLFormatter.detectLabel(type: type)
                    let confidence = calculateURLConfidence(url: normalized)

                    let parsed = ParsedURL(
                        url: normalized,
                        label: label,
                        type: type,
                        confidence: confidence
                    )

                    contact.urls.append(parsed)
                }
            }
        }

        return contact
    }

    // MARK: - Address Parsing

    private static func parseAddresses(from text: String, into contact: ParsedContact) -> ParsedContact {
        var contact = contact
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }

        // Strategy 1: Look for street address patterns
        let streetPattern = #"\d+\s+[A-Za-z0-9\s,.]+(Street|St|Avenue|Ave|Boulevard|Blvd|Road|Rd|Lane|Ln|Drive|Dr|Court|Ct|Circle|Cir|Place|Pl)"#

        guard let streetRegex = try? NSRegularExpression(pattern: streetPattern, options: .caseInsensitive) else {
            return contact
        }

        let nsText = text as NSString
        let streetMatches = streetRegex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

        for streetMatch in streetMatches {
            let street = nsText.substring(with: streetMatch.range)

            // Try to find city, state, zip on the next line
            var city: String?
            var state: String?
            var postalCode: String?

            // Look for city/state/zip pattern
            let cityStateZipPattern = #"([A-Za-z\s]+),\s*([A-Z]{2})\s*(\d{5}(?:-\d{4})?)"#
            if let cszRegex = try? NSRegularExpression(pattern: cityStateZipPattern, options: []) {
                // Search in the vicinity of the street address
                let searchStart = streetMatch.range.location
                let searchLength = min(200, nsText.length - searchStart)
                let searchRange = NSRange(location: searchStart, length: searchLength)

                if let cszMatch = cszRegex.firstMatch(in: text, range: searchRange) {
                    if cszMatch.numberOfRanges >= 4 {
                        city = nsText.substring(with: cszMatch.range(at: 1)).trimmingCharacters(in: .whitespaces)
                        state = nsText.substring(with: cszMatch.range(at: 2))
                        postalCode = nsText.substring(with: cszMatch.range(at: 3))
                    }
                }
            }

            // If we found enough data, create address
            if city != nil || state != nil || postalCode != nil {
                let contextStart = max(0, streetMatch.range.location - 30)
                let contextLength = min(200, nsText.length - contextStart)
                let contextRange = NSRange(location: contextStart, length: contextLength)
                let context = nsText.substring(with: contextRange)

                let label = AddressFormatter.detectLabel(from: context)
                let confidence = calculateAddressConfidence(
                    street: street,
                    city: city,
                    state: state,
                    postalCode: postalCode
                )

                let parsed = ParsedAddress(
                    street: AddressFormatter.formatStreet(street),
                    city: city.map { AddressFormatter.formatCity($0) },
                    state: state.map { AddressFormatter.formatState($0) },
                    postalCode: postalCode.map { AddressFormatter.formatPostalCode($0) },
                    country: "USA",
                    label: label,
                    confidence: confidence
                )

                contact.postalAddresses.append(parsed)
            }
        }

        // Strategy 2: Look for standalone city/state/zip patterns
        if contact.postalAddresses.isEmpty {
            let cityStateZipPattern = #"([A-Za-z\s]+),\s*([A-Z]{2})\s*(\d{5}(?:-\d{4})?)"#
            if let cszRegex = try? NSRegularExpression(pattern: cityStateZipPattern, options: []) {
                let matches = cszRegex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

                for match in matches {
                    if match.numberOfRanges >= 4 {
                        let city = nsText.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
                        let state = nsText.substring(with: match.range(at: 2))
                        let postalCode = nsText.substring(with: match.range(at: 3))

                        let parsed = ParsedAddress(
                            street: nil,
                            city: AddressFormatter.formatCity(city),
                            state: AddressFormatter.formatState(state),
                            postalCode: AddressFormatter.formatPostalCode(postalCode),
                            country: "USA",
                            label: CNLabelWork,
                            confidence: 0.7
                        )

                        contact.postalAddresses.append(parsed)
                    }
                }
            }
        }

        return contact
    }

    // MARK: - Organization Parsing

    private static func parseOrganization(from text: String, into contact: ParsedContact) -> ParsedContact {
        var contact = contact
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }

        // Strategy 1: Look for company/title keywords
        for line in lines {
            let lowercased = line.lowercased()

            if lowercased.contains("company:") || lowercased.contains("organization:") {
                let company = line.replacingOccurrences(
                    of: "(?i)(company|organization):\\s*",
                    with: "",
                    options: .regularExpression
                )
                contact.organizationName = OrganizationFormatter.formatCompany(company)
            } else if lowercased.contains("title:") || lowercased.contains("position:") {
                let title = line.replacingOccurrences(
                    of: "(?i)(title|position):\\s*",
                    with: "",
                    options: .regularExpression
                )
                contact.jobTitle = OrganizationFormatter.formatJobTitle(title)
            }
        }

        // Strategy 2: Heuristic - look for job title keywords
        if contact.jobTitle == nil {
            let titleKeywords = [
                "ceo", "cto", "cfo", "coo", "president", "vice president", "vp",
                "director", "manager", "engineer", "developer", "designer",
                "analyst", "consultant", "specialist", "coordinator", "lead",
                "senior", "junior", "principal", "staff", "head of"
            ]

            for line in lines.prefix(10) {
                let lowercased = line.lowercased()
                for keyword in titleKeywords {
                    if lowercased.contains(keyword) {
                        contact.jobTitle = OrganizationFormatter.formatJobTitle(line)
                        break
                    }
                }
                if contact.jobTitle != nil { break }
            }
        }

        // Strategy 3: Heuristic - second line might be company name
        if contact.organizationName == nil && lines.count >= 2 {
            let secondLine = lines[1]
            // If it's not a phone/email/url, might be company
            if !secondLine.contains("@") &&
               !secondLine.contains("www.") &&
               !secondLine.contains("http") &&
               secondLine.filter({ $0.isNumber }).count < 5 {
                contact.organizationName = OrganizationFormatter.formatCompany(secondLine)
            }
        }

        return contact
    }

    // MARK: - Confidence Calculation

    private static func calculatePhoneConfidence(number: String, context: String) -> Double {
        let digits = number.filter { $0.isNumber }

        var confidence = 0.0

        // Valid length
        if digits.count >= 10 && digits.count <= 15 {
            confidence += 0.5
        } else {
            confidence += 0.2
        }

        // Has formatting indicators nearby
        if context.lowercased().contains("phone") ||
           context.lowercased().contains("mobile") ||
           context.lowercased().contains("tel") {
            confidence += 0.3
        }

        // Has label indicators
        if context.lowercased().contains("cell") ||
           context.lowercased().contains("work") ||
           context.lowercased().contains("office") {
            confidence += 0.2
        }

        return min(confidence, 1.0)
    }

    private static func calculateEmailConfidence(email: String, context: String) -> Double {
        var confidence = 0.0

        // Valid format
        if EmailValidator.isValid(email) {
            confidence += 0.6
        } else {
            confidence += 0.2
        }

        // Has label nearby
        if context.lowercased().contains("email") ||
           context.lowercased().contains("e-mail") {
            confidence += 0.3
        }

        // Has valid TLD
        let commonTLDs = [".com", ".net", ".org", ".io", ".co", ".edu", ".gov"]
        if commonTLDs.contains(where: { email.lowercased().hasSuffix($0) }) {
            confidence += 0.1
        }

        return min(confidence, 1.0)
    }

    private static func calculateURLConfidence(url: String) -> Double {
        var confidence = 0.0

        // Has valid scheme
        if url.lowercased().hasPrefix("http://") || url.lowercased().hasPrefix("https://") {
            confidence += 0.4
        }

        // Has www.
        if url.lowercased().contains("www.") {
            confidence += 0.2
        }

        // Has valid TLD
        let commonTLDs = [".com", ".net", ".org", ".io", ".co"]
        if commonTLDs.contains(where: { url.lowercased().contains($0) }) {
            confidence += 0.3
        }

        // Is a known social platform
        let socialDomains = ["linkedin.com", "twitter.com", "facebook.com", "instagram.com"]
        if socialDomains.contains(where: { url.lowercased().contains($0) }) {
            confidence += 0.1
        }

        return min(confidence, 1.0)
    }

    private static func calculateAddressConfidence(street: String?, city: String?, state: String?, postalCode: String?) -> Double {
        var confidence = 0.0

        if street != nil {
            confidence += 0.3
        }

        if city != nil {
            confidence += 0.3
        }

        if state != nil {
            confidence += 0.2
        }

        if postalCode != nil {
            confidence += 0.2
        }

        return min(confidence, 1.0)
    }

    private static func updateConfidenceScores(_ contact: inout ParsedContact) {
        // Name confidence
        if contact.givenName != nil && contact.familyName != nil {
            contact.confidenceScores.name = 1.0
        } else if contact.givenName != nil || contact.familyName != nil {
            contact.confidenceScores.name = 0.5
        }

        // Phone confidence (average of all phones)
        if !contact.phoneNumbers.isEmpty {
            contact.confidenceScores.phone = contact.phoneNumbers
                .map { $0.confidence }
                .reduce(0, +) / Double(contact.phoneNumbers.count)
        }

        // Email confidence (average of all emails)
        if !contact.emailAddresses.isEmpty {
            contact.confidenceScores.email = contact.emailAddresses
                .map { $0.confidence }
                .reduce(0, +) / Double(contact.emailAddresses.count)
        }

        // Address confidence (average of all addresses)
        if !contact.postalAddresses.isEmpty {
            contact.confidenceScores.address = contact.postalAddresses
                .map { $0.confidence }
                .reduce(0, +) / Double(contact.postalAddresses.count)
        }

        // Organization confidence
        if contact.organizationName != nil && contact.jobTitle != nil {
            contact.confidenceScores.organization = 1.0
        } else if contact.organizationName != nil || contact.jobTitle != nil {
            contact.confidenceScores.organization = 0.5
        }

        // Calculate overall
        contact.confidenceScores.calculateOverall()
    }

    private static func updateValidationFlags(_ contact: inout ParsedContact) {
        // Name validation
        contact.validationFlags.hasValidName =
            (contact.givenName != nil || contact.familyName != nil)

        // Phone validation
        contact.validationFlags.hasValidPhone =
            contact.phoneNumbers.contains { $0.isValid }

        // Email validation
        contact.validationFlags.hasValidEmail =
            contact.emailAddresses.contains { $0.isValid }

        // Address validation
        contact.validationFlags.hasValidAddress =
            contact.postalAddresses.contains { $0.isValid }

        // Update minimum data
        contact.validationFlags.updateMinimumData(
            hasName: contact.validationFlags.hasValidName,
            hasPhone: contact.validationFlags.hasValidPhone,
            hasEmail: contact.validationFlags.hasValidEmail
        )
    }
}

// Simple validators used by ParsedContact
private enum EmailValidator {
    static func isValid(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
