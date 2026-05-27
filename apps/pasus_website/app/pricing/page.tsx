import { FaqSection } from "../../components/faq-section";
import { LicenseComingSoon } from "../../components/license-coming-soon";
import { PricingCards } from "../../components/pricing-cards";

export default function PricingPage() {
  return (
    <>
      <section className="bg-white py-20">
        <div className="container">
          <div className="pill bg-[#F5A524]/12 text-[#8A5A00]">Coming soon</div>
          <h1 className="mt-6 text-5xl font-bold">Licensing is not live yet.</h1>
          <p className="mt-5 max-w-3xl leading-8 text-[#5B6678]">
            Pasus plan names and capabilities are published for roadmap transparency. Checkout and license keys are not available.
          </p>
          <div className="mt-10"><PricingCards /></div>
        </div>
      </section>
      <LicenseComingSoon />
      <FaqSection />
    </>
  );
}
