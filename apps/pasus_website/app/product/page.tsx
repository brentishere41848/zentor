import { FeatureGrid } from "../../components/feature-grid";
import { SecurityDisclaimer } from "../../components/security-disclaimer";

export default function ProductPage() {
  return (
    <>
      <section className="bg-[#07111F] py-20 text-white">
        <div className="container">
          <h1 className="max-w-3xl text-5xl font-bold">Endpoint protection with local visibility.</h1>
          <p className="mt-5 max-w-3xl leading-8 text-white/72">
            Pasus Anti-Malware focuses on fast scans, transparent risk reasons, quarantine controls, and offline-first protection workflows.
          </p>
        </div>
      </section>
      <FeatureGrid />
      <section className="py-16"><div className="container"><SecurityDisclaimer /></div></section>
    </>
  );
}
