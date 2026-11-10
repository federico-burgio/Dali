import Foundation

/// The normal-color interval in each clock's own local day. The night
/// threshold is exclusive; 1440 means midnight at the end of the day.
struct ClockDisplayHours: Equatable {
    static let step = 30
    static let `default` = ClockDisplayHours(morningMinute: 360, nightMinute: 1200)

    let morningMinute: Int
    let nightMinute: Int

    init(morningMinute: Int, nightMinute: Int) {
        self.nightMinute = min(1440, max(Self.step, nightMinute))
        self.morningMinute = min(self.nightMinute - Self.step, max(0, morningMinute))
    }

    func isQuiet(at date: Date, in timeZone: TimeZone?) -> Bool {
        guard let timeZone else { return false }
        let components = Calendar.current.dateComponents(in: timeZone, from: date)
        let minute = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        return minute < morningMinute || minute >= nightMinute
    }
}
