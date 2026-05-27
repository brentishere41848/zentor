import { ProtectionStack } from "../../components/protection-stack";

export default function ProtectionPage() {
  return (
    <>
      <section className="bg-white py-20">
        <div className="container">
          <h1 className="text-5xl font-bold">Prevention-first protection, stated honestly.</h1>
          <p className="mt-5 max-w-3xl leading-8 text-[#5B6678]">
            Pasus uses local scanning, policy, quarantine, and behavior monitoring. Driver-level blocking is shown only when installed and verified.
          </p>
        </div>
      </section>
      <ProtectionStack />
    </>
  );
}
