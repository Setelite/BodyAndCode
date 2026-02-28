import WidgetKit
import SwiftUI

struct WorkoutProgressEntry: TimelineEntry {
    let date: Date
    let summary: WorkoutWidgetSummary?
}

struct WorkoutWidgetSummary: Codable {
    let workoutName: String
    let elapsedSeconds: Int
    let completedSets: Int
    let totalSets: Int
    let remainingSets: Int
    let progress: Double
    let updatedAt: Date
}

struct WorkoutProgressProvider: TimelineProvider {
    private let appGroupID = "group.Wowgorno.BodyCodeApp"
    private let summaryKey = "workout_widget_summary_v1"

    func placeholder(in context: Context) -> WorkoutProgressEntry {
        WorkoutProgressEntry(
            date: Date(),
            summary: WorkoutWidgetSummary(
                workoutName: "Текущая тренировка",
                elapsedSeconds: 820,
                completedSets: 7,
                totalSets: 12,
                remainingSets: 5,
                progress: 0.58,
                updatedAt: Date()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkoutProgressEntry) -> Void) {
        completion(WorkoutProgressEntry(date: Date(), summary: loadSummary()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutProgressEntry>) -> Void) {
        let entry = WorkoutProgressEntry(date: Date(), summary: loadSummary())
        let refresh = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date().addingTimeInterval(300)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func loadSummary() -> WorkoutWidgetSummary? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: summaryKey) else {
            return nil
        }
        return try? JSONDecoder().decode(WorkoutWidgetSummary.self, from: data)
    }
}

struct WorkoutProgressWidgetEntryView: View {
    var entry: WorkoutProgressProvider.Entry

    var body: some View {
        Group {
            if let summary = entry.summary {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Сейчас")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(summary.workoutName)
                        .font(.headline)
                        .lineLimit(1)

                    ProgressView(value: summary.progress)

                    HStack {
                        Text("\(summary.completedSets)/\(summary.totalSets) подходов")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Осталось: \(summary.remainingSets)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Text("Время: \(formatTime(summary.elapsedSeconds))")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(12)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body&Code")
                        .font(.headline)
                    Text("Нет активной тренировки")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

struct WorkoutProgressWidget: Widget {
    let kind: String = "WorkoutProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutProgressProvider()) { entry in
            WorkoutProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Текущая тренировка")
        .description("Показывает прогресс и сколько осталось.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    WorkoutProgressWidget()
} timeline: {
    WorkoutProgressEntry(
        date: .now,
        summary: WorkoutWidgetSummary(
            workoutName: "Грудь и Трицепс",
            elapsedSeconds: 1240,
            completedSets: 9,
            totalSets: 12,
            remainingSets: 3,
            progress: 0.75,
            updatedAt: .now
        )
    )
}
