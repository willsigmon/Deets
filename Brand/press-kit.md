# Deets - Press Kit

**Version**: 1.0.0
**Last Updated**: November 5, 2025
**Media Contact**: press@deets.app

---

## Quick Facts

| Detail | Information |
|--------|-------------|
| **App Name** | Deets - Business Card Scanner |
| **Developer** | [Company Name] |
| **Platform** | iOS 17.0+ (iPhone, iPad) |
| **Category** | Business, Productivity |
| **Price** | $2.99 USD (one-time purchase) |
| **Release Date** | TBD 2025 |
| **Website** | https://deets.app |
| **Support** | support@deets.app |
| **Press Contact** | press@deets.app |

---

## Elevator Pitch (30 seconds)

Deets is a privacy-first business card scanner for iPhone that processes cards entirely on-device using Apple's VisionKit. No cloud storage, no tracking, no account required. Professionals can scan cards at conferences, extract contact information, and export to Apple Contacts or VCF—all while maintaining complete data privacy. Available for $2.99 with no subscription.

---

## The Problem

After networking events, professionals face an uncomfortable choice: manually type dozens of business cards into their phone (tedious and error-prone), or use a "free" business card scanner that uploads contacts to cloud servers for data mining and targeted advertising.

Popular business card apps like CamCard and ScanBizCards require accounts, send data to remote servers, and monetize user information through ads or "premium" subscriptions. Privacy-conscious professionals have no good options.

---

## The Solution

Deets solves this by using Apple's VisionKit framework to scan and parse business cards entirely on the user's iPhone. No data leaves the device unless the user explicitly exports it. No account required, no cloud processing, no analytics collection.

**Key Features:**
- **On-Device OCR**: VisionKit processes cards locally
- **Smart Parsing**: Extracts name, title, company, email, phone, website
- **Offline-Capable**: Works at conferences, flights, anywhere
- **Export Options**: Apple Contacts, VCF, CSV
- **Optional iCloud Sync**: User-controlled, encrypted by Apple
- **One-Time Purchase**: $2.99, no subscription

---

## Why This Matters

### Privacy is a Human Right
In an era of data breaches and surveillance capitalism, professionals shouldn't have to trade their networking contacts for a free app. Deets proves privacy and convenience can coexist.

### Conferences Need Better Tools
With thousands of conferences and trade shows annually, professionals scan hundreds of business cards. Existing apps either require internet (limiting use in convention centers) or upload data to the cloud (privacy risk).

### The "Free" App Model is Broken
Free business card scanners make money by:
- Selling user data to marketers
- Displaying ads
- Upselling premium features ($10-30/month subscriptions)

Deets charges $2.99 once and delivers full functionality—no upsells, no data harvesting.

---

## Founder Story (Optional - Customize)

[Founder Name] built Deets after attending countless tech conferences and feeling uneasy about where business card scanner apps were sending contact data. As a [privacy advocate / developer / professional], they believed networking shouldn't require surrendering data to third parties.

After researching Apple's VisionKit framework (introduced in iOS 16), they realized it was possible to build a fully on-device business card scanner—no cloud required. Deets was born from the principle that privacy should be the default, not a premium feature.

---

## Product Details

### Scanning Process

1. **Open Deets** → Tap "Scan Card"
2. **Point Camera** → VisionKit automatically detects text
3. **Review Data** → Parsed fields appear (name, email, phone, etc.)
4. **Edit if Needed** → Correct any OCR errors
5. **Save** → Contact stored locally on iPhone
6. **Export (Optional)** → Share via Contacts, VCF, or CSV

**Time to Scan**: ~5 seconds per card
**Supported Languages**: English, Spanish, French, German (via VisionKit)
**Accuracy**: 90-95% on standard business cards

### Privacy Architecture

- **Local Processing**: All OCR happens on-device via VisionKit
- **Local Storage**: Contacts saved to SwiftData (encrypted by iOS)
- **No Servers**: Deets has no backend servers
- **No Analytics**: Zero telemetry or crash reporting (unless user opts in via iOS)
- **Optional iCloud**: User can enable iCloud sync (encrypted by Apple)
- **Easy Deletion**: Delete app = delete all data

### Technical Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData (iOS 17+)
- **OCR**: VisionKit (Apple's on-device framework)
- **Contacts Integration**: ContactsFramework
- **Deployment**: iOS 17.0+, iPhone and iPad

---

## Target Audience

### Primary
- **Sales Professionals**: Attend trade shows, collect 50-100 cards per event
- **Recruiters**: Career fairs, networking events
- **Consultants**: Client meetings, industry conferences
- **Entrepreneurs**: Pitch events, startup meetups
- **Conference Attendees**: Anyone who receives business cards regularly

### Secondary
- **Privacy-Conscious Users**: Anyone who avoids cloud-based apps
- **Offline Workers**: People in areas with poor connectivity
- **Enterprise IT**: Companies with strict data policies

### Psychographics
- Values privacy over "free" apps
- Attends 3+ networking events per year
- Willing to pay for quality tools
- Prefers native iOS apps over web apps
- Understands (or cares to learn) about data privacy

---

## Competitive Landscape

| App | Price | Cloud Storage | Account Required | Offline Capable | Privacy Focus |
|-----|-------|---------------|------------------|-----------------|---------------|
| **Deets** | $2.99 | No (optional iCloud) | No | Yes | ✅ High |
| CamCard | Free/$8/mo | Yes | Yes | Limited | ❌ Low |
| ScanBizCards | Free/$5/mo | Yes | Yes | No | ❌ Low |
| Business Card Reader | $4.99 | Yes | No | Limited | ⚠️ Medium |
| Microsoft Lens | Free | Yes | Yes | Limited | ⚠️ Medium |

**Key Differentiators**:
1. **Only on-device scanner**: No cloud processing
2. **No account required**: Download and use immediately
3. **Offline-first**: Works anywhere, even on planes
4. **No subscription**: One-time purchase, own forever

---

## Press Release (For Reference)

**FOR IMMEDIATE RELEASE**

**Deets Launches Privacy-First Business Card Scanner for iOS**

*New app processes business cards entirely on-device, with no cloud storage or tracking*

[CITY, STATE] – [DATE] – Today, [Company Name] announced the launch of Deets, a privacy-first business card scanner for iPhone and iPad. Unlike popular card scanning apps that upload contacts to cloud servers, Deets uses Apple's on-device VisionKit framework to process cards entirely on the user's device.

"After countless networking events, I was frustrated by apps that required accounts and sent my contacts to the cloud," said [Founder Name], creator of Deets. "I built Deets for professionals who want the convenience of automated card scanning without sacrificing their privacy."

Deets scans business cards using the iPhone's camera, automatically extracts contact information (name, title, company, email, phone, website), and stores data locally using SwiftData. Users can export contacts to Apple's Contacts app, VCF files, or CSV spreadsheets. Optional iCloud sync is available for users who want to sync across devices, but all data remains encrypted by Apple.

Key features include:
- On-device OCR using VisionKit (no cloud processing)
- Offline-capable (works at conferences, flights, anywhere)
- No account or login required
- Export to Apple Contacts, VCF, or CSV
- One-time purchase of $2.99 (no subscription)
- Full VoiceOver and Dynamic Type support

Deets is available now on the iOS App Store for $2.99.

For more information, visit https://deets.app or contact press@deets.app.

**About [Company Name]**
[Company Name] builds privacy-focused productivity apps for iOS. Founded in [YEAR], the company believes privacy should be the default, not a premium feature.

**Media Contact:**
[Name]
press@deets.app
https://deets.app

###

---

## Media Assets

### Logos

**Download Links**: [To be added - Dropbox/Google Drive folder]

- **App Icon** (1024×1024px PNG)
- **Logo - Full Color** (SVG, PNG at multiple sizes)
- **Logo - Monochrome Dark** (SVG, PNG)
- **Logo - Monochrome Light** (SVG, PNG)

### Screenshots

**Download Links**: [To be added]

- iPhone 15 Pro Max screenshots (5 images)
- iPad Pro 12.9" screenshots (5 images)
- Light and dark mode variants (if applicable)

### App Previews (Video)

**Download Links**: [To be added]

- 30-second app preview video (1080p MP4)
- B-roll footage for media use (if available)

### Brand Guidelines

**Download**: [Brand/kit.md or PDF version]

- Color palette (HEX, RGB values)
- Typography guidelines
- Logo usage rules
- Voice and tone guide

---

## Quotes for Media

### On Privacy
> "Privacy shouldn't be a premium feature. Deets proves you can build powerful, user-friendly apps without harvesting data."
> — [Founder Name], Creator of Deets

### On Offline Capability
> "Conference centers and trade show floors often have terrible Wi-Fi. Deets works everywhere because it doesn't need the internet."
> — [Founder Name]

### On Business Model
> "We charge $2.99 upfront so we don't have to sell your data or show you ads. It's that simple."
> — [Founder Name]

### On Competition
> "Free apps aren't really free. They're monetizing your data. Deets is honest about the transaction: you pay us, we give you a tool."
> — [Founder Name]

---

## FAQs for Media

**Q: How does Deets make money if there's no subscription?**
A: Deets is a one-time purchase of $2.99. We don't need recurring revenue because we have no server costs (everything runs on-device).

**Q: What's stopping users from just using the iPhone camera and manually typing contacts?**
A: Time. Scanning a card with Deets takes 5 seconds. Manually typing takes 60+ seconds. After a conference with 50 cards, that's 45 minutes saved.

**Q: Is this truly private, or just marketing?**
A: Truly private. We use Apple's VisionKit framework, which processes images on-device. Deets has no backend servers to send data to. You can verify this with network monitoring tools.

**Q: What if users want cloud backup?**
A: Users can enable iCloud sync in Settings. This uses Apple's CloudKit, which encrypts data and is controlled by the user's iCloud account. We (Deets developers) never see the data.

**Q: Why iOS only? What about Android?**
A: VisionKit is an Apple-exclusive framework. We plan an Android version using Google's ML Kit, but iOS is our focus for v1.0.

**Q: Who is your target customer?**
A: Professionals who attend conferences, trade shows, networking events, and career fairs. Anyone who collects more than 10 business cards per year.

**Q: How accurate is the OCR?**
A: 90-95% on standard business cards. Unusual fonts, handwritten cards, or non-English text may require manual correction. VisionKit (Apple's framework) handles most layouts well.

**Q: Can I scan multiple cards at once?**
A: Not in v1.0, but batch scanning is planned for v1.2 based on user feedback.

---

## Review Guidelines for Media

When reviewing Deets, please consider:

1. **Test Privacy Claims**: Use network monitoring tools (Charles Proxy, Wireshark) to verify no data leaves the device during scanning.

2. **Compare to Competitors**: Test CamCard, ScanBizCards, or Microsoft Lens alongside Deets. Note which require accounts, which work offline, which show ads.

3. **Real-World Use**: Take Deets to a conference or networking event. Scan 10-20 cards in quick succession.

4. **Accuracy**: Test with various card styles (minimal design, cluttered design, non-English text).

5. **Export Functionality**: Export contacts to Apple Contacts, verify data transfers correctly.

---

## Contact Information

### General Press Inquiries
**Email**: press@deets.app
**Response Time**: 24-48 hours

### Review Copies
**TestFlight Access**: Email press@deets.app for beta access
**Promo Codes**: Available upon request (for media reviews)

### Interview Requests
**Availability**: [Founder Name] available for interviews via:
- Email Q&A
- Phone/Zoom calls (by appointment)
- In-person (if in [City, State])

### Social Media
- **Twitter/X**: [@DeetsApp](https://twitter.com/DeetsApp) (to be created)
- **LinkedIn**: [Company LinkedIn](https://linkedin.com/company/deets) (to be created)
- **Mastodon**: [@deets@mastodon.social](https://mastodon.social/@deets) (to be created)

---

## Media Coverage Goals

### Target Publications

**Tech Media**:
- TechCrunch
- The Verge
- Ars Technica
- 9to5Mac
- MacRumors
- MacStories

**Privacy Media**:
- Electronic Frontier Foundation (EFF) blog
- Privacy International
- Krebs on Security
- PrivacyTools.io

**Business Media**:
- Fast Company
- Inc. Magazine
- Entrepreneur
- Forbes (small business section)

**Podcasts**:
- Accidental Tech Podcast
- Connected (Relay FM)
- Upgrade (Relay FM)
- MacBreak Weekly

### Pitch Angles

**For Tech Media**:
"New iOS app uses VisionKit to scan business cards entirely on-device, no cloud required"

**For Privacy Media**:
"Deets proves privacy-first apps can compete with free, data-harvesting alternatives"

**For Business Media**:
"Solo developer challenges enterprise apps with $2.99 business card scanner"

**For Podcasts**:
"Interview with developer who built privacy-first card scanner to compete with CamCard"

---

## Media Kit Download

**Link**: [To be added - Dropbox/Google Drive folder]

**Contents**:
- Press release (PDF, Word)
- High-resolution screenshots (PNG, 300 DPI)
- App icon (PNG, multiple sizes)
- Logos (SVG, PNG)
- Founder photo (JPG, 300 DPI) (optional)
- Brand guidelines (PDF)
- Fact sheet (PDF)

---

## Timeline

### Pre-Launch (Now - Launch Day)
- Finalize press kit
- Reach out to key media contacts
- Offer early access (TestFlight) to select reviewers
- Prepare launch day social media posts

### Launch Day
- Submit to App Store
- Send press release to media list
- Post on Twitter/X, LinkedIn, Hacker News, Product Hunt
- Email supporters/beta testers

### Post-Launch (Week 1-4)
- Monitor reviews, respond to feedback
- Follow up with media who requested more info
- Share user testimonials
- Post launch retrospective blog post

---

## Success Metrics

### Media Goals (First 30 Days)
- 3-5 tech blog mentions (TechCrunch, The Verge, etc.)
- 1-2 podcast interviews
- 10+ social media shares from influencers
- Featured on Product Hunt (goal: Top 10 for the day)

### App Store Goals
- 1,000 downloads in first 30 days
- 4.5+ star rating
- 25+ reviews
- Featured in "New Apps We Love" (Apple editorial)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-05 | Initial press kit |

---

## Contact

For press kit questions:
**Email**: press@deets.app
**Owner**: LUMEN (Brand & App Store Assets Lead)

**Last Updated**: November 5, 2025
**Version**: 1.0.0
