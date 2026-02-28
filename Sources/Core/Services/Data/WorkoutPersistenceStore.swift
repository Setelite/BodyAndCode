//
//  WorkoutPersistenceStore.swift
//  Body&Code
//
//  Created by Codex on 2/22/26.
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

struct StoredWorkoutSet: Codable, Hashable {
    let setNumber: Int
    let targetWeight: Double
    let targetReps: Int
    let completedWeight: Double
    let completedReps: Int
    let difficulty: String
}

struct StoredWorkoutExercise: Codable, Hashable {
    let exerciseId: UUID
    let exerciseName: String
    let sets: [StoredWorkoutSet]
    let weight: Double
    let reps: Int
}

struct StoredWorkoutHistorySession: Codable, Identifiable, Hashable {
    let id: UUID
    let workoutPlanId: UUID
    let workoutName: String
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let completedExercises: [StoredWorkoutExercise]
}

struct OngoingWorkoutSnapshot: Codable {
    let workoutPlan: WorkoutPlan
    let completedSets: [WorkoutSet]
    let workoutStartTime: Date?
    let elapsedSeconds: Int
    let isTimerRunning: Bool
    let exerciseSetPlan: [UUID: [CustomWorkoutSet]]
    let timerStartedAt: Date?
    let accumulatedElapsedBeforeCurrentRun: Int?
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

final class WorkoutPersistenceStore {
    private let ongoingKey = "ongoing_workout_snapshot_v1"
    private let historyKey = "structured_workout_history_v1"
    private let widgetSummaryKey = "workout_widget_summary_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveOngoing(_ snapshot: OngoingWorkoutSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: ongoingKey)
        saveWidgetSummary(from: snapshot)
    }

    func loadOngoing() -> OngoingWorkoutSnapshot? {
        guard let data = defaults.data(forKey: ongoingKey) else { return nil }
        return try? JSONDecoder().decode(OngoingWorkoutSnapshot.self, from: data)
    }

    func clearOngoing() {
        defaults.removeObject(forKey: ongoingKey)
        sharedDefaults?.removeObject(forKey: widgetSummaryKey)
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
#endif
    }

    func appendHistory(_ session: StoredWorkoutHistorySession) {
        var history = loadHistory()
        history.append(session)
        history.sort { $0.startDate > $1.startDate }
        guard let data = try? JSONEncoder().encode(history) else { return }
        defaults.set(data, forKey: historyKey)
    }

    func loadHistory() -> [StoredWorkoutHistorySession] {
        guard let data = defaults.data(forKey: historyKey),
              let sessions = try? JSONDecoder().decode([StoredWorkoutHistorySession].self, from: data) else {
            return []
        }
        return sessions.sorted { $0.startDate > $1.startDate }
    }

    private var sharedDefaults: UserDefaults? {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupIDs.bodyCodeShared) != nil else {
            return nil
        }
        return UserDefaults(suiteName: AppGroupIDs.bodyCodeShared)
    }

    private func saveWidgetSummary(from snapshot: OngoingWorkoutSnapshot) {
        guard let sharedDefaults else { return }
        let steps = buildSteps(from: snapshot)
        let totalSetsFromPlan = steps.count
        let fallbackTotal = snapshot.workoutPlan.exercises.count * 3
        let totalSets = max(totalSetsFromPlan > 0 ? totalSetsFromPlan : fallbackTotal, 1)
        let completed = min(snapshot.completedSets.count, totalSets)
        let remaining = max(totalSets - completed, 0)
        let progress = Double(completed) / Double(totalSets)
        let currentStepIndex = min(completed, max(steps.count - 1, 0))

        let summary = WorkoutWidgetSummary(
            workoutName: snapshot.workoutPlan.name,
            elapsedSeconds: snapshot.elapsedSeconds,
            completedSets: completed,
            totalSets: totalSets,
            remainingSets: remaining,
            progress: progress,
            steps: steps,
            currentStepIndex: currentStepIndex,
            isTimerRunning: snapshot.isTimerRunning,
            timerReferenceDate: timerReferenceDate(for: snapshot),
            restDurationSeconds: 90,
            restRemainingSeconds: 90,
            isRestTimerRunning: false,
            restTimerEndDate: nil,
            updatedAt: Date()
        )

        guard let data = try? JSONEncoder().encode(summary) else { return }
        sharedDefaults.set(data, forKey: widgetSummaryKey)
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
#endif
    }

    private func buildSteps(from snapshot: OngoingWorkoutSnapshot) -> [WorkoutWidgetSummary.WorkoutWidgetStep] {
        snapshot.workoutPlan.exercises.flatMap { exercise in
            let plannedSets = snapshot.exerciseSetPlan[exercise.id] ?? defaultSets()
            return plannedSets
                .sorted { $0.setNumber < $1.setNumber }
                .map {
                    WorkoutWidgetSummary.WorkoutWidgetStep(
                        exerciseName: exercise.name,
                        setNumber: $0.setNumber,
                        targetWeight: $0.targetWeight,
                        targetReps: $0.targetReps
                    )
                }
        }
    }

    private func defaultSets() -> [CustomWorkoutSet] {
        [
            CustomWorkoutSet(setNumber: 1, targetReps: 12, targetWeight: 0),
            CustomWorkoutSet(setNumber: 2, targetReps: 10, targetWeight: 0),
            CustomWorkoutSet(setNumber: 3, targetReps: 8, targetWeight: 0)
        ]
    }

    private func timerReferenceDate(for snapshot: OngoingWorkoutSnapshot) -> Date? {
        guard snapshot.isTimerRunning else { return nil }

        if let timerStartedAt = snapshot.timerStartedAt {
            let baseElapsed = snapshot.accumulatedElapsedBeforeCurrentRun ?? 0
            return timerStartedAt.addingTimeInterval(-Double(baseElapsed))
        }

        return Date().addingTimeInterval(-Double(snapshot.elapsedSeconds))
    }
}
