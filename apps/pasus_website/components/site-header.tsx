import Image from "next/image";
import Link from "next/link";
import { siteConfig } from "../lib/site-config";

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-50 border-b border-[#E1E7EF] bg-white/92 backdrop-blur">
      <div className="container flex h-20 items-center justify-between gap-6">
        <Link href="/" className="flex items-center gap-3 font-bold">
          <Image src="/pasus-logo.svg" alt="" width={42} height={42} />
          <span className="text-lg">{siteConfig.name}</span>
        </Link>
        <nav className="hidden items-center gap-7 text-sm font-semibold text-[#5B6678] lg:flex">
          {siteConfig.nav.map((item) => (
            <Link key={item.href} href={item.href} className="hover:text-[#0B1220]">
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="flex items-center gap-3">
          <Link
            href="/waitlist"
            className="hidden rounded-full border border-[#E1E7EF] px-5 py-3 text-sm font-bold md:inline-flex"
          >
            Join waitlist
          </Link>
          <Link
            href="/download"
            className="rounded-full bg-[#126BFF] px-5 py-3 text-sm font-bold text-white"
          >
            Download preview
          </Link>
        </div>
      </div>
    </header>
  );
}
