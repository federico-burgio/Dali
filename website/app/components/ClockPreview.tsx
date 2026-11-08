"use client";
import { useEffect, useState } from "react";
import { Clock3, Moon, Sun } from "lucide-react";
const cities = [
  { name: "San Francisco", code: "SFO", zone: "America/Los_Angeles" },
  { name: "London", code: "LON", zone: "Europe/London" },
  { name: "Bengaluru", code: "BLR", zone: "Asia/Kolkata" },
  { name: "Tokyo", code: "TKY", zone: "Asia/Tokyo" },
];
const initialTime = Date.UTC(2026, 10, 8, 12);
export default function ClockPreview() {
  const [now, setNow] = useState(initialTime);
  const [offset, setOffset] = useState(0);
  useEffect(() => {
    const initial = window.setTimeout(() => setNow(Date.now()), 0);
    const ticker = window.setInterval(() => setNow(Date.now()), 30000);
    return () => { window.clearTimeout(initial); window.clearInterval(ticker); };
  }, []);
  const date = new Date(now + offset * 60000);
  const clocks = cities.map(city => {
    const parts = new Intl.DateTimeFormat("en-GB", { timeZone: city.zone, hour: "2-digit", minute: "2-digit", hourCycle: "h23", timeZoneName: "shortOffset" }).formatToParts(date);
    const hour = Number(parts.find(part => part.type === "hour")?.value);
    const minute = parts.find(part => part.type === "minute")?.value;
    return { ...city, time: `${String(hour).padStart(2, "0")}:${minute}`, offset: parts.find(part => part.type === "timeZoneName")?.value.replace("-", "−"), day: hour >= 6 && hour < 20, working: hour >= 9 && hour < 17 };
  });
  const label = offset === 0 ? "Now" : `${offset > 0 ? "+" : "−"}${Math.floor(Math.abs(offset) / 60)}h ${Math.abs(offset) % 60}m`;
  const working = clocks.filter(clock => clock.working).length;
  return <div className="clock-preview">
    <div className="clock-menu" aria-label="Menu bar time preview">{clocks.slice(0, 3).map(clock => <span key={clock.code}>{clock.code} <b>{clock.time}</b></span>)}</div>
    <div className="clock-popover"><div className="clock-popover-header"><Clock3 size={17} /><strong>Your world, at a glance</strong><span>{offset === 0 ? "LIVE" : "PREVIEW"}</span></div>
      <div>{clocks.map(clock => <div className="clock-row" key={clock.code}><span className={`clock-day-icon ${clock.day ? "day" : "night"}`}>{clock.day ? <Sun size={18} /> : <Moon size={18} />}</span><span className="clock-place"><strong>{clock.name}</strong><small>{clock.code} · {clock.offset}</small></span><time>{clock.time}</time></div>)}</div>
      <div className="clock-timeline"><div className="timeline-labels"><span>−12h</span><output htmlFor="time-comparison">{label}</output><span>+12h</span></div><input id="time-comparison" type="range" min={-720} max={720} step={15} value={offset} onChange={event => setOffset(Number(event.target.value))} aria-label="Compare time across cities" aria-valuetext={label} /><p>{working === 4 ? "All cities are within working hours" : `${working} of 4 cities within working hours`}</p></div>
      <div className="clock-preview-footer"><span>4 clocks · 9am–5pm working hours</span><button disabled={offset === 0} onClick={() => setOffset(0)}>Back to now</button></div>
    </div>
  </div>;
}
