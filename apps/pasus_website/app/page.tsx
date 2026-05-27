import { FaqSection } from "../components/faq-section";
import { FeatureGrid } from "../components/feature-grid";
import { HeroSection } from "../components/hero-section";
import { LicenseComingSoon } from "../components/license-coming-soon";
import { PricingCards } from "../components/pricing-cards";
import { ProtectionStack } from "../components/protection-stack";
import { SecurityDisclaimer } from "../components/security-disclaimer";
import { WaitlistForm } from "../components/waitlist-form";

export default function HomePage() {
  return (
    <>
      <HeroSection />
      <section className="py-14">
        <div className="container grid gap-5 md:grid-cols-3">
          {["Local-first scanning", "Visible quarantine", "Licenses coming soon"].map((item) => (
            <div key={item} className="card p-6 font-bold">{item}</div>
          ))}
        </div>
      </section>
      <FeatureGrid />
      <ProtectionStack />
      <section className="py-20">
        <div className="container grid gap-10 lg:grid-cols-2">
          <div>
            <h2 className="text-4xl font-bold">Real-time protection is built around honest status.</h2>
            <p className="mt-5 leading-8 text-[#5B6678]">Pasus shows whether protection is active, unavailable, or running in fallback mode. It does not claim driver-level blocking unless that path is installed and verified.</p>
          </div>
          <SecurityDisclaimer />
        </div>
      </section>
      <section className="bg-white py-20">
        <div className="container">
          <h2 className="text-4xl font-bold">License plans</h2>
          <p className="mt-4 text-[#5B6678]">Plans are shown for roadmap clarity only. Payments are not live.</p>
          <div className="mt-10"><PricingCards /></div>
        </div>
      </section>
      <LicenseComingSoon />
      <section className="py-20">
        <div className="container grid gap-10 lg:grid-cols-[0.9fr_1.1fr]">
          <div>
            <h2 className="text-4xl font-bold">Join the license waitlist.</h2>
            <p className="mt-4 leading-8 text-[#5B6678]">We will notify interested testers and early users when Pasus licensing opens.</p>
          </div>
          <WaitlistForm />
        </div>
      </section>
      <FaqSection />
    </>
  );
}
