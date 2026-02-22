//
//  DailyProgram.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import Foundation

struct DailyProgram: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var dayOfWeek: DayOfWeek
    var exercises: [DailyExercise]

    init(id: UUID = UUID(),
         name: String,
         dayOfWeek: DayOfWeek,
         exercises: [DailyExercise]) {
        self.id = id
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.exercises = exercises
    }
}

struct DailyExercise: Identifiable, Codable, Hashable {
    let id: UUID
    var exercise: Exercise
    var isActive: Bool
    var sets: [DailySet]

    init(id: UUID = UUID(),
         exercise: Exercise,
         isActive: Bool = false,
         sets: [DailySet]) {
        self.id = id
        self.exercise = exercise
        self.isActive = isActive
        self.sets = sets
    }
}

struct DailySet: Identifiable, Codable, Hashable {
    let id: UUID
    var weight: Double
    var reps: Int

    init(id: UUID = UUID(), weight: Double, reps: Int) {
        self.id = id
        self.weight = weight
        self.reps = reps
    }
}

extension DayOfWeek {
    static func from(_ date: Date, calendar: Calendar = .current) -> DayOfWeek {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .saturday
        }
    }
}

extension DailyProgram {
    static func sample(for day: DayOfWeek) -> DailyProgram {
        DailyProgram(
            name: "Силовая",
            dayOfWeek: day,
            exercises: [
                DailyExercise(
                    exercise: Exercise(
                        name: "Жим штанги лежа",
                        muscleGroup: .chest,
                        description: "Жим штанги на горизонтальной скамье"
                    ),
                    isActive: true,
                    sets: [
                        DailySet(weight: 60, reps: 8),
                        DailySet(weight: 65, reps: 10),
                        DailySet(weight: 70, reps: 12)
                    ]
                ),
                DailyExercise(
                    exercise: Exercise(
                        name: "Жим гантелей на наклонной",
                        muscleGroup: .chest,
                        description: "Жим гантелей на наклонной скамье"
                    ),
                    sets: [
                        DailySet(weight: 22.5, reps: 10),
                        DailySet(weight: 22.5, reps: 10),
                        DailySet(weight: 22.5, reps: 10)
                    ]
                ),
                DailyExercise(
                    exercise: Exercise(
                        name: "Разгибания на трицепс",
                        muscleGroup: .arms,
                        description: "Разгибания рук на блоке для трицепса"
                    ),
                    sets: [
                        DailySet(weight: 25, reps: 12),
                        DailySet(weight: 25, reps: 12),
                        DailySet(weight: 25, reps: 12)
                    ]
                )
            ]
        )
    }
}
