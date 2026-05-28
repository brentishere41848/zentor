import type { Metadata } from "next";
import "./globals.css";
import { SiteFooter } from "../components/site-footer";
import { SiteHeader } from "../components/site-header";
import { siteConfig } from "../lib/site-config";

export const metadata: Metadata = {
  metadataBase: new URL(siteConfig.url),
  title: "Pasus Anti-Malware - Fast Local Malware Protection",
  description: siteConfig.description,
  openGraph: {
    title: "Pasus Anti-Malware - Fast Local Malware Protection",
    description: siteConfig.description,
    siteName: siteConfig.name,
    images: ["/pasus-shield.svg"],
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <SiteHeader />
        <main>{children}</main>
        <SiteFooter />
      </body>
    </html>
  );
}
