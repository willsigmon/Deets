# Troubleshooting Guide

This guide covers common issues and their solutions. Find your problem in the table of contents and jump to the solution.

## Table of Contents

- [Permission Issues](#permission-issues)
  - [Camera Access Denied](#camera-access-denied)
  - [Contacts Access Denied](#contacts-access-denied)
  - [Photos Access Denied](#photos-access-denied)
- [Scanning Problems](#scanning-problems)
  - [Camera Won't Open](#camera-wont-open)
  - [OCR Not Detecting Text](#ocr-not-detecting-text)
  - [Poor Text Recognition](#poor-text-recognition)
  - [Wrong Information Extracted](#wrong-information-extracted)
- [Sync Issues](#sync-issues)
  - [iCloud Sync Not Working](#icloud-sync-not-working)
  - [Contacts Not Syncing](#contacts-not-syncing)
  - [Duplicate Contacts Created](#duplicate-contacts-created)
- [Export Problems](#export-problems)
  - [Export Fails](#export-fails)
  - [Can't Share Files](#cant-share-files)
  - [Exported File Won't Open](#exported-file-wont-open)
- [Performance Issues](#performance-issues)
  - [App Runs Slowly](#app-runs-slowly)
  - [Crashes on Launch](#crashes-on-launch)
  - [High Battery Usage](#high-battery-usage)
- [Build Errors (Developers)](#build-errors-developers)
  - [Build Failed in Xcode](#build-failed-in-xcode)
  - [SwiftData Errors](#swiftdata-errors)
  - [Code Signing Issues](#code-signing-issues)
- [Data & Storage](#data--storage)
  - [Lost Contacts](#lost-contacts)
  - [Can't Delete Contacts](#cant-delete-contacts)
  - [Storage Full](#storage-full)
- [Getting Help](#getting-help)

---

## Permission Issues

### Camera Access Denied

**Problem:** App shows "Camera access denied" or camera doesn't open.

**Symptoms:**
- Black screen when tapping Scan button
- Error message about camera permissions
- Camera icon grayed out

**Solutions:**

**Step 1: Check System Settings**
1. Open **Settings** app on your iPhone
2. Scroll down to **Deets**
3. Tap **Camera**
4. Ensure it's set to **Allow** or **Ask Next Time**

**Step 2: Grant Permission When Prompted**
1. Open Deets
2. Tap **Scan** button
3. When iOS asks for camera access, tap **OK** or **Allow**

**Step 3: Reset Permissions (if stuck)**
1. Settings → General → Transfer or Reset iPhone
2. Tap **Reset**
3. Choose **Reset Location & Privacy**
4. Enter your passcode
5. Confirm reset
6. Reopen Deets and grant camera access

**Step 4: Check Screen Time Restrictions**
1. Settings → Screen Time → Content & Privacy Restrictions
2. Tap **Privacy**
3. Tap **Camera**
4. Ensure **Deets** is **Allowed**

**Still not working?**
- Restart your iPhone
- Update to latest iOS version (Settings → General → Software Update)
- Delete and reinstall Deets (⚠️ this will erase local data)

---

### Contacts Access Denied

**Problem:** Can't save contacts to iOS Contacts app.

**Symptoms:**
- "Save to Contacts" button disabled
- Error: "Contacts access denied"
- Contacts only save to Deets, not iOS Contacts

**Solutions:**

**Step 1: Enable Contacts Access**
1. Settings → **Deets**
2. Tap **Contacts**
3. Select **Read and Write** (not just "Read Only")

**Step 2: Verify in Deets**
1. Open Deets
2. Scan or select a contact
3. Try **Save to Contacts** again

**Step 3: Check for Contacts Restrictions**
1. Settings → Screen Time → Content & Privacy Restrictions
2. Tap **Privacy** → **Contacts**
3. Ensure **Deets** is allowed

**Note:** If you previously denied access, iOS won't ask again - you must manually enable it in Settings.

---

### Photos Access Denied

**Problem:** Can't discover contact photos from photo library.

**Symptoms:**
- "Find Photo" button missing or disabled
- Error: "Photos access denied"
- Photo library doesn't open

**Solutions:**

**Step 1: Grant Photos Access**
1. Settings → **Deets**
2. Tap **Photos**
3. Choose **Read and Write** or **All Photos**

**Step 2: Try Photo Discovery Again**
1. Open a contact in Deets
2. Tap **Find Photo**
3. Select photo from library

**Privacy Note:** Deets only accesses photos you explicitly select. We never upload or scan your entire photo library.

---

## Scanning Problems

### Camera Won't Open

**Problem:** Tapping the Scan button does nothing or shows a black screen.

**Symptoms:**
- Black camera viewfinder
- App freezes when scanning
- Camera opens but shows no preview

**Solutions:**

**Step 1: Check Camera Access** (see [Camera Access Denied](#camera-access-denied))

**Step 2: Verify Device Compatibility**
- VisionKit DataScanner requires **iOS 16+**
- Must be a **physical device** (not Simulator)
- Check Settings → General → About → **iOS Version**

**Step 3: Test Camera Independently**
1. Open iOS **Camera** app
2. Take a test photo
3. If Camera app works, restart Deets
4. If Camera app fails, restart iPhone

**Step 4: Force Quit and Reopen**
1. Swipe up from bottom (or double-press Home)
2. Swipe up on **Deets** to close it
3. Reopen Deets from home screen

**Step 5: Check for Other Apps Using Camera**
- Close all apps using camera (FaceTime, Zoom, Camera, Instagram)
- Some apps lock camera access until fully closed

**Developer Note:** If running from Xcode, check console for VisionKit errors:
```
Error: DataScannerViewController is not available
```
This means device doesn't support DataScanner (rare on iOS 16+).

---

### OCR Not Detecting Text

**Problem:** Camera opens but doesn't highlight any text on the business card.

**Symptoms:**
- No green/blue text highlights appear
- Capture button stays disabled
- Message: "No text detected"

**Solutions:**

**Step 1: Improve Card Visibility**
- **Lighting:** Use bright, even lighting (avoid shadows)
- **Angle:** Hold phone parallel to card (not tilted)
- **Distance:** Move closer - card should fill 60-80% of frame
- **Flatness:** Press card flat on table (avoid bent/curved cards)
- **Background:** Use contrasting background (white card on dark table)

**Step 2: Check Card Quality**
- **Faded text:** OCR struggles with low-contrast cards
- **Glossy cards:** Reduce glare by tilting card slightly
- **Textured cards:** May need better lighting
- **Embossed cards:** Ensure text is readable, not just embossed

**Step 3: Adjust OCR Settings** (if available)
1. Tap **Settings** in scan view
2. Toggle **High Contrast Mode** ON
3. Increase **Brightness** slider
4. Try **Enhanced Recognition** toggle

**Step 4: Manual Entry Fallback**
If OCR fails repeatedly:
1. Cancel scan
2. Tap **+** → **Manual Entry**
3. Type contact info manually

**Technical Limits:**
- Supports **English text only** (currently)
- Minimum text size: ~8pt font
- Maximum tilt angle: ±15 degrees
- Requires iOS 16+ device with neural engine

---

### Poor Text Recognition

**Problem:** OCR detects text but extracts wrong information.

**Symptoms:**
- Name appears in Company field
- Email address partially missing
- Phone numbers have extra digits
- Random characters in fields

**Solutions:**

**Step 1: Review Extracted Data**
1. After scan, **carefully check each field**
2. Tap field to edit incorrect information
3. Use **tab key** to move between fields quickly
4. Save once corrected

**Step 2: Improve Scan Quality**
- **Rescan** in better lighting
- **Clean camera lens** (fingerprints reduce accuracy)
- **Flatten card** completely
- **Remove background clutter**

**Step 3: Use Photo Mode** (if available)
1. Take a clear photo of the card first
2. Import into Deets
3. Crop to card boundaries
4. Process with OCR

**Step 4: Report Pattern**
If specific card types fail consistently:
1. Note the card design (font, layout, colors)
2. Report to GitHub Issues with:
   - Photo of card (obscure sensitive info)
   - What was detected vs. what should be detected
   - iOS version and device model

**Why OCR Makes Mistakes:**
- **Similar characters:** O vs 0, l vs I vs 1
- **Unusual fonts:** Script, decorative, or condensed fonts
- **Colored text:** Low contrast with background
- **Mixed languages:** English-only parser gets confused
- **Logos over text:** Overlapping graphics interfere

---

### Wrong Information Extracted

**Problem:** OCR detects text but assigns it to wrong fields.

**Examples:**
- Company name appears in Name field
- Website URL appears in Email field
- Address appears in Notes field

**Why This Happens:**
Deets uses pattern matching and heuristics to categorize text:
- **Email:** Must contain `@` symbol
- **Phone:** Must match phone number patterns
- **Website:** Must start with `http://` or `www.` or end with `.com/.net/etc.`
- **Name:** Usually top of card or near title
- **Company:** Near logo or largest text

**Solutions:**

**Step 1: Manual Correction**
1. Review extracted fields immediately after scan
2. **Tap and hold** a field to copy text
3. **Paste** into correct field
4. **Clear** the incorrect field

**Step 2: Improve Scan Technique**
- Ensure card is **right-side up**
- Avoid tilting or rotating card during scan
- Center the card in viewfinder
- Wait for OCR to stabilize (text highlights stop moving)

**Step 3: Use Field Hints** (future feature)
- Tap-to-select specific text for specific fields
- Coming in v1.1

**Developer Note:** The parser is in `Services/ContactParser.swift`. Known limitations documented in [ERROR_HANDLING_REPORT.md](ERROR_HANDLING_REPORT.md).

---

## Sync Issues

### iCloud Sync Not Working

**Problem:** Contacts don't sync across devices via iCloud.

**Symptoms:**
- New contacts on iPhone don't appear on iPad
- Sync status shows "Failed" or "Offline"
- "Last sync: Never" in settings

**Solutions:**

**Step 1: Verify iCloud Requirements**
1. Settings → [Your Name] → **iCloud**
2. Ensure **iCloud Drive** is **ON**
3. Check that you have **available iCloud storage** (Settings → [Your Name] → iCloud → Manage Storage)
4. Confirm same **Apple ID** signed in on all devices

**Step 2: Enable iCloud for Deets**
1. Open Deets on each device
2. Go to **Settings** (gear icon)
3. Toggle **iCloud Sync** ON
4. Wait for initial sync (can take 1-5 minutes)

**Step 3: Check Network Connection**
- Connect to **Wi-Fi** (cellular data sync is limited)
- Ensure strong signal strength
- Try disabling VPN temporarily

**Step 4: Force Manual Sync**
1. In Deets settings, tap **Sync Now**
2. Watch sync status indicator
3. If fails, note the error message

**Step 5: Check Sync Status in Settings**
1. Settings → [Your Name] → iCloud
2. Scroll to apps using iCloud
3. Look for **Deets** in the list
4. If missing, try toggling iCloud Drive off/on

**Step 6: Reset Sync (last resort)**
⚠️ **Warning: This will re-upload all contacts**
1. Deets Settings → **Advanced**
2. Tap **Reset Sync Status**
3. Confirm action
4. Wait for complete re-sync

**Common Errors:**

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "Network Unavailable" | No internet connection | Connect to Wi-Fi and retry |
| "iCloud Storage Full" | Out of iCloud space | Delete old backups or upgrade storage |
| "Sync Conflict Detected" | Same contact edited on 2 devices | Choose which version to keep |
| "Account Error" | Not signed into iCloud | Sign in: Settings → [Your Name] |

**Developer Note:** CloudKit sync implementation is in `Services/SyncService.swift`. Known issues in [ERROR_HANDLING_REPORT.md](ERROR_HANDLING_REPORT.md#8-missing-error-recovery-in-syncservice).

---

### Contacts Not Syncing

**Problem:** Saved contacts don't appear in iOS Contacts app.

**Symptoms:**
- Contact shows in Deets but not in Phone app
- "Saved to Contacts" badge missing
- Search in Contacts app returns nothing

**Solutions:**

**Step 1: Verify Save Method**
- When saving, did you tap **Save to Contacts** or **Save to Both**?
- If you tapped **Save to Deets Only**, contact is NOT in iOS Contacts
- To fix: Open contact in Deets → Tap **Save to Contacts**

**Step 2: Check Contacts Access** (see [Contacts Access Denied](#contacts-access-denied))

**Step 3: Verify in iOS Contacts App**
1. Open **Contacts** app (or **Phone** app → Contacts tab)
2. Search for the contact by name
3. Check "All Contacts" (not just a specific account)

**Step 4: Check Contacts Account**
1. Settings → Contacts → **Default Account**
2. Note which account (iCloud, Gmail, etc.)
3. Open Contacts app → **Groups**
4. Ensure that account's group is checked

**Step 5: Force Contacts Refresh**
1. Open Contacts app
2. Pull down to refresh
3. Force quit Contacts app
4. Reopen and search again

**Step 6: Re-save Contact**
1. In Deets, open the contact
2. Tap **Edit**
3. Tap **Save to Contacts** again
4. Check for duplicate warning
5. Choose **Update Existing** or **Create New**

---

### Duplicate Contacts Created

**Problem:** Saving creates duplicate contacts in iOS Contacts.

**Symptoms:**
- Two or more entries for same person
- Deets asks "Potential duplicate found - merge?"
- Contacts app shows multiple cards

**Solutions:**

**Step 1: Use Duplicate Detection**
When saving, if Deets detects a duplicate:
1. Tap **View Duplicates**
2. Review existing contacts
3. Choose:
   - **Merge** → Updates existing contact
   - **Save as New** → Creates separate contact
   - **Cancel** → Don't save

**Step 2: Manual Merge in iOS Contacts**
1. Open **Contacts** app
2. Find both duplicate entries
3. Open first contact → Tap **Edit**
4. Scroll down → Tap **Link Contacts**
5. Select the duplicate contact
6. Tap **Link** in top-right corner
7. Linked contacts now appear as one

**Step 3: Prevent Future Duplicates**
1. In Deets Settings, enable **Check for Duplicates** (should be ON by default)
2. Before saving, search existing contacts to verify they don't already exist
3. Use **Update Existing** when re-scanning previously saved cards

**Step 4: Clean Up Duplicates**
iOS Contacts has built-in duplicate detection:
1. Contacts app → **Groups**
2. Tap **All Contacts**
3. Scroll through and look for duplicates
4. iOS may suggest merging - tap **Merge** when prompted

**Developer Note:** Duplicate detection logic is in `Services/ContactsService.swift:242`. Current implementation checks first name + last name + email. Enhanced fuzzy matching coming in v1.1.

---

## Export Problems

### Export Fails

**Problem:** Export operation fails with an error.

**Symptoms:**
- "Export failed" error message
- Share sheet doesn't appear
- App crashes when exporting

**Solutions:**

**Step 1: Check What You're Exporting**
- **No contacts selected?** Select at least one contact first
- **Archived contacts?** Ensure contacts aren't archived/deleted
- **Empty fields?** Some export formats require minimum data

**Step 2: Verify Storage Space**
1. Settings → General → iPhone Storage
2. Ensure you have **at least 100MB free**
3. If low, delete apps/photos to free space
4. Try export again

**Step 3: Try Different Export Format**
- If vCard (.vcf) fails, try CSV (.csv)
- If CSV fails, try vCard
- If both fail, see Step 4

**Step 4: Reduce Export Size**
- Don't export all contacts at once if you have 500+
- Export in smaller batches (50-100 at a time)
- Large exports can timeout or run out of memory

**Step 5: Restart and Retry**
1. Force quit Deets
2. Restart iPhone
3. Reopen Deets
4. Try export with a single contact first (test)
5. Then try batch export

**Common Export Errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| "No cards selected" | Nothing to export | Select contacts first |
| "File creation failed" | Insufficient storage | Free up space |
| "Encoding failed" | Special characters issue | Contact support with card details |
| "Share sheet timeout" | iOS system error | Restart device |

**Developer Note:** Export errors documented in [ERROR_HANDLING_REPORT.md](ERROR_HANDLING_REPORT.md#medium-priority-issues). File creation errors are in `Services/Export/ExportService.swift:265-283`.

---

### Can't Share Files

**Problem:** Share sheet appears but can't send file.

**Symptoms:**
- AirDrop doesn't show recipients
- Email attach fails
- "Unable to attach file" error in Messages

**Solutions:**

**Step 1: Check Share Destination**
- **AirDrop:** Ensure recipient has AirDrop enabled and set to "Everyone" or "Contacts Only"
- **Email:** Verify file size < 25MB (most email providers' limit)
- **Messages:** Verify file size < 100MB
- **Files app:** Ensure iCloud Drive is enabled

**Step 2: Verify File Format**
- **.vcf (vCard):** Supported by all contacts apps
- **.csv (CSV):** Opens in Excel, Numbers, Google Sheets
- If recipient can't open, try alternative format

**Step 3: Alternative Sharing Methods**
1. Export contact
2. Instead of AirDrop, choose **Save to Files**
3. Save to **iCloud Drive** or **On My iPhone**
4. Open Files app and share from there
5. Or upload to Google Drive/Dropbox

**Step 4: Check Network (for iCloud shares)**
- Connect to Wi-Fi
- Disable VPN temporarily
- Ensure iCloud is not in Low Power Mode

**Step 5: Try Third-Party Apps**
If built-in share fails:
- Save to **Files** app first
- Open in third-party app (Dropbox, Google Drive, OneDrive)
- Share from that app

---

### Exported File Won't Open

**Problem:** Recipient can't open the exported file.

**Symptoms:**
- "Unable to open file" error
- File appears corrupted
- Wrong app tries to open file

**Solutions:**

**For vCard (.vcf) Files:**

**Recipient should:**
1. **iPhone/iPad:** Tap file → Tap **Add All [N] Contacts**
2. **Mac:** Double-click file → Opens in Contacts app
3. **Android:** Import via Contacts app → Settings → Import
4. **Windows:** Import into Outlook or Windows Contacts

**If import fails:**
- File may be corrupted - try exporting again
- Some older Android versions don't support vCard 4.0 - use CSV instead
- Gmail Contacts: Upload CSV instead of vCard

**For CSV (.csv) Files:**

**Recipient should:**
1. **Excel:** File → Open → Select CSV file → Import wizard opens
2. **Google Sheets:** File → Import → Upload CSV file
3. **Numbers (Mac):** File → Open → Select CSV file

**If CSV appears garbled:**
- Encoding issue - ensure recipient's app is set to **UTF-8**
- Excel may default to wrong encoding:
  - Data tab → Get External Data → From Text → Choose UTF-8 encoding
- Try opening in Google Sheets first (better UTF-8 support)

**Character Encoding Issues:**
- Special characters (é, ñ, ü) may display as �
- Fix: Open CSV in text editor → Save as UTF-8 with BOM
- Or use vCard format instead (better encoding support)

---

## Performance Issues

### App Runs Slowly

**Problem:** Deets is laggy, slow to respond, or freezes.

**Symptoms:**
- Slow scrolling in contact list
- OCR takes 10+ seconds
- UI animations stutter
- Keyboard input delayed

**Solutions:**

**Step 1: Check Device Storage**
1. Settings → General → iPhone Storage
2. If **almost full** (>90% used):
   - Delete unused apps
   - Clear Safari cache
   - Delete old photos/videos
3. Restart device after clearing space

**Step 2: Check Contact Count**
- If you have **1000+ contacts**, performance may degrade
- Future versions will optimize for large datasets
- Workaround: Archive old contacts

**Step 3: Disable Visual Effects** (if enabled)
1. Deets Settings → **Reduce Motion** ON
2. Deets Settings → **Reduce Transparency** ON
3. Or system-wide: Settings → Accessibility → Motion → **Reduce Motion**

**Step 4: Close Background Apps**
1. Swipe up from bottom (or double-press Home)
2. Swipe up on all apps to close
3. Reopen Deets

**Step 5: Force Restart Device**
- **iPhone 8 or later:** Volume Up → Volume Down → Hold Power until Apple logo
- **iPhone 7:** Hold Volume Down + Power until Apple logo
- **iPhone 6s or earlier:** Hold Home + Power until Apple logo

**Step 6: Update iOS**
1. Settings → General → Software Update
2. Install any available updates
3. Restart device

**Developer Note:** Performance profiling documented in `Config/FeatureFlags.swift`. Enable `performanceProfilingEnabled` in debug builds to identify bottlenecks.

---

### Crashes on Launch

**Problem:** Deets crashes immediately when opening.

**Symptoms:**
- App opens then immediately closes
- Flash of UI then crash to home screen
- "Deets has stopped working" (rare on iOS)

**Solutions:**

**Step 1: Force Quit and Reopen**
1. Double-press Home (or swipe up from bottom)
2. Swipe up on Deets to fully close
3. Wait 5 seconds
4. Reopen Deets from home screen

**Step 2: Restart iPhone**
1. Force restart (see steps in [App Runs Slowly](#app-runs-slowly))
2. Wait for device to fully boot
3. Try opening Deets again

**Step 3: Check iOS Version**
1. Settings → General → About
2. Deets requires **iOS 16.0 or later**
3. If older, update: Settings → General → Software Update

**Step 4: Check Crash Logs (Developers)**
1. Settings → Privacy & Security → Analytics & Improvements
2. Tap **Analytics Data**
3. Look for **Deets-[date].crash**
4. Share log file when reporting bug

**Step 5: Reinstall App** ⚠️
**Warning: This deletes all local data. Export contacts first if possible.**

1. Long-press Deets icon → **Remove App**
2. Restart iPhone
3. Reinstall from App Store or Xcode
4. Restore from iCloud backup (if sync was enabled)

**Common Crash Causes:**

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Crash on launch, every time | Corrupted SwiftData database | Reinstall app |
| Crash when opening specific contact | Bad data in that contact | Delete contact via Contacts app |
| Crash when scanning | VisionKit framework issue | Update iOS |
| Crash after update | Migration failed | Report to developer with crash log |

**Developer Note:** Critical crash risks documented in [ERROR_HANDLING_REPORT.md](ERROR_HANDLING_REPORT.md#critical-issues). See `App/DeetsApp.swift:57` for fatalError that crashes on SwiftData initialization failure.

---

### High Battery Usage

**Problem:** Deets drains battery quickly.

**Symptoms:**
- Battery depletes faster than normal
- Device gets warm when using Deets
- Settings → Battery shows Deets using 20%+ battery

**Solutions:**

**Step 1: Check Battery Usage**
1. Settings → Battery
2. Tap **Last 10 Days** to see trend
3. Note Deets usage percentage

**Step 2: Reduce Camera Usage**
- Camera + OCR processing is battery-intensive
- Batch your scanning: scan multiple cards in one session vs. throughout day
- Close camera when not actively scanning

**Step 3: Disable Background Sync** (if enabled)
1. Deets Settings → **Background Sync** OFF
2. This stops automatic iCloud syncing
3. Manually sync when needed (Settings → Sync Now)

**Step 4: Reduce Visual Effects**
1. Deets Settings → **Animations** OFF
2. Deets Settings → **Haptic Feedback** OFF (haptics use power)

**Step 5: Check for Rogue Sync**
- If sync gets stuck in infinite loop, battery drains fast
- Deets Settings → **Sync Status** → Should say "Idle"
- If says "Syncing..." for >5 minutes, force quit app and reopen

**Step 6: General Battery Optimization**
1. Settings → Battery → **Low Power Mode** ON (when needed)
2. Reduce screen brightness
3. Enable **Auto-Lock** to 30 seconds or 1 minute
4. Close Deets when not in use (don't leave camera open)

**Expected Battery Usage:**
- **Normal use** (5-10 scans/day): 2-5% per day
- **Heavy use** (50+ scans/day): 10-15% per day
- **Sync active**: +2-3% per sync session

If usage is significantly higher, please report with:
- Device model and iOS version
- Battery usage screenshot
- Crash logs (if any)

---

## Build Errors (Developers)

### Build Failed in Xcode

**Problem:** Xcode build fails with compilation errors.

**Common Errors and Solutions:**

**Error: "No such module 'SwiftData'"**
- **Cause:** Xcode version too old
- **Fix:** Update to Xcode 15.0 or later (SwiftData requires Xcode 15+)

**Error: "Cannot find 'DataScannerViewController' in scope"**
- **Cause:** Missing VisionKit import or deployment target too low
- **Fix:**
  1. Verify `import VisionKit` at top of file
  2. Check deployment target: Project Settings → Deployment Target → **iOS 16.0**

**Error: "Command CodeSign failed with a nonzero exit code"**
- **Cause:** Code signing issue
- **Fix:** See [Code Signing Issues](#code-signing-issues)

**Error: "Missing required module 'BusinessCard'"**
- **Cause:** SwiftData model not in target
- **Fix:**
  1. Select `BusinessCard.swift` in Project Navigator
  2. File Inspector (right panel) → **Target Membership**
  3. Check **Deets** target

**Error: "Type 'BusinessCard' does not conform to protocol 'Decodable'"**
- **Cause:** SwiftData models don't need Codable conformance
- **Fix:** Remove `: Codable` from BusinessCard declaration

**Error: "Ambiguous use of 'modelContainer'"**
- **Cause:** Multiple SwiftData imports or wrong usage
- **Fix:**
  1. Ensure only one `.modelContainer()` modifier in `DeetsApp.swift`
  2. Check for duplicate SwiftData imports

**Build Clean Steps:**
1. Product → Clean Build Folder (⌘⇧K)
2. Close Xcode
3. Delete **DerivedData**: `rm -rf ~/Library/Developer/Xcode/DerivedData`
4. Reopen project
5. Build again

---

### SwiftData Errors

**Problem:** Runtime errors related to SwiftData database.

**Common Errors:**

**"Fatal error: Could not create ModelContainer"**
- **Cause:** SwiftData can't initialize database
- **Impact:** App crashes on launch
- **Fix:**
  1. **Delete app from device/simulator**
  2. Clean build folder (⌘⇧K)
  3. Reset simulator: Device → Erase All Content and Settings
  4. Rebuild and run

**"Thread 1: Fatal error: No ObservableObject of type BusinessCard"**
- **Cause:** Missing `.modelContainer()` modifier or wrong placement
- **Fix:** In `DeetsApp.swift`, ensure:
  ```swift
  WindowGroup {
      CardListView()
          .modelContainer(for: BusinessCard.self)
  }
  ```

**"Unresolved error ... The model configuration is nil"**
- **Cause:** SwiftData schema mismatch or migration failure
- **Fix:**
  1. If in development: Delete app, clean build, reinstall
  2. If in production: Add migration code (see SwiftData migration guide)

**"Could not cast value of type 'NSManagedObject' to 'BusinessCard'"**
- **Cause:** Schema changed but no migration performed
- **Fix:** Version the schema using `VersionedSchema` and `SchemaMigrationPlan`

**Debug SwiftData Issues:**
1. Add this to **scheme arguments** (Edit Scheme → Run → Arguments):
   ```
   -com.apple.CoreData.SQLDebug 1
   ```
2. Run app - console will show SQL queries
3. Look for errors in query execution

**Reset SwiftData (Development Only):**
```bash
# Find app container
xcrun simctl get_app_container booted com.deets.app

# Delete database
rm -rf ~/Library/Developer/CoreSimulator/Devices/[DEVICE-ID]/data/Containers/Data/Application/[APP-ID]/Library/Application\ Support/default.store
```

---

### Code Signing Issues

**Problem:** Build fails with code signing errors.

**Common Errors:**

**"No signing certificate found"**
- **Cause:** No Apple Developer certificate installed
- **Fix:**
  1. Xcode → Settings → Accounts
  2. Click **+** → Add Apple ID
  3. Sign in with your Apple ID
  4. Click **Download Manual Profiles**
  5. In project settings, select your Team

**"Provisioning profile doesn't include signing certificate"**
- **Cause:** Certificate/profile mismatch
- **Fix:**
  1. Project Settings → Signing & Capabilities
  2. **Uncheck** "Automatically manage signing"
  3. **Re-check** "Automatically manage signing"
  4. Xcode will regenerate profiles

**"No profiles for 'com.deets.app' were found"**
- **Cause:** Bundle identifier already in use or not registered
- **Fix:**
  1. Change bundle identifier to something unique
  2. Project → Targets → Deets → General → **Bundle Identifier**
  3. Use reverse domain: `com.yourname.deets`

**"Untrusted Developer"** (when running on device)
- **Cause:** Developer certificate not trusted on device
- **Fix:**
  1. On iOS device: Settings → General → VPN & Device Management
  2. Tap your developer name
  3. Tap **Trust "[Your Name]"**
  4. Confirm trust

**"Team ID mismatch"**
- **Cause:** Wrong team selected in capabilities
- **Fix:**
  1. Verify all capabilities use same team
  2. Signing & Capabilities → Check each capability section
  3. Select correct team from dropdown

**Free Apple ID (No Paid Developer Account):**
- Can still build and run on your own devices
- Limitations:
  - App expires after 7 days (must rebuild)
  - Limited to 3 apps at a time
  - No App Store distribution
  - Some entitlements unavailable (iCloud in older Xcode versions)

---

## Data & Storage

### Lost Contacts

**Problem:** Contacts disappeared from Deets.

**Symptoms:**
- Contact list is empty
- Previously scanned cards missing
- "No contacts" message

**Solutions:**

**Step 1: Check if Accidentally Filtered**
1. Look for **active filter** (star icon or "Favorites Only")
2. Tap **All Contacts** to remove filter
3. Clear search bar if text is present

**Step 2: Check iCloud Sync**
If sync was enabled:
1. Settings → **iCloud Sync** → Ensure **ON**
2. Tap **Sync Now**
3. Wait 1-2 minutes for download
4. Contacts should reappear

**Step 3: Check iOS Contacts App**
If contacts were saved to iOS Contacts:
1. Open **Contacts** app
2. Search for missing contacts
3. They may still exist there even if missing from Deets
4. Re-import: Deets → Settings → **Import from Contacts**

**Step 4: Check for App Reinstall**
- Did you recently **delete and reinstall** Deets?
- Without iCloud sync enabled, local data is erased on uninstall
- Check if iCloud backup is available (Settings → iCloud Sync → Restore from iCloud)

**Step 5: Check Recent Changes**
1. Deets Settings → **Recently Deleted** (if feature exists)
2. Restore accidentally deleted contacts
3. If no Recently Deleted folder, contacts are permanently lost

**Prevention:**
- ✅ **Enable iCloud Sync** - Protects against data loss
- ✅ **Save to Contacts** - Backup in iOS Contacts app
- ✅ **Regular Exports** - Export all contacts monthly as .vcf backup

**Data Recovery (Last Resort):**
If you have an iTunes/iCloud backup from before contacts were lost:
1. Settings → General → Transfer or Reset iPhone
2. **Erase All Content and Settings**
3. Restore from backup during setup
4. ⚠️ **Warning:** This restores ENTIRE phone to old state

---

### Can't Delete Contacts

**Problem:** Delete button doesn't work or contact reappears.

**Symptoms:**
- Swipe to delete does nothing
- Contact reappears after deletion
- "Unable to delete" error

**Solutions:**

**Step 1: Try Different Delete Method**
- **Method 1:** Swipe left on contact → Tap **Delete**
- **Method 2:** Open contact → Tap **Edit** → Scroll down → **Delete Contact**
- **Method 3:** Select contact → Tap **...** menu → **Delete**

**Step 2: Check Sync Conflicts**
If iCloud sync is ON:
1. Contact may be syncing from another device
2. Wait 1 minute for sync to complete
3. Try delete again
4. Check other devices - delete there too

**Step 3: Check iOS Contacts**
If saved to iOS Contacts:
1. Open **Contacts** app
2. Find and delete contact there
3. Return to Deets
4. Tap **Sync** to update

**Step 4: Force Delete**
1. Deets Settings → **Advanced**
2. Tap **Reset Local Cache**
3. Confirm action
4. Re-sync from iCloud or Contacts

**Step 5: Report Bug**
If deletion consistently fails:
1. Note contact details (without sensitive info)
2. Check console in Xcode for errors
3. Report to GitHub Issues with:
   - Steps to reproduce
   - iOS version
   - Whether contact is synced, saved to Contacts, etc.

---

### Storage Full

**Problem:** Device says storage is full, Deets may be using too much space.

**Symptoms:**
- "iPhone Storage Almost Full" message
- Can't take photos
- Apps won't update

**Check Deets Storage Usage:**
1. Settings → General → iPhone Storage
2. Scroll to **Deets**
3. Note **App Size** and **Documents & Data** size

**Expected Storage:**
- **App:** 20-40 MB (the app itself)
- **Documents & Data:**
  - 1-10 MB per 100 contacts (without photos)
  - 50-200 MB per 100 contacts (with photos)
  - 1-2 GB for 1000+ contacts with photos

**Solutions:**

**Step 1: Delete Unused Contacts**
1. Review contact list
2. Delete outdated or duplicate contacts
3. This frees Documents & Data storage

**Step 2: Remove Contact Photos**
If photos take too much space:
1. Open contacts with photos
2. Tap **Edit**
3. Tap photo → **Remove Photo**
4. Save contact
5. Repeat for all contacts with large photos

**Step 3: Offload to iCloud**
1. Enable **iCloud Sync** (Settings → Deets)
2. Wait for upload to complete
3. Deets Settings → Advanced → **Optimize Storage**
4. This keeps contacts in iCloud, downloads on-demand

**Step 4: Export and Archive**
1. Export all contacts as .vcf file
2. Save to cloud storage (Google Drive, Dropbox)
3. Delete old contacts from Deets
4. Keeps backup but frees device space

**Step 5: Offload App** (iOS Feature)
1. Settings → General → iPhone Storage → Deets
2. Tap **Offload App**
3. This removes app but keeps data
4. Reinstall when needed - data returns

**Step 6: Delete and Reinstall** ⚠️
**Last resort - erases all local data**
1. Export all contacts first
2. Enable iCloud sync to backup
3. Delete Deets
4. Reinstall from App Store
5. Sign in and restore from iCloud

---

## Getting Help

### Before Asking for Help

1. ✅ Search this troubleshooting guide
2. ✅ Check [GitHub Issues](https://github.com/yourusername/Deets/issues) for similar problems
3. ✅ Try basic fixes: restart app, restart device, update iOS
4. ✅ Note exact error messages (screenshot them)
5. ✅ Gather system info: Settings → General → About

### How to Report a Bug

When opening a GitHub Issue, include:

**Required Info:**
- **iOS Version:** (Settings → General → About → Software Version)
- **Device Model:** (e.g., iPhone 14 Pro, iPad Air 5th gen)
- **Deets Version:** (Deets Settings → About)
- **Problem Description:** What happened vs. what you expected
- **Steps to Reproduce:** Exact steps to trigger the bug
- **Screenshots/Videos:** If applicable

**Example Bug Report:**
```
**Bug:** OCR not detecting text on business cards

**Environment:**
- iOS Version: 17.5.1
- Device: iPhone 15 Pro
- Deets Version: 1.0.2

**Steps to Reproduce:**
1. Open Deets
2. Tap Scan button
3. Point camera at business card
4. No text highlights appear

**Expected:** Green text highlights on detected text
**Actual:** No highlights, capture button disabled

**Screenshots:** [attached]

**Additional Context:**
- Card has white background, black text
- Happens in bright indoor lighting
- Camera permission granted
- Other cards scan fine
```

### Support Channels

**GitHub Issues** (Preferred)
- Report bugs: [Issues page](https://github.com/yourusername/Deets/issues)
- Request features: [Discussions page](https://github.com/yourusername/Deets/discussions)
- Contribute fixes: [Pull Requests](https://github.com/yourusername/Deets/pulls)

**Documentation**
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Quick start guide
- **[USER_GUIDE.md](USER_GUIDE.md)** - Full feature documentation
- **[README.md](README.md)** - Project overview
- **[ERROR_HANDLING_REPORT.md](ERROR_HANDLING_REPORT.md)** - Known issues (technical)

**Email Support** *(if available)*
- support@deets.app
- Include: Device info, iOS version, screenshots, detailed description

**Community**
- Twitter: **#DeetsApp**
- Reddit: r/DeetsApp *(if exists)*

### Privacy & Data Safety

**We Never:**
- Upload your contacts to our servers
- Share data with third parties
- Track your scanning activity
- Access your data without permission

**Your Data:**
- **Local:** Stored on your device in SwiftData database
- **iCloud:** End-to-end encrypted (if sync enabled)
- **Exports:** Remain on your device until you share them

See full privacy policy: [Privacy/privacy-policy.md](Privacy/privacy-policy.md)

---

## Glossary

**OCR** - Optical Character Recognition - Technology that converts images of text into actual text data

**vCard (.vcf)** - Virtual Contact File - Standard format for electronic business cards

**CSV** - Comma-Separated Values - Spreadsheet format readable by Excel, Google Sheets, etc.

**SwiftData** - Apple's framework for data persistence in iOS apps

**VisionKit** - Apple's framework for camera-based scanning and text recognition

**iCloud Sync** - Apple's service for keeping data synchronized across your devices

**DataScanner** - VisionKit component that provides real-time text recognition from camera

**Haptic Feedback** - Vibration feedback when you tap buttons or complete actions

**Dynamic Type** - iOS feature that adjusts text size based on user preferences

**VoiceOver** - iOS screen reader for accessibility

---

**Last Updated:** 2025-11-05

**Didn't find your issue?** [Open a GitHub Issue](https://github.com/yourusername/Deets/issues/new)
