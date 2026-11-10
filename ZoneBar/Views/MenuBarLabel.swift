import SwiftUI

struct MenuBarLabel: View {
    let store: ClockStore
    let settings: AppSettings
    let ticker: TimeTicker
    let focusFilter: FocusClockFilter

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        let segments = MenuBarRenderer.segments(
            for: focusFilter.menuBarClocks(from: store.clocks),
            at: ticker.now,
            is24Hour: settings.is24Hour,
            compact: settings.compactMode,
            showDate: settings.showDate,
            showDayNightIcon: settings.showDayNightIcon,
            displayHours: settings.clockDisplayHours,
            localClockID: settings.localClockID,
            locale: settings.locale
        )
        let text = MenuBarClockText.attributedText(for: segments, separator: settings.separatorStyle)
        let calendarDay = settings.showMenuBarCalendar ? MenuBarCalendar.day(
            from: store.clocks,
            selectedClockID: settings.menuBarCalendarClockID,
            at: ticker.now,
            locale: settings.locale
        ) : nil
        let accessibilityLabel = [calendarDay?.accessibilityLabel, String(text.characters)]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "; ")

        Group {
            if segments.isEmpty && calendarDay == nil {
                Image(systemName: "clock")
            } else if let image = MenuBarClockText.image(
                for: text, calendarDay: calendarDay, separator: settings.separatorStyle,
                colorScheme: colorScheme, scale: displayScale
            ) {
                Image(nsImage: image)
                    .renderingMode(.original)
                    .accessibilityLabel(Text(verbatim: accessibilityLabel))
            } else {
                MenuBarContent(text: text, calendarDay: calendarDay, separator: settings.separatorStyle)
            }
        }
        // Size the status item from the current label, including when display
        // options shorten it. Recreate the label to discard its previous layout.
        .fixedSize()
        .id(LabelIdentity(text: text, calendarDay: calendarDay, separator: settings.separatorStyle))
        .background(StatusItemConfigurator().frame(width: 0, height: 0))
        .task { await focusFilter.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task { await focusFilter.refresh() }
        }
    }

    private struct LabelIdentity: Hashable {
        let text: AttributedString
        let calendarDay: MenuBarCalendar.Day?
        let separator: SeparatorStyle
    }
}
