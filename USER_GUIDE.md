# Deets User Guide

**Complete guide to using Deets - Business Card Scanner**

Welcome! This guide covers everything you need to know about using Deets to scan, manage, and export your business card contacts.

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Scanning Business Cards](#scanning-business-cards)
4. [Managing Contacts](#managing-contacts)
5. [Editing Contact Information](#editing-contact-information)
6. [Photo Enrichment](#photo-enrichment)
7. [Exporting Contacts](#exporting-contacts)
8. [Syncing with iCloud](#syncing-with-icloud)
9. [Search & Organization](#search--organization)
10. [Settings & Preferences](#settings--preferences)
11. [Privacy & Security](#privacy--security)
12. [Tips & Best Practices](#tips--best-practices)
13. [FAQ](#faq)

---

## Introduction

### What is Deets?

Deets is an iOS app that transforms business cards into digital contacts using your iPhone's camera and advanced OCR (Optical Character Recognition) technology. Instead of manually typing contact information, simply scan the card and Deets extracts:

- Full Name
- Job Title
- Company
- Email Address(es)
- Phone Number(s)
- Website URLs
- Business Address
- Additional Notes

### Key Features

✨ **Instant Scanning** - Real-time text recognition powered by Apple VisionKit
📱 **Contacts Integration** - Save directly to your iOS Contacts app
☁️ **iCloud Sync** - Access contacts across all your Apple devices
📤 **Multiple Export Formats** - vCard (.vcf) and CSV (.csv)
📸 **Photo Enrichment** - Automatically discover contact photos from your library
🔍 **Smart Search** - Find contacts by name, company, email, or any field
⭐ **Favorites** - Mark important contacts for quick access
🎨 **Beautiful UI** - Native SwiftUI design with dark mode support
♿ **Accessible** - Full VoiceOver and Dynamic Type support

### What You'll Need

- iPhone or iPad with **iOS 16.0 or later**
- Camera access (required for scanning)
- Contacts access (optional, for saving to iOS Contacts)
- Photos access (optional, for photo enrichment)
- iCloud account (optional, for sync)

---

## Getting Started

### Installation

**For End Users:**
1. Download Deets from the App Store
2. Tap **Open** or find Deets on your home screen
3. Grant permissions when prompted (Camera, Contacts, Photos)

**For Developers:**
See [GETTING_STARTED.md](GETTING_STARTED.md) for build instructions.

### First Launch

When you first open Deets:

1. **Welcome Screen** - Brief intro to features
2. **Permission Requests** - Tap "Allow" for Camera and Contacts
3. **Main Screen** - Empty state with "Scan Your First Card" prompt

**[Image: Welcome screen and empty state]**

### Understanding the Interface

**Main Screen (Contact List):**
- **Navigation Bar** - App title, search button, settings
- **Scan Button (+)** - Large circular button at bottom center
- **Contact List** - Scrollable list of saved cards
- **Filter Menu** - Star icon to filter favorites
- **Search Bar** - Pull down to reveal search

**Contact Card Row:**
- **Profile Photo** - Contact image (if available)
- **Name** - Full name in bold
- **Company** - Organization name below
- **Job Title** - Role/position in smaller text
- **Star Icon** - Favorite status (filled = favorited)

**[Image: Main screen with contacts]**

---

## Scanning Business Cards

### How to Scan

**Step 1: Start Scan**
1. Tap the **+ (Scan)** button at bottom center
2. If prompted, grant **Camera access**
3. The camera viewfinder appears

**Step 2: Position the Card**

**Best Practices:**
- 📐 **Flat surface** - Place card on table or hold steady
- 💡 **Good lighting** - Use natural light or bright indoor lighting
- 📏 **Fill frame** - Card should occupy 60-80% of screen
- 🔲 **Parallel angle** - Hold phone directly above/in front of card
- ✨ **Minimize glare** - Avoid reflective surfaces

**What to Avoid:**
- ❌ Shadows across text
- ❌ Tilted or angled cards
- ❌ Bent or curved cards
- ❌ Cards with excessive glare
- ❌ Moving or shaking camera

**[Image: Good vs bad card positioning]**

**Step 3: Watch for Text Detection**

Deets highlights detected text in **real-time**:
- **Blue highlights** - Detected text items
- **Green highlights** - High-confidence text
- **No highlights** - Improve lighting or positioning

**Step 4: Capture**

When text is clearly highlighted:
1. Tap the **Capture** button (camera icon)
2. OCR processing begins (1-3 seconds)
3. **Contact Preview** screen appears

**[Image: Scanning interface with text highlights]**

### Scanning Tips

**For Cards with Dark Backgrounds:**
- Increase exposure by tapping bright area
- Use the brightness slider (if available)
- Ensure contrast between text and background

**For Cards with Multiple Languages:**
- Current version supports **English only**
- Scan English portions first
- Manually enter other languages

**For Embossed or Textured Cards:**
- Improve lighting to make embossing readable
- Reduce glare by tilting card slightly
- May need manual correction after scan

**For Low-Contrast Text:**
- Use OCR enhancement toggle (if available)
- Maximize lighting
- Consider manual entry for problem fields

**For Cards with QR Codes:**
- QR scanning coming in future update
- For now, use iPhone Camera app to scan QR code separately

---

## Managing Contacts

### Viewing Contact Details

**From List View:**
1. Tap any contact row
2. **Detail View** opens showing all information

**Detail View Shows:**
- Profile photo (if available)
- Full name and job title
- Company name
- All contact fields (email, phone, website, address)
- Notes
- Metadata (date scanned, date modified)
- Action buttons (Edit, Export, Delete, Star)

**[Image: Contact detail view]**

### Editing Contacts

**Quick Edit:**
1. Open contact detail view
2. Tap **Edit** button (top right)
3. Tap any field to modify
4. Use **tab key** to move between fields
5. Tap **Save** when done

**Editable Fields:**
- First Name / Last Name / Full Name
- Job Title
- Company
- Email (can add multiple)
- Phone (can add multiple)
- Website URL
- Business Address (street, city, state, ZIP, country)
- Notes (freeform text)

**Field Validation:**

Deets validates fields as you type:

- ✅ **Email** - Must contain @ symbol and valid domain
- ✅ **Phone** - Auto-formats based on country
- ✅ **Website** - Auto-adds https:// if missing
- ✅ **Required fields** - Name is required, others optional

Invalid fields show **red highlight** with error message.

**[Image: Edit mode with validation]**

### Adding Photos

**Option 1: Photo Enrichment** (Automatic)
1. Open contact detail view
2. Tap **Find Photo** button
3. Deets searches your photo library for matching faces
4. Select best photo from suggestions
5. Crop if needed
6. Tap **Save**

See [Photo Enrichment](#photo-enrichment) section for details.

**Option 2: Manual Photo**
1. Open contact detail view
2. Tap **Edit**
3. Tap profile photo circle
4. Choose **Take Photo** or **Choose Photo**
5. Crop to square
6. Tap **Save**

**Photo Guidelines:**
- Square aspect ratio (cropped automatically)
- Clear face shot (centered, good lighting)
- Minimum 200x200 pixels
- Maximum 2048x2048 pixels (automatically resized)

### Deleting Contacts

**Single Contact:**
1. **Option A:** Swipe left on contact → Tap **Delete**
2. **Option B:** Open contact → Tap **Edit** → Scroll down → **Delete Contact**
3. **Option C:** Open contact → Tap **...** menu → **Delete**

**Confirm Deletion:**
- Alert appears: "Delete this contact?"
- Tap **Delete** to confirm or **Cancel** to abort

**Important Notes:**
- Deleting from Deets does NOT delete from iOS Contacts
- If iCloud sync is enabled, deletion syncs across devices
- No "Recently Deleted" recovery (deleted = permanent)

**Batch Delete** (Future Feature):
- Select multiple contacts
- Tap **Delete All**
- Confirm batch deletion

### Marking Favorites

**To Favorite:**
1. Tap the **star icon** on contact row (list view)
2. **Or** open contact → Tap **star icon** (top right)
3. Star turns **gold** when favorited

**To Unfavorite:**
1. Tap the **gold star** again
2. Star becomes **outline only**

**Viewing Favorites:**
1. Main screen → Tap **filter icon** (funnel)
2. Select **Favorites Only**
3. List shows only favorited contacts
4. Tap **All Contacts** to clear filter

**Use Cases for Favorites:**
- Important clients or partners
- Frequently contacted people
- High-priority leads
- VIPs

---

## Editing Contact Information

### Understanding Contact Fields

**Name Fields:**
- **Full Name** - Complete name as it appears on card
- **First Name** - Given name (extracted from full name)
- **Last Name** - Surname/family name
- **Middle Name** - Optional middle name/initial
- **Name Prefix** - Dr., Mr., Ms., etc.
- **Name Suffix** - Jr., Sr., III, PhD, etc.

**Professional Fields:**
- **Job Title** - Position/role (e.g., "Senior Developer")
- **Company** - Organization name
- **Department** - Division/team (optional)

**Contact Fields:**
- **Email** - Can add multiple (work, personal, other)
- **Phone** - Can add multiple (work, mobile, home)
- **Website** - Company or personal URL

**Address Fields:**
- **Street Address** - Building number and street
- **City** - City/town
- **State/Province** - State abbreviation or province
- **ZIP/Postal Code** - Postal code
- **Country** - Country name

**Additional Fields:**
- **Notes** - Freeform text (where you met, topics discussed, follow-up tasks)
- **Tags** - Category labels (future feature)
- **Birthday** - Optional date field (future feature)

### Auto-Formatting

Deets automatically formats certain fields:

**Phone Numbers:**
- **US:** +1 (555) 123-4567
- **International:** Detects country code
- **Extensions:** Supports x1234 format

**Websites:**
- Auto-adds `https://` if missing
- Validates domain format
- Converts `www.example.com` → `https://www.example.com`

**Email:**
- Validates format (must have @ and domain)
- Lowercases automatically
- Detects multiple emails separated by comma

**Names:**
- Capitalizes first letter of each word
- Handles prefixes (Dr., Mr., Ms.)
- Handles suffixes (Jr., Sr., PhD)

### Field Validation Errors

Common validation errors and fixes:

| Error | Field | Fix |
|-------|-------|-----|
| "Invalid email format" | Email | Ensure format: name@domain.com |
| "Phone number too short" | Phone | Add area code and full number |
| "Invalid URL" | Website | Check spelling, ensure .com/.net/etc. |
| "Name is required" | Name | Cannot save without a name |

### Copying Field Values

**To Copy a Field:**
1. **Long press** on any field value
2. Tap **Copy** in popup menu
3. Paste anywhere (email, notes, messages)

**Quick Actions:**
- **Tap phone number** → Opens phone app to call
- **Tap email address** → Opens Mail app
- **Tap website** → Opens in Safari
- **Tap address** → Opens in Apple Maps

---

## Photo Enrichment

### What is Photo Enrichment?

Photo enrichment automatically discovers photos of your contacts from your iPhone's photo library. Using facial recognition, Deets suggests photos that likely match the contact.

**How It Works:**
1. Deets analyzes contact name
2. Searches photo library for matching faces
3. Uses iOS Photos face detection (respects privacy)
4. Ranks photos by confidence match
5. Presents top suggestions for you to choose

**Privacy Note:** Deets never uploads photos. All processing happens on-device using Apple's Photos framework.

### Enabling Photo Access

**First Time:**
1. Open a contact without a photo
2. Tap **Find Photo**
3. iOS asks: "Deets Would Like to Access Your Photos"
4. Tap **Allow Access to All Photos** (recommended)
5. **Or** tap **Select Photos** for limited access

**Change Permission Later:**
- Settings → Deets → Photos → Choose access level

### Finding Photos

**Automatic Discovery:**
1. Open contact detail view
2. Tap **Find Photo** button
3. Deets searches photo library (takes 5-15 seconds)
4. **Photo Selection Screen** appears with suggestions

**[Image: Photo suggestion grid]**

**Photo Selection Screen:**
- **Grid of suggestions** - Sorted by match confidence
- **Confidence badge** - High/Medium/Low match indicator
- **Source info** - Where photo is from (People album, event, etc.)
- **Select button** - Tap to choose photo

**No Suggestions Found?**
- Contact may not have photos in your library
- Name spelling may not match photo metadata
- Manually select: Tap **Choose Photo Manually**

### Selecting & Cropping Photos

**Step 1: Select Photo**
1. Tap a suggested photo
2. **Or** tap **Choose Manually** → Browse photo library
3. Photo opens in crop view

**Step 2: Crop to Square**
1. Pinch to zoom
2. Drag to reposition
3. Ensure face is centered
4. Tap **Done**

**[Image: Photo cropping interface]**

**Step 3: Confirm**
1. Preview appears in contact view
2. Tap **Save** to keep photo
3. **Or** tap **Change Photo** to try different one

### Removing Photos

**To Remove:**
1. Open contact → Tap **Edit**
2. Tap profile photo
3. Tap **Remove Photo**
4. Tap **Save**

Photo is removed from contact but remains in your photo library.

### Photo Quality Tips

**Best Photos:**
- ✅ Clear, front-facing view
- ✅ Good lighting
- ✅ High resolution (not blurry)
- ✅ Recent photo (if possible)
- ✅ Professional appearance

**Avoid:**
- ❌ Group photos (unless face is clear)
- ❌ Side profiles or turned away
- ❌ Sunglasses or hats covering face
- ❌ Low light/grainy photos
- ❌ Extreme close-ups

### Batch Photo Enrichment (Future)

Coming in v1.1:
- Scan all contacts for missing photos
- Bulk apply suggestions
- Review queue of suggested matches

---

## Exporting Contacts

### Export Formats

Deets supports two industry-standard export formats:

**vCard (.vcf)**
- **Best for:** Importing into contacts apps
- **Compatible with:** iOS Contacts, macOS Contacts, Gmail, Outlook, Android
- **Contains:** All contact fields, including photo
- **Standard:** vCard 4.0 (RFC 6350 compliant)

**CSV (.csv)**
- **Best for:** Spreadsheets and databases
- **Compatible with:** Excel, Google Sheets, Numbers, CRM systems
- **Contains:** Text fields only (no photos)
- **Customizable:** Select which fields to include

### Exporting Single Contact

**Step 1: Open Contact**
1. Tap contact from list view
2. Contact detail opens

**Step 2: Start Export**
1. Tap **Export** button (share icon, top right)
2. **Or** tap **...** menu → **Export Contact**

**Step 3: Choose Format**
1. **Export Options** sheet appears
2. Select format:
   - **vCard (.vcf)** - Default, recommended
   - **CSV (.csv)** - For spreadsheets

**[Image: Export format selection]**

**Step 4: Share**
1. iOS **Share Sheet** appears
2. Choose destination:
   - **AirDrop** - Send to nearby devices
   - **Messages** - Text the contact file
   - **Mail** - Email as attachment
   - **Files** - Save to iCloud Drive or local storage
   - **Third-party apps** - Dropbox, Google Drive, etc.

**[Image: iOS share sheet]**

### Exporting Multiple Contacts

**Step 1: Select Contacts**

**Option A: Select from List**
1. Main screen → Tap **Select** (top right)
2. Tap checkboxes next to contacts
3. Tap **Export** button (appears at bottom)

**Option B: Export All**
1. Main screen → Tap **...** menu
2. Tap **Export All Contacts**

**Option C: Export Filtered**
1. Apply filter (Favorites, Search results)
2. Tap **...** menu → **Export Visible**

**Step 2: Choose Format**
Same as single contact export.

**Step 3: Configure CSV (if selected)**

For CSV exports, select fields to include:

**Available Fields:**
- ✅ Full Name *(required)*
- ☐ First Name
- ☐ Last Name
- ☐ Job Title
- ☐ Company
- ☐ Email
- ☐ Phone Number
- ☐ Website
- ☐ Address
- ☐ Notes
- ☐ Date Scanned
- ☐ Date Modified
- ☐ Tags
- ☐ Favorite Status

**Presets:**
- **All Fields** - Select everything
- **Essential** - Name, Email, Phone, Company
- **Professional** - Name, Title, Company, Email, Phone, Website
- **Custom** - Manual selection

**[Image: CSV field selection]**

**Step 4: Preview (Optional)**
1. Tap **Preview** to see export output
2. First 5 rows displayed
3. Verify formatting
4. Tap **Back** to change fields or **Export** to continue

**[Image: CSV preview]**

**Step 5: Share**
Same share sheet as single contact.

### Export File Names

**Single Contact:**
- vCard: `John Doe.vcf`
- CSV: `John Doe.csv`

**Multiple Contacts:**
- vCard: `Deets Export - 25 contacts - 2025-11-05.vcf`
- CSV: `Deets Export - 25 contacts - 2025-11-05.csv`

**All Contacts:**
- vCard: `Deets Export - All Contacts - 2025-11-05.vcf`
- CSV: `Deets Export - All Contacts - 2025-11-05.csv`

### Importing Exported Files

**On iPhone/iPad:**
1. Open exported .vcf file (from Files, Mail, Messages)
2. Tap **Add All [N] Contacts**
3. Contacts import to iOS Contacts app

**On Mac:**
1. Double-click .vcf file
2. Contacts app opens
3. Contacts import automatically

**In Gmail:**
1. Gmail → Contacts → **Import**
2. Upload CSV or vCard file
3. Map fields if needed
4. Tap **Import**

**In Excel/Google Sheets:**
1. File → **Import** or **Open**
2. Select CSV file
3. Verify encoding: **UTF-8**
4. Import complete

### Export Troubleshooting

**Export fails:**
- Check available storage space
- Try exporting smaller batches
- See [TROUBLESHOOTING.md - Export Problems](TROUBLESHOOTING.md#export-problems)

**Imported contacts have garbled text:**
- Encoding issue - ensure app uses **UTF-8**
- Try vCard format instead of CSV

**Can't share exported file:**
- Check network connection (for AirDrop/iCloud)
- Ensure recipient's AirDrop is enabled
- Try saving to Files first, then share

---

## Syncing with iCloud

### What is iCloud Sync?

iCloud sync keeps your Deets contacts synchronized across all your Apple devices:
- iPhone
- iPad
- Mac (if Deets has Mac version)

**How It Works:**
- Contacts are stored in **iCloud Drive**
- Changes sync automatically in background
- End-to-end **encrypted** for privacy
- Works over **Wi-Fi or cellular data**

### Enabling iCloud Sync

**Requirements:**
- Signed into iCloud (Settings → [Your Name])
- iCloud Drive enabled (Settings → [Your Name] → iCloud → iCloud Drive)
- Available iCloud storage space

**Enable in Deets:**
1. Open Deets → **Settings** (gear icon)
2. Scroll to **Sync**
3. Toggle **iCloud Sync** ON
4. Tap **Sync Now** to start initial sync

**[Image: iCloud sync settings]**

**First Sync:**
- May take 1-5 minutes depending on contact count
- Status indicator shows progress
- Keep app open during first sync
- Subsequent syncs happen automatically

### How Sync Works

**Automatic Sync Triggers:**
- When you save a new contact
- When you edit an existing contact
- When you delete a contact
- Every 15 minutes (background)
- When app opens (if changes detected)

**Sync Status Indicators:**
- ☁️ **Cloud icon** - Sync enabled
- ↻ **Spinning arrows** - Sync in progress
- ✓ **Checkmark** - Sync complete
- ⚠️ **Warning icon** - Sync error

**Last Sync Time:**
- Settings → Sync → Shows "Last sync: 2 minutes ago"

### Managing Sync Conflicts

**What is a Sync Conflict?**
When the same contact is edited on two devices before syncing, Deets must decide which version to keep.

**Conflict Resolution:**

**Option 1: Automatic (Default)**
- Most recent edit wins
- Older version discarded
- Works well for most users

**Option 2: Manual**
1. Sync conflict alert appears
2. Shows both versions side-by-side
3. You choose which to keep:
   - **Keep iPhone version**
   - **Keep iCloud version**
   - **Merge changes**

**[Image: Sync conflict resolution screen]**

**Preventing Conflicts:**
- Let sync complete before editing on different device
- Check "Last sync" time before major edits
- Use "Sync Now" button before switching devices

### Disabling iCloud Sync

**To Disable:**
1. Settings → Sync
2. Toggle **iCloud Sync** OFF
3. Choose what happens to synced data:
   - **Keep local copy** - Contacts remain on this device
   - **Delete local copy** - Removes all contacts (⚠️ warning shown)

**Warning:** Disabling sync does NOT delete contacts from iCloud or other devices - only affects this device.

### iCloud Storage Management

**Check iCloud Usage:**
1. Settings → [Your Name] → iCloud
2. Tap **Manage Account Storage**
3. Find **Deets** in app list
4. Note storage used

**Expected Storage:**
- ~1-10 KB per contact (without photo)
- ~50-200 KB per contact (with photo)
- 100 contacts ≈ 1-20 MB
- 1000 contacts ≈ 10-200 MB

**Free Storage:**
If iCloud storage is full:
1. Delete old iCloud backups
2. Delete photos/videos from iCloud Photos
3. Upgrade iCloud storage plan
4. Or disable photo sync in Deets (keeps text data only)

### Sync Troubleshooting

See [TROUBLESHOOTING.md - Sync Issues](TROUBLESHOOTING.md#sync-issues) for:
- iCloud sync not working
- Duplicate contacts created
- Sync conflicts
- Network errors

---

## Search & Organization

### Searching Contacts

**Basic Search:**
1. Pull down on contact list to reveal **search bar**
2. Type any text (name, company, email, phone)
3. Results filter in real-time
4. Tap **X** to clear search

**[Image: Search bar with results]**

**Searchable Fields:**
- Full name (first, last, middle)
- Company name
- Job title
- Email address
- Phone number
- Website URL
- Address
- Notes

**Search Tips:**
- **Partial matches** - Type "Joh" finds "John," "Johnson," etc.
- **Case insensitive** - "apple" finds "Apple Inc."
- **Multi-word** - "John Apple" finds "John Doe" at "Apple Inc."
- **Email search** - Type "@gmail" finds all Gmail contacts

### Filtering Contacts

**Filter Options:**

**By Favorite Status:**
1. Tap **filter icon** (funnel, top right)
2. Select **Favorites Only**
3. List shows only starred contacts
4. Tap **All Contacts** to clear

**By Company** (Future):
1. Filter menu → **Group by Company**
2. Select company from list
3. Shows all contacts at that company

**By Tag** (Future):
1. Filter menu → **Filter by Tag**
2. Select tag (Client, Lead, Partner, etc.)
3. Shows tagged contacts

**By Date Added:**
1. Sort menu → **Recently Added**
2. Newest contacts appear first

**By Last Modified:**
1. Sort menu → **Recently Updated**
2. Recently edited contacts appear first

### Sorting Contacts

**Sort Options:**

Tap **sort icon** (A-Z) in toolbar:

1. **Alphabetical (A-Z)** - Default, by last name
2. **Alphabetical (Z-A)** - Reverse order
3. **Recently Added** - Newest first
4. **Recently Modified** - Last edited first
5. **Company Name** - Sort by organization
6. **Favorite First** - Starred contacts on top

**Default Sort:** Alphabetical by last name (customizable in Settings)

### Grouping Contacts (Future)

Coming in v1.1:

**Group by Company:**
- Contacts grouped under company headers
- Collapsible sections
- Count badge showing contacts per company

**Group by Tag:**
- Custom tag-based organization
- Multiple tags per contact

**Group by First Letter:**
- Alphabetical sections (A, B, C...)
- Fast scroll index on right edge

---

## Settings & Preferences

### Accessing Settings

**From Main Screen:**
1. Tap **gear icon** (top right)
2. **Or** tap **...** menu → **Settings**

### Settings Categories

**Account & Sync:**
- **iCloud Sync** - Toggle on/off
- **Sync Now** - Manual sync trigger
- **Last Sync Time** - Timestamp of last successful sync
- **Sync Status** - Idle, Syncing, Error

**Contacts:**
- **Default Save Location** - Deets only, Contacts only, or Both
- **Check for Duplicates** - Enable/disable duplicate detection
- **Auto-Link Contacts** - Automatically merge detected duplicates
- **Default Account** - Which Contacts account to save to (iCloud, Exchange, etc.)

**Scanning:**
- **OCR Language** - English (more languages in future)
- **Auto-Enhance Images** - Apply filters before OCR
- **Confidence Threshold** - Minimum OCR confidence (70% default)
- **Haptic Feedback** - Enable/disable vibration on scan
- **Save Photos** - Keep original business card photos

**Export:**
- **Default Export Format** - vCard or CSV
- **Default CSV Fields** - Which fields to include by default
- **Auto-Open After Export** - Open exported file immediately

**Appearance:**
- **Theme** - Light, Dark, or System
- **Accent Color** - Teal (default) or custom
- **Contact Photo Shape** - Circle or Square
- **List Density** - Compact or Comfortable
- **Reduce Motion** - Disable animations (accessibility)

**Privacy:**
- **Photo Access** - Review/change Photos permission
- **Contacts Access** - Review/change Contacts permission
- **Analytics** - Share crash reports (opt-in)
- **View Privacy Policy** - Opens privacy policy document

**Advanced:**
- **Clear Cache** - Free up storage space
- **Reset Sync Status** - Force re-sync from iCloud
- **Export All Data** - Backup everything
- **Delete All Contacts** - Nuclear option (⚠️ requires confirmation)

**About:**
- **Version** - App version number
- **Build** - Build number
- **Licenses** - Open source licenses
- **Support** - Link to documentation and GitHub
- **Rate App** - Link to App Store

**[Image: Settings screen]**

### Customizing Defaults

**Change Default Save Behavior:**
1. Settings → Contacts → **Default Save Location**
2. Choose:
   - **Deets Only** - Saves to app database only
   - **Contacts Only** - Saves to iOS Contacts only
   - **Both** - Saves to app and Contacts (recommended)

**Change Default Export Format:**
1. Settings → Export → **Default Export Format**
2. Choose vCard or CSV
3. Future exports use this format by default

**Change Appearance:**
1. Settings → Appearance → **Theme**
2. Choose Light, Dark, or **System** (follows iOS setting)

### Privacy Settings

**Review Permissions:**
1. Settings → Privacy
2. See granted permissions:
   - Camera - Required for scanning
   - Contacts - Optional, for saving to iOS Contacts
   - Photos - Optional, for photo enrichment

**Change Permission:**
1. Tap permission row
2. Opens iOS Settings app
3. Change access level
4. Return to Deets - takes effect immediately

**Data Collection:**
Deets collects:
- ✅ **Crash reports** (if opted in) - Helps fix bugs
- ❌ **NO analytics** - We don't track usage
- ❌ **NO advertising data** - No ads, ever
- ❌ **NO contact data** - Never uploaded to servers

See full privacy policy: [Privacy/privacy-policy.md](Privacy/privacy-policy.md)

---

## Privacy & Security

### What Data Does Deets Collect?

**Short Answer:** Only what you explicitly give permission for, and it never leaves your device (except iCloud sync).

**Detailed Answer:**

**Data Stored Locally:**
- Business card contact information (name, email, phone, etc.)
- Contact photos (if you add them)
- Scan history (date scanned, date modified)
- User preferences (settings, favorites)

**Data Stored in iCloud** (if sync enabled):
- Same as local data
- End-to-end encrypted
- Only accessible by you

**Data NEVER Collected:**
- Your contacts outside Deets
- Your full photo library
- Your location
- Your usage patterns
- Your identity/account info (we don't have accounts)

### Permissions Explained

**Camera Permission:**
- **Why needed:** To scan business cards
- **What we access:** Live camera feed during scanning only
- **What we store:** Only the final captured image (if "Save Photos" enabled)

**Contacts Permission:**
- **Why needed:** To save scanned cards to iOS Contacts
- **What we access:** Only contacts you save from Deets
- **What we store:** Copy of contact in Deets database

**Photos Permission:**
- **Why needed:** Photo enrichment feature
- **What we access:**
  - **All Photos:** Can search entire library for matches
  - **Selected Photos:** Only photos you explicitly choose
- **What we store:** Only the selected contact photo

### Data Security

**On-Device Encryption:**
- SwiftData database is encrypted at rest (iOS file protection)
- Photos stored in app sandbox (inaccessible to other apps)
- No plaintext passwords or sensitive data

**iCloud Encryption:**
- End-to-end encryption for synced data
- Apple cannot decrypt your data
- Only accessible from your iCloud-signed devices

**No Server Upload:**
- Deets has **no servers**
- No data leaves your device except:
  - iCloud sync (encrypted)
  - Exports you manually share

**Third-Party Access:**
- **Zero third-party SDKs** for analytics/tracking
- **Zero advertising networks**
- **Zero data brokers**

### Deleting Your Data

**Delete from Deets:**
1. Settings → Advanced → **Delete All Contacts**
2. Confirm action
3. All local data erased

**Delete from iCloud:**
1. Disable iCloud Sync
2. Settings → iCloud → Manage Storage → Deets → **Delete Documents & Data**

**Delete from iOS Contacts:**
1. Open Contacts app
2. Manually delete contacts saved from Deets
3. Or: Contacts → Groups → Deselect all → Reselect (clean slate)

**Complete Uninstall:**
1. Delete app from iPhone (long-press icon → Remove App)
2. All local data is erased
3. iCloud data remains (must delete separately)

### Privacy Policy

Full privacy policy available at:
- In-app: Settings → Privacy → **View Privacy Policy**
- Repository: [Privacy/privacy-policy.md](Privacy/privacy-policy.md)

**Summary:**
- We don't collect personal data
- We don't sell your data
- We don't track you
- Your contacts stay on your device
- You can delete everything anytime

### Security Best Practices

**Protect Your Device:**
- Use Face ID/Touch ID/passcode
- Enable automatic lock (Settings → Display & Brightness → Auto-Lock)
- Don't jailbreak your iPhone (disables security protections)

**Protect Your iCloud:**
- Use strong Apple ID password
- Enable two-factor authentication
- Don't share Apple ID with others

**When Sharing Contacts:**
- Review exported data before sharing
- Redact sensitive information if needed
- Use secure sharing methods (encrypted email, AirDrop)
- Don't post business card exports publicly

---

## Tips & Best Practices

### Scanning Tips

**Before Scanning:**
- ✅ Clean your camera lens
- ✅ Find good lighting (natural light best)
- ✅ Place card on contrasting background
- ✅ Flatten any bent corners

**During Scanning:**
- ✅ Hold steady - use table surface if shaky
- ✅ Fill 70-80% of frame with card
- ✅ Wait for text highlights to stabilize
- ✅ Capture when most text is highlighted

**After Scanning:**
- ✅ Review ALL fields before saving
- ✅ Fix common OCR mistakes (0 vs O, 1 vs l)
- ✅ Add notes about where/when you met
- ✅ Star important contacts immediately

### Organization Tips

**Use Favorites Strategically:**
- Star current clients/leads
- Unstar when project completes
- Keeps favorite list manageable (< 20 contacts)

**Add Detailed Notes:**
When you scan a card, immediately add:
- Where you met (conference, meeting, event)
- Date of meeting
- Topics discussed
- Follow-up actions
- Personal details (hobbies, interests)

**Regular Exports:**
- Export all contacts monthly as backup
- Save to cloud storage (Google Drive, Dropbox)
- Protects against device loss

**Keep Contacts Updated:**
- When someone changes jobs, update their card
- Remove old/outdated contacts annually
- Merge duplicates when detected

### Productivity Tips

**Keyboard Shortcuts** (iPad with keyboard):
- ⌘N - Start new scan
- ⌘F - Focus search
- ⌘R - Refresh list
- ⌘, - Open settings
- Delete - Delete selected contact

**Batch Scanning:**
After a conference or networking event:
1. Collect all business cards
2. Find good lighting and flat surface
3. Scan all cards in one session (faster than spread out)
4. Review and add notes while conversation is fresh

**Quick Save Workflow:**
1. Scan card
2. Quick review (5 seconds)
3. Tap "Save to Both"
4. Immediately star if important
5. Add note within 1 hour (while you remember)

**Contact Follow-Up:**
After saving a contact:
1. Send LinkedIn connection request
2. Send "Nice to meet you" email within 24 hours
3. Add calendar reminder for follow-up (1 week, 1 month)
4. Reference notes when reaching out

### Common Mistakes to Avoid

**❌ Don't:**
- Scan in low light or with shadows
- Save without reviewing fields
- Forget to add notes (you'll forget context later)
- Let cards pile up (scan promptly)
- Ignore duplicate warnings (creates clutter)

**✅ Do:**
- Review every field before saving
- Add contextual notes immediately
- Star important contacts right away
- Enable iCloud sync (backup protection)
- Export monthly backups

### Advanced Workflows

**CRM Integration** (Future):
1. Export contacts as CSV
2. Import into CRM (Salesforce, HubSpot, etc.)
3. Map Deets fields to CRM fields
4. Maintain sync workflow

**Email Marketing:**
1. Export contacts as CSV
2. Filter for clients/leads only
3. Import email addresses into MailChimp/Constant Contact
4. Segment by tags/notes

**Sales Pipeline:**
1. Add notes: "Lead - Hot," "Lead - Warm," "Lead - Cold"
2. Filter by note content
3. Export warm leads to CSV
4. Track in sales tool

**Event Management:**
After conferences:
1. Tag all contacts with event name in notes
2. Search by event name to find all attendees
3. Bulk export for follow-up campaign
4. Track conversion from event

---

## FAQ

### General Questions

**Q: Is Deets free?**
A: Current version is open-source and free. Future App Store version pricing TBD.

**Q: Does Deets work offline?**
A: Yes! Scanning, saving, and viewing work offline. Only iCloud sync requires internet.

**Q: How many contacts can I save?**
A: No hard limit. Tested with 5,000+ contacts. Performance may degrade with 10,000+.

**Q: Does Deets work on iPad?**
A: Yes! Universal iOS app. Optimized for both iPhone and iPad.

**Q: Does Deets work on Mac?**
A: Not yet. iOS/iPadOS only. Mac version possible in future.

**Q: Can I use Deets on Android?**
A: No. iOS-only app using Apple frameworks (VisionKit, SwiftData).

### Scanning Questions

**Q: Why doesn't OCR detect text on my card?**
A: Common causes:
- Poor lighting
- Card too small in frame
- Glossy card with glare
- Faded or low-contrast text
See [TROUBLESHOOTING.md - OCR Not Detecting Text](TROUBLESHOOTING.md#ocr-not-detecting-text)

**Q: Can I scan cards in other languages?**
A: v1.0 supports **English only**. Multi-language coming in v1.1.

**Q: Can I scan QR codes on business cards?**
A: Not yet. Use iPhone Camera app for QR codes. Feature planned for future.

**Q: Can I scan multiple cards at once?**
A: Not yet. Batch scanning (multiple cards in one session) coming in v1.1.

**Q: Why is OCR accuracy poor on my cards?**
A: OCR accuracy depends on:
- Card design (font, contrast, layout)
- Lighting quality
- Camera steadiness
- Text language (English only currently)
Accuracy typically 85-95% on standard business cards.

### Data & Sync Questions

**Q: Where is my data stored?**
A: Locally in SwiftData database on your device. Optionally synced to iCloud (encrypted).

**Q: Can I access Deets data from a computer?**
A: Not directly. Export contacts as vCard/CSV, then open on computer.

**Q: What happens if I lose my phone?**
A: If iCloud sync was enabled, contacts are safe in iCloud. Sign into new device and sync. If sync was disabled and no backup, data is lost.

**Q: How do I backup my contacts?**
A: Three ways:
1. Enable iCloud sync (automatic backup)
2. Export all contacts as vCard/CSV monthly
3. Save to iOS Contacts (backed up in iCloud/iTunes)

**Q: Can I import contacts from other apps?**
A: Yes! Import vCard (.vcf) files:
1. Share .vcf file to Deets
2. Deets imports contacts

### Privacy Questions

**Q: Does Deets upload my contacts?**
A: **No.** Deets has no servers. Data stays on-device (or encrypted in iCloud if sync enabled).

**Q: Can you see my contacts?**
A: **No.** We (developers) have zero access to your data.

**Q: Does Deets sell my data?**
A: **No.** No data collection = nothing to sell.

**Q: Does Deets have ads?**
A: **No.** No ads, no tracking, no data collection.

**Q: Is my data encrypted?**
A: Yes. iOS encrypts all app data at rest. iCloud sync uses end-to-end encryption.

### Feature Questions

**Q: Can I add custom fields?**
A: Not yet. Custom fields planned for v1.1.

**Q: Can I add tags to contacts?**
A: Not yet. Tagging system planned for v1.1.

**Q: Can I export to Google Contacts?**
A: Export as vCard or CSV, then import into Google Contacts manually.

**Q: Can I export to Salesforce/HubSpot?**
A: Export as CSV, then import into your CRM. Direct integration planned for future.

**Q: Can I scan receipts or documents?**
A: No. Deets is optimized for business cards only. Use Apple Notes scan feature for documents.

**Q: Can I scan ID cards or drivers licenses?**
A: Not recommended. Deets is designed for business cards, not identity documents.

### Troubleshooting Questions

**Q: Why did my app crash?**
A: See [TROUBLESHOOTING.md - Crashes on Launch](TROUBLESHOOTING.md#crashes-on-launch)

**Q: Why can't I save to Contacts?**
A: Check Contacts permission: Settings → Deets → Contacts → **Read and Write**

**Q: Why isn't iCloud sync working?**
A: See [TROUBLESHOOTING.md - iCloud Sync Not Working](TROUBLESHOOTING.md#icloud-sync-not-working)

**Q: How do I report a bug?**
A: Open GitHub issue: [github.com/yourusername/Deets/issues](https://github.com/yourusername/Deets/issues)

**Q: How do I request a feature?**
A: Open GitHub discussion: [github.com/yourusername/Deets/discussions](https://github.com/yourusername/Deets/discussions)

---

## Additional Resources

### Documentation

- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Quick setup guide (5 minutes)
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solutions to common problems
- **[README.md](README.md)** - Project overview and technical details
- **[Documentation/](Documentation/)** - Developer documentation

### Support

- **GitHub Issues:** Bug reports and feature requests
- **GitHub Discussions:** Q&A and community help
- **Email:** support@deets.app *(if available)*

### Privacy & Legal

- **[Privacy/privacy-policy.md](Privacy/privacy-policy.md)** - Full privacy policy
- **[Privacy/data-handling-guide.md](Privacy/data-handling-guide.md)** - How we handle data
- **Terms of Service:** [Privacy/policy.md](Privacy/policy.md)

### Community

- **Twitter:** #DeetsApp
- **Reddit:** r/DeetsApp *(if exists)*
- **Blog:** *(if exists)*

---

## Version History

**v1.0.0** (Current)
- Initial release
- Business card scanning with VisionKit OCR
- iOS Contacts integration
- iCloud sync
- vCard and CSV export
- Photo enrichment
- Search and favorites

**Upcoming - v1.1**
- Multi-language OCR
- Batch scanning
- QR code detection
- Custom fields and tags
- Enhanced duplicate detection
- Mac version (planned)

---

## Credits

**Built With:**
- SwiftUI - User interface
- SwiftData - Data persistence
- VisionKit - OCR and text recognition
- Contacts Framework - iOS Contacts integration
- PhotoKit - Photo library access

**Developed By:**
- [Your Name/Team]

**Special Thanks:**
- Apple Developer Documentation
- SwiftUI community
- Beta testers

---

## Get Started

Ready to digitize your business cards?

👉 **[Jump to Getting Started Guide](GETTING_STARTED.md)**

Or jump to a specific section:
- [Scan your first card](#scanning-business-cards)
- [Export contacts](#exporting-contacts)
- [Enable iCloud sync](#syncing-with-icloud)
- [Troubleshoot issues](TROUBLESHOOTING.md)

---

**Happy Scanning! 📇**

*Last updated: 2025-11-05*
*Version: 1.0*
