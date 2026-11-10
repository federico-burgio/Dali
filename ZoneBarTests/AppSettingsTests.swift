import Foundation
import Testing
@testable import ZoneBar

struct AppSettingsTests {
    @Test func languageDefaultsToAutomatic() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)

        #expect(settings.language == .automatic)
        #expect(settings.locale == .autoupdatingCurrent)
    }

    @Test func languageOverridePersists() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        settings.language = .japanese

        let reloaded = AppSettings(defaults: defaults)
        #expect(reloaded.language == .japanese)
        #expect(reloaded.locale.language.languageCode?.identifier == "ja")
    }

    @Test func japaneseResourcesAreAvailable() {
        #expect(AppLanguage.japanese.localized("Settings") == "設定")
        #expect(AppLanguage.japanese.localized("Tomorrow") == "明日")
    }

    @Test func calendarEventsAreOptInAndPersist() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        #expect(!settings.showCalendarEvents)

        settings.showCalendarEvents = true
        #expect(AppSettings(defaults: defaults).showCalendarEvents)
    }

    @Test func clockHoursDefaultAndPersist() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        #expect(settings.morningThresholdMinute == 360)
        #expect(settings.nightThresholdMinute == 1200)

        settings.morningThresholdMinute = 510
        settings.nightThresholdMinute = 1290
        let reloaded = AppSettings(defaults: defaults)
        #expect(reloaded.morningThresholdMinute == 510)
        #expect(reloaded.nightThresholdMinute == 1290)
    }

    @Test func thresholdsStayOrderedAndInsideOneDay() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        settings.morningThresholdMinute = 1440
        #expect(settings.morningThresholdMinute == 1170)
        settings.nightThresholdMinute = 0
        #expect(settings.nightThresholdMinute == 1200)
        settings.morningThresholdMinute = -30
        settings.nightThresholdMinute = 1500
        #expect(settings.morningThresholdMinute == 0)
        #expect(settings.nightThresholdMinute == 1440)
        #expect(AppSettings(defaults: defaults).clockDisplayHours == settings.clockDisplayHours)
    }

    @Test func invalidSavedThresholdsAreNormalizedOnLoad() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(1440, forKey: "morningThresholdMinute")
        defaults.set(-10, forKey: "nightThresholdMinute")

        let settings = AppSettings(defaults: defaults)
        #expect(settings.morningThresholdMinute == 0)
        #expect(settings.nightThresholdMinute == 30)
    }

    @Test func menuBarCalendarIsOptInAndRemembersCityWhileDisabled() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let settings = AppSettings(defaults: defaults)
        #expect(!settings.showMenuBarCalendar)
        #expect(settings.menuBarCalendarClockID == nil)

        let cityID = UUID()
        settings.showMenuBarCalendar = true
        settings.menuBarCalendarClockID = cityID
        let reloaded = AppSettings(defaults: defaults)
        #expect(reloaded.showMenuBarCalendar)
        #expect(reloaded.menuBarCalendarClockID == cityID)

        reloaded.showMenuBarCalendar = false
        #expect(!AppSettings(defaults: defaults).showMenuBarCalendar)
        #expect(AppSettings(defaults: defaults).menuBarCalendarClockID == cityID)
    }

    @Test func localClockSelectionPersistsAndCanBeCleared() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let settings = AppSettings(defaults: defaults)
        #expect(settings.localClockID == nil)
        let id = UUID()
        settings.localClockID = id
        #expect(AppSettings(defaults: defaults).localClockID == id)
        settings.localClockID = nil
        #expect(AppSettings(defaults: defaults).localClockID == nil)
    }

    private func makeDefaults() throws -> (UserDefaults, String) {
        let suiteName = "AppSettingsTests.\(UUID().uuidString)"
        return (try #require(UserDefaults(suiteName: suiteName)), suiteName)
    }
}
