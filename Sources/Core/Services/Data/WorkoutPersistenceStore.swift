//
//  WorkoutPersistenceStore.swift
//  Body&Code
//
//  Created by Codex on 2/22/26.
//

import Foundation

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
}

final class WorkoutPersistenceStore {
    private let ongoingKey = "ongoing_workout_snapshot_v1"
    private let historyKey = "structured_workout_history_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveOngoing(_ snapshot: OngoingWorkoutSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: ongoingKey)
    }

    func loadOngoing() -> OngoingWorkoutSnapshot? {
        guard let data = defaults.data(forKey: ongoingKey) else { return nil }
        return try? JSONDecoder().decode(OngoingWorkoutSnapshot.self, from: data)
    }

    func clearOngoing() {
        defaults.removeObject(forKey: ongoingKey)
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
}
