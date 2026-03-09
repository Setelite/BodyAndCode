//
//  CustomWorkoutDraftStore.swift
//  Body&Code
//
//  Created by Codex on 2/22/26.
//

import Foundation

struct CustomWorkoutDraft: Codable, Hashable {
    let id: UUID
    let name: String
    let createdAt: Date
    let exercises: [CustomWorkoutExercise]
}

struct CustomWorkoutExercise: Codable, Hashable {
    let id: UUID
    let exercise: Exercise
    let sets: [CustomWorkoutSet]
}

struct CustomWorkoutSet: Codable, Hashable {
    let setNumber: Int
    let targetReps: Int
    let targetWeight: Double
}

struct UploadedWorkout: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let sourceFileName: String
    let importedAt: Date
    let items: [UploadedWorkoutItem]
}

struct UploadedWorkoutItem: Identifiable, Codable, Hashable {
    let id: UUID
    let exercise: Exercise
    let sets: Int
    let reps: Int
    let weight: Double
}

final class CustomWorkoutDraftStore {
    private let key = "custom_workout_draft_v1"
    private let importedWorkoutsKey = "imported_workout_library_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ draft: CustomWorkoutDraft) {
        guard let data = try? JSONEncoder().encode(draft) else { return }
        defaults.set(data, forKey: key)
    }

    func load() -> CustomWorkoutDraft? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(CustomWorkoutDraft.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }

    func saveImportedWorkout(
        name: String,
        sourceFileName: String,
        items: [UploadedWorkoutItem]
    ) -> UploadedWorkout {
        let workout = UploadedWorkout(
            id: UUID(),
            name: name,
            sourceFileName: sourceFileName,
            importedAt: Date(),
            items: items
        )

        var stored = loadImportedWorkouts()
        stored.removeAll { $0.id == workout.id }
        stored.insert(workout, at: 0)

        guard let data = try? JSONEncoder().encode(stored) else { return workout }
        defaults.set(data, forKey: importedWorkoutsKey)
        return workout
    }

    func loadImportedWorkouts() -> [UploadedWorkout] {
        guard let data = defaults.data(forKey: importedWorkoutsKey),
              let decoded = try? JSONDecoder().decode([UploadedWorkout].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.importedAt > $1.importedAt }
    }

    func removeImportedWorkout(id: UUID) {
        var stored = loadImportedWorkouts()
        stored.removeAll { $0.id == id }
        guard let data = try? JSONEncoder().encode(stored) else { return }
        defaults.set(data, forKey: importedWorkoutsKey)
    }
}
