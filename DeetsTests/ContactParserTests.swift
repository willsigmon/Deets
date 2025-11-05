//
//  ContactParserTests.swift
//  DeetsTests
//
//  Test suite for contact parsing functionality
//

import XCTest
@testable import Deets

final class ContactParserTests: XCTestCase {
    // MARK: - Name Parsing Tests

    func testParseSimpleName() {
        let text = """
        John Smith
        CEO
        Acme Corporation
        john@acme.com
        (555) 123-4567
        """

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.givenName, "John")
        XCTAssertEqual(parsed.familyName, "Smith")
        XCTAssertTrue(parsed.validationFlags.hasValidName)
    }

    func testParseNameWithMiddle() {
        let text = "John Michael Smith"

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.givenName, "John")
        XCTAssertEqual(parsed.middleName, "Michael")
        XCTAssertEqual(parsed.familyName, "Smith")
    }

    func testParseNameWithPrefixSuffix() {
        let text = "Dr. John Smith Jr."

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.namePrefix, "Dr")
        XCTAssertEqual(parsed.givenName, "John")
        XCTAssertEqual(parsed.familyName, "Smith")
        XCTAssertEqual(parsed.nameSuffix, "JR")
    }

    // MARK: - Phone Number Parsing Tests

    func testParseUSPhoneNumber() {
        let text = "(555) 123-4567"

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.phoneNumbers.count, 1)
        XCTAssertEqual(parsed.phoneNumbers.first?.number, "5551234567")
        XCTAssertTrue(parsed.phoneNumbers.first?.isValid ?? false)
    }

    func testParseMultiplePhoneNumbers() {
        let text = """
        Mobile: (555) 123-4567
        Office: 555-987-6543
        """

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.phoneNumbers.count, 2)
    }

    func testParseInternationalPhone() {
        let text = "+1 (555) 123-4567"

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.phoneNumbers.count, 1)
        XCTAssertTrue(parsed.phoneNumbers.first?.isValid ?? false)
    }

    // MARK: - Email Parsing Tests

    func testParseEmail() {
        let text = "john.smith@acme.com"

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.emailAddresses.count, 1)
        XCTAssertEqual(parsed.emailAddresses.first?.address, "john.smith@acme.com")
        XCTAssertTrue(parsed.emailAddresses.first?.isValid ?? false)
    }

    func testParseMultipleEmails() {
        let text = """
        Work: john@acme.com
        Personal: john.smith@gmail.com
        """

        let parsed = ContactParser.parse(text)

        XCTAssertGreaterThanOrEqual(parsed.emailAddresses.count, 2)
    }

    func testParseEmailCaseInsensitive() {
        let text = "JOHN.SMITH@ACME.COM"

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.emailAddresses.first?.address, "john.smith@acme.com")
    }

    // MARK: - URL Parsing Tests

    func testParseWebsite() {
        let text = "https://www.acme.com"

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.urls.count, 1)
        XCTAssertTrue(parsed.urls.first?.isValid ?? false)
    }

    func testParseWebsiteWithoutScheme() {
        let text = "www.acme.com"

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.urls.count, 1)
        XCTAssertEqual(parsed.urls.first?.url, "https://www.acme.com")
    }

    func testParseLinkedIn() {
        let text = "linkedin.com/in/johnsmith"

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.urls.count, 1)
        XCTAssertEqual(parsed.urls.first?.type, .linkedin)
    }

    // MARK: - Address Parsing Tests

    func testParseFullAddress() {
        let text = """
        123 Main Street
        San Francisco, CA 94102
        """

        let parsed = ContactParser.parse(text)

        XCTAssertGreaterThanOrEqual(parsed.postalAddresses.count, 1)

        if let address = parsed.postalAddresses.first {
            XCTAssertNotNil(address.street)
            XCTAssertEqual(address.city, "San Francisco")
            XCTAssertEqual(address.state, "CA")
            XCTAssertEqual(address.postalCode, "94102")
        }
    }

    func testParseCityStateZip() {
        let text = "San Francisco, CA 94102"

        let parsed = ContactParser.parse(text)

        XCTAssertGreaterThanOrEqual(parsed.postalAddresses.count, 1)

        if let address = parsed.postalAddresses.first {
            XCTAssertEqual(address.city, "San Francisco")
            XCTAssertEqual(address.state, "CA")
            XCTAssertEqual(address.postalCode, "94102")
        }
    }

    // MARK: - Organization Parsing Tests

    func testParseCompanyName() {
        let text = """
        John Smith
        Acme Corporation
        CEO
        """

        let parsed = ContactParser.parse(text)

        XCTAssertNotNil(parsed.organizationName)
        XCTAssertTrue(parsed.organizationName?.contains("Acme") ?? false)
    }

    func testParseJobTitle() {
        let text = """
        John Smith
        Chief Executive Officer
        Acme Corp
        """

        let parsed = ContactParser.parse(text)

        XCTAssertNotNil(parsed.jobTitle)
    }

    // MARK: - Integration Tests

    func testParseRealBusinessCard() {
        let text = """
        John Michael Smith
        Chief Technology Officer
        Acme Corporation

        Mobile: (555) 123-4567
        Office: (555) 987-6543
        Email: john.smith@acme.com
        Web: www.acme.com

        123 Main Street, Suite 100
        San Francisco, CA 94102
        """

        let parsed = ContactParser.parse(text)

        // Name
        XCTAssertEqual(parsed.givenName, "John")
        XCTAssertEqual(parsed.middleName, "Michael")
        XCTAssertEqual(parsed.familyName, "Smith")

        // Organization
        XCTAssertNotNil(parsed.organizationName)
        XCTAssertNotNil(parsed.jobTitle)

        // Contact methods
        XCTAssertGreaterThanOrEqual(parsed.phoneNumbers.count, 2)
        XCTAssertGreaterThanOrEqual(parsed.emailAddresses.count, 1)
        XCTAssertGreaterThanOrEqual(parsed.urls.count, 1)

        // Address
        XCTAssertGreaterThanOrEqual(parsed.postalAddresses.count, 1)

        // Validation
        XCTAssertTrue(parsed.isValidForSaving)
        XCTAssertTrue(parsed.validationFlags.hasValidName)
        XCTAssertTrue(parsed.validationFlags.hasValidPhone)
        XCTAssertTrue(parsed.validationFlags.hasValidEmail)

        // Confidence
        XCTAssertGreaterThan(parsed.confidenceScores.overall, 0.5)
    }

    func testParseMinimalBusinessCard() {
        let text = """
        Jane Doe
        jane@example.com
        """

        let parsed = ContactParser.parse(text)

        XCTAssertEqual(parsed.givenName, "Jane")
        XCTAssertEqual(parsed.familyName, "Doe")
        XCTAssertEqual(parsed.emailAddresses.count, 1)
        XCTAssertTrue(parsed.isValidForSaving)
    }

    // MARK: - Confidence Score Tests

    func testConfidenceScoreCalculation() {
        let text = """
        John Smith
        john@example.com
        (555) 123-4567
        """

        let parsed = ContactParser.parse(text)

        XCTAssertGreaterThan(parsed.confidenceScores.name, 0.0)
        XCTAssertGreaterThan(parsed.confidenceScores.email, 0.0)
        XCTAssertGreaterThan(parsed.confidenceScores.phone, 0.0)
        XCTAssertGreaterThan(parsed.confidenceScores.overall, 0.0)
    }

    // MARK: - Validation Tests

    func testInvalidContact() {
        let text = "Random text with no contact info"

        let parsed = ContactParser.parse(text)

        XCTAssertFalse(parsed.isValidForSaving)
    }

    func testMinimumDataValidation() {
        let text = """
        John Smith
        john@example.com
        """

        let parsed = ContactParser.parse(text)

        XCTAssertTrue(parsed.validationFlags.hasMinimumData)
    }

    // MARK: - Edge Cases

    func testEmptyInput() {
        let text = ""

        let parsed = ContactParser.parse(text)

        XCTAssertFalse(parsed.isValidForSaving)
    }

    func testSpecialCharactersInName() {
        let text = "Mary O'Brien"

        let parsed = ContactParser.parse(text)

        XCTAssertNotNil(parsed.familyName)
        XCTAssertTrue(parsed.familyName?.contains("O'Brien") ?? false)
    }

    func testHyphenatedName() {
        let text = "Anne-Marie Smith-Jones"

        let parsed = ContactParser.parse(text)

        XCTAssertNotNil(parsed.givenName)
        XCTAssertNotNil(parsed.familyName)
    }
}
