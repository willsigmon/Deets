# Test Coverage Report

> **Generated**: [Date TBD - Run tests to generate]
> **Baseline Target**: 70% overall coverage

---

## Summary

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| **Overall Coverage** | TBD | 70% | 🔄 Pending |
| **Lines Covered** | TBD | - | 🔄 Pending |
| **Lines Total** | TBD | - | 🔄 Pending |

---

## Coverage by Component

### Services Layer

| Service | Coverage | Lines | Target | Status |
|---------|----------|-------|--------|--------|
| OCRService | TBD | TBD | 80% | 🔄 Pending |
| ContactsService | TBD | TBD | 80% | 🔄 Pending |
| ContactParser | TBD | TBD | 90% | 🔄 Pending |
| ExportService | TBD | TBD | 75% | 🔄 Pending |
| VCardExporter | TBD | TBD | 85% | 🔄 Pending |
| CSVExporter | TBD | TBD | 85% | 🔄 Pending |
| SyncService | TBD | TBD | 70% | 🔄 Pending |
| PhotoDiscoveryService | TBD | TBD | 75% | 🔄 Pending |

### ViewModels

| ViewModel | Coverage | Lines | Target | Status |
|-----------|----------|-------|--------|--------|
| ScanViewModel | TBD | TBD | 75% | 🔄 Pending |
| ContactPreviewViewModel | TBD | TBD | 75% | 🔄 Pending |
| CardListViewModel | TBD | TBD | 75% | 🔄 Pending |
| ExportViewModel | TBD | TBD | 75% | 🔄 Pending |
| SyncViewModel | TBD | TBD | 70% | 🔄 Pending |

### Models

| Model | Coverage | Lines | Target | Status |
|-------|----------|-------|--------|--------|
| BusinessCard | TBD | TBD | 60% | 🔄 Pending |
| ParsedContact | TBD | TBD | 80% | 🔄 Pending |
| ScannedText | TBD | TBD | 70% | 🔄 Pending |

### Utilities & Extensions

| Component | Coverage | Lines | Target | Status |
|-----------|----------|-------|--------|--------|
| TextValidator | TBD | TBD | 85% | 🔄 Pending |
| Formatters | TBD | TBD | 80% | 🔄 Pending |
| HapticManager | TBD | TBD | 50% | 🔄 Pending |

---

## Test Suite Breakdown

### Unit Tests

```
DeetsTests/
├── OCRServiceTests.swift          [TBD tests, TBD passing]
├── ContactsServiceTests.swift     [TBD tests, TBD passing]
├── SwiftDataTests.swift           [TBD tests, TBD passing]
├── ViewModelTests.swift           [TBD tests, TBD passing]
├── ContactParserTests.swift       [329 lines, established]
├── ExportTests.swift              [316 lines, established]
├── PhotoEnrichmentTests.swift     [established]
└── PerformanceTests.swift         [TBD tests, TBD passing]

Total Unit Tests: TBD
Pass Rate: TBD%
Average Duration: TBD ms/test
```

### UI Tests

```
DeetsUITests/
├── ScanToSaveFlowTests.swift      [TBD tests, TBD passing]
├── ExportFlowTests.swift          [TBD tests, TBD passing]
└── AccessibilityTests.swift       [TBD tests, TBD passing]

Total UI Tests: TBD
Pass Rate: TBD%
Average Duration: TBD ms/test
```

---

## Coverage Gaps

### Critical Gaps (High Priority)

| Component | Current | Target | Gap | Reason |
|-----------|---------|--------|-----|--------|
| TBD | TBD | TBD | TBD | [Analysis needed after first run] |

### Acceptable Gaps (Low Priority)

| Component | Current | Target | Gap | Reason |
|-----------|---------|--------|-----|--------|
| SwiftUI Views | ~0% | N/A | N/A | UI testing via UI tests, not unit tests |
| Generated Code | ~0% | N/A | N/A | SwiftData @Model macro expansions |
| App Entry Point | ~0% | N/A | N/A | DeetsApp.swift - minimal logic |

---

## Uncovered Lines by Category

### Error Handling Paths

| Component | Uncovered Scenario | Priority |
|-----------|-------------------|----------|
| TBD | TBD | [Analysis needed] |

### Edge Cases

| Component | Uncovered Scenario | Priority |
|-----------|-------------------|----------|
| TBD | TBD | [Analysis needed] |

### Async Operations

| Component | Uncovered Scenario | Priority |
|-----------|-------------------|----------|
| TBD | TBD | [Analysis needed] |

---

## Performance Metrics

### Test Execution Times

| Test Suite | Duration | Tests | Avg/Test | Threshold |
|------------|----------|-------|----------|-----------|
| Unit Tests (Fast) | TBD | TBD | TBD ms | < 100ms |
| Unit Tests (Slow) | TBD | TBD | TBD ms | < 1000ms |
| UI Tests | TBD | TBD | TBD ms | < 5000ms |
| Performance Tests | TBD | TBD | TBD ms | Variable |
| **Total** | **TBD** | **TBD** | **TBD ms** | **< 10min** |

### Slowest Tests

1. TBD (TBD ms)
2. TBD (TBD ms)
3. TBD (TBD ms)
4. TBD (TBD ms)
5. TBD (TBD ms)

---

## Trends

### Coverage Over Time

```
[Chart TBD - Track coverage % over commits/releases]

Target: 70% overall
Current: TBD%

Week 1: TBD%
Week 2: TBD%
Week 3: TBD%
Week 4: TBD%
```

### Test Count Growth

```
[Chart TBD - Track test count over time]

Current: TBD tests
Previous: TBD tests
Change: TBD (+/- %)
```

---

## Recommendations

### Immediate Actions

1. **Run initial coverage report** to establish baseline
2. **Prioritize critical path coverage** (Scan → Save flow)
3. **Add tests for identified gaps** starting with high-priority items
4. **Set up automated coverage tracking** in CI/CD pipeline

### Short-term Goals (Next Sprint)

1. Achieve 60% overall coverage
2. Reach 80% coverage for Services layer
3. Complete all ViewModel test suites
4. Implement snapshot testing for UI components

### Long-term Goals (Next Quarter)

1. Achieve 70% overall coverage target
2. Establish coverage gates in CI/CD (block PRs below threshold)
3. Add mutation testing for critical components
4. Implement visual regression testing

---

## How to Generate This Report

### Option 1: Xcode

1. Run tests with coverage: **⌘+U**
2. Open Report Navigator: **⌘+9**
3. Select latest test run
4. Click **Coverage** tab
5. Export coverage data

### Option 2: Command Line (Slather)

```bash
# Run tests with coverage
xcodebuild test \
  -scheme Deets \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES

# Generate HTML report
slather coverage \
  --html \
  --scheme Deets \
  --workspace Deets.xcworkspace \
  --output-directory coverage-report

# Generate Cobertura XML for CI/CD
slather coverage \
  --cobertura-xml \
  --scheme Deets \
  --workspace Deets.xcworkspace

# View report
open coverage-report/index.html
```

### Option 3: Automated (CI/CD)

Coverage reports are automatically generated on every CI/CD run and uploaded to:
- **Codecov**: Visual dashboards and trends
- **GitHub Actions Artifacts**: Downloadable HTML reports
- **PR Comments**: Coverage diff for each pull request

---

## Coverage Configuration

### .slather.yml

```yaml
coverage_service: cobertura_xml
xcodeproj: Deets.xcodeproj
workspace: Deets.xcworkspace
scheme: Deets
source_directory: Deets
output_directory: coverage-report
ignore:
  - "Deets/App/DeetsApp.swift"
  - "Deets/Views/**/*"  # UI tested via UI tests
  - "**/*Preview.swift"
  - "**/*+Preview.swift"
  - "**/Mock*.swift"
  - "**/Test*.swift"
```

### Xcode Test Plan Settings

**Deets.xctestplan:**
- Code Coverage: Enabled
- Coverage Targets: All application code
- Excluded: Generated code, previews, mocks

---

## Notes

### Why Some Files Have Low/No Coverage

1. **SwiftUI Views**: Tested via UI tests, not unit tests
2. **Generated Code**: SwiftData @Model macro expansions
3. **App Configuration**: Entry points with minimal logic
4. **Preview Providers**: Development-only code

### Coverage vs. Quality

- **Coverage is a metric, not a goal**: 100% coverage doesn't guarantee bug-free code
- **Test quality matters more**: Well-designed tests at 70% > poor tests at 100%
- **Focus on critical paths**: Scan → Save flow is more important than obscure error paths
- **Balance effort and value**: Diminishing returns after 80-85%

---

**Last Updated**: [TBD - Run tests to generate]
**Next Review**: [TBD]
**Report Owner**: QA Team (KAI)

---

## Quick Links

- [Testing Guide](./TESTING_GUIDE.md) - How to write and run tests
- [CI/CD Setup](../CI_CD_SETUP_GUIDE.md) - Automated testing pipeline
- [Architecture Docs](../Docs/architecture.md) - System design and components
