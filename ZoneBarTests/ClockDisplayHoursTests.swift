import Foundation
import Testing
@testable import ZoneBar

struct ClockDisplayHoursTests {
    private let utc = TimeZone(secondsFromGMT: 0)!

    @Test(arguments: [
        ("2024-01-01T08:29:59Z", true),
        ("2024-01-01T08:30:00Z", false),
        ("2024-01-01T21:29:59Z", false),
        ("2024-01-01T21:30:00Z", true),
        ("2024-01-02T00:00:00Z", true),
    ])
    func thresholdsUseLocalWallClockMinutes(instant: String, isQuiet: Bool) throws {
        let hours = ClockDisplayHours(morningMinute: 510, nightMinute: 1290)
        let date = try #require(ISO8601DateFormatter().date(from: instant))
        #expect(hours.isQuiet(at: date, in: utc) == isQuiet)
    }

    @Test func eachTimezoneHasItsOwnStatus() throws {
        let date = try #require(ISO8601DateFormatter().date(from: "2024-01-01T12:00:00Z"))
        let hours = ClockDisplayHours(morningMinute: 480, nightMinute: 1200)
        #expect(!hours.isQuiet(at: date, in: utc))
        #expect(hours.isQuiet(at: date, in: TimeZone(identifier: "America/Los_Angeles")))
        #expect(hours.isQuiet(at: date, in: TimeZone(identifier: "Asia/Tokyo")))
        #expect(!hours.isQuiet(at: date, in: TimeZone(identifier: "Asia/Kolkata")))
    }

    @Test func daylightSavingUsesCurrentLocalTime() throws {
        let hours = ClockDisplayHours(morningMinute: 480, nightMinute: 1200)
        let newYork = try #require(TimeZone(identifier: "America/New_York"))
        let winter = try #require(ISO8601DateFormatter().date(from: "2024-01-01T12:30:00Z"))
        let summer = try #require(ISO8601DateFormatter().date(from: "2024-07-01T12:30:00Z"))
        #expect(hours.isQuiet(at: winter, in: newYork)) // 07:30
        #expect(!hours.isQuiet(at: summer, in: newYork)) // 08:30
    }

    @Test func midnightEndpointsAllowNormalColorAllDay() throws {
        let hours = ClockDisplayHours(morningMinute: 0, nightMinute: 1440)
        for instant in ["2024-01-01T00:00:00Z", "2024-01-01T23:59:59Z"] {
            let date = try #require(ISO8601DateFormatter().date(from: instant))
            #expect(!hours.isQuiet(at: date, in: utc))
        }
    }

    @Test func invalidTimezoneDoesNotClaimQuietStatus() {
        #expect(!ClockDisplayHours.default.isQuiet(at: Date(), in: nil))
    }
}
