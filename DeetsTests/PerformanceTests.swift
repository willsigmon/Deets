//
//  PerformanceTests.swift
//  DeetsTests
//
//  Performance benchmarks for critical operations
//  Tests OCR speed, database performance, and UI responsiveness
//

import XCTest
import SwiftData
@testable import Deets

@MainActor
final class PerformanceTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()

        let schema = Schema([BusinessCard.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
        try await super.tearDown()
    }

    // MARK: - OCR Performance Tests

    func testOCRProcessingSpeed() async {
        let ocrService = OCRService()
        let testImage = createTestImage(size: CGSize(width: 640, height: 400))

        measure {
            let expectation = self.expectation(description: "OCR processing")

            Task {
                do {
                    _ = try await ocrService.processImage(testImage)
                } catch {
                    // Handle expected errors in test environment
                }
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    func testOCRImagePreprocessing() {
        let ocrService = OCRService()
        let testImage = createTestImage(size: CGSize(width: 1920, height: 1080))

        measure {
            _ = ocrService.preprocessImage(testImage)
        }
    }

    func testOCRBoundingBoxCalculation() {
        let items = (0..<100).map { i in
            ScannedText(
                text: "Text \(i)",
                confidence: Float.random(in: 0.5...1.0),
                boundingBox: BoundingBox(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                    width: CGFloat.random(in: 0.1...0.3),
                    height: CGFloat.random(in: 0.05...0.1)
                )
            )
        }

        let imageSize = CGSize(width: 1000, height: 800)

        measure {
            for item in items {
                _ = item.boundingBox.toCGRect(in: imageSize)
            }
        }
    }

    // MARK: - Database Performance Tests

    func testBulkInsertPerformance() throws {
        measure {
            let cards = (0..<100).map { i in
                BusinessCard(
                    fullName: "Person \(i)",
                    email: "person\(i)@example.com",
                    rawText: "Person \(i)"
                )
            }

            for card in cards {
                self.modelContext.insert(card)
            }

            do {
                try self.modelContext.save()
            } catch {
                XCTFail("Save failed: \(error)")
            }

            // Cleanup
            let descriptor = FetchDescriptor<BusinessCard>()
            if let allCards = try? self.modelContext.fetch(descriptor) {
                for card in allCards {
                    self.modelContext.delete(card)
                }
            }
        }
    }

    func testQueryPerformance() throws {
        // Insert test data
        insertTestCards(count: 500)

        measure {
            let descriptor = FetchDescriptor<BusinessCard>(
                sortBy: [SortDescriptor(\BusinessCard.fullName)]
            )

            do {
                _ = try self.modelContext.fetch(descriptor)
            } catch {
                XCTFail("Fetch failed: \(error)")
            }
        }
    }

    func testComplexQueryPerformance() throws {
        insertTestCards(count: 500)

        measure {
            let predicate = #Predicate<BusinessCard> { card in
                card.isFavorite == true && (card.company ?? "").contains("Corp")
            }

            let descriptor = FetchDescriptor<BusinessCard>(
                predicate: predicate,
                sortBy: [SortDescriptor(\BusinessCard.dateScanned, order: .reverse)]
            )

            do {
                _ = try self.modelContext.fetch(descriptor)
            } catch {
                XCTFail("Fetch failed: \(error)")
            }
        }
    }

    func testSearchQueryPerformance() throws {
        insertTestCards(count: 500)

        let searchQueries = ["Person", "example.com", "Corp", "Engineer", "123"]

        measure {
            for query in searchQueries {
                let predicate = #Predicate<BusinessCard> { card in
                    card.fullName.contains(query) || (card.email ?? "").contains(query)
                }

                let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)

                do {
                    _ = try self.modelContext.fetch(descriptor)
                } catch {
                    XCTFail("Search failed: \(error)")
                }
            }
        }
    }

    func testUpdatePerformance() throws {
        insertTestCards(count: 100)

        let descriptor = FetchDescriptor<BusinessCard>()
        let cards = try modelContext.fetch(descriptor)

        measure {
            for card in cards {
                card.dateModified = Date()
                card.isFavorite = !card.isFavorite
            }

            do {
                try self.modelContext.save()
            } catch {
                XCTFail("Update failed: \(error)")
            }
        }
    }

    func testDeletePerformance() throws {
        measure {
            // Insert cards
            self.insertTestCards(count: 100)

            // Delete them
            let descriptor = FetchDescriptor<BusinessCard>()
            if let cards = try? self.modelContext.fetch(descriptor) {
                for card in cards {
                    self.modelContext.delete(card)
                }

                do {
                    try self.modelContext.save()
                } catch {
                    XCTFail("Delete failed: \(error)")
                }
            }
        }
    }

    // MARK: - Parser Performance Tests

    func testContactParserPerformance() {
        let testText = """
        John Michael Smith Jr.
        Chief Technology Officer
        Acme Corporation

        Mobile: +1 (555) 123-4567
        Office: (555) 987-6543
        Email: john.smith@acme.com
        Web: https://www.acme.com
        LinkedIn: linkedin.com/in/johnsmith

        123 Main Street, Suite 100
        San Francisco, CA 94102
        United States
        """

        measure {
            _ = ContactParser.parse(testText)
        }
    }

    func testContactParserWithLargeText() {
        var largeText = ""
        for _ in 0..<100 {
            largeText += "Random line of text\n"
        }
        largeText += "John Doe\njohn@example.com\n555-1234"

        measure {
            _ = ContactParser.parse(largeText)
        }
    }

    func testEmailValidationPerformance() {
        let emails = (0..<1000).map { "user\($0)@example.com" }

        measure {
            for email in emails {
                var parsed = ParsedContact(rawText: "")
                parsed.emailAddresses = [ParsedEmail(address: email, label: "Work")]
                _ = parsed.isValidForSaving
            }
        }
    }

    // MARK: - Export Performance Tests

    func testVCardExportPerformance() {
        let card = BusinessCard(
            fullName: "John Doe",
            jobTitle: "Engineer",
            company: "Tech Corp",
            email: "john@tech.com",
            phoneNumber: "555-1234",
            website: "https://tech.com",
            address: "123 Main St",
            notes: "Test contact",
            rawText: "John Doe"
        )

        measure {
            _ = VCardExporter.exportCard(card)
        }
    }

    func testVCardBulkExportPerformance() {
        let cards = (0..<100).map { i in
            BusinessCard(
                fullName: "Person \(i)",
                email: "person\(i)@example.com",
                phoneNumber: "555-\(String(format: "%04d", i))",
                rawText: "Person \(i)"
            )
        }

        measure {
            _ = VCardExporter.exportMultipleCards(cards)
        }
    }

    func testCSVExportPerformance() {
        let cards = (0..<100).map { i in
            BusinessCard(
                fullName: "Person \(i)",
                email: "person\(i)@example.com",
                rawText: "Person \(i)"
            )
        }

        measure {
            _ = CSVExporter.exportCards(cards)
        }
    }

    // MARK: - ViewModel Performance Tests

    func testCardListViewModelFilteringPerformance() throws {
        insertTestCards(count: 500)

        let viewModel = CardListViewModel()

        measure {
            // Simulate user typing search query
            viewModel.updateSearchQuery("Person 123")

            // Predicate generation
            _ = viewModel.filterPredicate

            // Sort descriptors
            _ = viewModel.sortDescriptors
        }
    }

    func testContactPreviewViewModelValidationPerformance() {
        let viewModel = ContactPreviewViewModel(scannedText: "Test")

        measure {
            viewModel.fullName = "John Doe"
            viewModel.email = "john.doe@example.com"
            viewModel.phoneNumber = "+1 (555) 123-4567"
            viewModel.website = "https://example.com"

            viewModel.validateAllFields()

            _ = viewModel.canSave
            _ = viewModel.hasChanges
        }
    }

    // MARK: - Memory Performance Tests

    func testMemoryUsageWithLargeDataset() {
        measure(metrics: [XCTMemoryMetric()]) {
            insertTestCards(count: 1000)

            let descriptor = FetchDescriptor<BusinessCard>()
            _ = try? modelContext.fetch(descriptor)

            // Cleanup
            if let cards = try? modelContext.fetch(descriptor) {
                for card in cards {
                    modelContext.delete(card)
                }
            }
        }
    }

    func testMemoryUsageWithImageProcessing() {
        let ocrService = OCRService()

        measure(metrics: [XCTMemoryMetric()]) {
            let images = (0..<10).map { _ in
                createTestImage(size: CGSize(width: 1920, height: 1080))
            }

            for image in images {
                _ = ocrService.preprocessImage(image)
            }
        }
    }

    // MARK: - CPU Performance Tests

    func testCPUUsageWithComplexQueries() {
        insertTestCards(count: 1000)

        measure(metrics: [XCTCPUMetric()]) {
            let predicates = [
                #Predicate<BusinessCard> { $0.isFavorite == true },
                #Predicate<BusinessCard> { $0.savedToContacts == true },
                #Predicate<BusinessCard> { $0.fullName.contains("Person") }
            ]

            for predicate in predicates {
                let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
                _ = try? modelContext.fetch(descriptor)
            }
        }
    }

    // MARK: - Helper Methods

    private func insertTestCards(count: Int) {
        for i in 0..<count {
            let card = BusinessCard(
                fullName: "Person \(i)",
                jobTitle: i % 3 == 0 ? "Engineer" : "Manager",
                company: i % 2 == 0 ? "Tech Corp" : "Design Inc",
                email: "person\(i)@example.com",
                phoneNumber: "555-\(String(format: "%04d", i))",
                rawText: "Person \(i)",
                isFavorite: i % 5 == 0,
                savedToContacts: i % 7 == 0
            )
            modelContext.insert(card)
        }

        do {
            try modelContext.save()
        } catch {
            XCTFail("Failed to insert test cards: \(error)")
        }
    }

    private func createTestImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let text = "Test Business Card\nJohn Doe\njohn@example.com"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]

            text.draw(at: CGPoint(x: 20, y: 20), withAttributes: attributes)
        }
    }
}
