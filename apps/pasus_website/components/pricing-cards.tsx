import Link from "next/link";

const plans = [
  ["Pasus Essential", "1 device", ["Quick Scan", "Full Scan", "Quarantine", "Basic real-time protection when available"]],
  ["Pasus Plus", "3 devices", ["Real-time Guard", "Ransomware Guard", "Recovery Vault", "Local AI analysis", "Priority updates when available"]],
  ["Pasus Pro", "10 devices", ["Lockdown Mode", "Advanced policy controls", "Business-ready reporting", "Offline protection tools"]],
];

export function PricingCards() {
  return (
    <div className="grid gap-6 lg:grid-cols-3">
      {plans.map(([name, devices, features]) => (
        <article key={name as string} className="card flex flex-col p-7">
          <div className="pill w-fit bg-[#F5A524]/12 text-[#8A5A00]">Coming soon</div>
          <h3 className="mt-5 text-2xl font-bold">{name}</h3>
          <p className="mt-2 text-[#5B6678]">{devices}</p>
          <ul className="mt-6 flex-1 space-y-3 text-sm text-[#334155]">
            {(features as string[]).map((feature) => (
              <li key={feature}>• {feature}</li>
            ))}
          </ul>
          <Link href="/waitlist" className="mt-8 rounded-full border border-[#E1E7EF] px-5 py-3 text-center font-bold">
            Notify me
          </Link>
        </article>
      ))}
    </div>
  );
}
