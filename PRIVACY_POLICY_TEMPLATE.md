# Privacy Policy - Deets Business Card Scanner

**Last Updated**: [DATE]
**Effective Date**: [DATE]

---

## Introduction

Welcome to Deets, a business card scanning application for iOS. This Privacy Policy explains how Deets ("we", "our", or "the app") handles your information when you use our mobile application.

**TL;DR**: Deets processes everything on your device. We don't collect, store, or share your data with anyone. Period.

---

## Information We Collect

### 1. Business Card Data
When you scan a business card, Deets uses your device's camera and Apple's on-device Vision framework to extract:
- Names (first, middle, last, titles)
- Job titles and organization names
- Phone numbers
- Email addresses
- Physical addresses
- Websites and social media profiles

**How it's collected**: You initiate scanning by pointing your camera at a business card.
**Where it's stored**: Locally on your device using Apple's SwiftData framework.
**Third-party access**: None. Zero. Nada.

### 2. Photos
Deets may access photos from your library in two scenarios:
- **Scanning from library**: You choose an existing photo to scan instead of using the camera
- **Contact photo enrichment**: Optional feature that searches your photo library for photos matching a contact (requires explicit permission)

**How it's collected**: You grant photo library access and explicitly enable the feature.
**Where it's processed**: All photo processing happens on your device using Apple's Vision and PhotoKit frameworks.
**Third-party access**: None. Photos never leave your device.

### 3. App Settings & Preferences
Deets stores your app preferences locally, including:
- Feature toggles (e.g., haptic feedback on/off)
- iCloud sync enable/disable preference
- OCR language and confidence settings

**How it's collected**: You configure settings in the app.
**Where it's stored**: Locally in your device's app-specific storage (UserDefaults).
**Third-party access**: None.

---

## How We Use Your Information

### On-Device Processing Only
All business card scanning, text recognition (OCR), and photo processing happens **entirely on your device** using Apple's built-in frameworks:
- **VisionKit**: For live camera scanning
- **Vision Framework**: For text recognition
- **PhotoKit**: For photo library access
- **Contacts Framework**: For saving to Apple Contacts (with your permission)

**We do NOT**:
- Upload your data to any server
- Send your data to third-party services
- Use cloud processing or AI APIs
- Store your data outside your device (except iCloud, see below)

### Saving to Apple Contacts
When you tap "Save to Contacts", Deets asks for permission to access your Apple Contacts. If granted:
- The scanned contact data is saved to your Apple Contacts app
- This is handled by Apple's Contacts framework
- We do not retain any additional copies

You can delete these contacts anytime from the Apple Contacts app.

### Optional iCloud Sync
Deets offers optional iCloud sync for your scanned business cards:
- **Opt-in only**: Disabled by default, you must enable it in Settings
- **Apple's CloudKit**: Uses Apple's secure CloudKit framework (private database)
- **End-to-end encryption**: Your data is encrypted by Apple
- **Your iCloud account**: Synced only across your own devices signed into the same iCloud account
- **We cannot access your synced data**: It's in your private iCloud storage

To disable iCloud sync: Go to Deets Settings > iCloud Sync > Toggle Off

---

## Information We Do NOT Collect

Deets does NOT collect, store, or transmit:
- Device identifiers for tracking
- Location data
- Usage analytics or crash reports
- Advertising identifiers
- Browsing history
- Any data for profiling or targeting

**Zero tracking. Zero analytics. Zero ads.**

---

## Data Sharing & Third Parties

**We do not share your data with anyone.**

Deets does not:
- Sell your information
- Share data with advertisers
- Use third-party analytics services (e.g., Google Analytics, Facebook SDK)
- Integrate with marketing platforms
- Send data to any external servers

**Exception**: When you explicitly use export features (e.g., "Share via Email"), your device's standard iOS sharing mechanisms are used. This is controlled by iOS, not Deets.

---

## Data Storage & Security

### Local Storage
All scanned business cards are stored locally on your device using Apple's SwiftData framework. This data is:
- Encrypted by iOS automatically (when device is locked)
- Isolated to the Deets app sandbox
- Backed up to your iCloud backup (if you have iCloud Backup enabled in iOS settings)
- Deleted when you delete the app (unless backed up to iCloud)

### iCloud Storage (Optional)
If you enable iCloud sync:
- Data is stored in your private CloudKit database
- Encrypted in transit and at rest by Apple
- Accessible only to devices signed into your iCloud account
- Managed by Apple's security infrastructure

**We (Deets developers) cannot access your iCloud data.**

### Security Measures
- All processing happens on-device (no network transmission)
- Apple's security frameworks protect your data
- No server-side vulnerabilities (because there's no server)
- Regular security reviews of open-source dependencies

---

## Your Rights & Choices

### Data Access
You can view all your scanned business cards in the Deets app at any time.

### Data Deletion
To delete your data:
1. **Delete individual cards**: Swipe left in the card list
2. **Delete all app data**: iOS Settings > Deets > Reset App Data
3. **Delete the app**: Delete Deets from your device (removes all local data)
4. **Delete iCloud data**: Disable iCloud sync, then delete app (synced data may remain in iCloud for 30 days per Apple's policy)

### Permission Management
You can revoke permissions at any time:
- **Camera**: iOS Settings > Privacy > Camera > Deets (toggle off)
- **Photo Library**: iOS Settings > Privacy > Photos > Deets (toggle off)
- **Contacts**: iOS Settings > Privacy > Contacts > Deets (toggle off)

Deets will gracefully handle denied permissions and inform you which features require access.

### Export Your Data
You can export your scanned contacts at any time:
- **VCF (vCard)**: Standard contact format, compatible with all contact apps
- **CSV**: Spreadsheet format for Excel, Google Sheets, etc.
- **Apple Contacts**: Direct save to Apple Contacts app

---

## Children's Privacy

Deets does not knowingly collect data from children. The app:
- Does not require age verification (no accounts or login)
- Does not collect personal information beyond scanned business cards
- Is safe for users of all ages (rated 4+ on App Store)

If a parent or guardian believes a child has used Deets and wants data deleted, simply delete the app from the device.

---

## International Users & Data Transfers

**No data transfers occur** because all processing is on-device.

- **EU/GDPR**: Compliant. No data processing outside your device (except optional iCloud, controlled by Apple).
- **California/CCPA**: Compliant. We do not "sell" personal information (because we don't collect it in the first place).
- **Other Jurisdictions**: No data leaves your device, so local data protection laws apply to your device storage only.

### GDPR Rights (EU Users)
Under GDPR, you have the right to:
- **Access**: View your data in the Deets app
- **Rectification**: Edit scanned contacts in the app
- **Erasure**: Delete cards or the app
- **Data Portability**: Export to VCF or CSV
- **Objection**: Simply don't use the app or revoke permissions

Since we don't collect your data server-side, you have full control via the app itself.

---

## Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect:
- New features in the app
- Changes in privacy laws
- User feedback

When we make changes:
- The "Last Updated" date at the top will change
- If changes are material, we'll notify you in the app
- Continued use of the app after changes constitutes acceptance

**Version History**:
- v1.0 ([DATE]): Initial policy

---

## Third-Party Services

Deets uses **zero third-party services** for data processing. The only third parties involved are:

1. **Apple Inc.**
   - Frameworks: VisionKit, Vision, PhotoKit, Contacts, SwiftData, CloudKit
   - Purpose: Core iOS functionality
   - Privacy Policy: https://www.apple.com/legal/privacy/

2. **Your chosen export destinations** (optional)
   - When you use "Share" to export contacts (e.g., email, messaging apps)
   - Controlled by iOS standard sharing
   - Subject to those apps' privacy policies

---

## Contact Information & Questions

### Developer Contact
**App Developer**: [YOUR NAME/COMPANY]
**Email**: [YOUR EMAIL]
**Website**: [YOUR WEBSITE]

### Data Protection Officer (if applicable)
[DPO CONTACT INFO or "Not applicable for small businesses"]

### Questions or Concerns
If you have questions about this Privacy Policy or how Deets handles data:
- Email us at [YOUR EMAIL]
- Open an issue on GitHub (if app is open source): [GITHUB URL]
- Contact Apple Support for iCloud-related questions

### Complaints
EU users have the right to lodge a complaint with their local Data Protection Authority if they believe their data protection rights have been violated.

---

## Transparency Commitment

Deets is committed to radical transparency:
- **Open Source** (optional): [If app is open source, link to GitHub]
- **No tracking code**: You can verify this by reviewing our code or using network monitoring tools (you'll see zero network requests for analytics/tracking)
- **Privacy Manifest**: Deets includes an Apple Privacy Manifest file declaring all data usage (available in app bundle)

We built Deets with a "privacy-first" philosophy:
- ✅ On-device processing
- ✅ No servers
- ✅ No third-party SDKs
- ✅ No tracking
- ✅ No ads
- ✅ Optional iCloud sync (your control)

---

## Legal Basis for Processing (GDPR)

For EU users, our legal basis for processing personal data is:
- **Consent**: You explicitly grant camera, photo library, and contacts permissions
- **Legitimate Interest**: Processing scanned business card data is necessary for the app's core functionality (which you initiated)
- **Contract**: If you purchase the app or in-app purchases (if applicable)

You can withdraw consent at any time by revoking permissions in iOS Settings.

---

## Cookies & Tracking Technologies

**Deets does not use cookies, web beacons, or tracking technologies.**

The app is a native iOS application with no web views (except when displaying this privacy policy, if hosted on the web). No cookies are set by Deets.

---

## Data Retention

**Local Data**: Retained until you delete it (by deleting cards or the app).
**iCloud Data**: Retained until you disable sync and delete the app (Apple may retain for up to 30 days per their policy).
**No server retention**: Not applicable (we have no servers).

---

## Accessibility

This privacy policy is available:
- In the app (Settings > Privacy Policy)
- On our website: [URL]
- In plain language (we avoid legalese where possible)

If you need this policy in an alternative format (e.g., large print, audio), please contact us at [EMAIL].

---

## Automated Decision-Making

Deets does not use automated decision-making or profiling that produces legal effects or significantly affects you.

The only "automated" processing is:
- OCR text recognition (extracts text from images)
- Face detection (for photo cropping in enrichment feature)

These are standard image processing functions, not profiling or behavioral analysis.

---

## Summary (Plain Language)

**What Deets does**:
- Scans business cards using your camera
- Extracts text using your phone's built-in OCR
- Stores scanned contacts on your phone
- Optionally syncs to your iCloud (if you enable it)
- Saves to Apple Contacts (if you ask)

**What Deets does NOT do**:
- Track you
- Send data to servers
- Share data with anyone
- Sell your information
- Use analytics or ads

**Your control**:
- Grant or deny permissions anytime
- Delete data anytime
- Export data anytime
- Disable iCloud sync anytime

**Questions?** Email [YOUR EMAIL]

---

## Governing Law

This Privacy Policy is governed by the laws of [YOUR JURISDICTION, e.g., "California, USA" or "Germany"].

Any disputes will be resolved in the courts of [YOUR JURISDICTION].

---

## Acceptance of This Policy

By using Deets, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.

If you do not agree, please do not use the app.

---

**END OF PRIVACY POLICY**

---

## For Developers: How to Use This Template

1. Replace [PLACEHOLDERS] with your actual information:
   - [DATE] - Current date
   - [YOUR NAME/COMPANY] - Your legal entity
   - [YOUR EMAIL] - Support email
   - [YOUR WEBSITE] - Company website
   - [GITHUB URL] - If open source
   - [YOUR JURISDICTION] - Where you're based

2. Review all sections for accuracy:
   - Ensure features described match your app
   - Verify no additional third-party services were added
   - Confirm iCloud sync behavior is accurate

3. Host this policy publicly:
   - Website: https://yourdomain.com/privacy
   - GitHub Pages: If open source
   - App Store Connect: Link in app metadata

4. Add in-app link:
   - Settings > Privacy Policy button
   - Opens Safari/web view to hosted policy

5. Legal review (recommended):
   - Have a lawyer review if budget allows
   - Especially important if targeting EU or collecting payment info

6. Keep updated:
   - Update when adding features
   - Track changes in version history
   - Notify users of material changes

---

**This template is provided for reference and may require customization for your specific use case. Consult with a legal professional to ensure compliance with applicable laws.**
