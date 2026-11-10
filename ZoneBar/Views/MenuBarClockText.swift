import AppKit
import SwiftUI

@MainActor
enum MenuBarClockText {
    static func attributedText(
        for segments: [MenuBarRenderer.Segment],
        separator: SeparatorStyle
    ) -> AttributedString {
        var result = AttributedString()
        for (index, segment) in segments.enumerated() {
            if index > 0 { result.append(AttributedString(separator.value)) }
            var text = AttributedString(segment.text)
            if segment.isQuiet { text.foregroundColor = .quietHoursPurple }
            result.append(text)
        }
        return result
    }

    /// Keep per-clock colors when macOS renders the status item. Template
    /// images discard color, so supply an original, Retina-scale image.
    static func image(
        for text: AttributedString,
        calendarDay: MenuBarCalendar.Day? = nil,
        separator: SeparatorStyle = .spaces,
        colorScheme: ColorScheme,
        scale: CGFloat
    ) -> NSImage? {
        let renderer = ImageRenderer(
            content: MenuBarContent(text: text, calendarDay: calendarDay, separator: separator)
                .font(.system(size: NSFont.menuBarFont(ofSize: 0).pointSize))
                .fixedSize()
                .environment(\.colorScheme, colorScheme)
        )
        renderer.scale = scale
        let image = renderer.nsImage
        image?.isTemplate = false
        return image
    }
}

/// Shared layout keeps the settings preview and actual menu bar in sync.
struct MenuBarContent: View {
    let text: AttributedString
    let calendarDay: MenuBarCalendar.Day?
    var separator: SeparatorStyle = .spaces

    var body: some View {
        HStack(spacing: 0) {
            if let calendarDay {
                MenuBarCalendarIcon(day: calendarDay.number)
                    .accessibilityLabel(Text(verbatim: calendarDay.accessibilityLabel))
            }
            if !text.characters.isEmpty {
                if calendarDay != nil {
                    Text(verbatim: separator.value)
                        .fixedSize()
                }
                Text(text)
            }
        }
    }
}
