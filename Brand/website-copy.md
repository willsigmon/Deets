# Deets - Website Landing Page Copy

**Version**: 1.0.0
**Last Updated**: November 5, 2025
**Owner**: LUMEN (Brand & App Store Assets Lead)

---

## Page Structure

Single-page landing (scroll) with sections:
1. Hero
2. Problem/Solution
3. Features
4. Privacy Promise
5. Pricing
6. FAQ
7. Footer

---

## HERO SECTION

### Headline
```
Meet once. Remember always.
```

### Subheadline
```
Privacy-first business card scanner for iPhone.
Scan, save, export—all on your device.
```

### CTA Buttons
**Primary**: "Download on App Store" (Teal button, white text)
**Secondary**: "See How It Works" (White button, teal border, scrolls to features)

### Hero Visual
- iPhone mockup showing scan screen with business card
- Light background (Mist #F7F9FA)
- Subtle teal accent elements

---

## PROBLEM/SOLUTION SECTION

### Section Title
```
Networking Without the Tracking
```

### Copy
```
After conferences and networking events, you face a choice: manually type dozens of business cards into your phone, or use a "free" scanner app that sends your contacts to the cloud.

Deets is different. Using Apple's VisionKit framework, Deets scans and processes business cards entirely on your iPhone. No cloud servers. No data collection. No accounts.

Your contacts belong to you.
```

### Visual
- Two-column layout
- Left: Problem (cloud servers, tracking icons, crossed out)
- Right: Solution (iPhone with shield icon, checkmarks)

---

## FEATURES SECTION

### Section Title
```
Everything You Need, Nothing You Don't
```

### Feature 1: Fast Scanning

**Icon**: Camera icon (teal)

**Title**: Point and Scan

**Copy**:
```
Hold your iPhone over a business card. Deets automatically detects text and extracts contact information in seconds.
```

**Visual**: Screenshot of scan screen

---

### Feature 2: Smart Parsing

**Icon**: Brain/AI icon (teal)

**Title**: Smart Contact Extraction

**Copy**:
```
Name, title, company, email, phone, website—all automatically organized. Edit any field before saving.
```

**Visual**: Screenshot of contact preview with parsed fields

---

### Feature 3: Offline Capable

**Icon**: Airplane icon (teal)

**Title**: Works Everywhere

**Copy**:
```
No internet required. Scan cards at conferences, trade shows, underground parking, or on a plane. Deets works offline, always.
```

**Visual**: Illustration of conference center, airplane

---

### Feature 4: Export Options

**Icon**: Share icon (teal)

**Title**: Export Anywhere

**Copy**:
```
Save to Apple Contacts with one tap. Export to VCF for any contact manager. Or download as CSV for spreadsheets and CRMs.
```

**Visual**: Screenshot of export options

---

### Feature 5: Search & Organize

**Icon**: Magnifying glass (teal)

**Title**: Find Contacts Fast

**Copy**:
```
Search by name, company, or email. Mark favorites. Add notes. Keep track of who you met and where.
```

**Visual**: Screenshot of contact list with search

---

### Feature 6: Optional iCloud Sync

**Icon**: Cloud with checkmark (teal)

**Title**: Sync on Your Terms

**Copy**:
```
Turn on iCloud sync in Settings to access contacts across your devices. All data is encrypted by Apple. You control when and what syncs.
```

**Visual**: iPhone, iPad, Mac icons connected

---

## PRIVACY PROMISE SECTION

### Section Title
```
Privacy by Design, Not by Accident
```

### Copy
```
Most business card scanners are free because they monetize your data. Deets charges $2.99 because we don't.

✅ On-Device Processing
All scanning happens on your iPhone using Apple's VisionKit. No cloud servers. No external requests.

✅ No Account Required
Download, scan, done. We don't collect your email, phone number, or any personal information.

✅ Zero Tracking
No analytics. No crash reporting (unless you opt in via iOS). No third-party SDKs.

✅ Your Data, Your Control
Export contacts to Apple Contacts, VCF, or CSV anytime. Delete the app and your data is gone.

✅ Optional iCloud
Want to sync across devices? Enable iCloud sync. It's encrypted by Apple and controlled by you.

✅ Open & Honest
Questions about our privacy practices? Read our privacy policy or email privacy@deets.app.
```

### Visual
- Shield icon with iPhone
- Crossed-out cloud icon
- Checkmark icons for each point

---

## PRICING SECTION

### Section Title
```
Simple, Honest Pricing
```

### Pricing Card
```
┌─────────────────────────────┐
│                             │
│           $2.99             │
│         One-time            │
│                             │
│   ✅ Full-featured          │
│   ✅ No subscription        │
│   ✅ No ads                 │
│   ✅ No in-app purchases    │
│   ✅ Own it forever         │
│                             │
│   [Download on App Store]   │
│                             │
└─────────────────────────────┘
```

### Copy Below Card
```
Why not free? Because free apps make money by selling your data or showing you ads. We'd rather be honest about the transaction: you pay us $2.99, we give you a tool that respects your privacy.

No tricks. No upsells. No monthly fees.
```

---

## FAQ SECTION

### Section Title
```
Frequently Asked Questions
```

---

**Q: How does Deets work without the cloud?**

A: Deets uses Apple's VisionKit framework, which processes images entirely on your device. When you scan a card, your iPhone extracts the text—nothing is sent to external servers.

---

**Q: Can I trust Deets with my contacts?**

A: Deets doesn't "have" your contacts—they're stored locally on your iPhone using SwiftData (encrypted by iOS). We have no backend servers to send data to. You can verify this with network monitoring tools.

---

**Q: Does Deets work offline?**

A: Yes. Everything works without internet—scanning, saving, editing, searching. The only time Deets needs internet is if you enable iCloud sync (optional).

---

**Q: What can I export to?**

A: Export to Apple Contacts (one tap), VCF files (industry-standard format), or CSV (for spreadsheets and CRMs). Batch export multiple contacts at once.

---

**Q: Why isn't Deets free?**

A: Free business card scanners make money by:
• Selling your data to marketers
• Showing ads
• Charging $10-30/month subscriptions

We charge $2.99 once so we don't have to monetize your data.

---

**Q: Is iCloud sync required?**

A: No. iCloud sync is optional and disabled by default. If you enable it, contacts sync across your devices via Apple's CloudKit (encrypted by Apple).

---

**Q: What about Android?**

A: Deets v1.0 is iOS-only. We're exploring Android (using Google's ML Kit) based on user interest. Email support@deets.app if you'd use an Android version.

---

**Q: How accurate is the scanning?**

A: 90-95% on standard business cards. Unusual fonts, handwritten cards, or complex layouts may require manual correction. VisionKit (Apple's framework) handles most cards well.

---

**Q: Can I scan multiple cards at once?**

A: Not in v1.0, but batch scanning is planned for v1.2. Currently, scan one card at a time (takes ~5 seconds per card).

---

**Q: What languages are supported?**

A: VisionKit supports English, Spanish, French, German, Italian, Portuguese, Chinese, Japanese, and more. The app UI is currently English-only.

---

**Q: Is Deets open source?**

A: Not yet, but we're considering it. Email opensource@deets.app if you'd like to see the code or contribute.

---

**Q: Who built Deets?**

A: [Founder Name], a [developer/privacy advocate/professional] frustrated by business card apps that required accounts and sent data to the cloud. Deets is a solo project (for now).

---

## FOOTER

### Column 1: Product
- Home
- Features
- Pricing
- Privacy Policy
- Support

### Column 2: Company
- About
- Press Kit
- Contact
- Blog (if applicable)

### Column 3: Connect
- Twitter/X: @DeetsApp
- LinkedIn: /company/deets
- Email: hello@deets.app
- GitHub: /deets (if open-sourcing)

### Column 4: Download
- Download on the App Store (badge)
- System Requirements: iOS 17.0+
- Price: $2.99 USD

### Legal
```
© 2025 [Company Name]. All rights reserved.
Privacy Policy | Terms of Service
```

### Footer Tagline
```
Meet once. Remember always.
```

---

## ADDITIONAL PAGES

### /privacy (Privacy Policy)
**Content**: Use `Privacy/privacy-policy.md`

### /support (Support Page)

**Hero**:
```
How can we help?
```

**Search Bar**:
```
Search for help articles...
```

**Common Topics**:
- Getting Started
- Scanning Business Cards
- Exporting Contacts
- Privacy & Security
- iCloud Sync
- Troubleshooting

**Contact Form**:
```
Name:
Email:
Subject:
Message:
[Send Message]

Response time: 24-48 hours
```

### /press (Press Kit)
**Content**: Use `Brand/press-kit.md` (formatted for web)

---

## SEO METADATA

### Homepage

**Title Tag** (60 chars):
```
Deets - Privacy-First Business Card Scanner for iPhone
```

**Meta Description** (160 chars):
```
Scan business cards on your iPhone. All processing happens on-device—no cloud, no tracking, no accounts. Export to Contacts, VCF, or CSV. $2.99 one-time.
```

**Keywords**:
```
business card scanner, privacy, iOS, iPhone, offline, no cloud, VCF export, contact manager
```

**Open Graph Tags**:
```
og:title: Deets - Privacy-First Business Card Scanner
og:description: Scan business cards on your iPhone. No cloud. No tracking. No accounts.
og:image: [Hero screenshot URL]
og:url: https://deets.app
```

**Twitter Card Tags**:
```
twitter:card: summary_large_image
twitter:title: Deets - Privacy-First Business Card Scanner
twitter:description: Scan business cards on your iPhone. No cloud. No tracking.
twitter:image: [Hero screenshot URL]
twitter:site: @DeetsApp
```

---

## MICROCOPY

### Buttons
- "Download on App Store" (primary CTA)
- "See How It Works" (secondary CTA)
- "Read Privacy Policy" (footer link)
- "Contact Support" (footer link)
- "View Press Kit" (footer link)

### Form Labels
- "Your Email" (newsletter signup, if applicable)
- "Message" (contact form)
- "Send Message" (contact form submit)

### Error Messages
- "Please enter a valid email address."
- "Message cannot be empty."
- "Something went wrong. Please try again."

### Success Messages
- "Thanks! We'll respond within 24-48 hours."
- "Subscribed! Check your email for updates."

---

## DESIGN NOTES

### Typography
- **Headlines**: Inter Display Semibold, 48-72pt
- **Subheadlines**: Inter Display Medium, 28-36pt
- **Body**: Inter Regular, 16-18pt
- **Buttons**: Inter Medium, 16pt

### Colors
- **Background**: White (#FFFFFF) or Mist (#F7F9FA)
- **Text**: Graphite (#2B2E3A)
- **Secondary Text**: Slate (#6B7280)
- **Accent**: Teal (#23C4AE)
- **CTA Buttons**: Teal background, white text

### Spacing
- **Section Padding**: 120px top/bottom (desktop), 60px (mobile)
- **Content Max Width**: 1200px
- **Column Gaps**: 40px (desktop), 20px (mobile)

### Images
- **Hero**: iPhone mockup (right-aligned on desktop, centered on mobile)
- **Features**: Screenshots + icons
- **Privacy Section**: Illustration (shield + iPhone)
- **Pricing**: Minimal, text-focused

### Responsive Breakpoints
- **Desktop**: 1200px+
- **Tablet**: 768px - 1199px
- **Mobile**: < 768px

---

## A/B TESTING IDEAS

### Test 1: Headline
**Variant A**: "Meet once. Remember always." (brand tagline)
**Variant B**: "Privacy-first business card scanner for iPhone." (direct value prop)
Measure: Bounce rate, time on page

### Test 2: CTA Button
**Variant A**: "Download on App Store" (direct)
**Variant B**: "Start Scanning Privately" (benefit-focused)
Measure: Click-through rate

### Test 3: Hero Image
**Variant A**: iPhone mockup with scan screen
**Variant B**: Real photo of person scanning card at conference
Measure: Conversion rate

---

## CONVERSION TRACKING

### UTM Parameters

**App Store Link**:
```
https://apps.apple.com/app/deets/[APP_ID]?utm_source=website&utm_medium=hero_cta&utm_campaign=launch
```

**From Features Section**:
```
?utm_source=website&utm_medium=features_cta&utm_campaign=launch
```

**From Pricing Section**:
```
?utm_source=website&utm_medium=pricing_cta&utm_campaign=launch
```

### Goals to Track (Google Analytics)
- Page views
- Scroll depth (how far users scroll)
- CTA clicks (Download on App Store)
- Time on page
- Bounce rate
- Traffic sources (Twitter, Product Hunt, etc.)

---

## LAUNCH CHECKLIST

### Pre-Launch
- [ ] Domain purchased (deets.app)
- [ ] Hosting configured (Vercel, Netlify, or similar)
- [ ] SSL certificate installed (HTTPS)
- [ ] Website designed and built
- [ ] All copy written and reviewed
- [ ] Screenshots and graphics finalized
- [ ] SEO metadata added
- [ ] Google Analytics configured
- [ ] Contact form tested
- [ ] Mobile responsive design tested
- [ ] Privacy policy published at /privacy
- [ ] Terms of service published at /terms

### Launch Day
- [ ] Website live
- [ ] App Store link added (once approved)
- [ ] Social media links added
- [ ] Submit to Google Search Console
- [ ] Submit to Bing Webmaster Tools
- [ ] Tweet website launch
- [ ] Post on LinkedIn
- [ ] Share on Product Hunt (link to website)

### Post-Launch
- [ ] Monitor analytics (traffic, conversions)
- [ ] Fix any reported bugs
- [ ] A/B test headlines and CTAs
- [ ] Add testimonials (once users provide feedback)
- [ ] Optimize for SEO (based on Search Console data)

---

## CONTENT UPDATES

### Quarterly
- Update screenshots (if UI changes)
- Add new testimonials
- Refresh blog posts (if blog exists)
- Review SEO performance

### Annually
- Redesign hero section (stay modern)
- Update pricing (if changed)
- Refresh copy (keep voice current)

---

## TESTIMONIALS SECTION (FUTURE)

Once users provide feedback, add testimonial section:

### Section Title
```
What People Are Saying
```

### Testimonial Format
```
"[Quote about Deets]"
— [Name], [Title] at [Company]
```

**Example**:
```
"Finally, a business card scanner that doesn't require an account or send my data to the cloud."
— Alex Chen, Product Manager at Acme Corp
```

---

## BLOG (OPTIONAL)

If adding a blog, focus on:
- Privacy tips (not just Deets promotion)
- Networking advice
- Conference survival guides
- Behind-the-scenes (how Deets was built)
- VisionKit technical deep-dives

**Goal**: Provide value, attract organic search traffic, establish expertise.

---

## VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-05 | Initial website copy |

---

## CONTACT

For website copy questions:
**Email**: web@deets.app
**Owner**: LUMEN (Brand & App Store Assets Lead)

**Last Updated**: November 5, 2025
**Version**: 1.0.0
