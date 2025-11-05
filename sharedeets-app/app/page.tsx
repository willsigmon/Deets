import Hero from "./components/Hero";
import Features from "./components/Features";
import Experience from "./components/Experience";
import Story from "./components/Story";
import CTA from "./components/CTA";
import Footer from "./components/Footer";

export default function Home() {
  return (
    <main className="min-h-screen">
      <Hero />
      <Features />
      <Experience />
      <Story />
      <CTA />
      <Footer />
    </main>
  );
}
