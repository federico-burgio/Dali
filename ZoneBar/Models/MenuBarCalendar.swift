import Foundation

enum MenuBarCalendar {
    struct Day: Hashable {
        let number: Int
        let accessibilityLabel: String
    }

    /// The selected city stays independent of menu bar visibility and Focus.
    /// If it is deleted, use the first remaining city with a valid timezone.
    static func selectedClock(from clocks: [WorldClock], id: UUID?) -> WorldClock? {
        clocks.first { $0.id == id && $0.timeZone != nil }
            ?? clocks.first { $0.timeZone != nil }
    }

    static func day(
        from clocks: [WorldClock],
        selectedClockID: UUID?,
        at date: Date,
        locale: Locale = .current
    ) -> Day? {
        guard let clock = selectedClock(from: clocks, id: selectedClockID),
              let timeZone = clock.timeZone else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return Day(
            number: calendar.component(.day, from: date),
            accessibilityLabel: "\(clock.name), \(formatter.string(from: date))"
        )
    }
}
