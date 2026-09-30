import SwiftUI
import WidgetKit

struct SleepData: Decodable {
    var theme: WidgetTheme? = nil
    var hasData: Bool? = nil
    var lastHours: Double? = nil
    var lastScore: Int? = nil
    var lastLabel: String? = nil
    var avgHours: Double? = nil
    var avgScore: Int? = nil
    var nightsLogged: Int? = nil
    var week: [Double]? = nil
    var weekLabels: [String]? = nil
}

struct SleepWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PaperEntry<SleepData>

    var body: some View {
        let d = entry.data ?? SleepData()
        let t = d.theme ?? WidgetTheme()
        let ink = t.inkColor, soft = t.inkSoftColor
        let has = d.hasData ?? false
        let hours = has ? String(format: "%.1fH", d.lastHours ?? 0) : "--"
        let score = has ? "SCORE \(d.lastScore ?? 0)" : "NO NIGHTS LOGGED"
        let chart = BarChart(values: d.week ?? [], labels: d.weekLabels ?? [], maxValue: 10, theme: t)
        let avg = String(format: "AVG %.1fH · SCORE %d · %d NIGHTS", d.avgHours ?? 0, d.avgScore ?? 0, d.nightsLogged ?? 0)

        Group {
            switch family {
            case .systemSmall:
                VStack(alignment: .leading, spacing: 2) {
                    Text("SLEEP").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                    Text(hours).font(.system(size: 34, weight: .bold)).foregroundColor(ink)
                    Text(score).font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                    Text(d.lastLabel ?? "").font(.system(size: 11)).foregroundColor(soft)
                }
            case .systemLarge:
                VStack(alignment: .leading, spacing: 6) {
                    Text("SLEEP · LAST NIGHT").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                    Text(hours).font(.system(size: 40, weight: .bold)).foregroundColor(ink)
                    Text(score + (d.lastLabel.map { " · \($0)" } ?? "")).font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                    chart.padding(.top, 6)
                    Text(avg).font(.system(size: 12)).foregroundColor(soft)
                }
            default: // medium
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SLEEP · LAST NIGHT").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                        Text(hours).font(.system(size: 34, weight: .bold)).foregroundColor(ink)
                        Text(score).font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                        Text(d.lastLabel ?? "").font(.system(size: 11)).foregroundColor(soft)
                    }
                    chart
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .paperWidget(t, url: "journalinghabits://sleep")
    }
}

struct SleepWidget: Widget {
    let kind = "SleepWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PaperProvider<SleepData>(key: "sleep_data")) { entry in
            SleepWidgetView(entry: entry)
        }
        .configurationDisplayName("Sleep")
        .description("Last night's sleep, score and your 7-night trend.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabledIfAvailable()
    }
}

@main
struct HabitsWidgetsBundle: WidgetBundle {
    var body: some Widget {
        HabitsWidget()
        JournalWidget()
        SleepWidget()
    }
}
