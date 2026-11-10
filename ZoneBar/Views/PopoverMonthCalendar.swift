import SwiftUI

struct PopoverMonthCalendar: View {
    @Environment(AppSettings.self) private var settings
    @Environment(ClockStore.self) private var store
    @Environment(TimeTicker.self) private var ticker
    @Environment(CalendarEventService.self) private var calendarService

    // Nil follows the live date, including midnight while the menu is open.
    @State private var navigation = MonthCalendarNavigation()

    private var timeZone: TimeZone {
        MenuBarCalendar.selectedClock(from: store.clocks, id: settings.menuBarCalendarClockID)?.timeZone
            ?? .current
    }

    var body: some View {
        let month = MonthCalendar(containing: navigation.browsedMonth ?? ticker.now, timeZone: timeZone, locale: settings.locale)

        MonthCalendarCard(
            month: month,
            today: ticker.now,
            selectedDate: navigation.selectedDate ?? ticker.now,
            locale: settings.locale,
            markers: markers(for: month),
            previousMonth: { navigation.moveMonth(by: -1, in: month) },
            nextMonth: { navigation.moveMonth(by: 1, in: month) },
            goToToday: { navigation.goToToday() },
            selectDay: { navigation.selectDay($0, in: month) }
        )
        .task(id: month.visibleInterval) { calendarService.refreshMonth(in: month.visibleInterval) }
        .onChange(of: calendarService.accessState) { _, _ in
            calendarService.refreshMonth(in: month.visibleInterval)
        }
        .onChange(of: timeZone.identifier) { _, _ in
            navigation.goToToday()
        }
        .onDisappear { calendarService.clearMonth() }
    }

    private func markers(for month: MonthCalendar) -> [Date: [CalendarDayMarker]] {
        guard calendarService.accessState.canReadEvents else { return [:] }
        let calendars = calendarService.availableCalendars.filter {
            calendarService.isCalendarEnabled($0.calendarIdentifier)
        }
        let order = calendars.map(\.calendarIdentifier)
        let markers = Dictionary(uniqueKeysWithValues: calendars.map { calendar in
            (calendar.calendarIdentifier, CalendarDayMarker(
                id: calendar.calendarIdentifier,
                name: calendar.title,
                color: calendar.cgColor.map { Color(cgColor: $0) } ?? .accentColor
            ))
        })
        return Dictionary(uniqueKeysWithValues: month.days.map { day in
            (day.date, month.calendarIdentifiers(on: day.date, events: calendarService.monthEvents, calendarOrder: order)
                .compactMap { markers[$0] })
        })
    }
}
