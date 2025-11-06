# Android Testing Template

> **Template for future Android implementation**
> **Status**: Reference only - No Android code exists yet

---

## Overview

This document serves as a reference template for when Android development begins. It mirrors the iOS testing strategy to maintain consistency across platforms.

---

## Android Testing Stack

### Testing Frameworks

```kotlin
dependencies {
    // Unit Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.3.1")
    testImplementation("org.mockito.kotlin:mockito-kotlin:5.0.0")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    testImplementation("app.cash.turbine:turbine:1.0.0")

    // Instrumented Testing
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation("androidx.test.espresso:espresso-intents:3.5.1")
    androidTestImplementation("androidx.test:runner:1.5.2")
    androidTestImplementation("androidx.test:rules:1.5.0")

    // UI Testing (Compose)
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:1.5.4")
    debugImplementation("androidx.compose.ui:ui-test-manifest:1.5.4")

    // Performance Testing
    androidTestImplementation("androidx.benchmark:benchmark-junit4:1.2.0")

    // MockK (alternative to Mockito)
    testImplementation("io.mockk:mockk:1.13.5")
    androidTestImplementation("io.mockk:mockk-android:1.13.5")
}
```

---

## Test Structure

### Directory Structure

```
app/src/
├── test/                           # Unit Tests (JVM)
│   └── java/com/deets/
│       ├── services/
│       │   ├── OCRServiceTest.kt
│       │   ├── ContactsServiceTest.kt
│       │   └── DatabaseServiceTest.kt
│       ├── viewmodels/
│       │   ├── ScanViewModelTest.kt
│       │   ├── ContactPreviewViewModelTest.kt
│       │   └── CardListViewModelTest.kt
│       ├── parsers/
│       │   └── ContactParserTest.kt
│       ├── exporters/
│       │   ├── VCardExporterTest.kt
│       │   └── CSVExporterTest.kt
│       └── helpers/
│           ├── MockDataGenerator.kt
│           └── TestExtensions.kt
│
├── androidTest/                    # Instrumented Tests (Device/Emulator)
│   └── java/com/deets/
│       ├── ui/
│       │   ├── ScanFlowTest.kt
│       │   ├── ExportFlowTest.kt
│       │   └── AccessibilityTest.kt
│       ├── database/
│       │   └── RoomDatabaseTest.kt
│       └── performance/
│           ├── OCRPerformanceTest.kt
│           └── DatabasePerformanceTest.kt
│
└── benchmark/                      # Macrobenchmark Tests
    └── java/com/deets/benchmark/
        ├── ScanBenchmark.kt
        └── ListScrollBenchmark.kt
```

---

## Test Templates

### 1. Unit Test (ViewModel)

```kotlin
package com.sharedeets.viewmodels

import app.cash.turbine.test
import com.sharedeets.data.models.BusinessCard
import com.sharedeets.data.repository.CardRepository
import com.sharedeets.helpers.MockDataGenerator
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class ScanViewModelTest {

    private val testDispatcher = StandardTestDispatcher()
    private lateinit var repository: CardRepository
    private lateinit var viewModel: ScanViewModel

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        repository = mockk()
        viewModel = ScanViewModel(repository)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `initial state is correct`() {
        assertFalse(viewModel.isScanning.value)
        assertNull(viewModel.scannedText.value)
        assertNull(viewModel.error.value)
    }

    @Test
    fun `startScanning updates state`() = runTest {
        viewModel.startScanning()

        assertTrue(viewModel.isScanning.value)
        assertNull(viewModel.error.value)
    }

    @Test
    fun `handleScannedText updates state and shows preview`() = runTest {
        val testText = "John Doe\njohn@example.com"

        viewModel.handleScannedText(testText)

        assertEquals(testText, viewModel.scannedText.value)
        assertFalse(viewModel.isScanning.value)
        assertTrue(viewModel.showContactPreview.value)
    }

    @Test
    fun `handleScanError sets error and stops scanning`() = runTest {
        val errorMessage = "Camera unavailable"

        viewModel.handleScanError(Exception(errorMessage))

        assertEquals(errorMessage, viewModel.error.value)
        assertFalse(viewModel.isScanning.value)
    }

    @Test
    fun `cancelScanning resets state`() = runTest {
        // Setup
        viewModel.handleScannedText("Test")

        // Act
        viewModel.cancelScanning()

        // Assert
        assertFalse(viewModel.isScanning.value)
        assertNull(viewModel.scannedText.value)
        assertNull(viewModel.error.value)
    }

    @Test
    fun `state flow emits updates`() = runTest {
        viewModel.isScanning.test {
            // Initial state
            assertFalse(awaitItem())

            // Start scanning
            viewModel.startScanning()
            assertTrue(awaitItem())

            cancelAndIgnoreRemainingEvents()
        }
    }
}
```

### 2. Room Database Test

```kotlin
package com.sharedeets.database

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.sharedeets.data.database.CardDatabase
import com.sharedeets.data.database.dao.BusinessCardDao
import com.sharedeets.data.models.BusinessCard
import com.sharedeets.helpers.MockDataGenerator
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class RoomDatabaseTest {

    private lateinit var database: CardDatabase
    private lateinit var cardDao: BusinessCardDao

    @Before
    fun setup() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database = Room.inMemoryDatabaseBuilder(
            context,
            CardDatabase::class.java
        ).build()
        cardDao = database.businessCardDao()
    }

    @After
    fun tearDown() {
        database.close()
    }

    @Test
    fun insertAndRetrieveCard() = runTest {
        val card = MockDataGenerator.generateBusinessCard()

        cardDao.insert(card)
        val retrieved = cardDao.getById(card.id)

        assertNotNull(retrieved)
        assertEquals(card.fullName, retrieved?.fullName)
    }

    @Test
    fun updateCard() = runTest {
        val card = MockDataGenerator.generateBusinessCard()
        cardDao.insert(card)

        val updated = card.copy(fullName = "Updated Name")
        cardDao.update(updated)

        val retrieved = cardDao.getById(card.id)
        assertEquals("Updated Name", retrieved?.fullName)
    }

    @Test
    fun deleteCard() = runTest {
        val card = MockDataGenerator.generateBusinessCard()
        cardDao.insert(card)

        cardDao.delete(card)

        val retrieved = cardDao.getById(card.id)
        assertNull(retrieved)
    }

    @Test
    fun queryWithFilter() = runTest {
        val cards = MockDataGenerator.generateBusinessCards(count = 10)
        cards.forEach { cardDao.insert(it) }

        val favorites = cardDao.getFavorites()

        assertTrue(favorites.isNotEmpty())
        assertTrue(favorites.all { it.isFavorite })
    }

    @Test
    fun searchByName() = runTest {
        val card = MockDataGenerator.generateBusinessCard(
            fullName = "John Unique Smith"
        )
        cardDao.insert(card)

        val results = cardDao.search("Unique")

        assertEquals(1, results.size)
        assertEquals(card.id, results[0].id)
    }
}
```

### 3. Compose UI Test

```kotlin
package com.sharedeets.ui

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.sharedeets.ui.screens.ScanScreen
import com.sharedeets.viewmodels.ScanViewModel
import io.mockk.mockk
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ScanScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    private val mockViewModel: ScanViewModel = mockk(relaxed = true)

    @Test
    fun scanScreen_displaysCorrectly() {
        composeTestRule.setContent {
            ScanScreen(viewModel = mockViewModel)
        }

        // Verify title is displayed
        composeTestRule
            .onNodeWithText("Scan Business Card")
            .assertIsDisplayed()

        // Verify scan button exists
        composeTestRule
            .onNodeWithTag("scanButton")
            .assertIsDisplayed()
            .assertIsEnabled()
    }

    @Test
    fun scanButton_clickable() {
        composeTestRule.setContent {
            ScanScreen(viewModel = mockViewModel)
        }

        // Click scan button
        composeTestRule
            .onNodeWithTag("scanButton")
            .performClick()

        // Verify state change (would need to expose state)
        // This is a simplified example
    }

    @Test
    fun errorMessage_displaysWhenSet() {
        // Set error state in ViewModel
        // mockViewModel.error.value = "Camera unavailable"

        composeTestRule.setContent {
            ScanScreen(viewModel = mockViewModel)
        }

        // Verify error is displayed
        composeTestRule
            .onNodeWithText("Camera unavailable")
            .assertIsDisplayed()
    }

    @Test
    fun accessibilityLabels_present() {
        composeTestRule.setContent {
            ScanScreen(viewModel = mockViewModel)
        }

        // Verify accessibility
        composeTestRule
            .onNodeWithTag("scanButton")
            .assert(hasContentDescription("Start scanning business card"))
    }
}
```

### 4. Espresso UI Test (Views)

```kotlin
package com.sharedeets.ui

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.*
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.*
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.filters.LargeTest
import com.sharedeets.R
import com.sharedeets.ui.MainActivity
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
@LargeTest
class ScanToSaveFlowTest {

    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Test
    fun completeScanToSaveFlow() {
        // Navigate to Scan tab
        onView(withId(R.id.navigation_scan))
            .perform(click())

        // Verify scan screen
        onView(withText("Scan Business Card"))
            .check(matches(isDisplayed()))

        // Start scanning
        onView(withId(R.id.scanButton))
            .perform(click())

        // Wait for scan result (in real test, inject mock data)
        Thread.sleep(1000)

        // Verify preview screen
        onView(withId(R.id.fullNameField))
            .check(matches(isDisplayed()))

        // Edit name
        onView(withId(R.id.fullNameField))
            .perform(clearText(), typeText("John Doe"))

        // Save
        onView(withId(R.id.saveButton))
            .perform(click())

        // Verify success
        onView(withText("Card Saved"))
            .check(matches(isDisplayed()))
    }

    @Test
    fun emailValidation_showsError() {
        onView(withId(R.id.emailField))
            .perform(typeText("invalid-email"))

        onView(withId(R.id.emailFieldError))
            .check(matches(withText("Invalid email format")))

        onView(withId(R.id.saveButton))
            .check(matches(not(isEnabled())))
    }
}
```

### 5. Performance Test (Macrobenchmark)

```kotlin
package com.sharedeets.benchmark

import androidx.benchmark.macro.*
import androidx.benchmark.macro.junit4.MacrobenchmarkRule
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.uiautomator.By
import androidx.test.uiautomator.Until
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ScanBenchmark {

    @get:Rule
    val benchmarkRule = MacrobenchmarkRule()

    @Test
    fun scanStartup() = benchmarkRule.measureRepeated(
        packageName = "com.sharedeets",
        metrics = listOf(StartupTimingMetric()),
        iterations = 5,
        startupMode = StartupMode.COLD
    ) {
        pressHome()
        startActivityAndWait()
    }

    @Test
    fun scrollCardList() = benchmarkRule.measureRepeated(
        packageName = "com.sharedeets",
        metrics = listOf(FrameTimingMetric()),
        iterations = 5,
        startupMode = StartupMode.WARM
    ) {
        startActivityAndWait()

        // Navigate to list
        val device = device
        val listItem = device.findObject(By.res("cardList"))
        listItem.fling()
        device.waitForIdle()
    }

    @Test
    fun ocrProcessing() = benchmarkRule.measureRepeated(
        packageName = "com.sharedeets",
        metrics = listOf(
            FrameTimingMetric(),
            TraceSectionMetric("OCRProcessing")
        ),
        iterations = 5
    ) {
        startActivityAndWait()

        // Trigger OCR
        val device = device
        val scanButton = device.findObject(By.res("scanButton"))
        scanButton.click()

        // Wait for processing
        device.wait(Until.hasObject(By.res("previewScreen")), 5000)
    }
}
```

---

## Mock Data Generator (Android)

```kotlin
package com.sharedeets.helpers

import com.sharedeets.data.models.BusinessCard
import com.sharedeets.data.models.ParsedContact
import java.util.Date
import java.util.UUID

object MockDataGenerator {

    fun generateBusinessCard(
        index: Int = (0..1000).random(),
        isFavorite: Boolean = false,
        savedToContacts: Boolean = false
    ): BusinessCard {
        val names = listOf(
            "Alice Johnson", "Bob Smith", "Charlie Davis",
            "Diana Martinez", "Edward Chen", "Fiona O'Brien"
        )

        val titles = listOf(
            "Software Engineer", "Product Manager", "Designer",
            "CTO", "Marketing Director", "Sales Representative"
        )

        val companies = listOf(
            "Tech Corp", "Design Studio", "Innovation Labs",
            "Digital Solutions", "Cloud Systems", "AI Ventures"
        )

        val name = names[index % names.size]
        val title = titles[index % titles.size]
        val company = companies[index % companies.size]

        return BusinessCard(
            id = UUID.randomUUID().toString(),
            fullName = name,
            jobTitle = title,
            company = company,
            email = "${name.toLowerCase().replace(" ", ".")}@${company.toLowerCase().replace(" ", "")}.com",
            phoneNumber = generatePhoneNumber(),
            website = "https://${company.toLowerCase().replace(" ", "")}.com",
            address = generateAddress(),
            notes = if (index % 3 == 0) "Met at conference" else null,
            rawText = "$name\n$title\n$company",
            dateScanned = Date(),
            dateModified = Date(),
            tags = generateTags(),
            isFavorite = isFavorite,
            savedToContacts = savedToContacts
        )
    }

    fun generateBusinessCards(count: Int): List<BusinessCard> {
        return (0 until count).map { generateBusinessCard(it) }
    }

    fun generateParsedContact(withFullData: Boolean = true): ParsedContact {
        return ParsedContact(
            givenName = "John",
            familyName = "Smith",
            jobTitle = if (withFullData) "CEO" else null,
            organizationName = if (withFullData) "Acme Corp" else null,
            emailAddresses = if (withFullData) listOf("john.smith@acme.com") else emptyList(),
            phoneNumbers = if (withFullData) listOf("5551234567") else emptyList(),
            urls = if (withFullData) listOf("https://acme.com") else emptyList(),
            rawText = "John Smith\nCEO\nAcme Corp"
        )
    }

    private fun generatePhoneNumber(): String {
        val formats = listOf(
            "(555) 123-4567",
            "+1 (555) 987-6543",
            "555-246-8135"
        )
        return formats.random()
    }

    private fun generateAddress(): String {
        val streets = listOf("123 Main St", "456 Oak Ave", "789 Pine Rd")
        val cities = listOf(
            "San Francisco, CA 94102",
            "New York, NY 10001",
            "Austin, TX 78701"
        )
        return "${streets.random()}, ${cities.random()}"
    }

    private fun generateTags(): List<String> {
        val allTags = listOf(
            "Client", "Partner", "Tech", "Design",
            "Marketing", "Sales", "Conference"
        )
        val count = (0..3).random()
        return allTags.shuffled().take(count)
    }
}
```

---

## Running Tests

### Command Line

```bash
# Run all unit tests
./gradlew test

# Run all instrumented tests
./gradlew connectedAndroidTest

# Run specific test class
./gradlew test --tests ScanViewModelTest

# Run with coverage
./gradlew testDebugUnitTestCoverage

# Generate coverage report
./gradlew jacocoTestReport

# Run benchmarks
./gradlew :benchmark:connectedBenchmarkAndroidTest
```

### Android Studio

- **All tests**: Right-click on test directory → Run Tests
- **Single test**: Click green arrow next to test function
- **With coverage**: Run → Run with Coverage

---

## Coverage Configuration

### build.gradle.kts

```kotlin
plugins {
    id("jacoco")
}

android {
    buildTypes {
        debug {
            enableUnitTestCoverage = true
            enableAndroidTestCoverage = true
        }
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            isReturnDefaultValues = true
        }
    }
}

jacoco {
    toolVersion = "0.8.10"
}

tasks.register<JacocoReport>("jacocoTestReport") {
    dependsOn("testDebugUnitTest", "createDebugCoverageReport")

    reports {
        xml.required.set(true)
        html.required.set(true)
    }

    sourceDirectories.setFrom(files("src/main/java"))
    classDirectories.setFrom(files("build/intermediates/javac/debug"))
    executionData.setFrom(files(
        "build/jacoco/testDebugUnitTest.exec",
        "build/outputs/code_coverage/debugAndroidTest/connected/*coverage.ec"
    ))
}
```

---

## CI/CD Integration (GitHub Actions)

```yaml
name: Android Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Grant execute permission
        run: chmod +x gradlew

      - name: Run unit tests
        run: ./gradlew test

      - name: Run instrumented tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          script: ./gradlew connectedAndroidTest

      - name: Generate coverage report
        run: ./gradlew jacocoTestReport

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./build/reports/jacoco/jacocoTestReport/jacocoTestReport.xml
```

---

## Best Practices

### DO ✅

- Use `runTest` for coroutine testing
- Test ViewModels with Turbine for Flow assertions
- Use in-memory Room databases for tests
- Mock dependencies with MockK or Mockito
- Test Compose UI with `createComposeRule()`
- Use `@Before` and `@After` for setup/teardown
- Test accessibility with semantic matchers

### DON'T ❌

- Don't use `Thread.sleep()` - use IdlingResource or Turbine
- Don't test Android framework code
- Don't share mutable state between tests
- Don't skip instrumented tests (they catch real issues)
- Don't hardcode device-specific values

---

## Resources

- [Android Testing Codelab](https://developer.android.com/codelabs/advanced-android-kotlin-training-testing-basics)
- [Compose Testing Guide](https://developer.android.com/jetpack/compose/testing)
- [Espresso Documentation](https://developer.android.com/training/testing/espresso)
- [Room Testing Guide](https://developer.android.com/training/data-storage/room/testing-db)
- [Macrobenchmark Guide](https://developer.android.com/topic/performance/benchmarking/macrobenchmark-overview)

---

**Status**: Template only - No Android implementation exists
**Last Updated**: November 2025
**Maintained By**: QA Team (KAI)
