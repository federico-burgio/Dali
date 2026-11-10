import Foundation

struct CalendarMonthEvent: Equatable {
    let calendarIdentifier: String
    let startDate: Date
    let endDate: Date
}

struct MonthCalendarNavigation {
    private(set) var browsedMonth: Date?
    private(set) var selectedDate: Date?

    mutating func moveMonth(by offset: Int, in month: MonthCalendar) {
        browsedMonth = month.adjacentMonth(offset)
    }

    mutating func selectDay(_ date: Date, in month: MonthCalendar) {
        selectedDate = date
        if !month.calendar.isDate(date, equalTo: month.monthStart, toGranularity: .month) {
            browsedMonth = date
        }
    }

    // Nil resumes following the live date, rather than freezing at click time.
    mutating func goToToday() {
        browsedMonth = nil
        selectedDate = nil
    }
}

/// A Monday-first, six-week grid. Calendar arithmetic preserves local days
/// across daylight-saving changes and includes the adjacent-month dates.
struct MonthCalendar {
    struct Day: Identifiable {
        var id: Date { date }
        let date: Date
        let number: Int
        let isInMonth: Bool
    }

    let calendar: Calendar
    let monthStart: Date
    let days: [Day]
    let visibleInterval: DateInterval

    init(containing date: Date, timeZone: TimeZone, locale: Locale = .current) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = locale
        calendar.firstWeekday = 2
        self.calendar = calendar
        let monthStart = calendar.dateInterval(of: .month, for: date)!.start
        self.monthStart = monthStart
        let leadingDays = (calendar.component(.weekday, from: monthStart) + 5) % 7
        let start = calendar.date(byAdding: .day, value: -leadingDays, to: monthStart)!
        let end = calendar.date(byAdding: .day, value: 42, to: start)!
        visibleInterval = DateInterval(start: start, end: end)
        days = (0..<42).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            return Day(
                date: day,
                number: calendar.component(.day, from: day),
                isInMonth: calendar.isDate(day, equalTo: monthStart, toGranularity: .month)
            )
        }
    }

    func adjacentMonth(_ offset: Int) -> Date {
        calendar.date(byAdding: .month, value: offset, to: monthStart)!
    }

    func monthTitle(locale: Locale) -> String {
        let formatter = dateFormatter(locale: locale)
        formatter.setLocalizedDateFormatFromTemplate("LLLLyyyy")
        return formatter.string(from: monthStart).uppercased(with: locale)
    }

    func weekdayTitles(locale: Locale) -> [String] {
        let symbols = dateFormatter(locale: locale).shortStandaloneWeekdaySymbols!
        return Array(symbols.dropFirst()) + [symbols[0]]
    }

    func dayDescription(_ date: Date, locale: Locale) -> String {
        let formatter = dateFormatter(locale: locale)
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    /// One dot per distinct enabled calendar, in stable calendar order.
    /// An event ending at midnight does not mark the following day.
    func calendarIdentifiers(
        on date: Date,
        events: [CalendarMonthEvent],
        calendarOrder: [String]
    ) -> [String] {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let present = Set(events.lazy.filter {
            $0.startDate < $0.endDate && $0.startDate < end && $0.endDate > start
        }.map(\.calendarIdentifier))
        var seen = Set<String>()
        var result: [String] = []
        for identifier in calendarOrder where present.contains(identifier) && seen.insert(identifier).inserted {
            result.append(identifier)
            if result.count == 3 { break }
        }
        return result
    }

    private func dateFormatter(locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        return formatter
    }
}
