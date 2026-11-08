"use client";
import Link from "next/link";
import Image from "next/image";
import { useEffect, useState } from "react";
import { ArrowUpRight, Download, Menu, X } from "lucide-react";

export const downloadUrl = "https://github.com/kkz6/ZoneBar/releases/latest/download/ZoneBar.dmg";
const sourceUrl = "https://github.com/kkz6/ZoneBar";
export function DownloadButton({ small = false }: { small?: boolean }) {
  return <a className={`button download-button${small ? " small" : ""}`} href={downloadUrl} aria-label="Download ZoneBar for macOS"><Download size={small ? 16 : 19} />{small ? "Download" : "Download for macOS"}</a>;
}
export function SiteHeader({ docs = false }: { docs?: boolean }) {
  const [open, setOpen] = useState(false);
  useEffect(() => {
    const close = (event: KeyboardEvent) => { if (event.key === "Escape") setOpen(false); };
    window.addEventListener("keydown", close);
    return () => window.removeEventListener("keydown", close);
  }, []);
  const links = <><Link href="/#features">Features</Link><Link className={docs ? "selected" : undefined} href="/docs/">Documentation</Link><a href={`${sourceUrl}/releases/latest`}>Changelog</a><Link href="/#faq">FAQ</Link></>;
  return <><a className="skip-link" href="#main-content">Skip to content</a><header className="site-header"><div className="header-inner">
    <Link className="brand" href="/" aria-label="ZoneBar home"><Image className="brand-mark" src="/zonebar-icon.png" width={34} height={34} alt="" /><strong>ZoneBar</strong><span className="version-label">FOR MAC</span></Link>
    <nav className="primary-nav" aria-label="Main navigation">{links}</nav>
    <div className="header-actions"><a className="icon-button github-link" href={sourceUrl} aria-label="ZoneBar on GitHub"><GitHubMark /></a><DownloadButton small /><button className="icon-button mobile-menu" aria-label="Toggle navigation" aria-expanded={open} aria-controls="mobile-navigation" onClick={() => setOpen(!open)}>{open ? <X size={23} /> : <Menu size={23} />}</button></div>
  </div>{open && <nav id="mobile-navigation" className="mobile-navigation" aria-label="Mobile navigation" onClick={() => setOpen(false)}>{links}</nav>}</header></>;
}
export function SiteFooter() {
  return <footer className="site-footer"><div className="footer-inner"><div className="footer-intro"><Link className="brand" href="/"><Image className="brand-mark" src="/zonebar-icon.png" width={34} height={34} alt="" /><strong>ZoneBar</strong></Link><p>A little less distance.<br />A little more connection.</p><small className="footer-credit">Made for the people in your world. © 2026 GigCodes.</small></div>
    <div><h2>PRODUCT</h2><Link href="/#features">Features</Link><a href={downloadUrl}>Download</a><a href={`${sourceUrl}/releases/latest`}>Release notes</a><Link href="/#faq">Questions & answers</Link></div>
    <div><h2>LEARN</h2><Link href="/docs/">Getting started</Link><Link href="/docs/#compare">Compare times</Link><Link href="/docs/#calendar">Connect Calendar</Link><Link href="/docs/#privacy">Privacy</Link></div>
    <div><h2>ELSEWHERE</h2><a href={sourceUrl}>GitHub <ArrowUpRight size={12} /></a><a href={`${sourceUrl}/issues/new?template=bug_report.yml`}>Report an issue</a><a href={`${sourceUrl}/issues/new?template=feature_request.yml`}>Request a feature</a><a href="https://morrow.karti.dev/">Morrow</a><a href="https://karti.dev/">Made by Karthick</a></div>
  </div></footer>;
}

function GitHubMark() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true">
      <path
        fill="currentColor"
        d="M12 .7a11.5 11.5 0 0 0-3.64 22.41c.58.1.79-.25.79-.56v-2.24c-3.22.7-3.9-1.37-3.9-1.37-.53-1.34-1.29-1.7-1.29-1.7-1.05-.72.08-.71.08-.71 1.17.08 1.78 1.2 1.78 1.2 1.04 1.77 2.72 1.26 3.38.96.1-.75.4-1.26.74-1.55-2.57-.29-5.27-1.28-5.27-5.68 0-1.26.45-2.28 1.19-3.09-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.16 1.18A10.9 10.9 0 0 1 12 6.11c.98 0 1.95.13 2.87.39 2.19-1.49 3.15-1.18 3.15-1.18.64 1.59.24 2.76.12 3.05.74.81 1.18 1.83 1.18 3.09 0 4.41-2.7 5.38-5.28 5.67.42.36.79 1.06.79 2.14v3.28c0 .31.21.67.8.56A11.5 11.5 0 0 0 12 .7Z"
      />
    </svg>
  );
}

