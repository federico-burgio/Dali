import Link from "next/link";
import Image from "next/image";
import { ArrowRight, ArrowUpRight, CalendarDays, Clock3, Focus, Globe2, Monitor, Plus, Minus, ShieldCheck } from "lucide-react";
import { DownloadButton, SiteFooter, SiteHeader } from "./components/SiteChrome";
import ClockPreview from "./components/ClockPreview";

const features = [
  { icon: Globe2, label: "WORLD CLOCKS", title: "Your people. Their time.", text: "Keep your team's cities together, with local time, GMT offsets, and clear day and night indicators.", chips: ["176+ cities", "Day & night"], link: "clocks" },
  { icon: Clock3, label: "TIME COMPARISON", title: "A good time for everyone.", text: "Move the timeline and every clock follows. Find overlapping working hours without doing the timezone math.", chips: ["Time scrubber", "Working hours"], link: "compare" },
  { icon: Monitor, label: "MENU BAR", title: "A little more your own.", text: "Choose the clocks you see, shorten city names, and make the time format and separators feel right for you.", chips: ["Compact labels", "12 or 24 hour"], link: "menu-bar" },
  { icon: Focus, label: "FOCUS", title: "The right clocks, right now.", text: "Choose clocks for a macOS Focus. Your usual selection returns when the Focus ends, with every saved city kept in place.", chips: ["Focus filters", "Show all"], link: "focus" },
  { icon: CalendarDays, label: "CALENDAR", title: "See the rest of your day.", text: "Connect Calendar to see events and unavailable time on the timeline. Choose which calendars appear and open events in Calendar.", chips: ["Optional access", "On-device"], link: "calendar" },
  { icon: ShieldCheck, label: "MADE FOR MAC", title: "Quietly at home on your Mac.", text: "Native controls, light and dark appearances, optional launch at login, and signed app updates. No account to create.", chips: ["Native macOS", "Automatic updates"], link: "updates" },
];
const faqs = [
  ["Is ZoneBar free?", "Yes. ZoneBar is free and open source under the MIT license. You can inspect the code, report issues, and contribute on GitHub."],
  ["Which Macs are supported?", "ZoneBar runs on macOS 14 Sonoma or later. The current release supports Apple silicon and Intel Macs."],
  ["Does it work offline?", "Yes. World clocks and time comparison work offline. The app connects to GitHub to check for and download updates; your clock settings stay on your Mac."],
  ["Do I have to connect my calendar?", "No. Calendar access is optional and requested only when you choose to connect it. Calendar data is read on-device and is not sent to a ZoneBar server."],
  ["How do updates work?", "Choose About → Check for Updates, or enable automatic checks. Published downloads are Developer ID signed and notarized by Apple, and the updater verifies signed updates."],
  ["Can it open when I log in?", "Yes. Turn on Launch at login in ZoneBar's General settings. The app lives in your menu bar without adding a Dock icon."],
];

export default function Home() {
  return <>
    <SiteHeader />
    <main id="main-content" tabIndex={-1}>
      <section className="hero" aria-labelledby="hero-title">
        <div className="hero-pattern" aria-hidden="true" />
        <div className="hero-content">
          <div className="eyebrow hero-eyebrow">A LITTLE CLOSER, WHEREVER YOU ARE</div>
          <h1 id="hero-title">Different timezones.<br /><span>Beautifully in sync.</span></h1>
          <p className="hero-description">Keep your people’s time close. A small native Mac app for world clocks, easier conversations, and finding a moment that works for everyone.</p>
          <div className="hero-actions"><DownloadButton /><Link className="button text-button" href="/docs/">Get to know ZoneBar <ArrowRight size={18} /></Link></div>
          <div className="compatibility"><span>macOS 14+</span><span>Apple silicon & Intel</span><span>Free & open source</span></div>
        </div>
        <figure className="clock-stage"><ClockPreview /><figcaption>Try the timeline. This interactive website preview shows live city times.</figcaption></figure>
      </section>
      <section id="features" className="section-container features-section">
        <div className="section-heading"><div className="eyebrow">LESS CONVERTING. MORE CONNECTING.</div><h2>A world of time.<br />A little less distance.</h2><p>Thoughtful tools for the people you work and live with.</p></div>
        <div className="feature-grid">{features.map(({ icon: Icon, ...feature }) => <Link className="feature-card" href={`/docs/#${feature.link}`} key={feature.label}>
          <div className="feature-top"><Icon size={24} strokeWidth={1.6} /><span className="eyebrow">{feature.label}</span><ArrowUpRight className="feature-arrow" size={17} /></div><h3>{feature.title}</h3><p>{feature.text}</p><div className="feature-chips">{feature.chips.map(chip => <span key={chip}>{chip}</span>)}</div>
        </Link>)}</div>
      </section>
      <section className="workflow-section"><div className="section-container workflow-inner"><div className="workflow-copy"><div className="eyebrow">FROM DOWNLOAD TO YOUR NEXT HELLO</div><h2>Make room for<br />a world of time.</h2><p className="workflow-description">A familiar Mac install. No account, subscription, or complicated setup.</p><Link className="inline-link" href="/docs/">Read the getting started guide <ArrowRight size={18} /></Link></div><ol className="setup-steps"><li><span>01</span><div><h3>Download ZoneBar.</h3><p>Open the signed and notarized disk image.</p></div></li><li><span>02</span><div><h3>Move it into Applications.</h3><p>Drag ZoneBar onto the Applications shortcut, then open the app.</p></div></li><li><span>03</span><div><h3>Bring your people closer.</h3><p>Add your cities and choose which clocks belong in your menu bar.</p></div></li></ol></div></section>
      <section id="install" className="section-container install-section"><div className="install-card"><Image className="brand-mark" src="/zonebar-icon.png" alt="" width={54} height={54} /><div className="eyebrow">A SMALL APP WITH THE WORLD IN MIND</div><h2>Keep every<br />timezone close.</h2><p>Download. Pick your cities. Find your moment.</p><DownloadButton /><div className="install-meta"><ShieldCheck size={18} /> Signed & notarized · macOS 14+</div><a href="https://github.com/kkz6/ZoneBar/releases/latest" className="release-link">Release notes and checksums <ArrowUpRight size={15} /></a></div></section>
      <section id="faq" className="section-container faq-section"><div><div className="eyebrow">A FEW GOOD QUESTIONS</div><h2>Before you<br />{" "}settle in.</h2><p>Something else on your mind?<br /><a className="inline-link" href="https://github.com/kkz6/ZoneBar/issues">Ask us on GitHub <ArrowUpRight size={16} /></a></p></div><div className="faq-list">{faqs.map(([question, answer]) => <details key={question}><summary>{question}<Plus className="faq-plus" size={18} /><Minus className="faq-minus" size={18} /></summary><p>{answer}</p></details>)}</div></section>
    </main><SiteFooter />
  </>;
}
