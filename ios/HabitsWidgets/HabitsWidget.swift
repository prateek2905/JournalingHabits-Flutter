import SwiftUI
import WidgetKit

struct HabitsData: Decodable {
    struct Top: Decodable { var name: String; var count: Int; var pct: Int }

    var theme: WidgetTheme? = nil
    var month: String? = nil
    var todayDone: Int? = nil
    var todayTotal: Int? = nil
    var monthPct: Int? = nil
    var bestStreak: Int? = nil
    var week: [Double]? = nil
    var weekLabels: [String]? = nil
    var top: [Top]? = nil
}

struct HabitsWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PaperEntry<HabitsData>

    var body: some View {
        let d = entry.data ?? HabitsData()
        let t = d.theme ?? WidgetTheme()
        let ink = t.inkColor, soft = t.inkSoftColor
        let pct = d.monthPct ?? 0
        let today = "\(d.todayDone ?? 0)/\(d.todayTotal ?? 0)"
        let chart = BarChart(values: d.week ?? [], labels: d.weekLabels ?? [], maxValue: 100, theme: t)

        Group {
            switch family {
            case .systemSmall:
                VStack(alignment: .leading, spacing: 2) {
                    Text("HABITS").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                    Text("\(pct)%").font(.system(size: 34, weight: .bold)).foregroundColor(ink)
                    Text("TODAY \(today)").font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                    chart.padding(.top, 4)
                }
            case .systemLarge:
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("HABITS").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                        Spacer()
                        Text(d.month ?? "").font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                    }
                    HStack {
                        stat("\(pct)%", "THIS MONTH", ink, soft)
                        stat(today, "TODAY", ink, soft)
                        stat("\(d.bestStreak ?? 0)D", "BEST STREAK", ink, soft)
                    }
                    chart.frame(height: 64)
                    ForEach(Array((d.top ?? []).prefix(5).enumerated()), id: \.offset) { _, h in
                        VStack(spacing: 2) {
                            HStack {
                                Text(h.name).lineLimit(1).font(.system(size: 12)).foregroundColor(ink)
                                Spacer()
                                Text("\(h.count)D").font(.system(size: 12, weight: .bold)).foregroundColor(ink)
                            }
                            ProgressPill(fraction: Double(h.pct) / 100, theme: t)
                        }
                    }
                    Spacer(minLength: 0)
                }
            default: // medium
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HABITS · THIS MONTH").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                        Text("\(pct)%").font(.system(size: 34, weight: .bold)).foregroundColor(ink)
                        Text("TODAY \(today)").font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                        Text("BEST STREAK \(d.bestStreak ?? 0)D").font(.system(size: 12)).foregroundColor(soft)
                    }
                    chart
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .paperWidget(t, url: "journalinghabits://habits")
    }

    private func stat(_ value: String, _ label: String, _ ink: Color, _ soft: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value).font(.system(size: 22, weight: .bold)).foregroundColor(ink)
            Text(label).font(.system(size: 10)).foregroundColor(soft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HabitsWidget: Widget {
    let kind = "HabitsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PaperProvider<HabitsData>(key: "habits_data")) { entry in
            HabitsWidgetView(entry: entry)
        }
        .configurationDisplayName("Habit Success")
        .description("Today, this month and your streak.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabledIfAvailable()
    }
}

extension WidgetConfiguration {
    /// Keeps our own padding on iOS 17+ so the grid runs edge to edge.
    @WidgetConfigurationBuilder
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            self.contentMarginsDisabled()
        } else {
            self
        }
    }
}
