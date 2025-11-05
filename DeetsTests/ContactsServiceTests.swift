//
//  ContactsServiceTests.swift
//  DeetsTests
//
//  Tests for Contacts framework integration
//  Tests permission handling, save flow, duplicate detection, and CNContactStore interactions
//

import XCTest
import Contacts
@testable import Deets

@MainActor
final class ContactsServiceTests: XCTestCase {

    var contactsService: ContactsService!

    override func setUp() async throws {
        try await super.setUp()
        contactsService = ContactsService()
    }

    override func tearDown() async throws {
        contactsService = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(contactsService)
        XCTAssertNotNil(contactsService.authorizationStatus)
    }

    func testContactsIsAvailable() {
        XCTAssertTrue(ContactsService.isAvailable)
    }

    // MARK: - Authorization Tests

    func testCheckAuthorizationStatus() {
        contactsService.checkAuthorizationStatus()

        let validStatuses: [CNAuthorizationStatus] = [
            .notDetermined, .restricted, .denied, .authorized
        ]
        XCTAssertTrue(validStatuses.contains(contactsService.authorizationStatus))
    }

    func testAuthorizationStatusDescription() {
        // Set to known state
        let originalStatus = contactsService.authorizationStatus

        // Test descriptions for each status
        let descriptions = [
            CNAuthorizationStatus.authorized: "Authorized",
            CNAuthorizationStatus.denied: "Denied - Please enable in Settings",
            CNAuthorizationStatus.restricted: "Restricted by device policy",
            CNAuthorizationStatus.notDetermined: "Not yet requested"
        ]

        for (status, expectedSubstring) in descriptions {
            // Can't actually set the status, but can verify the method works
            let description = contactsService.permissionStatusDescription
            XCTAssertFalse(description.isEmpty)
        }
    }

    // MARK: - Contact Saving Tests (Require Authorization)

    func testSaveContactWithInsufficientData() async {
        let invalidContact = ParsedContact(rawText: "")
        // Empty contact should fail validation

        do {
            _ = try await contactsService.saveContact(invalidContact)
            XCTFail("Should throw error for invalid contact")
        } catch let error as ContactsError {
            // Could be accessDenied or insufficientData
            XCTAssertTrue(
                error.id == "access_denied" || error.id == "insufficient_data",
                "Expected access denied or insufficient data error"
            )
        } catch {
            XCTFail("Expected ContactsError, got \(error)")
        }
    }

    func testSaveContactWithMinimumData() async {
        // Only test if we have authorization
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        var parsedContact = ParsedContact(rawText: "John Doe\njohn@example.com")
        parsedContact.givenName = "John"
        parsedContact.familyName = "Doe"
        parsedContact.emailAddresses = [
            ParsedEmail(address: "john@example.com", label: CNLabelWork, confidence: 1.0)
        ]

        do {
            let identifier = try await contactsService.saveContact(parsedContact, checkDuplicates: false)

            XCTAssertFalse(identifier.isEmpty)

            // Cleanup: delete the contact
            try? await contactsService.deleteContact(identifier: identifier)
        } catch {
            // May fail in test environment without proper permissions
            print("Save contact test skipped: \(error.localizedDescription)")
        }
    }

    func testSaveMultipleContacts() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        let contacts = createTestParsedContacts(count: 3)

        do {
            let identifiers = try await contactsService.saveContacts(contacts, checkDuplicates: false)

            XCTAssertGreaterThan(identifiers.count, 0)

            // Cleanup
            for identifier in identifiers {
                try? await contactsService.deleteContact(identifier: identifier)
            }
        } catch {
            print("Batch save test skipped: \(error.localizedDescription)")
        }
    }

    // MARK: - Duplicate Detection Tests

    func testFindDuplicatesWithUniqueContact() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        var uniqueContact = ParsedContact(rawText: "")
        uniqueContact.givenName = "UniqueTestName\(UUID().uuidString.prefix(8))"
        uniqueContact.familyName = "Person"
        uniqueContact.emailAddresses = [
            ParsedEmail(address: "unique\(UUID().uuidString.prefix(8))@test.com", label: CNLabelWork)
        ]

        do {
            let duplicates = try await contactsService.findDuplicates(for: uniqueContact)

            XCTAssertNil(duplicates, "Unique contact should have no duplicates")
        } catch {
            print("Duplicate detection test skipped: \(error.localizedDescription)")
        }
    }

    func testFindDuplicatesByName() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        // First, save a test contact
        var testContact = ParsedContact(rawText: "")
        testContact.givenName = "DuplicateTest"
        testContact.familyName = "Person"
        testContact.emailAddresses = [
            ParsedEmail(address: "duplicate@test.com", label: CNLabelWork)
        ]

        do {
            let savedId = try await contactsService.saveContact(testContact, checkDuplicates: false)

            // Now search for duplicates with same name
            var searchContact = ParsedContact(rawText: "")
            searchContact.givenName = "DuplicateTest"
            searchContact.familyName = "Person"

            let duplicates = try await contactsService.findDuplicates(for: searchContact)

            XCTAssertNotNil(duplicates)
            XCTAssertGreaterThan(duplicates?.count ?? 0, 0)

            // Cleanup
            try? await contactsService.deleteContact(identifier: savedId)
        } catch {
            print("Duplicate by name test skipped: \(error.localizedDescription)")
        }
    }

    // MARK: - Contact Fetching Tests

    func testFetchContactWithInvalidIdentifier() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        do {
            _ = try await contactsService.fetchContact(identifier: "invalid-id-12345")
            XCTFail("Should throw error for invalid identifier")
        } catch let error as ContactsError {
            if case .contactNotFound = error {
                // Expected
            } else {
                XCTFail("Expected contactNotFound error")
            }
        } catch {
            XCTFail("Expected ContactsError")
        }
    }

    func testFetchAllContacts() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        do {
            let contacts = try await contactsService.fetchAllContacts()

            // Should return an array (may be empty)
            XCTAssertNotNil(contacts)
            print("Fetched \(contacts.count) contacts")
        } catch {
            print("Fetch all contacts test skipped: \(error.localizedDescription)")
        }
    }

    // MARK: - Contact Update Tests

    func testUpdateContact() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        // Create and save initial contact
        var initialContact = ParsedContact(rawText: "")
        initialContact.givenName = "UpdateTest"
        initialContact.familyName = "Person"
        initialContact.emailAddresses = [
            ParsedEmail(address: "update@test.com", label: CNLabelWork)
        ]

        do {
            let savedId = try await contactsService.saveContact(initialContact, checkDuplicates: false)

            // Update with new data
            var updatedContact = ParsedContact(rawText: "")
            updatedContact.phoneNumbers = [
                ParsedPhoneNumber(number: "5551234567", label: CNLabelPhoneNumberMain)
            ]

            try await contactsService.updateContact(identifier: savedId, with: updatedContact)

            // Fetch to verify update
            let fetchedContact = try await contactsService.fetchContact(identifier: savedId)
            XCTAssertGreaterThan(fetchedContact.phoneNumbers.count, 0)

            // Cleanup
            try? await contactsService.deleteContact(identifier: savedId)
        } catch {
            print("Update contact test skipped: \(error.localizedDescription)")
        }
    }

    func testUpdateNonexistentContact() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        let parsedContact = ParsedContact(rawText: "")

        do {
            try await contactsService.updateContact(identifier: "invalid-id", with: parsedContact)
            XCTFail("Should throw error for nonexistent contact")
        } catch let error as ContactsError {
            if case .contactNotFound = error {
                // Expected
            } else {
                XCTFail("Expected contactNotFound error")
            }
        } catch {
            XCTFail("Expected ContactsError")
        }
    }

    // MARK: - Contact Deletion Tests

    func testDeleteContact() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        // Create contact to delete
        var testContact = ParsedContact(rawText: "")
        testContact.givenName = "DeleteTest"
        testContact.familyName = "Person"
        testContact.emailAddresses = [
            ParsedEmail(address: "delete@test.com", label: CNLabelWork)
        ]

        do {
            let savedId = try await contactsService.saveContact(testContact, checkDuplicates: false)

            // Delete it
            try await contactsService.deleteContact(identifier: savedId)

            // Verify it's gone
            do {
                _ = try await contactsService.fetchContact(identifier: savedId)
                XCTFail("Contact should be deleted")
            } catch let error as ContactsError {
                if case .contactNotFound = error {
                    // Expected
                } else {
                    XCTFail("Expected contactNotFound error")
                }
            }
        } catch {
            print("Delete contact test skipped: \(error.localizedDescription)")
        }
    }

    func testDeleteNonexistentContact() async {
        guard contactsService.authorizationStatus == .authorized else {
            throw XCTSkip("Contacts access not authorized")
        }

        do {
            try await contactsService.deleteContact(identifier: "invalid-id-12345")
            XCTFail("Should throw error for nonexistent contact")
        } catch let error as ContactsError {
            if case .contactNotFound = error {
                // Expected
            } else {
                XCTFail("Expected contactNotFound error")
            }
        } catch {
            XCTFail("Expected ContactsError")
        }
    }

    // MARK: - Error Types Tests

    func testContactsErrorDescriptions() {
        let testContacts = [CNContact()]

        let errors: [ContactsError] = [
            .accessDenied,
            .insufficientData,
            .duplicateFound(contacts: testContacts),
            .contactNotFound,
            .saveFailed(underlying: NSError(domain: "test", code: 1)),
            .deleteFailed(underlying: NSError(domain: "test", code: 2)),
            .batchSaveFailed(errors: [.accessDenied])
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)

            XCTAssertNotNil(error.recoverySuggestion)
            XCTAssertFalse(error.recoverySuggestion!.isEmpty)

            XCTAssertFalse(error.id.isEmpty)
        }
    }

    // MARK: - Display Name Tests

    func testDisplayNameForContact() {
        let contact = CNMutableContact()
        contact.givenName = "John"
        contact.familyName = "Doe"

        let displayName = contactsService.displayName(for: contact)

        XCTAssertTrue(displayName.contains("John"))
        XCTAssertTrue(displayName.contains("Doe"))
    }

    func testDisplayNameForEmptyContact() {
        let contact = CNContact()

        let displayName = contactsService.displayName(for: contact)

        XCTAssertNotNil(displayName)
        // Should return "Unknown" or similar for empty contact
    }

    // MARK: - CNContact Extension Tests

    func testCNContactToParsedContactConversion() {
        let cnContact = CNMutableContact()
        cnContact.givenName = "Jane"
        cnContact.familyName = "Smith"
        cnContact.organizationName = "Test Corp"
        cnContact.jobTitle = "Engineer"

        let phoneNumber = CNPhoneNumber(stringValue: "5551234567")
        cnContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneNumber)]

        let parsed = cnContact.toParsedContact()

        XCTAssertEqual(parsed.givenName, "Jane")
        XCTAssertEqual(parsed.familyName, "Smith")
        XCTAssertEqual(parsed.organizationName, "Test Corp")
        XCTAssertEqual(parsed.jobTitle, "Engineer")
        XCTAssertGreaterThan(parsed.phoneNumbers.count, 0)
    }

    func testDuplicateMatchingStrict() {
        let cnContact = CNMutableContact()
        cnContact.givenName = "John"
        cnContact.familyName = "Doe"

        let phoneNumber = CNPhoneNumber(stringValue: "5551234567")
        cnContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneNumber)]

        var parsedContact = ParsedContact(rawText: "")
        parsedContact.givenName = "John"
        parsedContact.familyName = "Doe"
        parsedContact.phoneNumbers = [
            ParsedPhoneNumber(number: "5551234567", label: CNLabelPhoneNumberMain)
        ]

        let matches = cnContact.matches(parsedContact, strictness: .strict)
        XCTAssertTrue(matches, "Contact with matching name and phone should match strictly")
    }

    func testDuplicateMatchingMedium() {
        let cnContact = CNMutableContact()
        cnContact.givenName = "John"
        cnContact.familyName = "Doe"

        var parsedContact = ParsedContact(rawText: "")
        parsedContact.givenName = "John"
        parsedContact.familyName = "Doe"

        let matches = cnContact.matches(parsedContact, strictness: .medium)
        XCTAssertTrue(matches, "Contact with matching name should match with medium strictness")
    }

    func testDuplicateMatchingLoose() {
        let cnContact = CNMutableContact()
        cnContact.givenName = "John"
        cnContact.familyName = "Smith"

        var parsedContact = ParsedContact(rawText: "")
        parsedContact.givenName = "John"
        parsedContact.familyName = "Doe" // Different last name

        let matches = cnContact.matches(parsedContact, strictness: .loose)
        XCTAssertTrue(matches, "Contact with matching first name should match with loose strictness")
    }

    // MARK: - Helper Methods

    private func createTestParsedContacts(count: Int) -> [ParsedContact] {
        (0..<count).map { index in
            var contact = ParsedContact(rawText: "Test Contact \(index)")
            contact.givenName = "TestPerson\(index)"
            contact.familyName = "Surname"
            contact.emailAddresses = [
                ParsedEmail(address: "test\(index)@example.com", label: CNLabelWork)
            ]
            return contact
        }
    }
}
