//
//  TestUtilities.swift
//  DeetsTests
//
//  Shared test utilities and helper functions
//

import XCTest
import SwiftData
@testable import Deets

enum TestUtilities {

    // MARK: - SwiftData Helpers

    /// Create an in-memory model container for testing
    @MainActor
    static func createTestModelContainer() throws -> ModelContainer {
        let schema = Schema([BusinessCard.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    /// Populate test container with sample data
    @MainActor
    static func populateContainer(_ container: ModelContainer, cardCount: Int = 10) throws {
        let context = container.mainContext
        let cards = MockDataGenerator.generateBusinessCards(count: cardCount)

        for card in cards {
            context.insert(card)
        }

        try context.save()
    }

    // MARK: - Async Testing Helpers

    /// Wait for async operation with timeout
    static func waitFor<T>(
        timeout: TimeInterval = 5.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withTimeout(timeout) {
            try await operation()
        }
    }

    /// Run async test with timeout
    static func withTimeout<T>(
        _ timeout: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw TestError.timeout
            }

            guard let result = try await group.next() else {
                throw TestError.noResult
            }

            group.cancelAll()
            return result
        }
    }

    // MARK: - Assertion Helpers

    /// Assert that two dates are approximately equal (within tolerance)
    static func assertDatesEqual(
        _ date1: Date,
        _ date2: Date,
        tolerance: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let difference = abs(date1.timeIntervalSince(date2))
        XCTAssertLessThanOrEqual(
            difference,
            tolerance,
            "Dates differ by \(difference) seconds (tolerance: \(tolerance))",
            file: file,
            line: line
        )
    }

    /// Assert that a string contains all specified substrings
    static func assertContainsAll(
        _ string: String,
        _ substrings: [String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        for substring in substrings {
            XCTAssertTrue(
                string.contains(substring),
                "String does not contain '\(substring)'",
                file: file,
                line: line
            )
        }
    }

    /// Assert that array contains element matching predicate
    static func assertContains<T>(
        _ array: [T],
        where predicate: (T) -> Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            array.contains(where: predicate),
            "Array does not contain matching element",
            file: file,
            line: line
        )
    }

    // MARK: - Performance Helpers

    /// Measure execution time of operation
    static func measureTime(_ operation: () throws -> Void) rethrows -> TimeInterval {
        let start = Date()
        try operation()
        return Date().timeIntervalSince(start)
    }

    /// Assert operation completes within time limit
    static func assertFast(
        _ operation: () throws -> Void,
        timeLimit: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) rethrows {
        let duration = try measureTime(operation)
        XCTAssertLessThanOrEqual(
            duration,
            timeLimit,
            "Operation took \(duration)s (limit: \(timeLimit)s)",
            file: file,
            line: line
        )
    }

    // MARK: - Data Validation Helpers

    /// Validate business card has minimum required data
    static func validateMinimumCardData(
        _ card: BusinessCard,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertFalse(card.fullName.isEmpty, "Full name is required", file: file, line: line)
        XCTAssertNotNil(card.id, "Card should have ID", file: file, line: line)
        XCTAssertNotNil(card.dateScanned, "Card should have scan date", file: file, line: line)
    }

    /// Validate parsed contact has valid email
    static func validateEmail(
        _ email: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let isValid = email.range(of: emailRegex, options: [.regularExpression, .caseInsensitive]) != nil

        XCTAssertTrue(isValid, "Invalid email format: \(email)", file: file, line: line)
    }

    /// Validate phone number format
    static func validatePhoneNumber(
        _ phone: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // Remove formatting characters
        let digits = phone.filter { $0.isNumber }

        XCTAssertGreaterThanOrEqual(
            digits.count,
            10,
            "Phone number should have at least 10 digits",
            file: file,
            line: line
        )
    }

    // MARK: - Test Data Cleanup

    /// Delete all cards from context
    @MainActor
    static func cleanupTestData(in context: ModelContext) throws {
        let descriptor = FetchDescriptor<BusinessCard>()
        let cards = try context.fetch(descriptor)

        for card in cards {
            context.delete(card)
        }

        try context.save()
    }

    // MARK: - File System Helpers

    /// Create temporary test directory
    static func createTempDirectory() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        return tempDir
    }

    /// Cleanup temporary directory
    static func removeTempDirectory(_ url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    /// Write test data to temporary file
    static func writeTestFile(_ content: String, extension: String = "txt") throws -> URL {
        let tempDir = try createTempDirectory()
        let fileURL = tempDir.appendingPathComponent("test.\(`extension`)")

        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        return fileURL
    }

    // MARK: - Mock Object Helpers

    /// Create mock CNContact
    static func createMockCNContact(
        firstName: String = "John",
        lastName: String = "Doe",
        email: String = "john.doe@example.com"
    ) -> CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = firstName
        contact.familyName = lastName

        let emailValue = CNLabeledValue(label: CNLabelWork, value: email as NSString)
        contact.emailAddresses = [emailValue]

        return contact
    }
}

// MARK: - Test Errors

enum TestError: Error {
    case timeout
    case noResult
    case invalidData
    case setupFailed
    case teardownFailed
}

// MARK: - XCTest Extensions

extension XCTestCase {

    /// Add teardown block to clean up resources
    func addAsyncTeardownBlock(_ block: @escaping () async throws -> Void) {
        addTeardownBlock {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                try? await block()
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    /// Skip test if condition is not met
    func skipUnless(_ condition: Bool, _ message: String) throws {
        if !condition {
            throw XCTSkip(message)
        }
    }

    /// Skip test on CI environment
    func skipOnCI() throws {
        if ProcessInfo.processInfo.environment["CI"] != nil {
            throw XCTSkip("Skipping on CI environment")
        }
    }
}

// MARK: - Performance Utilities

enum PerformanceUtilities {

    /// Log memory usage
    static func logMemoryUsage(_ label: String = "") {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            print("Memory usage\(label.isEmpty ? "" : " (\(label))"): \(String(format: "%.2f", usedMB)) MB")
        }
    }

    /// Measure peak memory during operation
    static func measurePeakMemory(_ operation: () throws -> Void) rethrows -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        try operation()

        withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        return info.resident_size
    }
}

// MARK: - Import Required Frameworks

import Contacts
import Darwin
