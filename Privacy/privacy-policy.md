# Deets Privacy Policy

**Last Updated**: November 5, 2025
**Effective Date**: November 5, 2025

---

## Our Commitment to Privacy

Deets is designed with privacy as a core principle. We believe your business card data belongs to you, and you alone should control how it's used, stored, and shared.

**Our Promise:**
- We don't collect, store, or transmit your data to our servers
- We don't use third-party analytics or tracking
- We don't show ads or sell your data
- All processing happens on your device
- You control all exports and integrations

---

## What Data We Collect

### Data You Provide

When you use Deets, you create the following data:

1. **Business Card Photos**: Images captured using your device's camera
2. **Contact Information**: Text extracted from scanned cards (names, emails, phone numbers, addresses, etc.)
3. **App Settings**: Your preferences for how the app works
4. **Optional Notes**: Any notes you add to saved contacts

**Where This Data Lives:**
- **On Your Device**: All data is stored locally in the app's sandboxed storage
- **In iCloud (Optional)**: Only if you enable iCloud sync in Settings
- **In Apple Contacts (Optional)**: Only if you export contacts

### Data We Never Collect

- Usage analytics or telemetry
- Device identifiers for tracking
- Location data
- Crash reports (unless you explicitly send via iOS)
- Any data for advertising purposes

---

## How We Use Your Data

Your data is used **only** for the following purposes:

1. **Display Your Contacts**: Show scanned business cards in the app
2. **Search and Filter**: Help you find contacts quickly
3. **Export**: Allow you to export to Apple Contacts, VCF, or CSV (when you choose)
4. **Sync (Optional)**: Sync across your devices via iCloud (only if enabled)

**We never:**
- Send your data to our servers
- Share your data with third parties
- Use your data for marketing or analytics
- Process your data in the cloud

---

## How We Process Your Data

### On-Device Processing

All business card scanning and text recognition happens **entirely on your device** using Apple's VisionKit framework:

1. You capture a photo of a business card
2. VisionKit (Apple's framework) recognizes text **on your device**
3. Our app parses the text into contact fields **on your device**
4. The contact is saved to **your device's local storage**

**No cloud processing. No external APIs. No server uploads.**

### Photo Storage

Business card photos are stored in the app's **Documents directory** on your device:

- **Location**: `Documents/BusinessCards/{contactID}.jpg`
- **Accessible**: You can access these files via iOS Files app
- **Compressed**: JPEG format (quality 0.8) to save space
- **Secure**: Protected by iOS app sandboxing

### Database Storage

Contact data is stored using **SwiftData**, Apple's modern persistence framework:

- **Location**: App's local database on your device
- **Encrypted**: iOS automatically encrypts app data at rest
- **Private**: Not accessible to other apps
- **Portable**: You can export all contacts at any time

---

## Data Sharing and Exports

### You Control All Sharing

Deets **never** shares your data without your explicit action. You control when and how data leaves the app:

1. **Export to Apple Contacts**: When you tap "Export to Contacts", we request Contacts permission and save to your device's Contacts app
2. **Export to VCF**: When you choose "Export to VCF", we create a vCard file that you can share via iOS ShareSheet
3. **Export to CSV**: When you choose "Export to CSV", we create a CSV file that you can share via iOS ShareSheet
4. **iCloud Sync (Optional)**: If you enable iCloud sync, SwiftData syncs your contacts to your iCloud account (encrypted by Apple)

**In all cases, you initiate the sharing. We never automatically send data anywhere.**

---

## Permissions We Request

Deets requests the following iOS permissions, **only when needed**:

### Camera Permission
- **When**: You tap "Scan Card" for the first time
- **Why**: To capture business card photos
- **Usage**: Only used for scanning, never for background access
- **Framework**: iOS Camera, VisionKit

### Contacts Permission
- **When**: You tap "Export to Contacts" for the first time
- **Why**: To save business cards to your Apple Contacts
- **Usage**: Only writes contacts you explicitly export, never reads existing contacts
- **Framework**: iOS Contacts framework

### Photo Library Permission (Add Only)
- **When**: You choose to save a business card photo to your Photos app
- **Why**: To save the image to your photo library
- **Usage**: Write-only access, we never read your existing photos
- **Framework**: iOS PhotoKit

**We never request:**
- Location access
- Microphone access
- Full photo library access (read)
- Background app refresh for data collection
- Notifications for marketing

---

## iCloud Sync (Optional)

You can optionally enable iCloud sync to keep your contacts synchronized across your devices (iPhone, iPad, Mac).

### How iCloud Sync Works

- **Enable**: Settings → Privacy → Enable iCloud Sync
- **What Syncs**: All business card data and photos
- **Encryption**: Encrypted by Apple during transmission and storage
- **Who Can Access**: Only you, via your iCloud account
- **Disable Anytime**: Turn off sync in Settings → data remains on your device

### iCloud Privacy

When you enable iCloud sync:
- Data is encrypted by Apple using your iCloud encryption keys
- We (Deets developers) **cannot** access your iCloud data
- Apple handles all sync operations via CloudKit
- Data is subject to [Apple's iCloud Privacy Policy](https://www.apple.com/legal/privacy/)

**Default**: iCloud sync is **disabled** by default. You must explicitly enable it.

---

## Data Security

### How We Protect Your Data

1. **Local Storage**: All data stored in iOS app sandbox (protected by iOS security)
2. **Encryption at Rest**: iOS automatically encrypts app data when device is locked
3. **No Cloud Transmission**: Data never leaves your device unless you export it
4. **Secure Deletion**: When you delete a contact, we overwrite the photo file before deletion
5. **No Third-Party SDKs**: Zero third-party dependencies that could compromise privacy

### What You Can Do

- **Enable Device Passcode**: Protects app data with device encryption
- **Use Face ID/Touch ID**: Adds biometric protection
- **Keep iOS Updated**: Ensures you have latest security patches
- **Review Permissions**: Settings → Deets → check what permissions are granted

---

## Data Retention and Deletion

### How Long We Keep Data

**On Your Device**: Forever, or until you delete it
**In iCloud (if enabled)**: Forever, or until you delete it or disable sync

### How to Delete Your Data

**Delete Individual Contacts**:
1. Open contact in Deets
2. Tap "Delete"
3. Contact and photo are permanently deleted from device

**Delete All Data**:
1. Delete the Deets app from your device
2. All local data is automatically removed
3. If iCloud sync was enabled, delete from iCloud: Settings → iCloud → Manage Storage → Deets → Delete

**Export Before Deleting**:
If you want to keep your data, export to VCF or CSV before deleting the app.

---

## Third-Party Services

### We Use Zero Third-Party Services

Deets does not integrate with any third-party services for:
- Analytics (no Google Analytics, no Mixpanel, etc.)
- Crash reporting (unless you manually send via iOS Feedback)
- Advertising (no ads, no ad networks)
- Cloud storage (except Apple iCloud, if you enable it)
- Social login (no Facebook, Google, etc.)

### Apple Frameworks Only

We use only Apple's native frameworks:
- **VisionKit**: For document scanning and OCR (on-device)
- **SwiftData**: For local database (on-device)
- **Contacts**: For export to Apple Contacts (on-device)
- **PhotoKit**: For photo library access (on-device)
- **CloudKit**: For iCloud sync (only if you enable it)

All processing happens on your device or in your iCloud account.

---

## Children's Privacy

Deets is not directed at children under 13. We do not knowingly collect data from children. If you are under 13, please do not use this app.

---

## Changes to This Policy

We may update this privacy policy from time to time. Changes will be posted in the app and on our website.

**How We Notify You:**
- In-app notification when policy updates
- Updated "Last Modified" date at top of policy
- Major changes will require re-acceptance

**Your Rights:**
If you don't agree with policy changes, you can stop using the app and delete your data.

---

## Your Rights

You have the following rights regarding your data:

1. **Access**: View all your data in the app
2. **Export**: Export all contacts to VCF or CSV at any time
3. **Delete**: Delete individual contacts or all data
4. **Control**: Enable/disable iCloud sync, permissions, exports
5. **Portability**: Take your data with you (VCF format is universal)

**No Account, No Problem**: Since we don't have user accounts, you don't need to request data deletion from us. Just delete the app.

---

## Contact Us

If you have questions about this privacy policy or how we handle data:

**Email**: privacy@deets.app
**GitHub**: [github.com/yourusername/deets/issues](https://github.com/yourusername/deets/issues)

We'll respond within 7 business days.

---

## Legal

### California Privacy Rights (CCPA)

If you're a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):

- **Right to Know**: What data we collect (see "What Data We Collect" above)
- **Right to Delete**: Delete your data (see "Data Retention and Deletion" above)
- **Right to Opt-Out**: We don't sell data, so no opt-out needed
- **Right to Non-Discrimination**: We don't charge different prices based on privacy choices

**How to Exercise Rights**: Just use the app's built-in delete and export features.

### European Privacy Rights (GDPR)

If you're in the EU/EEA, you have rights under the General Data Protection Regulation (GDPR):

- **Data Controller**: You are the data controller (it's your data on your device)
- **Legal Basis**: Your consent when using the app
- **Right to Access**: View all data in the app
- **Right to Rectification**: Edit contacts in the app
- **Right to Erasure**: Delete contacts or app
- **Right to Portability**: Export to VCF or CSV

**How to Exercise Rights**: Use the app's built-in features (no need to contact us).

---

## Summary (TL;DR)

- **We don't collect your data**: Everything stays on your device
- **No cloud processing**: All OCR happens locally via Apple's VisionKit
- **No tracking**: Zero analytics, no ads, no third parties
- **You control exports**: Only you can share data (Contacts, VCF, CSV)
- **iCloud is optional**: Sync only if you enable it
- **Easy deletion**: Delete contacts or app anytime
- **Open source**: Code is auditable (coming soon)

**Questions?** Email privacy@deets.app

---

**Version**: 1.0.0
**Last Updated**: November 5, 2025
**Effective Date**: November 5, 2025
