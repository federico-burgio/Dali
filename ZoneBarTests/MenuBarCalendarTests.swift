import Foundation
import Testing
@testable import ZoneBar

struct MenuBarCalendarTests {
    @Test func dateFollowsSelectedCityAcrossMonthBoundaries() throws {
        let london = WorldClock(name: "London", country: "GB", timezone: "Europe/London")
        let tokyo = WorldClock(name: "Tokyo", country: "JP", timezone: "Asia/Tokyo")
        let now = try #require(ISO8601DateFormatter().date(from: "2024-01-31T23:30:00Z"))
        let clocks = [london, tokyo]

        let londonDay = try #require(MenuBarCalendar.day(from: clocks, selectedClockID: london.id, at: now))
        let tokyoDay = try #require(MenuBarCalendar.day(from: clocks, selectedClockID: tokyo.id, at: now))
        #expect(londonDay.number == 31)
        #expect(tokyoDay.number == 1)
        #expect(tokyoDay.accessibilityLabel.contains("Tokyo"))
    }

    @Test(arguments: [
        ("2024-02-29T14:59:59Z", 29),
        ("2024-02-29T15:00:00Z", 1),
        ("2024-12-31T14:59:59Z", 31),
        ("2024-12-31T15:00:00Z", 1),
    ])
    func midnightRollsOverLeapDayAndYear(instant: String, expectedDay: Int) throws {
        let tokyo = WorldClock(name: "Tokyo", country: "JP", timezone: "Asia/Tokyo")
        let now = try #require(ISO8601DateFormatter().date(from: instant))
        #expect(MenuBarCalendar.day(from: [tokyo], selectedClockID: tokyo.id, at: now)?.number == expectedDay)
    }

    @Test(arguments: [
        ("2024-01-01T04:59:59Z", 31),
        ("2024-01-01T05:00:00Z", 1),
        ("2024-07-01T03:59:59Z", 30),
        ("2024-07-01T04:00:00Z", 1),
    ])
    func midnightFollowsDaylightSavingOffset(instant: String, expectedDay: Int) throws {
        let newYork = WorldClock(name: "New York", country: "US", timezone: "America/New_York")
        let now = try #require(ISO8601DateFormatter().date(from: instant))
        #expect(MenuBarCalendar.day(from: [newYork], selectedClockID: newYork.id, at: now)?.number == expectedDay)
    }

    @Test func selectionSurvivesReorderingRenamingAndHidingClock() throws {
        let london = WorldClock(name: "London", country: "GB", timezone: "Europe/London")
        var tokyo = WorldClock(name: "Tokyo", country: "JP", timezone: "Asia/Tokyo")
        tokyo.name = "Home"
        tokyo.showInMenuBar = false
        let now = try #require(ISO8601DateFormatter().date(from: "2024-01-31T23:30:00Z"))
        let day = try #require(MenuBarCalendar.day(from: [tokyo, london], selectedClockID: tokyo.id, at: now))
        #expect(day.number == 1)
        #expect(day.accessibilityLabel.contains("Home"))
    }

    @Test func deletedCityFallsBackToFirstValidSavedCity() {
        let invalid = WorldClock(name: "Invalid", country: "", timezone: "Not/AZone")
        let tokyo = WorldClock(name: "Tokyo", country: "JP", timezone: "Asia/Tokyo")
        let london = WorldClock(name: "London", country: "GB", timezone: "Europe/London")
        #expect(MenuBarCalendar.selectedClock(from: [invalid, tokyo, london], id: UUID())?.id == tokyo.id)
        #expect(MenuBarCalendar.selectedClock(from: [tokyo, london], id: london.id)?.id == london.id)
        #expect(MenuBarCalendar.selectedClock(from: [london, tokyo], id: nil)?.id == london.id)
        #expect(MenuBarCalendar.day(from: [], selectedClockID: nil, at: Date()) == nil)
        #expect(MenuBarCalendar.day(from: [invalid], selectedClockID: invalid.id, at: Date()) == nil)
    }
}
