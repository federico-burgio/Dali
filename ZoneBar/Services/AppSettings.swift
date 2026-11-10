import Foundation
import Observation

@Observable
final class AppSettings {
    var is24Hour: Bool {
        didSet { defaults.set(is24Hour, forKey: Keys.is24Hour) }
    }

    var showDate: Bool {
        didSet { defaults.set(showDate, forKey: Keys.showDate) }
    }

    var compactMode: Bool {
        didSet { defaults.set(compactMode, forKey: Keys.compactMode) }
    }

    var showDayNightIcon: Bool {
        didSet { defaults.set(showDayNightIcon, forKey: Keys.showDayNightIcon) }
    }

    var showMenuBarCalendar: Bool {
        didSet { defaults.set(showMenuBarCalendar, forKey: Keys.showMenuBarCalendar) }
    }

    var menuBarCalendarClockID: UUID? {
        didSet { defaults.set(menuBarCalendarClockID?.uuidString, forKey: Keys.menuBarCalendarClockID) }
    }

    var localClockID: UUID? {
        didSet { defaults.set(localClockID?.uuidString, forKey: Keys.localClockID) }
    }

    var morningThresholdMinute: Int {
        get { storedMorningThresholdMinute }
        set {
            storedMorningThresholdMinute = min(nightThresholdMinute - ClockDisplayHours.step, max(0, newValue))
        }
    }

    var nightThresholdMinute: Int {
        get { storedNightThresholdMinute }
        set {
            storedNightThresholdMinute = min(1440, max(morningThresholdMinute + ClockDisplayHours.step, newValue))
        }
    }

    private var storedMorningThresholdMinute: Int {
        didSet { defaults.set(storedMorningThresholdMinute, forKey: Keys.morningThresholdMinute) }
    }

    private var storedNightThresholdMinute: Int {
        didSet { defaults.set(storedNightThresholdMinute, forKey: Keys.nightThresholdMinute) }
    }

    var clockDisplayHours: ClockDisplayHours {
        ClockDisplayHours(morningMinute: morningThresholdMinute, nightMinute: nightThresholdMinute)
    }

    var separatorStyle: SeparatorStyle {
        didSet { defaults.set(separatorStyle.rawValue, forKey: Keys.separatorStyle) }
    }

    var theme: AppTheme {
        didSet { defaults.set(theme.rawValue, forKey: Keys.theme) }
    }

    var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }

    var showCalendarEvents: Bool {
        didSet { defaults.set(showCalendarEvents, forKey: Keys.showCalendarEvents) }
    }

    var showPopoverCalendar: Bool {
        didSet { defaults.set(showPopoverCalendar, forKey: Keys.showPopoverCalendar) }
    }

    var locale: Locale { language.locale }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        defaults.register(defaults: [
            Keys.is24Hour: true,
            Keys.showDate: false,
            Keys.compactMode: false,
            Keys.showDayNightIcon: false,
            Keys.showMenuBarCalendar: false,
            Keys.morningThresholdMinute: ClockDisplayHours.default.morningMinute,
            Keys.nightThresholdMinute: ClockDisplayHours.default.nightMinute,
            Keys.separatorStyle: SeparatorStyle.spaces.rawValue,
            Keys.theme: AppTheme.system.rawValue,
            Keys.language: AppLanguage.automatic.rawValue,
            Keys.showCalendarEvents: false,
            Keys.showPopoverCalendar: false,
        ])

        is24Hour = defaults.bool(forKey: Keys.is24Hour)
        showDate = defaults.bool(forKey: Keys.showDate)
        compactMode = defaults.bool(forKey: Keys.compactMode)
        showDayNightIcon = defaults.bool(forKey: Keys.showDayNightIcon)
        showMenuBarCalendar = defaults.bool(forKey: Keys.showMenuBarCalendar)
        menuBarCalendarClockID = defaults.string(forKey: Keys.menuBarCalendarClockID).flatMap(UUID.init(uuidString:))
        localClockID = defaults.string(forKey: Keys.localClockID).flatMap(UUID.init(uuidString:))
        let hours = ClockDisplayHours(
            morningMinute: defaults.integer(forKey: Keys.morningThresholdMinute),
            nightMinute: defaults.integer(forKey: Keys.nightThresholdMinute)
        )
        storedMorningThresholdMinute = hours.morningMinute
        storedNightThresholdMinute = hours.nightMinute
        separatorStyle = SeparatorStyle(rawValue: defaults.string(forKey: Keys.separatorStyle) ?? "") ?? .spaces
        theme = AppTheme(rawValue: defaults.string(forKey: Keys.theme) ?? "") ?? .system
        language = AppLanguage(rawValue: defaults.string(forKey: Keys.language) ?? "") ?? .automatic
        showCalendarEvents = defaults.bool(forKey: Keys.showCalendarEvents)
        showPopoverCalendar = defaults.bool(forKey: Keys.showPopoverCalendar)
    }

    private enum Keys {
        static let is24Hour = "is24Hour"
        static let showDate = "showDate"
        static let compactMode = "compactMode"
        static let showDayNightIcon = "showDayNightIcon"
        static let showMenuBarCalendar = "showMenuBarCalendar"
        static let menuBarCalendarClockID = "menuBarCalendarClockID"
        static let localClockID = "localClockID"
        static let morningThresholdMinute = "morningThresholdMinute"
        static let nightThresholdMinute = "nightThresholdMinute"
        static let separatorStyle = "separatorStyle"
        static let theme = "appearanceMode"
        static let language = "appLanguage"
        static let showCalendarEvents = "showCalendarEvents"
        static let showPopoverCalendar = "showPopoverCalendar"
    }
}
