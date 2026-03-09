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
        guard let summary = await WidgetSharedStore.loadSummary() else {
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

        await WidgetSharedStore.saveSummary(updated)
        return .result()
    }
}

struct CompleteSetIntent: AppIntent {
    static var title: LocalizedStringResource = "Выполнил подход"

    func perform() async throws -> some IntentResult {
        guard let summary = await WidgetSharedStore.loadSummary() else {
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
            isRestTimerRunning: false,
            restTimerEndDate: nil,
            updatedAt: now
        )

        await WidgetSharedStore.saveSummary(updated)
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
    @Environment(\.colorScheme) private var colorScheme

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
        .padding(family == .systemSmall ? 10 : 12)
    }

    @ViewBuilder
    private func mediumLayout(_ summary: WorkoutWidgetSummary) -> some View {
        GeometryReader { geo in
            let topHeight = geo.size.height * 0.58
            let sideInset: CGFloat = 16

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 6) {
                        Text(currentExerciseName(summary))
                            .font(.system(size: 16, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Text("⟶")
                            .font(.system(size: 15, weight: .regular))
                        Text(nextExerciseTitle(summary))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(widgetSecondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }

                    Spacer(minLength: 8)

                    HStack(alignment: .lastTextBaseline, spacing: 10) {
                        restTimerDisplay(summary)
                            .font(.system(size: 66, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        Spacer(minLength: 16)

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Подход \(activeSetIndex(summary))/\(activeExerciseTotalSets(summary))")
                                .font(.system(size: 18, weight: .regular))
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                            Text("Упр. \(completedExercises(summary))/\(totalExercises(summary))")
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
                .padding(.horizontal, sideInset)
                .padding(.top, 4)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, maxHeight: topHeight, alignment: .topLeading)

                Rectangle()
                    .fill(widgetDivider)
                    .frame(height: 1)
                    .padding(.horizontal, 2)

                HStack(spacing: 0) {
                    Button(intent: ToggleRestTimerIntent()) {
                        Text((summary.isRestTimerRunning ?? false) ? "Продолжить" : "Отдых")
                            .font(.system(size: 26, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color(red: 0.10, green: 0.78, blue: 0.36))
                    .padding(.horizontal, 20)

                    Rectangle()
                        .fill(widgetDivider)
                        .frame(width: 1)
                        .padding(.vertical, 22)

                    Button(intent: CompleteSetIntent()) {
                        Text(primaryActionTitle(summary))
                            .font(.system(size: 26, weight: .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(widgetPrimaryText)
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, sideInset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .foregroundStyle(widgetPrimaryText)
    }

    @ViewBuilder
    private func smallLayout(_ summary: WorkoutWidgetSummary) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(currentStepTitle(summary))
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)

            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .medium))
                timerText(summary)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .monospacedDigit()
            }

            HStack(spacing: 0) {
                Button(intent: ToggleRestTimerIntent()) {
                    Text((summary.isRestTimerRunning ?? false) ? "СТОП" : "СТАРТ")
                        .font(.system(size: 11, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                .buttonStyle(.plain)
                .foregroundStyle((summary.isRestTimerRunning ?? false) ? .white : Color(red: 0.08, green: 0.74, blue: 0.52))

                Rectangle()
                    .fill(widgetDivider.opacity(0.8))
                    .frame(width: 1)
                    .padding(.vertical, 7)

                Button(intent: CompleteSetIntent()) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                .buttonStyle(.plain)
                .foregroundStyle(widgetPrimaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(9)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(widgetPrimaryText)
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

    private func currentStepTitle(_ summary: WorkoutWidgetSummary) -> String {
        if let step = currentStep(summary) {
            return "\(step.exerciseName) • \(step.setNumber)"
        }
        if !isWorkoutCompleted(summary) {
            return "Подход \(summary.completedSets + 1)"
        } else {
            return "Все подходы выполнены"
        }
    }

    private func nextExerciseTitle(_ summary: WorkoutWidgetSummary) -> String {
        guard !summary.steps.isEmpty else {
            return "Следующий подход"
        }
        let requestedNext = summary.currentStepIndex + 1
        guard requestedNext < summary.steps.count else {
            return "Завершить тренировку"
        }
        let nextIndex = min(requestedNext, summary.steps.count - 1)
        return summary.steps[nextIndex].exerciseName
    }

    private func activeSetIndex(_ summary: WorkoutWidgetSummary) -> Int {
        if let step = currentStep(summary) {
            return max(step.setNumber, 1)
        }
        return 1
    }

    private func activeExerciseTotalSets(_ summary: WorkoutWidgetSummary) -> Int {
        guard let step = currentStep(summary) else {
            return 1
        }
        let sameExerciseSets = summary.steps
            .filter { $0.exerciseName == step.exerciseName }
            .map(\.setNumber)
        return max(sameExerciseSets.max() ?? step.setNumber, 1)
    }

    private func primaryActionTitle(_ summary: WorkoutWidgetSummary) -> String {
        guard let current = currentStep(summary) else {
            return "Выполнено"
        }
        let nextIndex = summary.currentStepIndex + 1
        guard nextIndex < summary.steps.count else {
            return "Выполнено"
        }
        let next = summary.steps[nextIndex]
        return next.exerciseName == current.exerciseName ? "Дальше" : "Выполнено"
    }

    private func totalExercises(_ summary: WorkoutWidgetSummary) -> Int {
        let names = Set(summary.steps.map(\.exerciseName))
        return max(names.count, 1)
    }

    private func completedExercises(_ summary: WorkoutWidgetSummary) -> Int {
        guard !summary.steps.isEmpty else { return 0 }
        let completedCount = min(summary.completedSets, summary.steps.count)
        let completedSteps = Array(summary.steps.prefix(completedCount))
        let allNames = Set(summary.steps.map(\.exerciseName))

        let completed = allNames.filter { exerciseName in
            let totalSetsForExercise = summary.steps.filter { $0.exerciseName == exerciseName }.count
            let doneSetsForExercise = completedSteps.filter { $0.exerciseName == exerciseName }.count
            return doneSetsForExercise >= totalSetsForExercise
        }
        return completed.count
    }

    private func currentExerciseName(_ summary: WorkoutWidgetSummary) -> String {
        currentStep(summary)?.exerciseName.capitalized ?? "Текущее упражнение"
    }

    @ViewBuilder
    private func restTimerInline(_ summary: WorkoutWidgetSummary, font: Font) -> some View {
        if summary.isRestTimerRunning == true,
           let endDate = summary.restTimerEndDate,
           endDate.timeIntervalSinceNow > 0 {
            Text(endDate, style: .timer)
                .font(font)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        } else {
            Text(formatTime(restRemaining(summary)))
                .font(font)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    @ViewBuilder
    private func restTimerDisplay(_ summary: WorkoutWidgetSummary) -> some View {
        if summary.isRestTimerRunning == true,
           let endDate = summary.restTimerEndDate,
           endDate.timeIntervalSinceNow > 0 {
            Text(endDate, style: .timer)
        } else {
            Text(formatShortTime(restRemaining(summary)))
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

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private func formatShortTime(_ seconds: Int) -> String {
        let clamped = max(seconds, 0)
        let m = clamped / 60
        let s = clamped % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var widgetThemeOverride: String? {
        UserDefaults(suiteName: WidgetSharedStore.appGroupID)?
            .string(forKey: "selectedTheme")
    }

    private var isDarkTheme: Bool {
        switch widgetThemeOverride {
        case "dark":
            return true
        case "light":
            return false
        default:
            return colorScheme == .dark
        }
    }

    private var widgetPrimaryText: Color {
        isDarkTheme ? .white : .black
    }

    private var widgetSecondaryText: Color {
        isDarkTheme ? .white.opacity(0.74) : .black.opacity(0.72)
    }

    private var widgetDivider: Color {
        isDarkTheme ? .white.opacity(0.65) : .black.opacity(0.9)
    }

}

struct WorkoutProgressWidget: Widget {
    let kind = "WorkoutProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutProgressProvider()) { entry in
            WorkoutProgressWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("Текущая тренировка")
        .description("Показывает прогресс и сколько осталось")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
