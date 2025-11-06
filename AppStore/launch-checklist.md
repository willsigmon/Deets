# Deets - App Store Launch Checklist

**Version**: 1.0.0
**Last Updated**: November 5, 2025
**Owner**: LUMEN (Brand & App Store Assets Lead)

---

## Overview

This checklist covers everything needed to launch Deets on the iOS App Store, from technical requirements to marketing materials. Follow each phase sequentially.

**Timeline**: 4-6 weeks from development complete to App Store launch

---

## PHASE 1: Pre-Submission (Week 1-2)

### App Development

- [ ] **App builds and runs** on physical iPhone (iOS 17.0+)
- [ ] **All features functional**: Scanning, saving, exporting, search
- [ ] **No crashes or major bugs** in primary workflows
- [ ] **Xcode project clean**: No compiler warnings
- [ ] **Bundle ID configured**: `com.sharedeets.app` (or your chosen ID)
- [ ] **Version number set**: 1.0.0 (Marketing Version)
- [ ] **Build number set**: 1 (increments with each build)
- [ ] **Deployment target**: iOS 17.0 (minimum)
- [ ] **Devices supported**: iPhone, iPad (Universal)
- [ ] **Architectures**: arm64 (for physical devices)

### App Icon

- [ ] **App icon created**: 1024×1024px PNG (see `Brand/app-icon-guide.md`)
- [ ] **All sizes generated**: Use Asset Catalog in Xcode
- [ ] **Icon added to Xcode**: `Assets.xcassets/AppIcon.appiconset`
- [ ] **Icon appears correctly**: Test on Home Screen (device)
- [ ] **No transparency**: Background must be opaque
- [ ] **Follows HIG**: No text, no rounded corners (iOS adds them)

### Permissions & Privacy

- [ ] **Camera permission**: `NSCameraUsageDescription` in Info.plist
  - Text: "Deets needs camera access to scan business cards."
- [ ] **Contacts permission**: `NSContactsUsageDescription` in Info.plist
  - Text: "Export business cards to your Contacts app."
- [ ] **Photos permission** (optional): `NSPhotoLibraryAddUsageDescription`
  - Text: "Save business card images to your Photos library."
- [ ] **Privacy manifest**: Create `PrivacyInfo.xcprivacy` if using tracking domains (we're not)
- [ ] **Privacy policy live**: Published at `https://deets.app/privacy`
- [ ] **Privacy policy URL accurate**: Matches live URL

### Info.plist Configuration

- [ ] **App name**: "Deets"
- [ ] **Bundle display name**: "Deets"
- [ ] **Version string**: 1.0.0
- [ ] **Short version**: 1.0.0
- [ ] **Copyright**: "© 2025 [Company Name]"
- [ ] **Privacy descriptions**: All required permissions added
- [ ] **Background modes**: None (unless using iCloud sync)
- [ ] **URL schemes**: None required for v1.0

### Code Signing

- [ ] **Apple Developer account**: Active ($99/year)
- [ ] **App ID registered**: In Apple Developer portal
- [ ] **Provisioning profile**: Distribution profile created
- [ ] **Certificates**: Distribution certificate installed in Xcode
- [ ] **Signing configured**: Xcode → Signing & Capabilities → Automatic or Manual
- [ ] **Team set**: Your Apple Developer team selected

### Testing

- [ ] **Device testing**: Tested on 3+ physical iPhones (different models)
- [ ] **iOS version testing**: Test on iOS 17.0, 17.1, latest version
- [ ] **Scan workflow**: Scan 10+ business cards, verify accuracy
- [ ] **Export workflow**: Export to Contacts, VCF, CSV—verify success
- [ ] **Search & filter**: Test with 20+ contacts
- [ ] **Offline mode**: Test with airplane mode enabled
- [ ] **iCloud sync**: Test sync across 2 devices (if feature included)
- [ ] **VoiceOver**: Test with VoiceOver enabled (accessibility)
- [ ] **Dynamic Type**: Test with largest text size (accessibility)
- [ ] **Dark mode**: Test UI in dark mode
- [ ] **Memory/Performance**: Profile with Instruments (no leaks)

---

## PHASE 2: App Store Connect Setup (Week 2-3)

### Apple Developer Account

- [ ] **Account active**: $99/year membership paid
- [ ] **Tax forms completed**: In App Store Connect
- [ ] **Banking info entered**: For payouts (if applicable)
- [ ] **Contact info updated**: Email, phone number current

### App Store Connect - App Creation

- [ ] **New app created**: App Store Connect → My Apps → +
- [ ] **Bundle ID selected**: Matches Xcode project
- [ ] **App name**: "Deets - Business Card Scanner" (30 chars max)
- [ ] **Primary language**: English (U.S.)
- [ ] **SKU**: Unique identifier (e.g., `deets-ios-001`)

### App Store Connect - App Information

- [ ] **Subtitle**: "Meet once. Remember always." (30 chars)
- [ ] **Primary category**: Business
- [ ] **Secondary category**: Productivity
- [ ] **Age rating**: 4+ (no objectionable content)
- [ ] **Privacy policy URL**: `https://deets.app/privacy`
- [ ] **Support URL**: `https://deets.app/support`
- [ ] **Marketing URL**: `https://deets.app`
- [ ] **Copyright**: "© 2025 [Company Name]"

### App Store Connect - Pricing

- [ ] **Price tier**: $2.99 USD (Tier 3)
- [ ] **Availability**: All countries (or selected regions)
- [ ] **Pre-order**: No (launch immediately)
- [ ] **Volume purchase program**: Enabled (for enterprise)

### App Store Connect - Privacy Nutrition Label

- [ ] **Data collection**: None (or specify if using iCloud)
- [ ] **Data used to track you**: No
- [ ] **Data linked to you**: No (or iCloud data if sync enabled)
- [ ] **Data not collected**: Confirm
- [ ] **Third-party partners**: None

**Privacy Labels (if using iCloud sync)**:
- [ ] Data type: Contact Info
- [ ] Linked to user: No (Apple handles encryption)
- [ ] Used for tracking: No

### App Store Connect - Export Compliance

- [ ] **Export compliance**: Answer questions
  - Uses encryption: Yes (HTTPS, iOS encryption)
  - Encryption type: Exempt (iOS standard encryption)
  - Submit annual report: Not required (no proprietary encryption)
- [ ] **U.S. Government encryption registration**: Not required

---

## PHASE 3: Marketing Assets (Week 3-4)

### Screenshots

**Required Sizes**:
- [ ] iPhone 6.7" (1290 × 2796px): 5 screenshots
- [ ] iPhone 6.5" (1242 × 2688px): 5 screenshots
- [ ] iPhone 5.5" (1242 × 2208px): 5 screenshots
- [ ] iPad 12.9" (2048 × 2732px): 5 screenshots (optional)

**Screenshot Content** (see `AppStore/screenshots-plan.md`):
- [ ] Screenshot 1: Scan screen with business card
- [ ] Screenshot 2: Contact preview with parsed data
- [ ] Screenshot 3: Contact list with search
- [ ] Screenshot 4: Privacy messaging ("Everything stays on your device")
- [ ] Screenshot 5: Export options (share sheet)

**Upload to App Store Connect**:
- [ ] All screenshots uploaded in correct order
- [ ] Preview in App Store Connect looks correct
- [ ] No text cutoff or alignment issues

### App Preview (Video) - Optional

- [ ] **30-second video created**: Shows scan workflow
- [ ] **Correct resolution**: Matches device size
- [ ] **No third-party trademarks**: Apple guidelines compliant
- [ ] **Uploaded to App Store Connect**: All required sizes
- [ ] **Preview frame selected**: Choose compelling thumbnail

### App Description

**Copy** (see `AppStore/description.md`):
- [ ] **App name**: "Deets - Business Card Scanner"
- [ ] **Subtitle**: "Meet once. Remember always."
- [ ] **Promotional text**: 170 chars, updatable without app submission
- [ ] **Description**: Full description (4000 char max, currently 2847 chars)
- [ ] **Keywords**: 100 chars (see `AppStore/keywords.txt`)
- [ ] **What's New**: Version 1.0.0 release notes (see `AppStore/whats-new.txt`)

**Upload to App Store Connect**:
- [ ] All copy pasted into App Store Connect
- [ ] Character limits verified (no truncation)
- [ ] Formatting preserved (bullets, line breaks)
- [ ] Proofread for typos

---

## PHASE 4: Build Submission (Week 4)

### Archive & Upload

- [ ] **Xcode scheme**: Set to "Release" (not "Debug")
- [ ] **Clean build folder**: Product → Clean Build Folder
- [ ] **Archive app**: Product → Archive
- [ ] **Archive successful**: No errors in Xcode
- [ ] **Validate archive**: Organizer → Validate App
- [ ] **Upload to App Store**: Organizer → Distribute App
- [ ] **Upload successful**: Check App Store Connect (5-10 min delay)

### Build Configuration

- [ ] **Build appears in App Store Connect**: App Store Connect → TestFlight
- [ ] **Build processing complete**: Wait 15-60 minutes
- [ ] **Export compliance answered**: In App Store Connect (if prompted)
- [ ] **Build selected for App Store**: Prepare for Submission → Build

### TestFlight (Optional but Recommended)

- [ ] **TestFlight enabled**: For internal/external testing
- [ ] **Internal testers invited**: Add team members
- [ ] **External testers invited**: Add beta users (optional)
- [ ] **Test notes provided**: What testers should focus on
- [ ] **Beta testing complete**: 10+ testers, no critical bugs
- [ ] **Feedback collected**: Issues resolved or noted

---

## PHASE 5: App Review Submission (Week 4-5)

### App Review Information

- [ ] **Contact email**: support@deets.app (monitored 24/7 during review)
- [ ] **Contact phone**: Valid phone number (Apple may call)
- [ ] **Demo account**: Not required (no login in app)
- [ ] **Review notes**: Add if special testing needed
  - "Scanning requires physical business card. If needed, we can provide sample images."
- [ ] **Attachments**: None required

### Age Rating Questionnaire

- [ ] **Profanity or crude humor**: None
- [ ] **Sexual content**: None
- [ ] **Violence**: None
- [ ] **Alcohol, tobacco, drugs**: None
- [ ] **Gambling**: None
- [ ] **Medical/Treatment info**: None
- [ ] **User-generated content**: No (contacts are not UGC)
- [ ] **Final age rating**: 4+

### Content Rights

- [ ] **App icon**: Original design (no copyright issues)
- [ ] **Screenshots**: Original content or properly licensed
- [ ] **App description**: Original copy
- [ ] **Sample data**: Fictional names and companies (no real data)
- [ ] **Brand guidelines**: Deets owns all assets

### Submit for Review

- [ ] **All required fields filled**: Green checkmarks in App Store Connect
- [ ] **No errors or warnings**: Address all red/yellow indicators
- [ ] **Pricing set**: $2.99 USD
- [ ] **Territories selected**: All or specific countries
- [ ] **Click "Submit for Review"**: Final submission
- [ ] **Confirmation email received**: From Apple

---

## PHASE 6: During App Review (1-7 days typical)

### Monitor Status

- [ ] **Check App Store Connect daily**: Status updates
- [ ] **Email notifications enabled**: Get alerts from Apple
- [ ] **Phone available**: Apple may call if issues arise

### Possible Statuses

**"Waiting for Review"**:
- Your app is in the queue. Can take 1-7 days.
- Action: Be patient, monitor email.

**"In Review"**:
- Apple is actively reviewing your app (24-48 hours).
- Action: Keep phone nearby, respond quickly if contacted.

**"Metadata Rejected"**:
- Issue with description, screenshots, or metadata (not app code).
- Action: Fix metadata in App Store Connect, resubmit immediately (no new build needed).

**"Rejected"**:
- App code or functionality violates guidelines.
- Action: Read rejection reason, fix issue, upload new build, resubmit.

**"Pending Developer Release"**:
- App approved! Waiting for you to release it.
- Action: Choose "Release this version" or schedule release date.

**"Ready for Sale"**:
- App is live on the App Store!
- Action: Celebrate, then start launch day activities.

### Common Rejection Reasons (Be Prepared)

**Privacy Issues**:
- Problem: Missing privacy policy or insufficient permission descriptions.
- Fix: Ensure privacy policy is live and permissions have clear descriptions.

**Misleading Metadata**:
- Problem: Screenshots or description don't match actual app functionality.
- Fix: Update screenshots to show real app UI, revise description.

**Broken Functionality**:
- Problem: App crashes during review or core feature doesn't work.
- Fix: Test thoroughly before resubmitting. Provide testing notes if needed.

**Incomplete Info.plist**:
- Problem: Missing required keys (e.g., camera usage description).
- Fix: Add all required keys, upload new build.

---

## PHASE 7: Launch Day (Day of Approval)

### Pre-Launch Final Checks

- [ ] **Website live**: `https://deets.app` is accessible
- [ ] **Privacy policy live**: `https://deets.app/privacy` works
- [ ] **Support page ready**: `https://deets.app/support` has contact form
- [ ] **Social media accounts created**: Twitter, LinkedIn, Product Hunt
- [ ] **Press kit published**: `Brand/press-kit.md` available for media
- [ ] **App Store link confirmed**: `https://apps.apple.com/app/deets/[APP_ID]`

### Launch Day Activities (First 4 Hours)

**Hour 1: Release App**
- [ ] **Release app**: App Store Connect → Release this version
- [ ] **Verify live**: Search "Deets" in App Store (may take 15-30 min)
- [ ] **Test download**: Download on your own device, verify it works

**Hour 2: Social Media Blitz**
- [ ] **Twitter**: Post launch announcement (see `Brand/social-media-guide.md`)
- [ ] **LinkedIn**: Post launch announcement (longer form)
- [ ] **Product Hunt**: Submit app (12:01 AM PT ideal)
- [ ] **Hacker News**: Post "Show HN" (optional, if tech-focused)

**Hour 3: Outreach**
- [ ] **Email beta testers**: Thank them, ask for App Store reviews
- [ ] **Email press contacts**: Send press release (see `Brand/press-kit.md`)
- [ ] **Post in relevant subreddits**: r/iOS, r/privacy, r/productivity

**Hour 4: Monitor & Engage**
- [ ] **Monitor social mentions**: Reply to every tweet/comment
- [ ] **Check App Store reviews**: Respond within 24 hours
- [ ] **Track downloads**: App Store Connect Analytics (refreshes every 24 hrs)

### Launch Day Content (Ready in Advance)

**Twitter Launch Tweet** (280 chars):
```
Deets is live on the App Store! 🎉

The privacy-first business card scanner that keeps everything on your device. No cloud. No tracking. No BS.

Meet once. Remember always.

[App Store Link]
```

**LinkedIn Launch Post**:
```
We're excited to launch Deets, a privacy-first business card scanner for iOS.

After attending countless conferences and networking events, we were frustrated by apps that required accounts, uploaded contacts to cloud servers, and monetized user data.

So we built Deets differently:
✅ On-device OCR (Apple's VisionKit)
✅ No account or login required
✅ Offline-capable (works at any event)
✅ Export to Contacts, VCF, or CSV
✅ $2.99 one-time purchase (no subscription)

Privacy and convenience shouldn't be mutually exclusive.

Download Deets: [App Store Link]

#Privacy #BusinessTools #Networking #iOS
```

**Product Hunt Description**:
```
Deets is a privacy-first business card scanner for iOS. It uses Apple's VisionKit to scan and parse business cards entirely on your iPhone—no cloud servers, no tracking, no accounts.

Key features:
• On-device OCR (VisionKit)
• Offline-capable
• Export to Contacts, VCF, CSV
• $2.99 one-time (no subscription)

Built for professionals who value privacy.
```

---

## PHASE 8: Post-Launch (Week 1-4)

### Week 1: Monitor & Respond

- [ ] **Check reviews daily**: App Store, Twitter, Product Hunt
- [ ] **Respond to all reviews**: Thank positive, help negative
- [ ] **Monitor crash reports**: Xcode → Organizer → Crashes
- [ ] **Track downloads**: App Store Connect Analytics
- [ ] **Track keywords**: Monitor search ranking (see `AppStore/keywords.txt`)
- [ ] **Fix critical bugs**: Release 1.0.1 if needed (fast-track for bug fixes)

### Week 2: Engagement

- [ ] **Share user testimonials**: Retweet positive feedback
- [ ] **Post feature highlights**: Twitter threads, LinkedIn posts
- [ ] **Reach out to media**: Follow up with press who requested info
- [ ] **Monitor competitors**: Check their updates, reviews, positioning
- [ ] **Analyze traffic sources**: Google Analytics (website), UTM tracking (App Store)

### Week 3-4: Iterate

- [ ] **Plan v1.1 features**: Based on user feedback
- [ ] **Update App Store description**: If needed (no app submission required)
- [ ] **Test ASO variations**: Try different keywords (see `AppStore/keywords.txt`)
- [ ] **Gather case studies**: Email power users for testimonials
- [ ] **Write launch retrospective**: Blog post or Twitter thread

---

## METRICS TO TRACK

### App Store Metrics

- **Downloads** (daily, weekly, monthly)
- **Conversion rate** (impressions → downloads)
- **Ratings** (avg rating, # of ratings)
- **Reviews** (# of reviews, sentiment)
- **Keyword rankings** (for target keywords)
- **Revenue** (total, daily average)

### Website Metrics

- **Visitors** (daily, weekly, monthly)
- **Bounce rate** (homepage, features page)
- **CTA clicks** ("Download on App Store" button)
- **Traffic sources** (Twitter, Product Hunt, organic search)

### Social Metrics

- **Followers** (Twitter, LinkedIn)
- **Engagement** (likes, retweets, comments)
- **Mentions** (# of times @DeetsApp is mentioned)
- **Click-through rate** (social → App Store)

### Success Benchmarks (First 30 Days)

- [ ] **1,000 downloads** (goal)
- [ ] **4.5+ star rating** (goal)
- [ ] **25+ reviews** (goal)
- [ ] **3-5 media mentions** (TechCrunch, The Verge, etc.)
- [ ] **Featured on Product Hunt** (Top 10 for the day)
- [ ] **10+ user testimonials** (for website, social proof)

---

## COMMON MISTAKES TO AVOID

### Before Submission

❌ **Don't skip device testing**: Simulator isn't enough.
❌ **Don't use placeholder text**: All copy should be final.
❌ **Don't rush screenshots**: Low-quality screenshots hurt conversion.
❌ **Don't ignore privacy policy**: Required for App Store approval.
❌ **Don't forget accessibility**: VoiceOver, Dynamic Type are essential.

### During Submission

❌ **Don't submit untested builds**: Always test on device first.
❌ **Don't ignore App Store guidelines**: Read them thoroughly.
❌ **Don't be vague in descriptions**: Clear, specific copy performs better.
❌ **Don't over-promise**: Only claim features that exist in v1.0.

### After Launch

❌ **Don't ignore reviews**: Respond to every review within 24 hours.
❌ **Don't go silent**: Post updates on Twitter, share milestones.
❌ **Don't stop marketing**: Launch day is just the beginning.
❌ **Don't ignore analytics**: Data tells you what's working (or not).

---

## EMERGENCY CONTACTS

### Critical Issues During Review

**Apple Developer Support**: https://developer.apple.com/contact/
**Phone**: 1-800-633-2152 (U.S.)
**Email**: Through App Store Connect (contact reviewer)

### Critical Bugs After Launch

**Priority 1 (Crashes)**: Fix immediately, submit 1.0.1 expedited review
**Priority 2 (Major bugs)**: Fix within 48 hours, submit update
**Priority 3 (Minor bugs)**: Bundle fixes into next scheduled update

---

## POST-LAUNCH UPDATE CADENCE

### Version 1.0.1 (Bug Fixes)
- Timeline: 1-2 weeks after launch
- Focus: Fix critical bugs reported by users
- Review time: Expedited (1-2 days for bug fixes)

### Version 1.1.0 (Minor Features)
- Timeline: 1-2 months after launch
- Focus: Most-requested features (e.g., batch scanning, custom tags)
- Review time: Standard (1-7 days)

### Version 2.0.0 (Major Update)
- Timeline: 6-12 months after launch
- Focus: Major new features (e.g., AI parsing, photo storage)
- Review time: Standard (1-7 days)

---

## RESOURCES

### Apple Documentation
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)

### Internal Documentation
- Brand Guidelines: `Brand/kit.md`
- App Icon Guide: `Brand/app-icon-guide.md`
- Screenshot Plan: `AppStore/screenshots-plan.md`
- App Store Copy: `AppStore/description.md`
- Keywords: `AppStore/keywords.txt`
- Press Kit: `Brand/press-kit.md`
- Social Media Guide: `Brand/social-media-guide.md`

---

## SIGN-OFF

### Final Approval

Before submitting to App Store, get sign-off from:
- [ ] **Development Lead**: App is stable, no known critical bugs
- [ ] **LUMEN (Brand Lead)**: All copy and visuals approved
- [ ] **Product Owner**: Features match spec, ready to ship
- [ ] **Legal**: Privacy policy accurate, no compliance issues

**Date Submitted**: _______________
**Submitted By**: _______________
**App Store Connect URL**: https://appstoreconnect.apple.com

---

## VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-05 | Initial launch checklist |

---

## CONTACT

For launch checklist questions:
**Email**: launch@deets.app
**Owner**: LUMEN (Brand & App Store Assets Lead)

**Last Updated**: November 5, 2025
**Version**: 1.0.0
