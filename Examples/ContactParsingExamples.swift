//
//  ContactParsingExamples.swift
//  Deets
//
//  Usage examples for contact parsing and saving
//

import Foundation
import SwiftUI
import Contacts

// MARK: - Example 1: Basic Parsing

func example1_basicParsing() {
    let ocrText = """
    John Smith
    CEO
    Acme Corporation
    john@acme.com
    (555) 123-4567
    """

    let parsed = ContactParser.parse(ocrText)

    print("=== Basic Parsing ===")
    print("Name: \(parsed.givenName ?? "") \(parsed.familyName ?? "")")
    print("Company: \(parsed.organizationName ?? "N/A")")
    print("Title: \(parsed.jobTitle ?? "N/A")")
    print("Phones: \(parsed.phoneNumbers.count)")
    print("Emails: \(parsed.emailAddresses.count)")
    print("Valid for saving: \(parsed.isValidForSaving)")
    print("Confidence: \(String(format: "%.0f%%", parsed.confidenceScores.overall * 100))")
}

// MARK: - Example 2: Saving to Contacts

@MainActor
func example2_savingContact() async {
    let contactsService = ContactsService()

    // Check permission status
    print("=== Saving Contact ===")
    print("Permission status: \(contactsService.permissionStatusDescription)")

    // Request access if needed
    do {
        if contactsService.authorizationStatus != .authorized {
            try await contactsService.requestAccess()
            print("Permission granted!")
        }

        // Parse a business card
        let ocrText = """
        Jane Doe
        Chief Technology Officer
        Tech Corp Inc.

        Mobile: (555) 987-6543
        Email: jane.doe@techcorp.com
        LinkedIn: linkedin.com/in/janedoe
        Website: www.techcorp.com

        456 Tech Boulevard, Suite 200
        San Francisco, CA 94105
        """

        let parsed = ContactParser.parse(ocrText)

        // Save with duplicate checking
        let identifier = try await contactsService.saveContact(
            parsed,
            checkDuplicates: true
        )

        print("Contact saved successfully!")
        print("Identifier: \(identifier)")

    } catch ContactsError.accessDenied {
        print("Error: Contacts access denied")
        print("Please enable in Settings > Privacy > Contacts")

    } catch ContactsError.duplicateFound(let duplicates) {
        print("Warning: Found \(duplicates.count) potential duplicate(s)")
        for duplicate in duplicates {
            print("  - \(CNContactFormatter.string(from: duplicate, style: .fullName) ?? "Unknown")")
        }

    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Example 3: Duplicate Detection

@MainActor
func example3_duplicateDetection() async {
    let contactsService = ContactsService()

    let ocrText = """
    John Smith
    john.smith@example.com
    (555) 123-4567
    """

    let parsed = ContactParser.parse(ocrText)

    do {
        if let duplicates = try await contactsService.findDuplicates(for: parsed) {
            print("=== Duplicate Detection ===")
            print("Found \(duplicates.count) potential duplicate(s):")

            for duplicate in duplicates {
                let name = CNContactFormatter.string(from: duplicate, style: .fullName) ?? "Unknown"
                let phones = duplicate.phoneNumbers.map { $0.value.stringValue }.joined(separator: ", ")
                let emails = duplicate.emailAddresses.map { $0.value as String }.joined(separator: ", ")

                print("\nCandidate:")
                print("  Name: \(name)")
                print("  Phones: \(phones)")
                print("  Emails: \(emails)")

                // Check match strictness
                let isStrict = duplicate.matches(parsed, strictness: .strict)
                let isMedium = duplicate.matches(parsed, strictness: .medium)
                let isLoose = duplicate.matches(parsed, strictness: .loose)

                print("  Match - Strict: \(isStrict), Medium: \(isMedium), Loose: \(isLoose)")
            }
        } else {
            print("No duplicates found - safe to save")
        }
    } catch {
        print("Error checking duplicates: \(error.localizedDescription)")
    }
}

// MARK: - Example 4: Batch Processing

@MainActor
func example4_batchProcessing() async {
    let contactsService = ContactsService()

    // Simulate multiple business cards
    let businessCards = [
        """
        Alice Johnson
        alice@startup.io
        (555) 111-2222
        """,
        """
        Bob Williams
        Product Manager
        bob.williams@bigcorp.com
        (555) 333-4444
        """,
        """
        Carol Martinez
        Design Lead
        carol@designstudio.com
        (555) 555-6666
        """
    ]

    let parsedContacts = businessCards.map { ContactParser.parse($0) }

    print("=== Batch Processing ===")
    print("Parsed \(parsedContacts.count) business cards")

    // Filter valid contacts
    let validContacts = parsedContacts.filter { $0.isValidForSaving }
    print("Valid contacts: \(validContacts.count)")

    // Save batch
    do {
        let identifiers = try await contactsService.saveContacts(
            validContacts,
            checkDuplicates: true
        )

        print("Successfully saved \(identifiers.count) contacts")

    } catch ContactsError.batchSaveFailed(let errors) {
        print("Batch save completed with \(errors.count) errors:")
        for error in errors {
            print("  - \(error.localizedDescription)")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Example 5: Custom Formatting

func example5_customFormatting() {
    print("=== Custom Formatting ===")

    // Phone formatting
    let rawPhone = "5551234567"
    let formatted = PhoneNumberFormatter.format(rawPhone)
    print("Phone: \(rawPhone) -> \(formatted ?? "N/A")")

    // Name formatting
    let rawName = "JOHN SMITH JR"
    let properName = NameFormatter.formatName(rawName)
    print("Name: \(rawName) -> \(properName)")

    // Name component parsing
    let fullName = "Dr. John Michael Smith Jr."
    let components = NameFormatter.parseComponents(from: fullName)
    print("Name components:")
    print("  Prefix: \(components.prefix ?? "N/A")")
    print("  Given: \(components.given ?? "N/A")")
    print("  Middle: \(components.middle ?? "N/A")")
    print("  Family: \(components.family ?? "N/A")")
    print("  Suffix: \(components.suffix ?? "N/A")")

    // Address formatting
    let rawStreet = "123 main st apt 5"
    let formattedStreet = AddressFormatter.formatStreet(rawStreet)
    print("Address: \(rawStreet) -> \(formattedStreet)")

    let rawState = "california"
    let stateCode = AddressFormatter.formatState(rawState)
    print("State: \(rawState) -> \(stateCode)")

    // Email normalization
    let rawEmail = "John.Smith@EXAMPLE.COM"
    let normalized = EmailFormatter.normalize(rawEmail)
    print("Email: \(rawEmail) -> \(normalized)")

    // URL normalization
    let rawURL = "www.example.com"
    let normalizedURL = URLFormatter.normalize(rawURL)
    print("URL: \(rawURL) -> \(normalizedURL)")
}

// MARK: - Example 6: Confidence Scoring

func example6_confidenceScoring() {
    let highConfidenceText = """
    John Smith
    Senior Software Engineer
    Tech Company Inc.

    Mobile: (555) 123-4567
    Office: (555) 987-6543
    Email: john.smith@techcompany.com
    LinkedIn: linkedin.com/in/johnsmith
    Website: www.johnsmith.dev

    123 Main Street, Suite 456
    San Francisco, CA 94102
    """

    let lowConfidenceText = """
    Some Name Maybe
    random text
    something 123
    """

    print("=== Confidence Scoring ===")

    print("\nHigh confidence example:")
    let highParsed = ContactParser.parse(highConfidenceText)
    printConfidenceScores(highParsed)

    print("\nLow confidence example:")
    let lowParsed = ContactParser.parse(lowConfidenceText)
    printConfidenceScores(lowParsed)
}

private func printConfidenceScores(_ contact: ParsedContact) {
    print("Name: \(String(format: "%.0f%%", contact.confidenceScores.name * 100))")
    print("Phone: \(String(format: "%.0f%%", contact.confidenceScores.phone * 100))")
    print("Email: \(String(format: "%.0f%%", contact.confidenceScores.email * 100))")
    print("Address: \(String(format: "%.0f%%", contact.confidenceScores.address * 100))")
    print("Organization: \(String(format: "%.0f%%", contact.confidenceScores.organization * 100))")
    print("Overall: \(String(format: "%.0f%%", contact.confidenceScores.overall * 100))")
    print("Valid for saving: \(contact.isValidForSaving)")
}

// MARK: - Example 7: Error Handling

@MainActor
func example7_errorHandling() async {
    let contactsService = ContactsService()

    let ocrText = """
    John Smith
    john@example.com
    (555) 123-4567
    """

    let parsed = ContactParser.parse(ocrText)

    print("=== Error Handling ===")

    do {
        let identifier = try await contactsService.saveContact(parsed)
        print("Success! Contact ID: \(identifier)")

    } catch ContactsError.accessDenied {
        print("Error: Permission denied")
        print("Recovery: Go to Settings > Privacy > Contacts")

    } catch ContactsError.insufficientData {
        print("Error: Not enough data to create contact")
        print("Recovery: Ensure name + (phone OR email) present")

    } catch ContactsError.duplicateFound(let duplicates) {
        print("Error: Found \(duplicates.count) duplicate(s)")
        print("Recovery: Show duplicate resolution UI")

        // Option 1: Update existing
        if let first = duplicates.first {
            do {
                try await contactsService.updateContact(
                    identifier: first.identifier,
                    with: parsed
                )
                print("Updated existing contact")
            } catch {
                print("Update failed: \(error.localizedDescription)")
            }
        }

        // Option 2: Force save without duplicate check
        do {
            let id = try await contactsService.saveContact(
                parsed,
                checkDuplicates: false
            )
            print("Forced save: \(id)")
        } catch {
            print("Force save failed: \(error.localizedDescription)")
        }

    } catch ContactsError.saveFailed(let underlying) {
        print("Error: Save failed")
        print("Underlying: \(underlying.localizedDescription)")
        print("Recovery: Retry or report error")

    } catch {
        print("Unknown error: \(error.localizedDescription)")
    }
}

// MARK: - Example 8: SwiftUI Integration

struct ContactSaveView: View {
    @StateObject private var contactsService = ContactsService()
    @State private var ocrText: String = ""
    @State private var parsedContact: ParsedContact?
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("OCR Text") {
                    TextEditor(text: $ocrText)
                        .frame(height: 200)
                        .font(.system(.body, design: .monospaced))
                }

                Section("Parsed Data") {
                    if let contact = parsedContact {
                        LabeledContent("Name") {
                            Text("\(contact.givenName ?? "") \(contact.familyName ?? "")")
                        }

                        LabeledContent("Company") {
                            Text(contact.organizationName ?? "N/A")
                        }

                        LabeledContent("Phones") {
                            Text("\(contact.phoneNumbers.count)")
                        }

                        LabeledContent("Emails") {
                            Text("\(contact.emailAddresses.count)")
                        }

                        LabeledContent("Confidence") {
                            Text(String(format: "%.0f%%", contact.confidenceScores.overall * 100))
                        }
                    } else {
                        Text("No data parsed yet")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Parse") {
                        parsedContact = ContactParser.parse(ocrText)
                    }

                    Button("Save to Contacts") {
                        Task {
                            await saveContact()
                        }
                    }
                    .disabled(parsedContact == nil || !(parsedContact?.isValidForSaving ?? false))
                }
            }
            .navigationTitle("Contact Parser")
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveContact() async {
        guard let contact = parsedContact else { return }

        do {
            try await contactsService.requestAccess()
            let identifier = try await contactsService.saveContact(contact)
            errorMessage = "Contact saved! ID: \(identifier)"
            showingError = true
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - Example 9: Testing Utilities

#if DEBUG
func example9_testingUtilities() {
    print("=== Testing Utilities ===")

    // Test data generator
    let testBusinessCards = [
        // Minimal
        """
        John Doe
        john@example.com
        """,

        // Standard
        """
        Jane Smith
        Senior Engineer
        Tech Corp
        jane@techcorp.com
        (555) 123-4567
        """,

        // Complete
        """
        Robert Johnson Jr.
        Chief Executive Officer
        Mega Corporation International

        Mobile: (555) 111-2222
        Office: (555) 333-4444
        Fax: (555) 555-6666

        Email: robert.johnson@megacorp.com
        Personal: rob@gmail.com

        LinkedIn: linkedin.com/in/robertjohnson
        Twitter: twitter.com/robjohnson
        Website: www.megacorp.com

        1000 Corporate Drive, Suite 500
        New York, NY 10001
        """
    ]

    // Parse and validate all
    for (index, card) in testBusinessCards.enumerated() {
        print("\nTest card \(index + 1):")
        let parsed = ContactParser.parse(card)
        print("  Valid: \(parsed.isValidForSaving)")
        print("  Confidence: \(String(format: "%.0f%%", parsed.confidenceScores.overall * 100))")
        print("  Summary: \(parsed.summary)")
    }
}
#endif

// MARK: - Main Entry Point

@main
struct ExamplesRunner {
    static func main() async {
        print("Deets Contact Parsing Examples\n")

        // Run examples
        example1_basicParsing()
        print("\n---\n")

        await example2_savingContact()
        print("\n---\n")

        await example3_duplicateDetection()
        print("\n---\n")

        await example4_batchProcessing()
        print("\n---\n")

        example5_customFormatting()
        print("\n---\n")

        example6_confidenceScoring()
        print("\n---\n")

        await example7_errorHandling()
        print("\n---\n")

        #if DEBUG
        example9_testingUtilities()
        #endif
    }
}
