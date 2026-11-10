import SwiftUI

struct MenuBarPane: View {
    @Environment(AppSettings.self) private var settings
    @Environment(ClockStore.self) private var store
    @Environment(TimeTicker.self) private var ticker
    @Environment(FocusClockFilter.self) private var focusFilter

    var body: some View {
        @Bindable var settings = settings

        SettingsPane(section: SettingsSection.menuBar) {
            SettingsGroup(header: "Preview") {
                HStack {
                    MenuBarContent(text: previewText, calendarDay: calendarDay, separator: settings.separatorStyle)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, SettingsLayout.cardHorizontalInset)
                .frame(minHeight: DS.Size.rowHeight)
            }

            SettingsGroup(header: "Display") {
                SettingRow(title: "Compact city names", subtitle: "New York → NY") {
                    Toggle("", isOn: $settings.compactMode)
                        .settingsToggle()
                }

                SettingsDivider()

                SettingRow(title: "Local clock", subtitle: "Show time without a city label") {
                    Picker("Local clock", selection: localClockBinding) {
                        Text("None").tag(UUID?.none)
                        ForEach(store.clocks) { clock in
                            Text(verbatim: clock.name).tag(Optional(clock.id))
                        }
                    }
                    .labelsHidden()
                    .frame(maxWidth: 150)
                }

                SettingsDivider()

                SettingRow(title: "Day / night icon", subtitle: "Prefix each clock with ☀ or ☾") {
                    Toggle("", isOn: $settings.showDayNightIcon)
                        .settingsToggle()
                }

                SettingsDivider()

                SettingRow(
                    title: "Show calendar",
                    subtitle: calendarClocks.isEmpty ? "Add a city first." : "Day number in the selected city"
                ) {
                    Toggle("", isOn: $settings.showMenuBarCalendar)
                        .settingsToggle()
                        .disabled(calendarClocks.isEmpty)
                }

                if settings.showMenuBarCalendar && !calendarClocks.isEmpty {
                    SettingsDivider()

                    SettingRow(title: "Calendar city") {
                        Picker("Calendar city", selection: calendarClockBinding) {
                            ForEach(calendarClocks) { clock in
                                Text(verbatim: clock.name).tag(Optional(clock.id))
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: 180)
                    }
                }

                SettingsDivider()

                SegmentedRow(title: "Separator", selection: $settings.separatorStyle, options: [
                    .init(value: .spaces, title: "Spaces", symbol: "space"),
                    .init(value: .dot, title: "Dot", glyph: "•"),
                    .init(value: .pipe, title: "Pipe", glyph: "|"),
                    .init(value: .slash, title: "Slash", glyph: "/"),
                ])
            }

            SettingsGroup(header: "Clock hours") {
                thresholdSlider(
                    title: "Morning threshold",
                    minute: $settings.morningThresholdMinute,
                    range: 0...Double(settings.nightThresholdMinute - ClockDisplayHours.step)
                )

                SettingsDivider()

                thresholdSlider(
                    title: "Night threshold",
                    minute: $settings.nightThresholdMinute,
                    range: Double(settings.morningThresholdMinute + ClockDisplayHours.step)...1440
                )
            }

            SettingsNote(
                text: "Clocks turn purple before the morning threshold and from the night threshold onward, using each clock’s local time.",
                fontSize: 11
            )

            SettingsNote(
                text: "Choose which clocks appear in the menu bar from the Clocks section.",
                fontSize: 11
            )
        }
    }

    private var calendarClocks: [WorldClock] {
        store.clocks.filter { $0.timeZone != nil }
    }

    private var localClockBinding: Binding<UUID?> {
        Binding(
            get: { store.clocks.contains { $0.id == settings.localClockID } ? settings.localClockID : nil },
            set: { settings.localClockID = $0 }
        )
    }

    private var calendarClockBinding: Binding<UUID?> {
        Binding(
            get: {
                MenuBarCalendar.selectedClock(from: store.clocks, id: settings.menuBarCalendarClockID)?.id
            },
            set: { settings.menuBarCalendarClockID = $0 }
        )
    }

    private var calendarDay: MenuBarCalendar.Day? {
        guard settings.showMenuBarCalendar else { return nil }
        return MenuBarCalendar.day(
            from: store.clocks,
            selectedClockID: settings.menuBarCalendarClockID,
            at: ticker.now,
            locale: settings.locale
        )
    }

    private func thresholdSlider(
        title: LocalizedStringKey,
        minute: Binding<Int>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(spacing: DS.Spacing.sm) {
            HStack {
                Text(title)
                    .font(.system(size: 13))
                Spacer()
                Text(thresholdTime(minute.wrappedValue))
                    .font(.system(size: 13, weight: .medium))
                    .monospacedDigit()
            }
            Slider(
                value: Binding(
                    get: { Double(minute.wrappedValue) },
                    set: { minute.wrappedValue = Int($0.rounded()) }
                ),
                in: range.lowerBound...max(range.lowerBound + Double(ClockDisplayHours.step), range.upperBound),
                step: Double(ClockDisplayHours.step)
            ) {
                Text(title)
            }
            .labelsHidden()
            .disabled(range.lowerBound == range.upperBound)
            .accessibilityValue(Text(thresholdTime(minute.wrappedValue)))
        }
        .padding(.horizontal, SettingsLayout.cardHorizontalInset)
        .padding(.vertical, SettingsLayout.cardVerticalInset)
    }

    private func thresholdTime(_ minute: Int) -> String {
        if minute == 1440 { return settings.language.localized("Midnight") }
        let formatter = DateFormatter()
        formatter.locale = settings.locale
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.setLocalizedDateFormatFromTemplate(settings.is24Hour ? "HHmm" : "hmma")
        return formatter.string(from: Date(timeIntervalSince1970: Double(minute * 60)))
    }

    private var previewText: AttributedString {
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
        if segments.isEmpty {
            return calendarDay == nil
                ? AttributedString(settings.language.localized("🕐  (no clocks selected)"))
                : AttributedString()
        }
        return MenuBarClockText.attributedText(for: segments, separator: settings.separatorStyle)
    }
}

#if DEBUG
#Preview("Menu Bar") {
    MenuBarPane()
        .settingsPreviewEnvironment()
        .frame(width: 400, height: 520, alignment: .top)
}
#endif
