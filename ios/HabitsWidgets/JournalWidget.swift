import SwiftUI
import WidgetKit

struct JournalData: Decodable {
    struct Task: Decodable { var text: String; var done: Bool }

    var theme: WidgetTheme? = nil
    var date: String? = nil
    var day: Int? = nil
    var tasksDone: Int? = nil
    var tasksTotal: Int? = nil
    var moments: Int? = nil
    var tasks: [Task]? = nil
}

struct JournalWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PaperEntry<JournalData>

    var body: some View {
        let d = entry.data ?? JournalData()
        let t = d.theme ?? WidgetTheme()
        let ink = t.inkColor, soft = t.inkSoftColor
        let total = d.tasksTotal ?? 0
        let prog = total == 0 ? "NO TASKS YET" : "\(d.tasksDone ?? 0)/\(total) DONE"
        let date = d.date ?? "TODAY"
        let shortDate = date.components(separatedBy: " ·").first ?? date
        let tasks = d.tasks ?? []

        Group {
            switch family {
            case .systemSmall:
                VStack(alignment: .leading, spacing: 2) {
                    Text("JOURNAL").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                    Text("\(d.day ?? 0)").font(.system(size: 34, weight: .bold)).foregroundColor(ink)
                    Text(shortDate).font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                    Text(prog).font(.system(size: 12, weight: .bold)).foregroundColor(ink).padding(.top, 4)
                    Text("TAP TO WRITE ✎").font(.system(size: 11)).foregroundColor(soft)
                }
            case .systemLarge:
                VStack(alignment: .leading, spacing: 6) {
                    Text("JOURNAL").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                    Text(date).font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                    Text(prog).font(.system(size: 22, weight: .bold)).foregroundColor(ink)
                    taskList(tasks, max: 5, t: t, size: 14)
                    Spacer(minLength: 0)
                    Text("\(d.moments ?? 0) MOMENTS TODAY").font(.system(size: 12)).foregroundColor(soft)
                    Text("TAP TO WRITE ✎").font(.system(size: 11, weight: .bold)).foregroundColor(ink)
                }
            default: // medium
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("JOURNAL").font(.system(size: 11, weight: .bold)).foregroundColor(soft)
                        Text("\(d.day ?? 0)").font(.system(size: 34, weight: .bold)).foregroundColor(ink)
                        Text(shortDate).font(.system(size: 12, weight: .medium)).foregroundColor(ink)
                        Text(prog).font(.system(size: 12, weight: .bold)).foregroundColor(ink).padding(.top, 2)
                        Text("TAP TO WRITE ✎").font(.system(size: 11)).foregroundColor(soft)
                    }
                    taskList(tasks, max: 3, t: t, size: 13)
                        .frame(maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .paperWidget(t, url: "journalinghabits://journal")
    }

    @ViewBuilder
    private func taskList(_ tasks: [JournalData.Task], max: Int, t: WidgetTheme, size: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if tasks.isEmpty {
                Text("ADD TODAY'S FIRST TASK").font(.system(size: size)).foregroundColor(t.inkSoftColor)
            } else {
                ForEach(Array(tasks.prefix(max).enumerated()), id: \.offset) { _, task in
                    Text((task.done ? "✕ " : "○ ") + task.text)
                        .lineLimit(1)
                        .font(.system(size: size))
                        .foregroundColor(task.done ? t.inkSoftColor : t.inkColor)
                }
            }
        }
    }
}

struct JournalWidget: Widget {
    let kind = "JournalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PaperProvider<JournalData>(key: "journal_data")) { entry in
            JournalWidgetView(entry: entry)
        }
        .configurationDisplayName("Journal")
        .description("Today's tasks, with a quick way into your journal.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabledIfAvailable()
    }
}
