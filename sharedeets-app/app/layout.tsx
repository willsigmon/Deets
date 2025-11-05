import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://sharedeets.app"),
  title: "Deets — Meet once. Remember always.",
  description: "Deets helps you capture and remember every real-world connection. Scan cards, fill contacts, and sync effortlessly.",
  keywords: ["deets", "networking", "contacts", "business cards", "contact management"],
  authors: [{ name: "Deets" }],
  openGraph: {
    title: "Deets — Meet once. Remember always.",
    description: "Deets helps you capture and remember every real-world connection. Scan cards, fill contacts, and sync effortlessly.",
    url: "https://sharedeets.app",
    siteName: "Deets",
    images: [
      {
        url: "/meta/og-sharedeets.png",
        width: 1200,
        height: 630,
        alt: "Deets App",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Deets — Meet once. Remember always.",
    description: "Deets helps you capture and remember every real-world connection. Scan cards, fill contacts, and sync effortlessly.",
    images: ["/meta/og-sharedeets.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
