//
//  XCTestCase+Extensions.swift
//  DeetsTests
//
//  Convenience extensions for XCTestCase
//

import XCTest
import SwiftData
@testable import Deets

extension XCTestCase {

    // MARK: - SwiftData Helpers

    /// Create and configure test model container
    @MainActor
    func makeTestContainer() throws -> ModelContainer {
        try TestUtilities.createTestModelContainer()
    }

    /// Assert fetch returns expected count
    @MainActor
    func assertFetchCount<T: PersistentModel>(
        _ type: T.Type,
        equals expectedCount: Int,
        in context: ModelContext,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let descriptor = FetchDescriptor<T>()
        let results = try context.fetch(descriptor)

        XCTAssertEqual(
            results.count,
            expectedCount,
            "Expected \(expectedCount) items, found \(results.count)",
            file: file,
            line: line
        )
    }

    // MARK: - Async Testing

    /// Test async throwing operation
    func testAsync(
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line,
        _ operation: @escaping () async throws -> Void
    ) {
        let expectation = expectation(description: "Async operation")

        Task {
            do {
                try await operation()
                expectation.fulfill()
            } catch {
                XCTFail("Async operation failed: \(error)", file: file, line: line)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    /// Test async operation with result
    func testAsync<T>(
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line,
        _ operation: @escaping () async throws -> T,
        validation: @escaping (T) -> Void
    ) {
        let expectation = expectation(description: "Async operation with result")

        Task {
            do {
                let result = try await operation()
                validation(result)
                expectation.fulfill()
            } catch {
                XCTFail("Async operation failed: \(error)", file: file, line: line)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
    }

    // MARK: - Error Testing

    /// Assert error is thrown with specific type
    func assertThrowsError<T, E: Error>(
        _ expression: @autoclosure () throws -> T,
        errorType: E.Type,
        file: StaticString = #file,
        line: UInt = #line,
        _ errorHandler: ((E) -> Void)? = nil
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) { error in
            guard let specificError = error as? E else {
                XCTFail("Expected error of type \(E.self), got \(type(of: error))", file: file, line: line)
                return
            }

            errorHandler?(specificError)
        }
    }

    /// Assert async error is thrown
    func assertAsyncThrows<T>(
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line,
        _ operation: @escaping () async throws -> T
    ) {
        let expectation = expectation(description: "Async error")
        var didThrow = false

        Task {
            do {
                _ = try await operation()
            } catch {
                didThrow = true
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertTrue(didThrow, "Expected operation to throw error", file: file, line: line)
    }

    // MARK: - Collection Assertions

    /// Assert collection is not empty
    func assertNotEmpty<C: Collection>(
        _ collection: C,
        _ message: String = "Collection should not be empty",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertFalse(collection.isEmpty, message, file: file, line: line)
    }

    /// Assert collection contains element
    func assertContains<C: Collection, Element>(
        _ collection: C,
        _ element: Element,
        file: StaticString = #file,
        line: UInt = #line
    ) where C.Element == Element, Element: Equatable {
        XCTAssertTrue(
            collection.contains(element),
            "Collection does not contain \(element)",
            file: file,
            line: line
        )
    }

    /// Assert all elements match predicate
    func assertAllMatch<C: Collection>(
        _ collection: C,
        _ predicate: (C.Element) -> Bool,
        _ message: String = "Not all elements match predicate",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(collection.allSatisfy(predicate), message, file: file, line: line)
    }

    /// Assert any element matches predicate
    func assertAnyMatch<C: Collection>(
        _ collection: C,
        _ predicate: (C.Element) -> Bool,
        _ message: String = "No elements match predicate",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(collection.contains(where: predicate), message, file: file, line: line)
    }

    // MARK: - String Assertions

    /// Assert string matches regex pattern
    func assertMatches(
        _ string: String,
        pattern: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let range = string.range(of: pattern, options: .regularExpression)
        XCTAssertNotNil(range, "String '\(string)' does not match pattern '\(pattern)'", file: file, line: line)
    }

    /// Assert string does not match regex pattern
    func assertNotMatches(
        _ string: String,
        pattern: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let range = string.range(of: pattern, options: .regularExpression)
        XCTAssertNil(range, "String '\(string)' should not match pattern '\(pattern)'", file: file, line: line)
    }

    /// Assert string contains substring
    func assertContains(
        _ string: String,
        _ substring: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            string.contains(substring),
            "String '\(string)' does not contain '\(substring)'",
            file: file,
            line: line
        )
    }

    // MARK: - Business Logic Assertions

    /// Assert business card is valid for saving
    func assertValidCard(
        _ card: BusinessCard,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertFalse(card.fullName.isEmpty, "Full name is required", file: file, line: line)
        XCTAssertNotNil(card.id, "Card should have ID", file: file, line: line)
        XCTAssertNotNil(card.dateScanned, "Card should have scan date", file: file, line: line)
        XCTAssertTrue(card.hasContactInfo, "Card should have email or phone", file: file, line: line)
    }

    /// Assert parsed contact is valid
    func assertValidContact(
        _ contact: ParsedContact,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(contact.isValidForSaving, "Contact should be valid for saving", file: file, line: line)
        XCTAssertTrue(contact.validationFlags.hasMinimumData, "Contact should have minimum data", file: file, line: line)
    }

    // MARK: - Performance Helpers

    /// Measure and assert operation is fast
    func assertFastOperation(
        _ operation: () throws -> Void,
        timeLimit: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) rethrows {
        let duration = try TestUtilities.measureTime(operation)

        XCTAssertLessThanOrEqual(
            duration,
            timeLimit,
            "Operation took \(duration)s, expected < \(timeLimit)s",
            file: file,
            line: line
        )
    }

    // MARK: - Notification Testing

    /// Wait for notification to be posted
    func waitForNotification(
        _ name: Notification.Name,
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Notification {
        let expectation = XCTNSNotificationExpectation(name: name)

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)

        XCTAssertEqual(result, .completed, "Notification '\(name)' not received", file: file, line: line)

        return expectation.observation?.notification ?? Notification(name: name)
    }

    // MARK: - UI Testing Helpers

    /// Assert view model state changes
    func assertStateChange<T: AnyObject, V: Equatable>(
        on object: T,
        keyPath: KeyPath<T, V>,
        from initialValue: V,
        to expectedValue: V,
        after action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(object[keyPath: keyPath], initialValue, "Initial state mismatch", file: file, line: line)

        action()

        XCTAssertEqual(object[keyPath: keyPath], expectedValue, "Expected state change did not occur", file: file, line: line)
    }

    // MARK: - File System Testing

    /// Create temporary test file
    func createTempFile(content: String = "", extension: String = "txt") throws -> URL {
        try TestUtilities.writeTestFile(content, extension: `extension`)
    }

    /// Clean up temporary file
    func removeTempFile(_ url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Mock Data

    /// Generate test business cards
    func generateCards(count: Int = 10) -> [BusinessCard] {
        MockDataGenerator.generateBusinessCards(count: count)
    }

    /// Generate test parsed contact
    func generateParsedContact(withFullData: Bool = true) -> ParsedContact {
        MockDataGenerator.generateParsedContact(withFullData: withFullData)
    }
}

// MARK: - Date Testing Extensions

extension XCTestCase {

    /// Assert dates are approximately equal
    func assertDatesEqual(
        _ date1: Date,
        _ date2: Date,
        tolerance: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        TestUtilities.assertDatesEqual(date1, date2, tolerance: tolerance, file: file, line: line)
    }

    /// Assert date is recent (within last N seconds)
    func assertDateIsRecent(
        _ date: Date,
        within seconds: TimeInterval = 60.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let now = Date()
        let difference = abs(now.timeIntervalSince(date))

        XCTAssertLessThanOrEqual(
            difference,
            seconds,
            "Date \(date) is not within \(seconds) seconds of now",
            file: file,
            line: line
        )
    }
}

// MARK: - Debug Helpers

extension XCTestCase {

    /// Print formatted test info
    func logTestInfo(_ message: String) {
        print("\n\u{1F4DD} [TEST] \(message)")
    }

    /// Print formatted error
    func logTestError(_ message: String) {
        print("\n\u{274C} [ERROR] \(message)")
    }

    /// Print formatted success
    func logTestSuccess(_ message: String) {
        print("\n\u{2705} [SUCCESS] \(message)")
    }

    /// Print separator
    func logSeparator() {
        print("\n" + String(repeating: "=", count: 60))
    }
}
