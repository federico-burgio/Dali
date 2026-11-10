import EventKit
import Foundation
import Testing
@testable import ZoneBar

@MainActor
struct CalendarSelectionTests {
    @MainActor
    private final class Fixture {
        let suiteName = "ZoneBar.CalendarSelectionTests.\(UUID().uuidString)"
        let defaults: UserDefaults
        let store = EKEventStore()
        let date = Date(timeIntervalSince1970: 1_792_624_200)
        var calendars: [EKCalendar] = []
        var items: [EKEvent] = []
        var calendarReads = 0
        var eventReads = 0
        var requestedIntervals: [DateInterval] = []
        let notifications = NotificationCenter()

        init() { defaults = UserDefaults(suiteName: suiteName)! }
        deinit { defaults.removePersistentDomain(forName: suiteName) }

        func addCalendar(_ name: String) -> EKCalendar {
            let calendar = EKCalendar(for: .event, eventStore: store)
            calendar.title = name
            calendars.append(calendar)
            return calendar
        }

        func addEvent(_ title: String, from calendar: EKCalendar) {
            let event = EKEvent(eventStore: store)
            event.calendar = calendar
            event.title = title
            event.startDate = date
            event.endDate = date.addingTimeInterval(3_600)
            items.append(event)
        }

        func makeService(access: CalendarAccessState = .connected) -> CalendarEventService {
            CalendarEventService(
                eventStore: store,
                notificationCenter: notifications,
                accessStateOverride: access,
                eventFetcher: { start, end in
                    self.eventReads += 1
                    self.requestedIntervals.append(DateInterval(start: start, end: end))
                    return self.items
                },
                calendarFetcher: {
                    self.calendarReads += 1
                    return self.calendars
                },
                defaults: defaults
            )
        }
    }

    @Test func existingAndNewCalendarsDefaultToBothAndEnabled() {
        let fixture = Fixture()
        let work = fixture.addCalendar("Work")
        fixture.addEvent("Meeting", from: work)
        fixture.addEvent("Out of office", from: work)
        let service = fixture.makeService()
        service.refresh(for: fixture.date)
        #expect(service.isCalendarEnabled(work.calendarIdentifier))
        #expect(service.displayMode(for: work.calendarIdentifier) == .both)
        #expect(service.events.count == 2)

        let home = fixture.addCalendar("Home")
        fixture.addEvent("Appointment", from: home)
        service.refresh(for: fixture.date)
        #expect(service.availableCalendars.count == 2)
        #expect(service.isCalendarEnabled(home.calendarIdentifier))
        #expect(service.events.count == 3)
    }

    @Test func duplicateTitlesKeepIndependentSelectionsAndPersistAcrossRestart() throws {
        let fixture = Fixture()
        let first = fixture.addCalendar("Work")
        let second = fixture.addCalendar("Work")
        #expect(first.calendarIdentifier != second.calendarIdentifier)
        fixture.addEvent("First account", from: first)
        fixture.addEvent("Second account", from: second)
        let service = fixture.makeService()
        service.refresh(for: fixture.date)
        service.setCalendarEnabled(first.calendarIdentifier, enabled: false)
        #expect(service.events.map(\.title) == ["Second account"])
        #expect(service.events(at: fixture.date).map(\.title) == ["Second account"])
        #expect(service.availableCalendars.count == 2)

        let reloaded = fixture.makeService()
        reloaded.refresh(for: fixture.date)
        #expect(!reloaded.isCalendarEnabled(first.calendarIdentifier))
        #expect(reloaded.isCalendarEnabled(second.calendarIdentifier))
        #expect(reloaded.events.map(\.title) == ["Second account"])
        #expect(try #require(reloaded.events.first).calendarIdentifier == second.calendarIdentifier)
    }

    @Test func uncheckingEveryCalendarShowsNothingAndReenablingRestoresEvents() {
        let fixture = Fixture()
        let first = fixture.addCalendar("Work")
        let second = fixture.addCalendar("Home")
        fixture.addEvent("Meeting", from: first)
        fixture.addEvent("Appointment", from: second)
        let service = fixture.makeService()
        service.refresh(for: fixture.date)
        service.setCalendarEnabled(first.calendarIdentifier, enabled: false)
        service.setCalendarEnabled(second.calendarIdentifier, enabled: false)
        #expect(service.events.isEmpty)
        #expect(service.events(at: fixture.date).isEmpty)
        #expect(service.availableCalendars.count == 2)
        service.setCalendarEnabled(second.calendarIdentifier, enabled: true)
        #expect(service.events.map(\.title) == ["Appointment"])
    }

    @Test func modesFilterEachCalendarImmediatelyAndPersistWhenDisabled() {
        let fixture = Fixture()
        let work = fixture.addCalendar("Work")
        let home = fixture.addCalendar("Home")
        fixture.addEvent("Meeting", from: work)
        fixture.addEvent("OOO", from: work)
        fixture.addEvent("Appointment", from: home)
        let service = fixture.makeService()
        service.refresh(for: fixture.date)
        service.setDisplayMode(.events, for: work.calendarIdentifier)
        #expect(Set(service.events.map(\.title)) == ["Meeting", "Appointment"])
        service.setDisplayMode(.unavailable, for: work.calendarIdentifier)
        #expect(Set(service.events.map(\.title)) == ["OOO", "Appointment"])
        service.setCalendarEnabled(work.calendarIdentifier, enabled: false)
        #expect(service.events.map(\.title) == ["Appointment"])

        let reloaded = fixture.makeService()
        #expect(reloaded.displayMode(for: work.calendarIdentifier) == .unavailable)
        #expect(!reloaded.isCalendarEnabled(work.calendarIdentifier))
        reloaded.setCalendarEnabled(work.calendarIdentifier, enabled: true)
        #expect(Set(reloaded.events.map(\.title)) == ["OOO", "Appointment"])
        reloaded.setDisplayMode(.both, for: work.calendarIdentifier)
        #expect(reloaded.events.count == 3)
    }

    @Test func removingAndReaddingCalendarKeepsItsPreferences() {
        let fixture = Fixture()
        let work = fixture.addCalendar("Work")
        let service = fixture.makeService()
        service.setDisplayMode(.events, for: work.calendarIdentifier)
        service.setCalendarEnabled(work.calendarIdentifier, enabled: false)
        fixture.calendars = []
        service.refreshCalendars()
        #expect(service.availableCalendars.isEmpty)
        fixture.calendars = [work]
        service.refreshCalendars()
        #expect(service.availableCalendars.count == 1)
        #expect(!service.isCalendarEnabled(work.calendarIdentifier))
        #expect(service.displayMode(for: work.calendarIdentifier) == .events)
    }

    @Test(arguments: [CalendarAccessState.notDetermined, .denied, .restricted, .writeOnly])
    func noCalendarOrEventReadsWithoutPermission(_ access: CalendarAccessState) {
        let fixture = Fixture()
        let service = fixture.makeService(access: access)
        service.refreshCalendars()
        service.refresh(for: fixture.date)
        service.refreshMonth(in: MonthCalendar(containing: fixture.date, timeZone: TimeZone(secondsFromGMT: 0)!).visibleInterval)
        #expect(service.availableCalendars.isEmpty)
        #expect(service.events.isEmpty)
        #expect(service.monthEvents.isEmpty)
        #expect(fixture.calendarReads == 0)
        #expect(fixture.eventReads == 0)
    }

    @Test func monthIncludesAllDayEventsWithoutReplacingTimelineEvents() {
        let fixture = Fixture()
        let work = fixture.addCalendar("Work")
        fixture.addEvent("Meeting", from: work)
        let allDay = EKEvent(eventStore: fixture.store)
        allDay.calendar = work
        allDay.title = "Birthday"
        allDay.isAllDay = true
        allDay.startDate = Calendar.current.startOfDay(for: fixture.date)
        allDay.endDate = Calendar.current.date(byAdding: .day, value: 1, to: allDay.startDate)
        fixture.items.append(allDay)
        let service = fixture.makeService()
        service.refresh(for: fixture.date)
        let timelineEvents = service.events
        #expect(timelineEvents.count == 1)
        let month = MonthCalendar(containing: fixture.date, timeZone: TimeZone(secondsFromGMT: 0)!)
        service.refreshMonth(in: month.visibleInterval)
        #expect(service.monthEvents.count == 2)
        #expect(service.events == timelineEvents)
        #expect(fixture.requestedIntervals.last == month.visibleInterval)
    }

    @Test func monthSelectionsAndModesUpdateImmediatelyAndAllUncheckedMeansNoReads() {
        let fixture = Fixture()
        let work = fixture.addCalendar("Work")
        let home = fixture.addCalendar("Home")
        fixture.addEvent("Meeting", from: work)
        fixture.addEvent("OOO", from: work)
        fixture.addEvent("Appointment", from: home)
        let service = fixture.makeService()
        let range = MonthCalendar(containing: fixture.date, timeZone: TimeZone(secondsFromGMT: 0)!).visibleInterval
        service.refreshMonth(in: range)
        #expect(service.monthEvents.count == 3)
        service.setDisplayMode(.unavailable, for: work.calendarIdentifier)
        #expect(service.monthEvents.count == 2)
        service.setCalendarEnabled(work.calendarIdentifier, enabled: false)
        #expect(service.monthEvents.map(\.calendarIdentifier) == [home.calendarIdentifier])
        service.setCalendarEnabled(home.calendarIdentifier, enabled: false)
        let reads = fixture.eventReads
        service.refreshMonth(in: range)
        #expect(service.monthEvents.isEmpty)
        #expect(fixture.eventReads == reads)
    }

    @Test func storeChangesRefreshBrowsedMonthAndClosingReleasesMonthQuery() async throws {
        let fixture = Fixture()
        let work = fixture.addCalendar("Work")
        fixture.addEvent("Meeting", from: work)
        let service = fixture.makeService()
        let range = MonthCalendar(containing: fixture.date, timeZone: TimeZone(secondsFromGMT: 0)!).visibleInterval
        service.refresh(for: fixture.date)
        service.refreshMonth(in: range)
        fixture.addEvent("New event", from: work)
        fixture.notifications.post(name: .EKEventStoreChanged, object: fixture.store)
        try await Task.sleep(for: .milliseconds(50))
        #expect(service.monthEvents.count == 2)
        #expect(fixture.requestedIntervals.last == range)
        service.clearMonth()
        #expect(service.monthEvents.isEmpty)
        service.setDisplayMode(.events, for: work.calendarIdentifier)
        #expect(fixture.requestedIntervals.last?.duration ?? 0 <= 25 * 3600)
    }

    @Test func monthQueryClipsResultsToVisibleRange() {
        let fixture = Fixture()
        let work = fixture.addCalendar("Work")
        fixture.addEvent("Meeting", from: work)
        fixture.addEvent("Outside", from: work)
        fixture.items[1].startDate = fixture.date.addingTimeInterval(100 * 86400)
        fixture.items[1].endDate = fixture.items[1].startDate.addingTimeInterval(3600)
        let service = fixture.makeService()
        service.refreshMonth(in: MonthCalendar(containing: fixture.date, timeZone: TimeZone(secondsFromGMT: 0)!).visibleInterval)
        #expect(service.monthEvents.count == 1)
    }

    @Test func unsupportedSavedModesFallBackToBothWithoutLosingExclusions() {
        let fixture = Fixture()
        fixture.defaults.set(["work": "future-mode", "home": "events"], forKey: "calendarDisplayModes")
        fixture.defaults.set(["work"], forKey: "excludedCalendarIDs")
        let service = fixture.makeService()
        #expect(service.displayMode(for: "work") == .both)
        #expect(service.displayMode(for: "home") == .events)
        #expect(!service.isCalendarEnabled("work"))
    }
}
