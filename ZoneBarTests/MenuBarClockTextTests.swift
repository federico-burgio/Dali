import AppKit
import SwiftUI
import Testing
@testable import ZoneBar

@MainActor
struct MenuBarClockTextTests {
    @Test func onlyQuietClocksReceivePurpleAndSeparatorsStayNeutral() {
        let text = MenuBarClockText.attributedText(
            for: [
                .init(text: "London 12:00", isQuiet: false),
                .init(text: "Tokyo 21:00", isQuiet: true),
            ],
            separator: .pipe
        )
        #expect(String(text.characters) == "London 12:00  |  Tokyo 21:00")
        let purpleRuns = text.runs.filter { $0.foregroundColor == .quietHoursPurple }
        #expect(purpleRuns.count == 1)
        #expect(purpleRuns.map { String(text[$0.range].characters) } == ["Tokyo 21:00"])
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func originalImagePreservesPurpleWithoutChangingWidth(colorScheme: ColorScheme) throws {
        func image(isQuiet: Bool) throws -> NSImage {
            let text = MenuBarClockText.attributedText(
                for: [.init(text: "Tokyo 21:00", isQuiet: isQuiet)], separator: .spaces
            )
            return try #require(MenuBarClockText.image(for: text, colorScheme: colorScheme, scale: 2))
        }
        let quiet = try image(isQuiet: true)
        let normal = try image(isQuiet: false)
        #expect(!quiet.isTemplate)
        #expect(quiet.size == normal.size)
        #expect(quiet.size.width > 0)
        #expect(try containsPurple(quiet))
        #expect(try !containsPurple(normal))
    }

    @Test(arguments: [ColorScheme.light, .dark], SeparatorStyle.allCases)
    func calendarUsesClockSeparatorAndWorksWithoutVisibleClocks(colorScheme: ColorScheme, separator: SeparatorStyle) throws {
        let text = MenuBarClockText.attributedText(
            for: [.init(text: "Tokyo 21:00", isQuiet: true)], separator: .spaces
        )
        let plain = try #require(MenuBarClockText.image(for: text, colorScheme: colorScheme, scale: 2))
        let gap = try #require(MenuBarClockText.image(
            for: AttributedString(separator.value), colorScheme: colorScheme, scale: 2
        ))
        #expect(gap.size.width > 6)
        for number in [1, 9, 10, 21, 31] {
            let day = MenuBarCalendar.Day(number: number, accessibilityLabel: "Tokyo, day \(number)")
            let combined = try #require(MenuBarClockText.image(
                for: text, calendarDay: day, separator: separator, colorScheme: colorScheme, scale: 2
            ))
            let alone = try #require(MenuBarClockText.image(
                for: AttributedString(), calendarDay: day, colorScheme: colorScheme, scale: 2
            ))
            #expect(alone.size == CGSize(width: 20, height: 20))
            // Raster bounds may round each isolated label to the next pixel.
            #expect(abs(combined.size.width - plain.size.width - 20 - gap.size.width) <= 1)
            #expect(combined.size.height == max(plain.size.height, 20))
            #expect(try containsPurple(combined))
        }
    }

    private func containsPurple(_ image: NSImage) throws -> Bool {
        let data = try #require(image.tiffRepresentation)
        let bitmap = try #require(NSBitmapImageRep(data: data))
        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide {
                guard let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB),
                      color.alphaComponent > 0.5 else { continue }
                if color.blueComponent > color.redComponent + 0.2,
                   color.blueComponent > color.greenComponent + 0.2,
                   abs(color.redComponent - color.greenComponent) < 0.15 {
                    return true
                }
            }
        }
        return false
    }
}
