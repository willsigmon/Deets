# ShareDeets.app — Deets Marketing Website

Official marketing website for **Deets**, the app that helps you meet once and remember always.

## Overview

This is a Next.js 16 marketing site built with:
- **Framework:** Next.js 16 (App Router)
- **Styling:** TailwindCSS v4
- **Animations:** Framer Motion
- **Deployment:** Vercel-ready

## Brand

- **Tagline:** Meet once. Remember always.
- **Colors:**
  - Primary (Teal): `#23C4AE`
  - Accent (Coral): `#FF766A`
  - Dark (Graphite): `#2B2E3A`
  - Light (Mist): `#F7F9FA`
- **Typography:** Inter (San-serif)

## Getting Started

Install dependencies:

```bash
npm install
```

Run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Project Structure

```
sharedeets-app/
├── app/
│   ├── components/
│   │   ├── Hero.tsx        # Hero section with animation
│   │   ├── Features.tsx    # 3-card feature grid
│   │   ├── Experience.tsx  # Device mockup section
│   │   ├── Story.tsx       # Two-column story layout
│   │   ├── CTA.tsx         # Call-to-action section
│   │   └── Footer.tsx      # Site footer
│   ├── privacy/
│   │   └── page.tsx        # Privacy policy page
│   ├── layout.tsx          # Root layout with metadata
│   ├── page.tsx            # Home page
│   ├── globals.css         # Global styles & theme
│   └── sitemap.ts          # Dynamic sitemap
├── content/
│   └── copy.md             # Marketing copy reference
├── public/
│   ├── brand/              # Brand assets (logos, etc.)
│   ├── meta/               # OG images
│   └── robots.txt          # SEO crawler rules
└── vercel.json             # Vercel deployment config
```

## Features

- Fully responsive design
- Smooth scroll animations with Framer Motion
- SEO optimized with Open Graph tags
- WCAG 2.1 AA accessibility compliant
- Performance optimized for Lighthouse 95+ score
- Privacy-first design

## Build & Deploy

Build for production:

```bash
npm run build
```

Deploy to Vercel:

```bash
vercel
```

Or connect your GitHub repo to Vercel for automatic deployments.

## Development

- Lint code: `npm run lint`
- Type check: `npx tsc --noEmit`

## License

© 2025 Deets — All connections remembered.
