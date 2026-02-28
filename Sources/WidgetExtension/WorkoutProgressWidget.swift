import WidgetKit
import SwiftUI
import AppIntents

struct WorkoutProgressEntry: TimelineEntry {
    let date: Date
    let summary: WorkoutWidgetSummary?
}

struct WorkoutWidgetSummary: Codable {
    struct WorkoutWidgetStep: Codable {
        let exerciseName: String
        let setNumber: Int
        let targetWeight: Double
        let targetReps: Int
    }

    let workoutName: String
    let elapsedSeconds: Int
    let completedSets: Int
    let totalSets: Int
    let remainingSets: Int
    let progress: Double
    let steps: [WorkoutWidgetStep]
    let currentStepIndex: Int
    let isTimerRunning: Bool
    let timerReferenceDate: Date?
    let restDurationSeconds: Int?
    let restRemainingSeconds: Int?
    let isRestTimerRunning: Bool?
    let restTimerEndDate: Date?
    let updatedAt: Date
}

private struct LegacyWorkoutWidgetSummary: Codable {
    let workoutName: String
    let elapsedSeconds: Int
    let completedSets: Int
    let totalSets: Int
    let remainingSets: Int
    let progress: Double
    let isTimerRunning: Bool
    let timerReferenceDate: Date?
    let restDurationSeconds: Int?
    let restRemainingSeconds: Int?
    let isRestTimerRunning: Bool?
    let restTimerEndDate: Date?
    let updatedAt: Date
}

private enum WidgetSharedStore {
    static let appGroupID = "group.Wowgorno.BodyCodeApp"
    static let summaryKey = "workout_widget_summary_v1"

    static func loadSummary() -> WorkoutWidgetSummary? {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil else {
            return nil
        }
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: summaryKey) else {
            return nil
        }
        if let decoded = try? JSONDecoder().decode(WorkoutWidgetSummary.self, from: data) {
            return decoded
        }
        if let legacy = try? JSONDecoder().decode(LegacyWorkoutWidgetSummary.self, from: data) {
            return WorkoutWidgetSummary(
                workoutName: legacy.workoutName,
                elapsedSeconds: legacy.elapsedSeconds,
                completedSets: legacy.completedSets,
                totalSets: legacy.totalSets,
                remainingSets: legacy.remainingSets,
                progress: legacy.progress,
                steps: [],
                currentStepIndex: 0,
                isTimerRunning: legacy.isTimerRunning,
                timerReferenceDate: legacy.timerReferenceDate,
                restDurationSeconds: legacy.restDurationSeconds,
                restRemainingSeconds: legacy.restRemainingSeconds,
                isRestTimerRunning: legacy.isRestTimerRunning,
                restTimerEndDate: legacy.restTimerEndDate,
                updatedAt: legacy.updatedAt
            )
        }
        return nil
    }

    static func saveSummary(_ summary: WorkoutWidgetSummary) {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil else {
            return
        }
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(summary) else {
            return
        }
        defaults.set(data, forKey: summaryKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ToggleRestTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Старт/стоп отдыха"

    func perform() async throws -> some IntentResult {
        guard let summary = WidgetSharedStore.loadSummary() else {
            return .result()
        }

        let defaultRest = max(summary.restDurationSeconds ?? 90, 15)
        let currentlyRunning = summary.isRestTimerRunning ?? false
        let now = Date()

        let updated: WorkoutWidgetSummary
        if currentlyRunning {
            let remaining: Int
            if let endDate = summary.restTimerEndDate {
                remaining = max(Int(endDate.timeIntervalSince(now)), 0)
            } else {
                remaining = summary.restRemainingSeconds ?? defaultRest
            }

            updated = WorkoutWidgetSummary(
                workoutName: summary.workoutName,
                elapsedSeconds: summary.elapsedSeconds,
                completedSets: summary.completedSets,
                totalSets: summary.totalSets,
                remainingSets: summary.remainingSets,
                progress: summary.progress,
                steps: summary.steps,
                currentStepIndex: summary.currentStepIndex,
                isTimerRunning: summary.isTimerRunning,
                timerReferenceDate: summary.timerReferenceDate,
                restDurationSeconds: defaultRest,
                restRemainingSeconds: remaining,
                isRestTimerRunning: false,
                restTimerEndDate: nil,
                updatedAt: now
            )
        } else {
            let remaining = max(summary.restRemainingSeconds ?? defaultRest, 1)
            updated = WorkoutWidgetSummary(
                workoutName: summary.workoutName,
                elapsedSeconds: summary.elapsedSeconds,
                completedSets: summary.completedSets,
                totalSets: summary.totalSets,
                remainingSets: summary.remainingSets,
                progress: summary.progress,
                steps: summary.steps,
                currentStepIndex: summary.currentStepIndex,
                isTimerRunning: summary.isTimerRunning,
                timerReferenceDate: summary.timerReferenceDate,
                restDurationSeconds: defaultRest,
                restRemainingSeconds: remaining,
                isRestTimerRunning: true,
                restTimerEndDate: now.addingTimeInterval(TimeInterval(remaining)),
                updatedAt: now
            )
        }

        WidgetSharedStore.saveSummary(updated)
        return .result()
    }
}

struct CompleteSetIntent: AppIntent {
    static var title: LocalizedStringResource = "Выполнил подход"

    func perform() async throws -> some IntentResult {
        guard let summary = WidgetSharedStore.loadSummary() else {
            return .result()
        }

        let defaultRest = max(summary.restDurationSeconds ?? 90, 15)
        let nextCompleted = min(summary.completedSets + 1, summary.totalSets)
        let remaining = max(summary.totalSets - nextCompleted, 0)
        let progress = summary.totalSets > 0 ? Double(nextCompleted) / Double(summary.totalSets) : 0
        let now = Date()
        let nextStepIndex = min(nextCompleted, max(summary.steps.count - 1, 0))

        let updated = WorkoutWidgetSummary(
            workoutName: summary.workoutName,
            elapsedSeconds: summary.elapsedSeconds,
            completedSets: nextCompleted,
            totalSets: summary.totalSets,
            remainingSets: remaining,
            progress: progress,
            steps: summary.steps,
            currentStepIndex: nextStepIndex,
            isTimerRunning: summary.isTimerRunning,
            timerReferenceDate: summary.timerReferenceDate,
            restDurationSeconds: defaultRest,
            restRemainingSeconds: defaultRest,
            isRestTimerRunning: true,
            restTimerEndDate: now.addingTimeInterval(TimeInterval(defaultRest)),
            updatedAt: now
        )

        WidgetSharedStore.saveSummary(updated)
        return .result()
    }
}

struct WorkoutProgressProvider: TimelineProvider {
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
                steps: [
                    WorkoutWidgetSummary.WorkoutWidgetStep(exerciseName: "Присед со штангой", setNumber: 1, targetWeight: 80, targetReps: 10),
                    WorkoutWidgetSummary.WorkoutWidgetStep(exerciseName: "Присед со штангой", setNumber: 2, targetWeight: 85, targetReps: 8),
                    WorkoutWidgetSummary.WorkoutWidgetStep(exerciseName: "Жим ногами", setNumber: 1, targetWeight: 120, targetReps: 12)
                ],
                currentStepIndex: 1,
                isTimerRunning: true,
                timerReferenceDate: Date().addingTimeInterval(-820),
                restDurationSeconds: 90,
                restRemainingSeconds: 90,
                isRestTimerRunning: false,
                restTimerEndDate: nil,
                updatedAt: Date()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkoutProgressEntry) -> Void) {
        completion(WorkoutProgressEntry(date: Date(), summary: WidgetSharedStore.loadSummary()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutProgressEntry>) -> Void) {
        let entry = WorkoutProgressEntry(date: Date(), summary: WidgetSharedStore.loadSummary())
        let refresh = Calendar.current.date(byAdding: .second, value: 15, to: Date()) ?? Date().addingTimeInterval(15)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct WorkoutProgressWidgetEntryView: View {
    let entry: WorkoutProgressProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if let summary = entry.summary {
                switch family {
                case .systemSmall:
                    smallLayout(summary)
                default:
                    mediumLayout(summary)
                }
            } else {
                emptyLayout
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(family == .systemSmall ? 8 : 10)
        .background(innerGlass)
    }

    @ViewBuilder
    private func mediumLayout(_ summary: WorkoutWidgetSummary) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(summary.workoutName)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            currentStepBlock(summary)

            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.caption)
                timerText(summary)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            ProgressView(value: summary.progress)
                .tint(.white.opacity(0.95))

            HStack {
                Text("\(summary.completedSets)/\(summary.totalSets) подходов")
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer()
                Text("Осталось \(summary.remainingSets)")
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            if isWorkoutCompleted(summary) {
                Text("Тренировка завершена")
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                HStack(spacing: 6) {
                    Button(intent: CompleteSetIntent()) {
                        Label("Подход", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.green.opacity(0.78))
                    )

                    Button(intent: ToggleRestTimerIntent()) {
                        Label((summary.isRestTimerRunning ?? false) ? "Стоп отдых" : "Старт отдых", systemImage: "timer")
                            .font(.system(size: 13, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .padding(.vertical, 9)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white.opacity(0.38))
                    )
                }
            }

            restTimerLabel(summary)
        }
        .foregroundStyle(.primary)
    }

    @ViewBuilder
    private func smallLayout(_ summary: WorkoutWidgetSummary) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(summary.workoutName)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            if let step = currentStep(summary) {
                Text("\(step.exerciseName) • \(step.setNumber)")
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.caption2)
                timerText(summary)
                    .font(.caption2.weight(.semibold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            ProgressView(value: summary.progress)
                .tint(.white.opacity(0.95))

            Text("\(summary.completedSets)/\(summary.totalSets) • осталось \(summary.remainingSets)")
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !isWorkoutCompleted(summary) {
                HStack(spacing: 6) {
                    Button(intent: CompleteSetIntent()) {
                        Image(systemName: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.green.opacity(0.82))
                    )

                    Button(intent: ToggleRestTimerIntent()) {
                        Image(systemName: (summary.isRestTimerRunning ?? false) ? "pause.circle.fill" : "timer")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.white.opacity(0.38))
                    )
                }
            }
        }
        .foregroundStyle(.primary)
    }

    private var emptyLayout: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Body&Code")
                .font(.headline)
            Text("Нет активной тренировки")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func timerText(_ summary: WorkoutWidgetSummary) -> some View {
        if summary.isTimerRunning, let timerReferenceDate = summary.timerReferenceDate {
            Text(timerReferenceDate, style: .timer)
        } else {
            Text(formatTime(summary.elapsedSeconds))
        }
    }

    @ViewBuilder
    private func restTimerLabel(_ summary: WorkoutWidgetSummary) -> some View {
        let running = summary.isRestTimerRunning ?? false
        let remaining = restRemaining(summary)
        let label = running ? "Отдых (идет): \(formatTime(remaining))" : "Отдых: \(formatTime(remaining))"
        Text(label)
            .font(.caption2)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }

    @ViewBuilder
    private func currentStepBlock(_ summary: WorkoutWidgetSummary) -> some View {
        if let step = currentStep(summary) {
            VStack(alignment: .leading, spacing: 2) {
                Text(step.exerciseName)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("Подход \(step.setNumber) • \(Int(step.targetWeight)) кг × \(step.targetReps)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.22))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else if !isWorkoutCompleted(summary) {
            Text("Следующий подход: \(summary.completedSets + 1)")
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            Text("Все подходы выполнены")
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private func currentStep(_ summary: WorkoutWidgetSummary) -> WorkoutWidgetSummary.WorkoutWidgetStep? {
        guard !summary.steps.isEmpty, !isWorkoutCompleted(summary) else { return nil }
        let index = min(summary.currentStepIndex, summary.steps.count - 1)
        return summary.steps[index]
    }

    private func isWorkoutCompleted(_ summary: WorkoutWidgetSummary) -> Bool {
        summary.totalSets > 0 && summary.completedSets >= summary.totalSets
    }

    private func restRemaining(_ summary: WorkoutWidgetSummary) -> Int {
        if summary.isRestTimerRunning == true, let endDate = summary.restTimerEndDate {
            return max(Int(endDate.timeIntervalSinceNow), 0)
        }
        return max(summary.restRemainingSeconds ?? summary.restDurationSeconds ?? 90, 0)
    }

    private var innerGlass: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.26),
                                .blue.opacity(0.08),
                                .purple.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.52), .white.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

struct WorkoutProgressWidget: Widget {
    let kind = "WorkoutProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutProgressProvider()) { entry in
            WorkoutProgressWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [
                            Color(red: 0.86, green: 0.9, blue: 0.98),
                            Color(red: 0.77, green: 0.83, blue: 0.98),
                            Color(red: 0.84, green: 0.78, blue: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Текущая тренировка")
        .description("Показывает прогресс и сколько осталось")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
