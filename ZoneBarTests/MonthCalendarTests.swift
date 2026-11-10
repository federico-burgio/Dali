import Foundation
import Testing
@testable import ZoneBar

struct MonthCalendarTests {
    private let utc = TimeZone(secondsFromGMT: 0)!
    private func date(_ value: String) -> Date { ISO8601DateFormatter().date(from: value)! }

    @Test func novemberMatchesReferenceWithMondayFirstAndSixRows() {
        let month = MonthCalendar(containing: date("2026-11-10T12:00:00Z"), timeZone: utc)
        #expect(month.days.count == 42)
        #expect(month.days.first?.date == date("2026-10-26T00:00:00Z"))
        #expect(month.days.last?.date == date("2026-12-06T00:00:00Z"))
        #expect(month.days.filter(\.isInMonth).count == 30)
        #expect(month.weekdayTitles(locale: Locale(identifier: "en_GB")) == ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
        #expect(month.monthTitle(locale: Locale(identifier: "en_GB")) == "NOVEMBER 2026")
    }

    @Test(arguments: [("2024-02-15T12:00:00Z", 29), ("2021-02-01T12:00:00Z", 28), ("2026-03-15T12:00:00Z", 31)])
    func leapYearsAndShortMonthsKeepStableGrid(instant: String, dayCount: Int) {
        let month = MonthCalendar(containing: date(instant), timeZone: utc)
        #expect(month.days.count == 42)
        #expect(month.days.filter(\.isInMonth).map(\.number) == Array(1...dayCount))
        #expect(month.calendar.component(.weekday, from: month.days[0].date) == 2)
    }

    @Test func navigationCrossesYearAndTodayResumesLiveDate() {
        let december = MonthCalendar(containing: date("2026-12-31T12:00:00Z"), timeZone: utc)
        var navigation = MonthCalendarNavigation()
        navigation.moveMonth(by: 1, in: december)
        #expect(navigation.browsedMonth == date("2027-01-01T00:00:00Z"))
        let january = MonthCalendar(containing: navigation.browsedMonth!, timeZone: utc)
        navigation.moveMonth(by: -1, in: january)
        #expect(navigation.browsedMonth == date("2026-12-01T00:00:00Z"))
        navigation.selectDay(date("2027-01-01T00:00:00Z"), in: december)
        #expect(navigation.selectedDate == date("2027-01-01T00:00:00Z"))
        #expect(navigation.browsedMonth == navigation.selectedDate)
        navigation.goToToday()
        #expect(navigation.browsedMonth == nil)
        #expect(navigation.selectedDate == nil)
    }

    @Test(arguments: [("2026-03-10T12:00:00Z", -3600.0), ("2026-11-10T12:00:00Z", 3600.0)])
    func gridUsesLocalDaysAcrossDaylightSaving(instant: String, adjustment: Double) {
        let month = MonthCalendar(containing: date(instant), timeZone: TimeZone(identifier: "America/New_York")!)
        #expect(month.visibleInterval.duration == 42 * 86400 + adjustment)
        #expect(month.days.allSatisfy { month.calendar.component(.hour, from: $0.date) == 0 })
        for pair in zip(month.days, month.days.dropFirst()) {
            #expect(month.calendar.dateComponents([.day], from: pair.0.date, to: pair.1.date).day == 1)
        }
    }

    @Test func markersAreDistinctAndLimitedToThreeInCalendarOrder() {
        let now = date("2026-11-10T12:00:00Z")
        let month = MonthCalendar(containing: now, timeZone: utc)
        let events = ["work", "work", "home", "travel", "other", "unknown"].map {
            CalendarMonthEvent(calendarIdentifier: $0, startDate: now, endDate: now.addingTimeInterval(3600))
        }
        #expect(month.calendarIdentifiers(on: now, events: events, calendarOrder: ["travel", "home", "work", "work", "other"]) == ["travel", "home", "work"])
        #expect(month.calendarIdentifiers(on: now, events: [], calendarOrder: ["work"]).isEmpty)
    }

    @Test func multiDayEventsExcludeTheirMidnightEndAndInvalidIntervals() {
        let month = MonthCalendar(containing: date("2026-11-10T12:00:00Z"), timeZone: utc)
        let events = [
            CalendarMonthEvent(calendarIdentifier: "work", startDate: date("2026-11-10T00:00:00Z"), endDate: date("2026-11-12T00:00:00Z")),
            CalendarMonthEvent(calendarIdentifier: "invalid", startDate: date("2026-11-10T12:00:00Z"), endDate: date("2026-11-10T12:00:00Z")),
        ]
        for day in [10, 11] {
            #expect(month.calendarIdentifiers(on: date("2026-11-\(day)T12:00:00Z"), events: events, calendarOrder: ["work", "invalid"]) == ["work"])
        }
        #expect(month.calendarIdentifiers(on: date("2026-11-12T00:00:00Z"), events: events, calendarOrder: ["work"]).isEmpty)
    }

    @Test func eventDotsFollowCalendarCityTimezone() {
        let now = date("2026-11-10T00:30:00Z")
        let month = MonthCalendar(containing: now, timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        let event = CalendarMonthEvent(calendarIdentifier: "work", startDate: now, endDate: now.addingTimeInterval(600))
        let ninth = month.days.first { $0.isInMonth && $0.number == 9 }!
        let tenth = month.days.first { $0.isInMonth && $0.number == 10 }!
        #expect(month.calendarIdentifiers(on: ninth.date, events: [event], calendarOrder: ["work"]) == ["work"])
        #expect(month.calendarIdentifiers(on: tenth.date, events: [event], calendarOrder: ["work"]).isEmpty)
    }
}
