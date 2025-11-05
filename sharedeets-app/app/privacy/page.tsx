import Link from "next/link";
import Footer from "../components/Footer";

export const metadata = {
  title: "Privacy Policy — Deets",
  description: "Learn how Deets protects your privacy and handles your data.",
};

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-background">
      {/* Header */}
      <header className="bg-white border-b border-dark/5">
        <div className="max-w-5xl mx-auto px-6 md:px-12 py-6">
          <Link href="/" className="flex items-center gap-2 hover:opacity-80 transition-opacity">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-accent flex items-center justify-center font-bold text-white">
              D
            </div>
            <span className="text-xl font-bold text-dark">Deets</span>
          </Link>
        </div>
      </header>

      {/* Content */}
      <article className="max-w-4xl mx-auto px-6 md:px-12 py-16 md:py-24">
        <h1 className="text-4xl md:text-5xl font-extrabold text-dark mb-6">Privacy Policy</h1>
        <p className="text-dark/60 mb-8">Last updated: November 5, 2025</p>

        <div className="prose prose-lg max-w-none space-y-8 text-dark/80">
          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">Our Commitment to Privacy</h2>
            <p>
              At Deets, we believe your connections are personal. We&apos;ve designed our app to capture and
              organize your contacts while respecting your privacy at every step.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">What We Collect</h2>
            <p className="mb-4">Deets processes the following information:</p>
            <ul className="list-disc pl-6 space-y-2">
              <li>
                <strong>Contact Information:</strong> Names, phone numbers, email addresses, and other details
                you scan from business cards or manually enter.
              </li>
              <li>
                <strong>Photos:</strong> Images of business cards you scan using the app (processed locally on
                your device).
              </li>
              <li>
                <strong>Device Data:</strong> Basic information about your device, iOS version, and app usage
                for troubleshooting and improvement.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">How We Use Your Data</h2>
            <p className="mb-4">We use your information to:</p>
            <ul className="list-disc pl-6 space-y-2">
              <li>Process and organize contact information from scanned business cards</li>
              <li>Sync your contacts to your Apple Contacts and iCloud</li>
              <li>Improve the accuracy of our card scanning technology</li>
              <li>Provide customer support when you reach out</li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">Data Storage and Security</h2>
            <p>
              Your contact data is stored directly in your device&apos;s Contacts app and synced via iCloud
              according to your device settings. We use industry-standard encryption to protect any data
              transmitted through our services. Business card images are processed locally on your device and
              are not uploaded to our servers unless you explicitly enable cloud backup features.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">Third-Party Services</h2>
            <p>
              Deets integrates with Apple&apos;s Contacts and iCloud services. Your use of these services is
              governed by Apple&apos;s privacy policy. We do not share your personal information with any other
              third parties for marketing purposes.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">Your Rights</h2>
            <p className="mb-4">You have the right to:</p>
            <ul className="list-disc pl-6 space-y-2">
              <li>Access, edit, or delete any contact information stored in the app</li>
              <li>Opt out of analytics and crash reporting</li>
              <li>Request a complete deletion of your account and associated data</li>
              <li>Export your contact data at any time</li>
            </ul>
          </section>

          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">Children&apos;s Privacy</h2>
            <p>
              Deets is not intended for use by children under 13. We do not knowingly collect personal
              information from children under 13.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">Changes to This Policy</h2>
            <p>
              We may update this privacy policy from time to time. We will notify you of any significant
              changes by posting the new policy on this page and updating the &quot;Last updated&quot; date.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-bold text-dark mb-4">Contact Us</h2>
            <p>
              If you have questions about this privacy policy or how we handle your data, please contact us at:
            </p>
            <p className="mt-4">
              <a href="mailto:privacy@sharedeets.app" className="text-primary font-semibold hover:underline">
                privacy@sharedeets.app
              </a>
            </p>
          </section>
        </div>
      </article>

      <Footer />
    </main>
  );
}
