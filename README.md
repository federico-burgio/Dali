# ZoneBar

> **This is an unofficial community fork** of [kkz6/ZoneBar](https://github.com/kkz6/ZoneBar)
> by [karti.dev](https://karti.dev), used under the MIT License. It is not affiliated with
> or endorsed by the original author, and it is distributed as source only: there are no
> signed or notarized binaries and no automatic updates. Please report problems with this
> fork in this repository, not to the upstream project. Original copyright and license
> are preserved in [LICENSE](LICENSE).

A lightweight native macOS menu bar app for tracking world clocks. Built with
SwiftUI and a focused AppKit settings-window host, targeting macOS 14+ (Sonoma).

ZoneBar replaces heavy Electron-based world clock apps with a fast, native experience that integrates deeply with macOS -- system appearance, launch at login, and more.

## Features

### World Clocks
- Add clocks by searching 176+ cities across 124 timezones
- Day/night indicators with sun and moon icons
- Relative day labels (Tomorrow, Yesterday)
- Per-clock GMT offset display
- Hover over a clock and drag its handle to reorder in Clocks settings and the menu bar popover
- Inline rename and delete from the Clocks settings
- Toggle which clocks appear in the menu bar
- Link clock selections to macOS Focus modes through native Focus filters

### Streamlined Popover
- Clean, glanceable clock rows with day/night icon, GMT offset, and large time
- Whole-row scrolling list (no clipped rows) that scrolls past six clocks
- **Time scrubber** — drag the bar to compare what time it is across every clock,
  with a green "match" dot when all zones are in working hours, and a Now reset
- Optional Calendar connection overlays timed events in blue, identifies the
  event at the selected comparison time, and opens it directly in Calendar
- Quick-add a city inline with the **+** button
- Settings and quit in the footer
- Optional Monday-first month calendar above the clocks, with month navigation and a Today button
- Up to three event dots per day in the enabled calendars' colors; the month remains usable without calendar access
- The month follows the selected calendar city's timezone and includes all-day and multi-day events

### Menu Bar
- Displays selected clock times directly in the macOS menu bar
- Compact mode abbreviates city names (New York → NY)
- Optional date and day/night (☀/☾) prefixes
- Optional compact calendar before the clocks, showing the day of the month in a selected saved city's timezone
- The calendar uses the same separator as the clocks; its simplified outline leaves more room for the day number
- Choose a local clock to hide its city label in the menu bar (choose None to restore every label)
- Configurable separator between clocks
- 12-hour or 24-hour time format
- Morning and night threshold sliders in 30-minute steps (06:00–20:00 by default)
- Clocks turn purple outside those hours in their own timezone; the menu bar preview updates live
- Falls back to a clock icon when neither clocks nor the calendar are displayed

### Settings (sidebar window)
- **General:** time format, date display, launch at login
- **Menu Bar:** compact names, day/night icon, separator, live preview
- **Clocks:** add, reorder, rename, delete, and choose menu-bar visibility
- **Focus:** follow Focus filters, view the current selection, and temporarily show all clocks
- **Calendar:** connect macOS Calendar and control timeline event visibility
- **Appearance:** System, Light, or Dark theme (accent follows macOS)
- **About:** version and links

### Focus-linked Clocks

In **System Settings → Focus**, select a Focus, add a **ZoneBar** filter, and
choose your saved clocks. ZoneBar shows those clocks in the menu bar and dropdown
while the filter is active. The usual clock selection returns when the filter
ends. Use **Show all** to temporarily pause filtering, or disable it from
**ZoneBar Settings → Focus**. Clock order and saved visibility settings are preserved.

### System Integration
- Pure menu bar app (no dock icon)
- Launch at login via SMAppService
- Respects system dark/light mode
- App sandbox
- Calendar data stays on-device and is only read after explicit permission

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 16.0 or later (for building; the project uses file-system-synchronized groups)

## Getting Started

### Build from Source

ZoneBar is distributed as source only. Build it on your own Mac:

```bash
git clone https://github.com/federico-burgio/Dali.git
cd Dali
open ZoneBar.xcodeproj
```

Press **Cmd+R** in Xcode to build and run. To keep a copy in `/Applications`, set the
scheme's Run configuration to Release (Product → Scheme → Edit Scheme) or build it
with `xcodebuild -scheme ZoneBar -configuration Release`, then copy `ZoneBar.app`
from the build products folder. Xcode signs local builds for you; no Apple Developer
account is required. Because those builds have no stable signing identity, macOS may
ask for Calendar access again after you rebuild.

There is no automatic updater. To update, pull the latest changes and rebuild.

### First Launch

On first launch, ZoneBar detects your local timezone and adds it along with UTC as default clocks. Use the search field in the popover to add more cities.

## Project Structure

```
ZoneBar/
├── ZoneBarApp.swift              # App entry point, MenuBarExtra + Settings
├── DesignSystem/
│   ├── DesignSystem.swift        # Reusable controls and visual tokens
│   ├── SettingsLayout.swift      # Reusable settings content framework
│   └── SettingsWindowController.swift # Fixed AppKit window and chrome owner
├── Models/
│   ├── WorldClock.swift          # Clock model, time formatting, day/night logic
│   └── CityDatabase.swift        # Hybrid city search (bundled JSON + Apple API)
├── Views/
│   ├── ClockPopover.swift        # Main popover and clock rows
│   ├── TimeScrubberView.swift    # Cross-timezone time preview
│   ├── CitySearchView.swift      # City search and add
│   ├── Settings/                 # Settings shell and six panes
│   └── MenuBarLabel.swift        # Dynamic menu bar label
├── Services/
│   ├── ClockStore.swift          # Clock persistence and CRUD
│   ├── AppSettings.swift         # UserDefaults-backed preferences
│   ├── CalendarEventService.swift # EventKit permission and event queries
│   └── TimeTicker.swift          # Minute-aligned clock updates
└── Resources/
    └── cities.json               # 176 cities, 124 timezones, all continents
```

## Architecture

- **SwiftUI-first:** `MenuBarExtra` plus an AppKit-owned fixed settings window
- **State management:** Observation (`@Observable`) with environment injection
- **Persistence:** JSON file for clocks, UserDefaults for settings
- **Timer:** Minute-boundary aligned for accurate clock updates
- **City data:** Hybrid approach -- bundled city database + Apple `TimeZone` API fallback

## Roadmap

Planned features:

- **Phase 2:** Widgets, keyboard shortcuts, Spotlight/Shortcuts integration
- **Phase 3:** Calendar-aware meeting suggestions and best meeting time finder
- **Phase 4:** Focus timer, quick time converter, travel mode
- **Phase 5:** iCloud sync, iOS app, watchOS complication

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Acknowledgements

ZoneBar was inspired by [Hovrly](https://github.com/tarutin/hovrly).

## License

MIT
