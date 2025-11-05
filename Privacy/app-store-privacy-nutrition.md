# App Store Privacy Nutrition Label

**For Deets iOS App Submission**
**Last Updated:** November 5, 2025

## About This Document

This document provides the exact responses needed for Apple's App Store Privacy Nutrition Label questionnaire. Use these responses when submitting Deets to App Store Connect.

Apple's Privacy Nutrition Label helps users understand your app's privacy practices before downloading. Be accurate and complete—Apple may reject apps with misleading labels.

---

## Privacy Questionnaire Responses

### Section 1: Data Collection Overview

**Question:** Does your app collect data?

**Answer:** ✅ YES

**Explanation:** While Deets processes data locally on the device, it accesses device capabilities (camera, contacts) which Apple considers data collection for Privacy Label purposes.

---

### Section 2: Data Types

For each data type category, indicate whether your app collects it:

#### Contact Info
**Data Types:**
- ☑️ **Name** - YES
- ☑️ **Email Address** - YES
- ☑️ **Phone Number** - YES
- ☑️ **Physical Address** - YES
- ☑️ **Other User Contact Info** - YES (company names, job titles, etc.)

**Purpose(s):**
- ☑️ App Functionality

**Linked to User:** ❌ NO
**Used for Tracking:** ❌ NO

**Explanation:** Deets scans and stores contact information from business cards, but this data is stored locally on the device and is not linked to any user identifier or transmitted to servers.

---

#### Photos or Videos
**Data Types:**
- ☑️ **Photos or Videos** - YES

**Purpose(s):**
- ☑️ App Functionality

**Linked to User:** ❌ NO
**Used for Tracking:** ❌ NO

**Explanation:** Deets captures photos of business cards using the camera and stores them locally. Images are processed on-device for OCR and are not transmitted externally.

---

#### Identifiers
**Data Types:**
- ❌ User ID - NO
- ❌ Device ID - NO

**Answer:** ❌ NO identifiers collected

**Explanation:** Deets does not collect, create, or store any user identifiers or device identifiers. No analytics, advertising IDs, or tracking mechanisms are used.

---

#### Usage Data
**Data Types:**
- ❌ Product Interaction - NO
- ❌ Advertising Data - NO
- ❌ Other Usage Data - NO

**Answer:** ❌ NO usage data collected

**Explanation:** Deets does not collect analytics, telemetry, crash reports, or any usage data about how you interact with the app.

---

#### Diagnostics
**Data Types:**
- ❌ Crash Data - NO
- ❌ Performance Data - NO
- ❌ Other Diagnostic Data - NO

**Answer:** ❌ NO diagnostic data collected

**Explanation:** Deets does not collect crash logs, performance metrics, or diagnostic information.

---

#### Other Data Types

**Contacts:**
- ☑️ **Contacts** - YES

**Purpose(s):**
- ☑️ App Functionality

**Linked to User:** ❌ NO
**Used for Tracking:** ❌ NO

**Explanation:** Deets reads and writes to the iOS Contacts database to save scanned contact information. This data is managed by iOS and stored locally on the device.

---

### Section 3: Data Usage

**Question:** Do you or your third-party partners use data from this app for tracking purposes?

**Answer:** ❌ NO

**Definition Reminder:** Apple defines "tracking" as linking data collected from your app about a user or device with data collected from other companies' apps, websites, or offline properties for targeted advertising or advertising measurement purposes.

**Explanation:** Deets does not track users. No data is shared with third parties, no advertising networks are integrated, and no user profiling occurs.

---

### Section 4: Data Linked to You

**Question:** Is any data collected from this app linked to the user's identity?

**Answer:** ❌ NO

**Explanation:** All data processed by Deets is stored locally on the user's device. We do not maintain user accounts, create user identifiers, or link data to any identity. The app functions entirely offline (Phase 1) with no server communication.

---

### Section 5: Data Used to Track You

**Question:** Is data collected from this app used to track users?

**Answer:** ❌ NO

**Explanation:** Deets does not engage in any tracking activities. No data is shared with advertising networks, analytics providers, or data brokers. No cross-app or cross-site tracking occurs.

---

### Section 6: Third-Party SDKs

**Question:** Does your app include third-party code (SDKs, libraries, frameworks)?

**Answer for Phase 1:** ✅ YES (standard iOS frameworks only)

**Third-Party Code Used:**
- **Apple Frameworks ONLY:**
  - UIKit / SwiftUI (User Interface)
  - Vision Framework (On-device OCR)
  - Contacts Framework (Contact management)
  - AVFoundation (Camera access)
  - PhotoKit (Photo library access - Phase 2)
  - CloudKit (Optional iCloud sync - Phase 2)

**Privacy Impact:** Apple's native frameworks follow Apple's privacy policies. No data is transmitted to third parties. All processing occurs on-device.

**No Third-Party Analytics:** ❌
**No Third-Party Advertising:** ❌
**No Third-Party Crash Reporting:** ❌
**No Third-Party Cloud Services:** ❌ (Phase 1)

---

## Complete Privacy Nutrition Label Summary

### Data Collected

| Data Type | Purpose | Linked to You | Tracking |
|-----------|---------|---------------|----------|
| Contact Info (Name, Email, Phone, Address) | App Functionality | NO | NO |
| Photos or Videos | App Functionality | NO | NO |
| Contacts | App Functionality | NO | NO |

### Data Not Collected
- Identifiers (User ID, Device ID, Advertising ID)
- Usage Data (Analytics, Interactions, Behavior)
- Diagnostics (Crashes, Performance Metrics)
- Location Data
- Financial Information
- Health & Fitness Data
- Browsing History
- Search History
- Sensitive Information

### Tracking
**This app does not track you.**

### Privacy Practices Summary
- ✅ Data stored locally on your device
- ✅ No user accounts required
- ✅ No data transmitted to servers (Phase 1)
- ✅ No third-party data sharing
- ✅ No advertising networks
- ✅ No analytics or tracking
- ✅ Full user control over data deletion

---

## App Store Connect: Step-by-Step

When submitting Deets in App Store Connect, navigate to:
**App Privacy → Get Started**

### Step 1: Do you collect data from this app?
Select: **Yes**

### Step 2: Select data types
Check these categories:
- ☑️ Contact Info
- ☑️ Photos or Videos
- ☑️ Contacts

Click **Next**

### Step 3: Contact Info Details
For each selected item (Name, Email Address, Phone Number, Physical Address, Other Contact Info):

**How is this data used?**
- Check: ☑️ App Functionality

**Is this data linked to the user's identity?**
- Select: **No**

**Do you or your third-party partners use this data for tracking purposes?**
- Select: **No**

Click **Next**

### Step 4: Photos or Videos Details
**How is this data used?**
- Check: ☑️ App Functionality

**Is this data linked to the user's identity?**
- Select: **No**

**Do you or your third-party partners use this data for tracking purposes?**
- Select: **No**

Click **Next**

### Step 5: Contacts Details
**How is this data used?**
- Check: ☑️ App Functionality

**Is this data linked to the user's identity?**
- Select: **No**

**Do you or your third-party partners use this data for tracking purposes?**
- Select: **No**

Click **Next**

### Step 6: Review and Publish
Review all selections:
- Data collected: Contact Info, Photos/Videos, Contacts
- Purpose: App Functionality (all)
- Linked to user: NO (all)
- Tracking: NO (all)

Click **Publish** to save your privacy details.

---

## Common App Store Review Questions

### Q: Why do you access Contacts?
**A:** Deets is a contact management app that scans business cards and saves contact information to the user's iOS Contacts database. This core functionality requires Contacts access.

### Q: Why do you access the Camera?
**A:** Deets uses the camera to capture photos of business cards, which are then processed using on-device OCR to extract contact information. This is the primary feature of the app.

### Q: Where is data stored?
**A:** All data is stored locally on the user's device using iOS secure storage mechanisms. No data is transmitted to external servers in Phase 1.

### Q: Do you use any analytics or tracking?
**A:** No. Deets does not integrate any analytics SDKs, advertising networks, or tracking technologies. We do not collect usage data, diagnostics, or crash reports.

### Q: How do users delete their data?
**A:** Users can delete individual contacts within the app or delete all data by uninstalling the app from iOS Settings. Contacts saved to the iOS Contacts database can be deleted through the Contacts app.

### Q: Will you add tracking in future versions?
**A:** No. Privacy is a core value of Deets. We will never add user tracking, advertising, or data sharing with third parties. Any future features (like optional iCloud sync) will be clearly disclosed and under user control.

---

## Privacy Label Updates

### When to Update the Privacy Label

Update your Privacy Nutrition Label when:

1. **Adding new features** that collect additional data types
2. **Integrating third-party SDKs** (analytics, advertising, cloud services)
3. **Enabling server communication** (API calls, cloud sync)
4. **Changing data usage purposes**
5. **Implementing tracking** (never planned, but would require update)

### Phase 2 Considerations

If implementing optional iCloud sync in Phase 2:

**Question:** Is any data collected from this app linked to the user's identity?

**Answer:** ✅ YES (if iCloud sync enabled)

**Explanation:** When users opt-in to iCloud sync, contact data syncs across their devices using their Apple ID. This is managed by Apple's CloudKit framework. Users must explicitly enable this feature.

**Update Required:**
- Add "User ID" to Identifiers (Apple ID for CloudKit)
- Change "Linked to User" to YES for synced data
- Update privacy policy to explain iCloud sync clearly
- Ensure opt-in consent flow before enabling sync

---

## Legal Review Checklist

Before submitting to App Store:

- [ ] Privacy Policy reviewed by legal counsel
- [ ] Privacy Nutrition Label matches actual app behavior
- [ ] All permission prompts include clear usage descriptions
- [ ] Info.plist usage strings are user-friendly and accurate
- [ ] App functionality matches privacy disclosures
- [ ] No undisclosed data collection or transmission
- [ ] Third-party SDK audit completed (confirm no tracking)
- [ ] GDPR/CCPA compliance verified (if applicable)
- [ ] Contact information for privacy inquiries is valid
- [ ] Privacy policy accessible from app and website

---

## App Store Rejection Prevention

### Common Privacy Rejections

**Guideline 5.1.1(iv) - Data Collection and Storage:**
- ❌ Rejection: Privacy label doesn't match app behavior
- ✅ Prevention: Ensure label accurately reflects all data access

**Guideline 5.1.2 - Data Use and Sharing:**
- ❌ Rejection: Undisclosed third-party data sharing
- ✅ Prevention: Audit all frameworks and SDKs for tracking

**Guideline 2.3.8 - Metadata Rejection:**
- ❌ Rejection: Privacy policy not accessible or incomplete
- ✅ Prevention: Host privacy policy on public URL, link in App Store description

**Guideline 5.1.1(v) - Account Sign-In:**
- ❌ Rejection: Unnecessary account requirement
- ✅ Prevention: Deets requires no account (local-only storage)

### Our Compliance Strategy

Deets is designed to exceed Apple's privacy requirements:
- ✅ Minimal data collection (only what's needed for core functionality)
- ✅ Local-first architecture (no server communication in Phase 1)
- ✅ No user accounts or identifiers
- ✅ No third-party tracking or analytics
- ✅ Clear, honest privacy disclosures
- ✅ User control over all data access permissions

---

## Contact for App Store Privacy Questions

**Internal Privacy Lead:** MIRA (this document maintainer)
**Legal Review:** [TO BE ASSIGNED]
**App Store Contact:** privacy@deets.app
**Developer Support:** support@deets.app

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | 2025-11-05 | Initial Privacy Nutrition Label documentation | MIRA |

---

**Document ID:** DEETS-APP-STORE-PRIVACY-LABEL-2025
**Review Cycle:** Before each App Store submission
**Last Audit:** 2025-11-05

---

## Additional Resources

- [Apple Privacy Guidelines](https://developer.apple.com/app-store/user-privacy-and-data-use/)
- [App Store Review Guidelines - Privacy](https://developer.apple.com/app-store/review/guidelines/#privacy)
- [Privacy Nutrition Label Documentation](https://developer.apple.com/app-store/app-privacy-details/)
- [GDPR Compliance Guide](https://gdpr.eu/)
- [CCPA Compliance Guide](https://oag.ca.gov/privacy/ccpa)

---

**End of App Store Privacy Nutrition Label Documentation**
