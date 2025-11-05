# Deets Testing Guide

> Comprehensive testing strategy for iOS business card scanner app

## Table of Contents

1. [Overview](#overview)
2. [Test Architecture](#test-architecture)
3. [Running Tests](#running-tests)
4. [Writing Tests](#writing-tests)
5. [Test Coverage](#test-coverage)
6. [CI/CD Integration](#cicd-integration)
7. [Troubleshooting](#troubleshooting)

---

## Overview

Deets uses a comprehensive testing strategy that includes:

- **Unit Tests**: Business logic, services, and ViewModels
- **Integration Tests**: SwiftData operations, export functionality
- **UI Tests**: Critical user flows and accessibility
- **Performance Tests**: OCR speed, database performance, UI responsiveness

### Test Philosophy

- **70%+ code coverage** goal for business logic
- **Test-first for critical paths** (scan → save flow)
- **Fast feedback** (most tests < 0.5s)
- **Isolated tests** (no shared state between tests)
- **Realistic test data** via MockDataGenerator

---

## Test Architecture

### Directory Structure

```
Deets/
├── DeetsTests/                 # Unit & Integration Tests
│   ├── OCRServiceTests.swift
│   ├── ContactsServiceTests.swift
│   ├── SwiftDataTests.swift
│   ├── ViewModelTests.swift
│   ├── ContactParserTests.swift
│   ├── ExportTests.swift
│   ├── PhotoEnrichmentTests.swift
│   ├── PerformanceTests.swift
│   └── TestHelpers/
│       ├── MockDataGenerator.swift
│       ├── TestUtilities.swift
│       └── XCTestCase+Extensions.swift
│
└── DeetsUITests/               # UI & Accessibility Tests
    ├── ScanToSaveFlowTests.swift
    ├── ExportFlowTests.swift
    └── AccessibilityTests.swift
```

### Test Categories

#### 1. OCRServiceTests.swift
Tests Vision framework integration, text recognition, and bounding boxes.

**Key Areas:**
- Device capability detection
- Camera authorization
- Scanner lifecycle (start/stop/pause)
- Static image processing
- Bounding box accuracy
- Error handling

**Example:**
```swift
func testProcessValidImage() async throws {
    let testImage = createTestBusinessCardImage()
    let result = try await ocrService.processImage(testImage)

    XCTAssertNotNil(result.items)
    for item in result.items {
        XCTAssertGreaterThanOrEqual(item.confidence, 0.0)
        XCTAssertLessThanOrEqual(item.confidence, 1.0)
    }
}
```

#### 2. ContactsServiceTests.swift
Tests Apple Contacts framework integration.

**Key Areas:**
- Permission handling (authorization flow)
- Contact saving (single & batch)
- Duplicate detection (name, phone, email)
- Contact updates and merges
- Contact deletion
- CNContact conversion

**Example:**
```swift
func testSaveContactWithMinimumData() async {
    guard contactsService.authorizationStatus == .authorized else {
        throw XCTSkip("Contacts access not authorized")
    }

    var parsedContact = ParsedContact(rawText: "John Doe\njohn@example.com")
    parsedContact.givenName = "John"
    parsedContact.familyName = "Doe"

    let identifier = try await contactsService.saveContact(parsedContact)
    XCTAssertFalse(identifier.isEmpty)

    // Cleanup
    try? await contactsService.deleteContact(identifier: identifier)
}
```

#### 3. SwiftDataTests.swift
Tests database CRUD operations, queries, and filtering.

**Key Areas:**
- Model creation and validation
- Insert/Update/Delete operations
- Fetch descriptors and predicates
- Sorting and filtering
- Complex queries
- Performance with large datasets

**Example:**
```swift
func testComplexQuery() throws {
    insertTestCards(count: 100)

    let predicate = #Predicate<BusinessCard> { card in
        card.isFavorite == true && (card.company ?? "").contains("Tech")
    }

    let descriptor = FetchDescriptor<BusinessCard>(predicate: predicate)
    let results = try modelContext.fetch(descriptor)

    XCTAssertGreaterThan(results.count, 0)
}
```

#### 4. ViewModelTests.swift
Tests state management and business logic in ViewModels.

**Covered ViewModels:**
- `ScanViewModel` - Scanning state transitions
- `ContactPreviewViewModel` - Form validation, save logic
- `CardListViewModel` - Search, sort, filter logic
- `ExportViewModel` - Export configuration

**Example:**
```swift
func testEmailValidation() {
    viewModel.email = "valid@example.com"
    viewModel.validateEmail()
    XCTAssertTrue(viewModel.isValidEmail)

    viewModel.email = "invalid-email"
    viewModel.validateEmail()
    XCTAssertFalse(viewModel.isValidEmail)
}
```

#### 5. UI Tests

**ScanToSaveFlowTests.swift** - Critical path testing:
- Complete scan → preview → save flow
- Form validation
- Error handling (camera permissions, device support)
- Cancel operations

**ExportFlowTests.swift** - Export functionality:
- Format selection (vCard/CSV)
- Field selection for CSV
- Multi-card export
- Share sheet interaction

**AccessibilityTests.swift** - WCAG compliance:
- VoiceOver navigation
- Accessibility labels
- Dynamic Type support
- Focus management
- Color contrast (visual verification)

---

## Running Tests

### Xcode

#### Run All Tests
```bash
# Command + U
# Or: Product → Test
```

#### Run Specific Test Suite
```bash
# Click test diamond in gutter
# Or: Right-click test class → "Run Tests"
```

#### Run Single Test
```bash
# Click test diamond next to test function
```

### Command Line

#### Run all tests
```bash
xcodebuild test \
  -scheme Deets \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0'
```

#### Run unit tests only
```bash
xcodebuild test \
  -scheme Deets \
  -testPlan Deets \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0'
```

#### Run UI tests only
```bash
xcodebuild test \
  -scheme Deets \
  -testPlan DeetsUITests \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0'
```

#### Generate code coverage report
```bash
xcodebuild test \
  -scheme Deets \
  -enableCodeCoverage YES \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0'

# View coverage with slather
slather coverage --scheme Deets --workspace Deets.xcworkspace
```

### GitHub Actions

Tests run automatically on:
- **Push to main/develop** - Full test suite
- **Pull requests** - Full test suite + coverage report
- **Nightly builds** - Performance tests included

---

## Writing Tests

### Test Structure

Follow the **Arrange-Act-Assert** pattern:

```swift
func testExampleFeature() async throws {
    // ARRANGE: Set up test data and conditions
    let card = MockDataGenerator.generateBusinessCard()
    modelContext.insert(card)
    try modelContext.save()

    // ACT: Perform the action being tested
    let descriptor = FetchDescriptor<BusinessCard>()
    let results = try modelContext.fetch(descriptor)

    // ASSERT: Verify expected outcomes
    XCTAssertEqual(results.count, 1)
    XCTAssertEqual(results.first?.fullName, card.fullName)
}
```

### Using Test Helpers

#### MockDataGenerator

```swift
// Generate single card
let card = MockDataGenerator.generateBusinessCard()

// Generate multiple cards
let cards = MockDataGenerator.generateBusinessCards(count: 100)

// Generate specific variations
let minimalCard = MockDataGenerator.generateMinimalCard()
let completeCard = MockDataGenerator.generateCompleteCard()

// Generate test image
let image = MockDataGenerator.generateTestBusinessCardImage()
```

#### TestUtilities

```swift
// Create test container
let container = try makeTestContainer()

// Assert dates are equal (with tolerance)
assertDatesEqual(card.dateScanned, Date(), tolerance: 2.0)

// Assert collection contains matching element
assertContains(cards) { $0.fullName == "John Doe" }

// Measure performance
assertFastOperation({
    _ = ContactParser.parse(largeText)
}, timeLimit: 0.5)
```

#### XCTestCase Extensions

```swift
// Assert async operation throws error
assertAsyncThrows {
    try await service.invalidOperation()
}

// Assert collection is not empty
assertNotEmpty(results)

// Assert string matches regex
assertMatches(email, pattern: #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#)
```

### Async Testing

```swift
func testAsyncOperation() async throws {
    let result = try await ocrService.processImage(testImage)
    XCTAssertNotNil(result)
}

// Or with expectations
func testAsyncWithExpectation() {
    let expectation = expectation(description: "Async op")

    Task {
        try await someAsyncOperation()
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
}
```

### MainActor Testing

```swift
@MainActor
final class MyViewModelTests: XCTestCase {
    var viewModel: MyViewModel!

    override func setUp() async throws {
        try await super.setUp()
        viewModel = MyViewModel()
    }

    func testViewModelState() {
        XCTAssertFalse(viewModel.isLoading)
    }
}
```

### Skipping Tests

```swift
func testRequiringCamera() throws {
    guard OCRService.isSupported else {
        throw XCTSkip("Camera not available on this device")
    }

    // Test logic...
}
```

### Performance Tests

```swift
func testDatabaseQueryPerformance() throws {
    insertTestCards(count: 1000)

    measure {
        let descriptor = FetchDescriptor<BusinessCard>()
        _ = try? modelContext.fetch(descriptor)
    }
}

// With metrics
func testMemoryUsage() {
    measure(metrics: [XCTMemoryMetric()]) {
        let cards = MockDataGenerator.generateBusinessCards(count: 10000)
        // ...
    }
}
```

---

## Test Coverage

### Coverage Goals

| Component | Target | Current |
|-----------|--------|---------|
| Services | 80% | TBD |
| ViewModels | 75% | TBD |
| Parsers | 90% | TBD |
| Models | 60% | TBD |
| UI (critical paths) | 70% | TBD |
| **Overall** | **70%** | **TBD** |

### Viewing Coverage

#### Xcode
1. Run tests with coverage enabled: **Product → Test** (⌘+U)
2. View coverage: **Report Navigator** (⌘+9) → Coverage tab
3. Click file to see line-by-line coverage

#### Slather (CLI)
```bash
# Generate HTML report
slather coverage \
  --html \
  --scheme Deets \
  --workspace Deets.xcworkspace \
  --output-directory coverage-report

# Open report
open coverage-report/index.html
```

#### CI/CD
Coverage reports are automatically generated and uploaded to:
- **Codecov** - Visual coverage tracking
- **GitHub Actions Artifacts** - Downloadable HTML reports

### Coverage Best Practices

1. **Focus on critical paths first**: Scan → Save flow is highest priority
2. **Test public APIs thoroughly**: Private implementation details can change
3. **Don't chase 100%**: Diminishing returns after 80-85%
4. **Test error paths**: Failure cases are important
5. **Ignore generated code**: SwiftData models, SwiftUI previews

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.2.app

      - name: Run tests
        run: |
          xcodebuild test \
            -scheme Deets \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
            -enableCodeCoverage YES \
            -resultBundlePath TestResults

      - name: Generate coverage report
        run: slather coverage --cobertura-xml --scheme Deets

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./cobertura.xml
```

### Test Parallelization

Tests run in parallel across:
- Multiple simulators
- Test classes
- Independent test methods

Estimated total runtime: **5-8 minutes**

---

## Troubleshooting

### Common Issues

#### 1. Tests Timing Out

**Symptom**: Tests hang or timeout after 60 seconds

**Solutions**:
- Increase timeout in test expectations
- Check for deadlocks in async code
- Verify mock services don't block indefinitely

```swift
// Increase timeout
wait(for: [expectation], timeout: 10.0) // Instead of 5.0
```

#### 2. SwiftData Persistence Issues

**Symptom**: Tests fail with "Context not available" or "Cannot save"

**Solutions**:
- Ensure tests use in-memory containers
- Verify context is on MainActor
- Check setUp/tearDown properly initialize/cleanup

```swift
override func setUp() async throws {
    try await super.setUp()
    let schema = Schema([BusinessCard.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    modelContainer = try ModelContainer(for: schema, configurations: [config])
    modelContext = modelContainer.mainContext
}
```

#### 3. Simulator State Pollution

**Symptom**: Tests pass individually but fail when run together

**Solutions**:
- Reset simulator between test runs
- Clean build folder (⌘+Shift+K)
- Ensure tearDown properly cleans up state

```bash
# Reset all simulators
xcrun simctl erase all
```

#### 4. UI Tests Flakiness

**Symptom**: UI tests pass sometimes, fail other times

**Solutions**:
- Increase wait timeouts for elements
- Use `.waitForExistence(timeout:)` consistently
- Avoid hardcoded delays (`sleep`)
- Check for animation/transition interference

```swift
// Good: Wait for element
XCTAssertTrue(button.waitForExistence(timeout: 5))
button.tap()

// Bad: Hardcoded delay
sleep(2)
button.tap()
```

#### 5. Performance Test Variability

**Symptom**: Performance tests fail intermittently

**Solutions**:
- Run on dedicated simulator
- Set baseline for performance tests
- Account for CI/CD environment differences
- Use relative metrics, not absolute thresholds

#### 6. Code Coverage Not Generating

**Symptom**: Coverage report shows 0% or is missing

**Solutions**:
```bash
# Enable coverage in scheme settings
# Or use command line flag
xcodebuild test -enableCodeCoverage YES ...

# Check slather configuration
cat .slather.yml
```

### Debug Test Failures

```swift
// Add breakpoints in tests
func testExample() {
    let result = someFunction()
    print("Debug: result = \(result)") // Add logging
    XCTAssertEqual(result, expectedValue)
}

// Use XCTContext for detailed failure messages
func testWithContext() {
    XCTContext.runActivity(named: "Testing card validation") { _ in
        XCTAssertTrue(card.isValid, "Card should be valid: \(card)")
    }
}
```

---

## Best Practices

### DO ✅

- **Test one thing per test** - Single responsibility
- **Use descriptive names** - `testSaveContactWithInvalidEmail()` not `testSave()`
- **Clean up after tests** - Delete test data in tearDown
- **Use test helpers** - MockDataGenerator, TestUtilities
- **Test edge cases** - Empty strings, nil values, boundary conditions
- **Test error paths** - What happens when things fail?
- **Mock external dependencies** - Don't hit real APIs or file system

### DON'T ❌

- **Don't share state between tests** - Each test should be independent
- **Don't test private implementation** - Test public APIs only
- **Don't hardcode delays** - Use expectations and waits
- **Don't skip flaky tests** - Fix them or remove them
- **Don't test SwiftUI rendering** - Use snapshot tests if needed
- **Don't commit failing tests** - Fix or skip with XCTSkip

---

## Resources

- [Apple Testing Documentation](https://developer.apple.com/documentation/xctest)
- [XCTest Framework Reference](https://developer.apple.com/documentation/xctest)
- [WWDC Testing Sessions](https://developer.apple.com/wwdc/)
- [Deets Architecture Docs](../Docs/architecture.md)
- [CI/CD Setup Guide](../CI_CD_SETUP_GUIDE.md)

---

**Last Updated**: November 2025
**Maintained By**: QA Team (KAI)
