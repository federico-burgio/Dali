import Foundation

/// Menu bar content and per-clock status, independent of UI and global state.
enum MenuBarRenderer {
    struct Segment: Hashable {
        let text: String
        let isQuiet: Bool
    }

    static func text(
        for clocks: [WorldClock],
        at now: Date,
        is24Hour: Bool,
        compact: Bool,
        showDate: Bool,
        showDayNightIcon: Bool,
        separator: SeparatorStyle,
        displayHours: ClockDisplayHours = .default,
        localClockID: UUID? = nil,
        locale: Locale = .current
    ) -> String {
        segments(
            for: clocks, at: now, is24Hour: is24Hour, compact: compact,
            showDate: showDate, showDayNightIcon: showDayNightIcon,
            displayHours: displayHours, localClockID: localClockID, locale: locale
        )
        .map(\.text)
        .joined(separator: separator.value)
    }

    static func segments(
        for clocks: [WorldClock],
        at now: Date,
        is24Hour: Bool,
        compact: Bool,
        showDate: Bool,
        showDayNightIcon: Bool,
        displayHours: ClockDisplayHours = .default,
        localClockID: UUID? = nil,
        locale: Locale = .current
    ) -> [Segment] {
        clocks.filter(\.showInMenuBar).map { clock in
            let isQuiet = displayHours.isQuiet(at: now, in: clock.timeZone)
            var parts: [String] = []
            if showDayNightIcon {
                parts.append(isQuiet ? "☾" : "☀")
            }
            if clock.id != localClockID {
                parts.append(compact ? clock.compactName : clock.name)
            }
            parts.append(clock.formattedTime(at: now, is24Hour: is24Hour, locale: locale))
            if showDate {
                parts.append(clock.formattedDate(at: now, locale: locale))
            }
            return Segment(text: parts.joined(separator: " "), isQuiet: isQuiet)
        }
    }
}
