import Link from "next/link";

export function HeroSection() {
  return (
    <section className="bg-[#07111F] py-24 text-white">
      <div className="container grid items-center gap-14 lg:grid-cols-[1.1fr_0.9fr]">
        <div>
          <div className="pill bg-white/10 text-[#14C8A8]">License sales: Coming soon</div>
          <h1 className="mt-8 max-w-3xl text-5xl font-bold leading-tight tracking-tight md:text-7xl">
            Anti-malware protection built for speed, control, and visibility.
          </h1>
          <p className="mt-6 max-w-2xl text-lg leading-8 text-white/72">
            Pasus helps scan, block, quarantine, and review threats locally. Real-time protection and licensing are being prepared for release.
          </p>
          <div className="mt-9 flex flex-wrap gap-4">
            <Link href="/waitlist" className="rounded-full bg-[#126BFF] px-7 py-4 font-bold text-white">
              Join the license waitlist
            </Link>
            <Link href="/download" className="rounded-full border border-white/20 px-7 py-4 font-bold">
              Download preview build
            </Link>
          </div>
        </div>
        <div className="dark-card rounded-[32px] p-7">
          <div className="rounded-3xl bg-[#07111F] p-6">
            <div className="flex items-center justify-between border-b border-white/10 pb-5">
              <span className="font-bold">Pasus Protection Console</span>
              <span className="pill bg-[#14C8A8]/10 text-[#14C8A8]">Preview</span>
            </div>
            {["Fast Quick Scan", "Quarantine review", "Ransomware Guard", "Lockdown Mode"].map((item) => (
              <div key={item} className="mt-5 rounded-2xl border border-white/10 bg-white/[0.03] p-4">
                <div className="text-sm font-bold">{item}</div>
                <div className="mt-2 h-2 rounded-full bg-white/10">
                  <div className="h-2 rounded-full bg-[#14C8A8]" style={{ width: item === "Lockdown Mode" ? "48%" : "72%" }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
