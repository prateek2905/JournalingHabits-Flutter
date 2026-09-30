import SwiftUI
import WidgetKit

/// Must match `WidgetSync.appGroupId` in lib/services/widget_sync.dart.
let appGroupId = "group.com.prateekmishra.journalingHabits"

// MARK: - Theme (pushed from Dart so widgets follow the app's paper theme)

struct WidgetTheme: Decodable {
    var paper: String? = nil
    var ink: String? = nil
    var inkSoft: String? = nil
    var grid: String? = nil
    var hi: String? = nil
    var onHi: String? = nil

    var paperColor: Color { Color(argb: paper, fallback: 0xFFFDFCF8) }
    var inkColor: Color { Color(argb: ink, fallback: 0xFF23241F) }
    var inkSoftColor: Color { Color(argb: inkSoft, fallback: 0x9923241F) }
    var gridColor: Color { Color(argb: grid, fallback: 0x33606A60) }
    var hiColor: Color { Color(argb: hi, fallback: 0xFFB6FF2E) }
}

extension Color {
    /// Parses "#AARRGGBB".
    init(argb: String?, fallback: UInt32) {
        var value = fallback
        if let s = argb?.replacingOccurrences(of: "#", with: ""), let parsed = UInt32(s, radix: 16) {
            value = parsed
        }
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: Double((value >> 24) & 0xFF) / 255
        )
    }
}

// MARK: - Timeline plumbing

struct PaperEntry<T: Decodable>: TimelineEntry {
    let date: Date
    let data: T?
}

/// Reads one JSON payload (written by `WidgetSync`) from the shared app group.
struct PaperProvider<T: Decodable>: TimelineProvider {
    let key: String

    private func load() -> T? {
        guard let json = UserDefaults(suiteName: appGroupId)?.string(forKey: key),
              let bytes = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: bytes)
    }

    func placeholder(in context: Context) -> PaperEntry<T> { PaperEntry(date: Date(), data: load()) }

    func getSnapshot(in context: Context, completion: @escaping (PaperEntry<T>) -> Void) {
        completion(PaperEntry(date: Date(), data: load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PaperEntry<T>>) -> Void) {
        // The app pushes fresh data (and reloads timelines) whenever anything changes;
        // this periodic refresh just keeps the widget from going stale overnight.
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [PaperEntry(date: Date(), data: load())], policy: .after(next)))
    }
}

// MARK: - Shared views

/// Paper with the app's 20pt grid.
struct PaperBackground: View {
    let theme: WidgetTheme

    var body: some View {
        ZStack {
            theme.paperColor
            Canvas { ctx, size in
                var path = Path()
                var x: CGFloat = 20
                while x < size.width { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)); x += 20 }
                var y: CGFloat = 20
                while y < size.height { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)); y += 20 }
                ctx.stroke(path, with: .color(theme.gridColor), lineWidth: 0.6)
            }
        }
    }
}

extension View {
    /// Applies the paper background the way the current OS expects.
    @ViewBuilder
    func paperWidget(_ theme: WidgetTheme, url: String) -> some View {
        if #available(iOS 17.0, *) {
            self.padding(14)
                .widgetURL(URL(string: url))
                .containerBackground(for: .widget) { PaperBackground(theme: theme) }
        } else {
            self.padding(14)
                .background(PaperBackground(theme: theme))
                .widgetURL(URL(string: url))
        }
    }
}

/// Highlighter-style vertical bars with a letter label, mirroring the app's charts.
struct BarChart: View {
    let values: [Double]
    let labels: [String]
    let maxValue: Double
    let theme: WidgetTheme

    var body: some View {
        GeometryReader { geo in
            let labelH: CGFloat = 12
            let plotH = max(geo.size.height - labelH, 4)
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(values.indices, id: \.self) { i in
                    VStack(spacing: 2) {
                        Spacer(minLength: 0)
                        let v = values[i]
                        let h = v <= 0 ? 2 : max(3, CGFloat(min(v, maxValue) / maxValue) * plotH)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(v > 0 ? theme.hiColor : Color.clear)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(theme.inkColor, lineWidth: 1.2))
                            .frame(height: h)
                        Text(i < labels.count ? labels[i] : "")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(theme.inkSoftColor)
                            .frame(height: labelH - 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

/// Highlighter-style horizontal progress bar (fraction 0...1).
struct ProgressPill: View {
    let fraction: Double
    let theme: WidgetTheme

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(theme.hiColor)
                    .frame(width: max(8, geo.size.width * CGFloat(min(max(fraction, 0), 1))))
                    .opacity(fraction > 0 ? 1 : 0)
                Capsule().stroke(theme.inkSoftColor, lineWidth: 1)
            }
        }
        .frame(height: 8)
    }
}
