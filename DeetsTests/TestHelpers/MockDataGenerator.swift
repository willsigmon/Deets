//
//  MockDataGenerator.swift
//  DeetsTests
//
//  Generates realistic mock data for testing
//

import Foundation
@testable import Deets

enum MockDataGenerator {

    // MARK: - Business Cards

    static func generateBusinessCard(
        index: Int? = nil,
        isFavorite: Bool = false,
        savedToContacts: Bool = false
    ) -> BusinessCard {
        let i = index ?? Int.random(in: 0..<1000)

        let names = [
            "Alice Johnson", "Bob Smith", "Charlie Davis", "Diana Martinez",
            "Edward Chen", "Fiona O'Brien", "George Williams", "Hannah Lee",
            "Isaac Brown", "Julia Garcia", "Kevin Taylor", "Laura Anderson"
        ]

        let titles = [
            "Software Engineer", "Product Manager", "Designer", "CTO",
            "Marketing Director", "Sales Representative", "Data Scientist",
            "DevOps Engineer", "UX Researcher", "Business Analyst"
        ]

        let companies = [
            "Tech Corp", "Design Studio", "Innovation Labs", "Digital Solutions",
            "Cloud Systems", "AI Ventures", "Mobile Apps Inc", "Creative Agency",
            "Data Analytics Co", "Software House"
        ]

        let name = names[i % names.count]
        let title = titles[i % titles.count]
        let company = companies[i % companies.count]

        let emailDomain = company.lowercased().replacingOccurrences(of: " ", with: "")
        let email = "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@\(emailDomain).com"

        return BusinessCard(
            fullName: name,
            jobTitle: title,
            company: company,
            email: email,
            phoneNumber: generatePhoneNumber(),
            website: "https://\(emailDomain).com",
            address: generateAddress(),
            notes: i % 3 == 0 ? "Met at conference" : nil,
            rawText: "\(name)\n\(title)\n\(company)",
            tags: generateTags(),
            isFavorite: isFavorite,
            savedToContacts: savedToContacts
        )
    }

    static func generateBusinessCards(count: Int) -> [BusinessCard] {
        (0..<count).map { generateBusinessCard(index: $0) }
    }

    // MARK: - Parsed Contacts

    static func generateParsedContact(withFullData: Bool = true) -> ParsedContact {
        var contact = ParsedContact(rawText: "John Smith\nCEO\nAcme Corp")

        contact.givenName = "John"
        contact.familyName = "Smith"

        if withFullData {
            contact.jobTitle = "CEO"
            contact.organizationName = "Acme Corp"

            contact.emailAddresses = [
                ParsedEmail(address: "john.smith@acme.com", label: CNLabelWork, confidence: 0.95)
            ]

            contact.phoneNumbers = [
                ParsedPhoneNumber(number: "5551234567", label: CNLabelPhoneNumberMain, confidence: 0.92)
            ]

            contact.urls = [
                ParsedURL(url: "https://acme.com", label: CNLabelWork, confidence: 0.88)
            ]

            contact.postalAddresses = [
                ParsedAddress(
                    street: "123 Main St",
                    city: "San Francisco",
                    state: "CA",
                    postalCode: "94102",
                    country: "USA",
                    label: CNLabelWork,
                    confidence: 0.85
                )
            ]
        }

        return contact
    }

    // MARK: - Scanned Text

    static func generateScannedText(count: Int = 10) -> [ScannedText] {
        let texts = [
            "John Smith",
            "john.smith@example.com",
            "(555) 123-4567",
            "CEO",
            "Acme Corporation",
            "https://acme.com",
            "123 Main Street",
            "San Francisco, CA 94102"
        ]

        return (0..<min(count, texts.count)).map { i in
            ScannedText(
                text: texts[i],
                confidence: Float.random(in: 0.7...0.99),
                boundingBox: BoundingBox(
                    x: CGFloat.random(in: 0.1...0.8),
                    y: CGFloat(i) * 0.1 + 0.1,
                    width: CGFloat.random(in: 0.3...0.5),
                    height: 0.08
                ),
                category: categorizeText(texts[i])
            )
        }
    }

    static func generateScanResult() -> ScanResult {
        ScanResult(
            items: generateScannedText(),
            captureDate: Date(),
            imageData: nil
        )
    }

    // MARK: - Business Card Variations

    static func generateMinimalCard() -> BusinessCard {
        BusinessCard(
            fullName: "Jane Doe",
            email: "jane@example.com",
            rawText: "Jane Doe\njane@example.com"
        )
    }

    static func generateCompleteCard() -> BusinessCard {
        BusinessCard(
            fullName: "Robert Johnson",
            jobTitle: "Senior Software Engineer",
            company: "Tech Innovations Inc",
            email: "robert.johnson@techinnovations.com",
            phoneNumber: "+1 (555) 987-6543",
            website: "https://techinnovations.com",
            address: "456 Technology Drive, Suite 200, San Jose, CA 95110",
            notes: "Expert in iOS development. Met at WWDC 2024. Interested in AI/ML collaboration.",
            rawText: "Robert Johnson\nSenior Software Engineer\nTech Innovations Inc",
            tags: ["Tech", "iOS", "AI/ML", "Conference"],
            isFavorite: true,
            savedToContacts: true
        )
    }

    static func generateCardsWithTags(tagCombinations: [[String]]) -> [BusinessCard] {
        tagCombinations.enumerated().map { index, tags in
            var card = generateBusinessCard(index: index)
            card.tags = tags
            return card
        }
    }

    // MARK: - Helper Functions

    private static func generatePhoneNumber() -> String {
        let formats = [
            "(555) 123-4567",
            "+1 (555) 987-6543",
            "555-246-8135",
            "+1 555 369 2580"
        ]
        return formats.randomElement()!
    }

    private static func generateAddress() -> String {
        let streets = ["123 Main St", "456 Oak Ave", "789 Pine Rd", "321 Elm Blvd"]
        let cities = ["San Francisco, CA 94102", "New York, NY 10001", "Austin, TX 78701", "Seattle, WA 98101"]

        return "\(streets.randomElement()!), \(cities.randomElement()!)"
    }

    private static func generateTags() -> [String] {
        let allTags = ["Client", "Partner", "Tech", "Design", "Marketing", "Sales", "Conference", "Networking"]
        let count = Int.random(in: 0...3)

        return Array(allTags.shuffled().prefix(count))
    }

    private static func categorizeText(_ text: String) -> TextCategory {
        if text.contains("@") {
            return .email
        } else if text.contains("http") || text.contains("www") {
            return .website
        } else if text.range(of: #"[\d\-\(\)\+]"#, options: .regularExpression) != nil {
            return .phone
        } else if text.contains(",") || text.range(of: #"\d{5}"#, options: .regularExpression) != nil {
            return .address
        } else {
            return .name
        }
    }

    // MARK: - Export Test Data

    static func generateExportableCards(count: Int = 5) -> [BusinessCard] {
        (0..<count).map { i in
            BusinessCard(
                fullName: "Export Test \(i)",
                jobTitle: "Position \(i)",
                company: "Company \(i)",
                email: "export\(i)@test.com",
                phoneNumber: "555-000\(i)",
                rawText: "Export Test \(i)"
            )
        }
    }

    // MARK: - Test Images

    static func generateTestBusinessCardImage(size: CGSize = CGSize(width: 640, height: 400)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Business card content
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]

            let text = """
            John Smith
            Senior Engineer
            Tech Corp

            john.smith@techcorp.com
            (555) 123-4567
            https://techcorp.com
            """

            let attributedText = NSAttributedString(string: text, attributes: attributes)
            attributedText.draw(at: CGPoint(x: 40, y: 40))
        }
    }

    static func generateBlankImage(size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.lightGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - CNContact Label Constants

import Contacts

extension MockDataGenerator {
    static let CNLabelWork = "Work"
    static let CNLabelPhoneNumberMain = "Main"
}
