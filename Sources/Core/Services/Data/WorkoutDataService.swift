//
//  WorkoutDataService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/30/25.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class WorkoutDataService: ObservableObject {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @Published var workoutHistory: [WorkoutHistorySession] = []
    
    init() {
        do {
            modelContainer = try ModelContainer(for: WorkoutHistorySession.self)
            modelContext = modelContainer.mainContext
            loadWorkoutHistory()
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    // Загрузка истории тренировок
    func loadWorkoutHistory() {
        let descriptor = FetchDescriptor<WorkoutHistorySession>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        
        do {
            workoutHistory = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load workout history: \(error)")
        }
    }
    
    // Сохранение завершенной тренировки
    func saveWorkoutSession(_ session: WorkoutHistorySession) {
        modelContext.insert(session)
        saveContext()
        loadWorkoutHistory() // Обновляем локальный массив
    }
    
    // Получение статистики по упражнениям
    func getExerciseStats(exerciseId: UUID) -> [WorkoutExerciseStat] {
        var stats: [WorkoutExerciseStat] = []
        
        for session in workoutHistory {
            for exercise in session.completedExercises {
                if exercise.exerciseId == exerciseId {
                    let stat = WorkoutExerciseStat(
                        date: session.startDate,
                        weight: exercise.weight,
                        reps: exercise.reps
                    )
                    stats.append(stat)
                }
            }
        }
        
        return stats.sorted { $0.date < $1.date }
    }
    
    // Получение последних PR для упражнения
    func getPersonalRecord(for exerciseId: UUID) -> WorkoutCompletedExercise? {
        let exercises = workoutHistory.flatMap { $0.completedExercises }
            .filter { $0.exerciseId == exerciseId }
            .sorted { $0.weight > $1.weight }
        
        return exercises.first
    }
    
    // Получение всех тренировок за период
    func getWorkoutsInDateRange(from startDate: Date, to endDate: Date) -> [WorkoutHistorySession] {
        return workoutHistory.filter { session in
            session.startDate >= startDate && session.startDate <= endDate
        }
    }
    
    // Получение общего объема тренировок
    func getTotalVolume() -> Double {
        return workoutHistory.reduce(0) { total, session in
            let sessionVolume = session.completedExercises.reduce(0) { exerciseTotal, exercise in
                let exerciseVolume = exercise.sets.reduce(0) { setTotal, set in
                    setTotal + (set.completedWeight * Double(set.completedReps))
                }
                return exerciseTotal + exerciseVolume
            }
            return total + sessionVolume
        }
    }
    
    // Получение количества тренировок за месяц
    func getMonthlyWorkoutCount() -> Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        
        return workoutHistory.filter { session in
            calendar.component(.month, from: session.startDate) == currentMonth
        }.count
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

// MARK: - Data Models for History
@Model
class WorkoutHistorySession {
    var id: UUID
    var workoutPlanId: UUID
    var workoutName: String
    var startDate: Date
    var endDate: Date
    var duration: TimeInterval
    var completedExercises: [WorkoutCompletedExercise]
    
    init(id: UUID = UUID(),
         workoutPlanId: UUID,
         workoutName: String,
         startDate: Date,
         endDate: Date,
         duration: TimeInterval,
         completedExercises: [WorkoutCompletedExercise]) {
        self.id = id
        self.workoutPlanId = workoutPlanId
        self.workoutName = workoutName
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.completedExercises = completedExercises
    }
}

// MARK: - Supporting Structures
struct WorkoutCompletedExercise: Codable, Hashable {
    let id: UUID
    let exerciseId: UUID
    let exerciseName: String
    let sets: [WorkoutCompletedSet]
    let weight: Double
    let reps: Int
    
    init(id: UUID = UUID(),
         exerciseId: UUID,
         exerciseName: String,
         sets: [WorkoutCompletedSet],
         weight: Double,
         reps: Int) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.sets = sets
        self.weight = weight
        self.reps = reps
    }
}

struct WorkoutCompletedSet: Codable, Hashable {
    let setNumber: Int
    let targetWeight: Double
    let targetReps: Int
    let completedWeight: Double
    let completedReps: Int
    let difficulty: String
    
    init(setNumber: Int,
         targetWeight: Double,
         targetReps: Int,
         completedWeight: Double,
         completedReps: Int,
         difficulty: String) {
        self.setNumber = setNumber
        self.targetWeight = targetWeight
        self.targetReps = targetReps
        self.completedWeight = completedWeight
        self.completedReps = completedReps
        self.difficulty = difficulty
    }
}

struct WorkoutExerciseStat {
    let date: Date
    let weight: Double
    let reps: Int
}
