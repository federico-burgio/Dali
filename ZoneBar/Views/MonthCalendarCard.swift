import SwiftUI

struct CalendarDayMarker: Identifiable {
    let id: String
    let name: String
    let color: Color
}

/// Presentation is separate from EventKit so the reference layout can be
/// previewed and verified without reading personal calendars.
struct MonthCalendarCard: View {
    let month: MonthCalendar
    let today: Date
    let selectedDate: Date
    let locale: Locale
    let markers: [Date: [CalendarDayMarker]]
    let previousMonth: () -> Void
    let nextMonth: () -> Void
    let goToToday: () -> Void
    let selectDay: (Date) -> Void

    @Environment(\.colorScheme) private var colorScheme

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

    var body: some View {
        VStack(spacing: 6) {
            header

            VStack(spacing: 4) {
                HStack(spacing: 3) {
                    ForEach(Array(month.weekdayTitles(locale: locale).enumerated()), id: \.offset) { _, title in
                        Text(verbatim: title.uppercased(with: locale))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 13)

                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(month.days) { day in
                        dayCell(day)
                    }
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.09 : 0.12), lineWidth: 0.75)
        }
    }

    private var header: some View {
        ZStack {
            Text(verbatim: month.monthTitle(locale: locale))
                .font(.system(size: 12.5, weight: .medium))
                .lineLimit(1)

            HStack(spacing: 2) {
                MonthCalendarNavigationButton(symbol: "calendar.badge.clock", title: "Today", action: goToToday)
                Spacer(minLength: 0)
                MonthCalendarNavigationButton(symbol: "chevron.left", title: "Previous month", action: previousMonth)
                MonthCalendarNavigationButton(symbol: "chevron.right", title: "Next month", action: nextMonth)
            }
        }
        .frame(height: 24)
    }

    private func dayCell(_ day: MonthCalendar.Day) -> some View {
        let selected = month.calendar.isDate(day.date, inSameDayAs: selectedDate)
        let isToday = month.calendar.isDate(day.date, inSameDayAs: today)
        let dots = Array((markers[day.date] ?? []).prefix(3))
        let description = month.dayDescription(day.date, locale: locale)

        return Button { selectDay(day.date) } label: {
            VStack(spacing: 1) {
                Text(day.number, format: .number.locale(locale))
                    .font(.system(size: 13, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(dayTextColor(selected: selected, inMonth: day.isInMonth, today: isToday))

                HStack(spacing: 1.5) {
                    ForEach(dots) { marker in
                        Circle().fill(marker.color).frame(width: 3, height: 3)
                    }
                }
                .frame(height: 3)
                .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(cellColor(selected: selected, inMonth: day.isInMonth))
            }
            .overlay {
                if selected {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(selectionColor, lineWidth: 1)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: description))
        .accessibilityValue(Text(verbatim: dots.map(\.name).joined(separator: ", ")))
        .accessibilityAddTraits(selected ? .isSelected : [])
        .help(Text(verbatim: ([description] + dots.map(\.name)).joined(separator: "\n")))
    }

    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(.sRGB, red: 37 / 255, green: 41 / 255, blue: 45 / 255, opacity: 1)
            : Color(nsColor: .controlBackgroundColor)
    }

    private func cellColor(selected: Bool, inMonth: Bool) -> Color {
        if selected {
            return colorScheme == .dark
                ? Color(.sRGB, red: 36 / 255, green: 67 / 255, blue: 105 / 255, opacity: 1)
                : selectionColor.opacity(0.9)
        }
        guard inMonth else { return .clear }
        return colorScheme == .dark
            ? Color(.sRGB, red: 33 / 255, green: 38 / 255, blue: 41 / 255, opacity: 1)
            : Color.primary.opacity(0.035)
    }

    private func dayTextColor(selected: Bool, inMonth: Bool, today: Bool) -> Color {
        if selected { return .white }
        if today { return selectionColor }
        return inMonth ? .primary : .secondary.opacity(0.75)
    }

    private var selectionColor: Color {
        Color(.sRGB, red: 22 / 255, green: 133 / 255, blue: 255 / 255, opacity: 1)
    }
}

private struct MonthCalendarNavigationButton: View {
    let symbol: String
    let title: LocalizedStringKey
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
                .background(Color.primary.opacity(isHovering ? 0.07 : 0), in: RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .help(Text(title))
        .onHover { isHovering = $0 }
    }
}
