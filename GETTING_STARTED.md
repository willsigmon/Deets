# Getting Started with Deets

Welcome to Deets! This guide will have you scanning and managing business cards in under 5 minutes.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Setup](#quick-setup)
- [Your First Scan](#your-first-scan)
- [What's Next](#whats-next)
- [Need Help?](#need-help)

---

## Prerequisites

Before you begin, ensure you have:

- **iOS 16.0 or later** on your iPhone or iPad
- **Xcode 15.0+** (for development)
- **Swift 5.9+**
- **Physical iOS device** (camera scanning requires real hardware - won't work in Simulator)
- **Camera access** (you'll be prompted during first scan)

### Optional Requirements

- **Contacts access** - To save cards directly to your iOS Contacts
- **Photos access** - To discover and attach contact photos
- **iCloud account** - For optional sync across devices

---

## Quick Setup

### Option 1: Using XcodeGen (Recommended)

**Step 1: Clone the repository**
```bash
cd ~/Projects  # or your preferred directory
git clone https://github.com/yourusername/Deets.git
cd Deets
```

**Step 2: Install XcodeGen**
```bash
brew install xcodegen
```

**Step 3: Generate the Xcode project**
```bash
xcodegen generate
```

**Step 4: Open in Xcode**
```bash
open Deets.xcodeproj
```

**Step 5: Configure your development team**
1. In Xcode, select the `Deets` project in the navigator
2. Select the `Deets` target
3. Go to **Signing & Capabilities**
4. Select your **Team** from the dropdown
5. Xcode will automatically manage provisioning

**Step 6: Build and run**
1. Connect your iOS device via USB
2. Select your device from the device menu (top toolbar)
3. Press **⌘R** or click the **Run** button
4. Wait for the build to complete (~30-60 seconds)
5. The app will launch on your device

### Option 2: Manual Xcode Project

**Step 1: Clone the repository**
```bash
cd ~/Projects
git clone https://github.com/yourusername/Deets.git
```

**Step 2: Create a new Xcode project**
1. Open Xcode
2. File → New → Project
3. Select **iOS → App**
4. Product Name: `Deets`
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Minimum Deployment: **iOS 16.0**

**Step 3: Add project files**
1. Drag all files from the cloned `Deets/` folder into your Xcode project
2. Ensure **Copy items if needed** is checked
3. Create groups for organization (App, Models, Views, etc.)

**Step 4: Configure Info.plist**

Add these privacy permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>Deets needs camera access to scan business cards</string>

<key>NSContactsUsageDescription</key>
<string>Deets needs contacts access to save scanned business cards</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Deets can discover contact photos from your photo library</string>
```

**Step 5: Build and run** (same as Option 1, steps 5-6)

---

## Your First Scan

Congratulations! Deets is now running on your device. Let's scan your first business card.

### Step 1: Grant Camera Permission

When you first tap the **Scan** button:

1. iOS will ask: **"Deets Would Like to Access the Camera"**
2. Tap **Allow**
3. The camera viewfinder will appear

**[Image: Camera permission prompt]**

### Step 2: Position the Business Card

For best results:

- **Good lighting** - Natural light or bright indoor lighting works best
- **Flat surface** - Place card on a table or hold it steady
- **Fill the frame** - Get close enough that the card fills most of the screen
- **Minimal glare** - Avoid reflective surfaces or harsh overhead lights
- **Straight angle** - Hold your phone parallel to the card (not tilted)

**[Image: Proper card positioning]**

### Step 3: Scan the Card

1. Point your camera at the business card
2. Deets automatically detects and highlights text in **real-time**
3. When ready, tap the **Capture** button (camera icon)
4. The OCR engine processes the text (takes 1-2 seconds)

**[Image: Scanning in progress]**

### Step 4: Review & Edit

The **Contact Preview** screen appears showing extracted information:

- **Name** - Person's full name
- **Job Title** - Their position/role
- **Company** - Organization name
- **Email** - Email address(es)
- **Phone** - Phone number(s)
- **Website** - Company or personal website
- **Address** - Business address

**What to check:**

✅ **Verify accuracy** - OCR is 90%+ accurate but can make mistakes
✅ **Fix any errors** - Tap any field to edit
✅ **Add missing info** - Fill in any blank fields
✅ **Delete incorrect data** - Clear fields that were misread

**[Image: Contact preview screen]**

### Step 5: Save the Contact

You have three options:

1. **Save to Deets Only** - Stores in the app's local database
2. **Save to Contacts** - Adds to iOS Contacts app
3. **Save to Both** ⭐ **(Recommended)** - Maximum accessibility

Tap **Save to Both** for the best experience.

**[Image: Save options]**

### Step 6: Success!

You'll see a confirmation message and haptic feedback. The contact now appears in:

- **Deets app** → Main list view
- **iOS Contacts** (if saved there)

**[Image: Success confirmation]**

---

## What's Next?

Now that you've scanned your first card, explore these features:

### 📋 View Your Cards

- **Main screen** shows all saved cards
- **Search** by name, company, or any field
- **Filter** by favorites or recently added
- **Sort** alphabetically or by date

**Quick tip:** Pull down to refresh the list

### ⭐ Mark Favorites

Tap the **star icon** on any card to mark it as a favorite. Access favorites quickly via the filter menu.

### 📤 Export Contacts

Export your business cards in multiple formats:

1. Tap a card to view details
2. Tap the **Export** button (share icon)
3. Choose format:
   - **vCard (.vcf)** - Import into any contacts app
   - **CSV (.csv)** - Open in Excel, Google Sheets, etc.
4. Share via AirDrop, Messages, Email, or save to Files

**[Image: Export options screen]**

### 📸 Add Contact Photos

Deets can automatically find photos of your contacts:

1. Open a contact's detail view
2. Tap **Find Photo** (if available)
3. Grant Photos permission when prompted
4. Deets searches your photo library for matching faces
5. Select the best photo or crop as needed

**[Image: Photo selection screen]**

### ☁️ Sync with iCloud (Optional)

Enable iCloud sync to keep contacts across all your devices:

1. Go to **Settings** (gear icon)
2. Toggle **iCloud Sync** ON
3. Ensure you're signed into iCloud on your device
4. Contacts sync automatically in the background

**Note:** First sync may take a minute for large collections

### 🔍 Advanced Scanning Tips

**For low-quality cards:**
- Use the **brightness slider** in scan view
- Try the **contrast boost** toggle
- Scan in brighter lighting

**For business cards with logos:**
- Focus on the text areas
- The OCR engine filters out graphics automatically

**For multi-language cards:**
- Currently supports **English only**
- Multi-language support coming in v1.1

---

## Need Help?

### Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Camera not working | Check Settings → Deets → Camera is **ON** |
| Can't save to Contacts | Check Settings → Deets → Contacts is **ON** |
| OCR not detecting text | Improve lighting, flatten card, reduce glare |
| App crashes on scan | Update to latest iOS version, restart device |
| Sync not working | Check iCloud connection in Settings |

**See full troubleshooting guide:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Documentation Resources

- **[USER_GUIDE.md](USER_GUIDE.md)** - Complete feature guide for end users
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solutions to common issues
- **[README.md](README.md)** - Project overview and architecture
- **[Documentation/](Documentation/)** - Technical documentation for developers

### Get Support

- **GitHub Issues:** Report bugs or request features
- **Email Support:** support@deets.app *(if available)*
- **Privacy Policy:** [Privacy/privacy-policy.md](Privacy/privacy-policy.md)

### Community

- Share your experience on Twitter with **#DeetsApp**
- Contribute to the project on GitHub
- Suggest features in GitHub Discussions

---

## Keyboard Shortcuts (iPad)

| Shortcut | Action |
|----------|--------|
| **⌘N** | New scan |
| **⌘F** | Search contacts |
| **⌘,** | Open settings |
| **⌘R** | Refresh list |
| **Delete** | Delete selected contact |

---

## Next Steps

1. ✅ Complete your first scan
2. ⭐ Mark some favorites
3. 📤 Try exporting a contact
4. 📸 Add contact photos
5. ☁️ Enable iCloud sync
6. 📖 Read the [USER_GUIDE.md](USER_GUIDE.md) for advanced features

---

## Quick Reference Card

**Scan a card:** Main screen → **+** button → Point camera → Tap capture → Review → Save
**Search contacts:** Pull down → Type in search bar
**Export contact:** Tap card → **Share** icon → Choose format
**Add photo:** Tap card → **Find Photo** → Select from library
**Enable sync:** Settings → **iCloud Sync** → Toggle ON

---

**Welcome to Deets! Happy scanning! 📇**

*Last updated: 2025-11-05*
