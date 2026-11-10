import AppKit
import SwiftUI
import Testing
@testable import ZoneBar

@MainActor
struct MonthCalendarRenderingTests {
    @Test(arguments: [ColorScheme.light, .dark], [true, false])
    func referenceLayoutRendersWithAndWithoutDots(scheme: ColorScheme, hasEvents: Bool) throws {
        let date = ISO8601DateFormatter().date(from: "2026-11-10T12:00:00Z")!
        let month = MonthCalendar(containing: date, timeZone: TimeZone(secondsFromGMT: 0)!)
        let markers = hasEvents ? Dictionary(uniqueKeysWithValues: month.days.map { day in
            (day.date, [CalendarDayMarker(id: "work", name: "Work", color: .red)])
        }) : [:]
        let view = MonthCalendarCard(
            month: month, today: date, selectedDate: date, locale: Locale(identifier: "en_GB"), markers: markers,
            previousMonth: {}, nextMonth: {}, goToToday: {}, selectDay: { _ in }
        )
        .frame(width: 296)
        .environment(\.colorScheme, scheme)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let image = try #require(renderer.nsImage)
        #expect(image.size == CGSize(width: 296, height: 249))
        let tiff = try #require(image.tiffRepresentation)
        let bitmap = try #require(NSBitmapImageRep(data: tiff))
        var hasRedDots = false
        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide {
                if let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.sRGB),
                   color.alphaComponent > 0.9,
                   color.redComponent > color.greenComponent + 0.3,
                   color.redComponent > color.blueComponent + 0.3 {
                    hasRedDots = true
                }
            }
        }
        #expect(hasRedDots == hasEvents)
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func expandedMenuFitsCalendarClocksAndTimeline(scheme: ColorScheme) throws {
        let suite = "MonthCalendarRenderingTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let settings = AppSettings(defaults: defaults)
        settings.showPopoverCalendar = true
        settings.language = .english
        let store = ClockStore(
            saveURL: FileManager.default.temporaryDirectory.appendingPathComponent("\(suite).json"),
            seedDefaults: false
        )
        store.clocks = [
            WorldClock(name: "Dublin", country: "IE", timezone: "Europe/Dublin"),
            WorldClock(name: "UTC", country: "", timezone: "UTC"),
            WorldClock(name: "Tokyo", country: "JP", timezone: "Asia/Tokyo"),
            WorldClock(name: "New York", country: "US", timezone: "America/New_York"),
        ]
        let date = ISO8601DateFormatter().date(from: "2026-11-10T12:00:00Z")!
        let ticker = TimeTicker(now: date, startsAutomatically: false)
        let service = CalendarEventService(accessStateOverride: .notDetermined)
        let focus = FocusClockFilter(defaults: defaults, loadCurrent: { nil })
        let view = ClockPopover()
            .environment(settings)
            .environment(store)
            .environment(ticker)
            .environment(service)
            .environment(focus)
            .environment(\.colorScheme, scheme)
            .tint(.zoneAccent)
            .background(Color(nsColor: .windowBackgroundColor))
            .fixedSize()
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let image = try #require(renderer.nsImage)
        #expect(image.size.width == 320)
        #expect(image.size.height <= 700)
        // The clock list uses a native scroll view, which ImageRenderer cannot
        // capture. Render the complete menu through AppKit for visual review.
        let hosting = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: image.size),
            styleMask: .borderless, backing: .buffered, defer: false
        )
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: scheme == .dark ? .darkAqua : .aqua)
        window.contentView = hosting
        defer { window.close() }
        hosting.frame = NSRect(origin: .zero, size: image.size)
        hosting.layoutSubtreeIfNeeded()
        let bitmap = try #require(hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds))
        hosting.cacheDisplay(in: hosting.bounds, to: bitmap)
        let png = try #require(bitmap.representation(using: .png, properties: [:]))
        let file = FileManager.default.temporaryDirectory
            .appendingPathComponent("dali-month-popover-\(scheme == .dark ? "dark" : "light").png")
        try png.write(to: file)
        print("CALENDAR_LAYOUT_PREVIEW \(file.path)")
    }
}
