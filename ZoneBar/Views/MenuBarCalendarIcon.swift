import SwiftUI

/// A fixed-size calendar with enough space for every day from 1 through 31.
struct MenuBarCalendarIcon: View {
    let day: Int

    var body: some View {
        ZStack {
            CalendarOutline()
                .stroke(style: StrokeStyle(lineWidth: 1.2, lineCap: .round, lineJoin: .round))
            Text(verbatim: String(day))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .position(x: 10, y: 12)
        }
        .foregroundStyle(.primary)
        .frame(width: 20, height: 20)
        .fixedSize()
    }
}

private struct CalendarOutline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(
            in: CGRect(x: 0.75, y: 0.75, width: 18.5, height: 18.5),
            cornerSize: CGSize(width: 2.5, height: 2.5)
        )
        path.move(to: CGPoint(x: 0.75, y: 4.25))
        path.addLine(to: CGPoint(x: 19.25, y: 4.25))
        return path
    }
}
