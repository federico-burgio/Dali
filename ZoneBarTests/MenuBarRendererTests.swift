import Testing
import Foundation
@testable import ZoneBar

struct MenuBarRendererTests {
    // Fixed instant: 2024-01-01 12:00:00 UTC
    private let now = Date(timeIntervalSince1970: 1_704_110_400)

    private func clock(_ name: String, _ tz: String, menuBar: Bool = true) -> WorldClock {
        WorldClock(name: name, country: "", timezone: tz, showInMenuBar: menuBar)
    }

    @Test func emptyWhenNoClocks() {
        let text = MenuBarRenderer.text(for: [], at: now, is24Hour: true, compact: false, showDate: false, showDayNightIcon: false, separator: .spaces)
        #expect(text.isEmpty)
    }

    @Test func emptyWhenNoneVisible() {
        let clocks = [clock("Tokyo", "Asia/Tokyo", menuBar: false)]
        let text = MenuBarRenderer.text(for: clocks, at: now, is24Hour: true, compact: false, showDate: false, showDayNightIcon: false, separator: .spaces)
        #expect(text.isEmpty)
    }

    @Test func rendersNameAndTime24Hour() {
        let clocks = [clock("London", "Europe/London")]
        let text = MenuBarRenderer.text(for: clocks, at: now, is24Hour: true, compact: false, showDate: false, showDayNightIcon: false, separator: .spaces)
        #expect(text == "London 12:00")
    }

    @Test func twelveHourFormat() {
        let clocks = [clock("London", "Europe/London")]
        let text = MenuBarRenderer.text(for: clocks, at: now, is24Hour: false, compact: false, showDate: false, showDayNightIcon: false, separator: .spaces)
        #expect(text.contains("12:00") && text.contains("PM"))
    }

    @Test func compactNameAbbreviates() {
        let clocks = [clock("New York", "America/New_York")]
        let text = MenuBarRenderer.text(for: clocks, at: now, is24Hour: true, compact: true, showDate: false, showDayNightIcon: false, separator: .spaces)
        #expect(text.hasPrefix("NY "))
    }

    @Test func onlyVisibleClocksRendered() {
        let clocks = [
            clock("London", "Europe/London"),
            clock("Tokyo", "Asia/Tokyo", menuBar: false),
        ]
        let text = MenuBarRenderer.text(for: clocks, at: now, is24Hour: true, compact: false, showDate: false, showDayNightIcon: false, separator: .spaces)
        #expect(text.contains("London"))
        #expect(!text.contains("Tokyo"))
    }

    @Test func separatorJoinsMultipleClocks() {
        let clocks = [clock("London", "Europe/London"), clock("UTC", "UTC")]
        let text = MenuBarRenderer.text(for: clocks, at: now, is24Hour: true, compact: false, showDate: false, showDayNightIcon: false, separator: .pipe)
        #expect(text.contains("|"))
    }

    @Test func dayNightIconPrefix() {
        let clocks = [clock("London", "Europe/London")] // noon → day
        let text = MenuBarRenderer.text(for: clocks, at: now, is24Hour: true, compact: false, showDate: false, showDayNightIcon: true, separator: .spaces)
        #expect(text.hasPrefix("☀"))
    }

    @Test(arguments: [true, false])
    func localClockOmitsOnlyItsCityInFullAndCompactModes(compact: Bool) {
        let london = clock("London", "Europe/London")
        let tokyo = clock("Tokyo", "Asia/Tokyo")
        let text = MenuBarRenderer.text(
            for: [london, tokyo], at: now, is24Hour: true, compact: compact,
            showDate: false, showDayNightIcon: false, separator: .pipe,
            localClockID: london.id, locale: Locale(identifier: "en_GB")
        )
        #expect(text == (compact ? "12:00  |  TOK 21:00" : "12:00  |  Tokyo 21:00"))
    }

    @Test func localClockKeepsItsDateIconAndQuietStatus() {
        let tokyo = clock("Tokyo", "Asia/Tokyo")
        let segments = MenuBarRenderer.segments(
            for: [tokyo], at: now, is24Hour: false, compact: false,
            showDate: true, showDayNightIcon: true,
            localClockID: tokyo.id, locale: Locale(identifier: "en_US")
        )
        #expect(segments.count == 1)
        #expect(segments[0].isQuiet)
        #expect(segments[0].text.hasPrefix("☾ 9:00"))
        #expect(segments[0].text.contains("PM"))
        #expect(segments[0].text.contains("Jan"))
        #expect(!segments[0].text.contains("Tokyo"))
    }

    @Test func missingOrHiddenLocalClockDoesNotHideAnotherCity() {
        let london = clock("London", "Europe/London")
        let hidden = clock("Tokyo", "Asia/Tokyo", menuBar: false)
        for localID in [UUID(), hidden.id] {
            let text = MenuBarRenderer.text(
                for: [london, hidden], at: now, is24Hour: true, compact: false,
                showDate: false, showDayNightIcon: false, separator: .spaces,
                localClockID: localID, locale: Locale(identifier: "en_GB")
            )
            #expect(text == "London 12:00")
        }
    }

    @Test func quietStatusAndIconsFollowCustomHoursPerClock() {
        let clocks = [
            clock("London", "Europe/London"),
            clock("Tokyo", "Asia/Tokyo"),
            clock("Hidden", "UTC", menuBar: false),
        ]
        let segments = MenuBarRenderer.segments(
            for: clocks, at: now, is24Hour: true, compact: false,
            showDate: false, showDayNightIcon: true,
            displayHours: ClockDisplayHours(morningMinute: 480, nightMinute: 1200),
            locale: Locale(identifier: "en_GB")
        )
        #expect(segments == [
            .init(text: "☀ London 12:00", isQuiet: false),
            .init(text: "☾ Tokyo 21:00", isQuiet: true),
        ])

        let laterMorning = MenuBarRenderer.segments(
            for: clocks, at: now, is24Hour: true, compact: false,
            showDate: false, showDayNightIcon: false,
            displayHours: ClockDisplayHours(morningMinute: 780, nightMinute: 1320)
        )
        #expect(laterMorning.map(\.isQuiet) == [true, false])
    }
}
