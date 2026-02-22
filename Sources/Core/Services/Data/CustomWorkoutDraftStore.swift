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

final class CustomWorkoutDraftStore {
    private let key = "custom_workout_draft_v1"
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
}
