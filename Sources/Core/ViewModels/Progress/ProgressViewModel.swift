//
//  ProgressViewModel.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/24/25.
//

import SwiftUI
import Combine

@MainActor
final class ProgressViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var weightData: [WeightData] = []
    @Published var exerciseProgress: [ExerciseProgress] = []
    @Published var personalRecords: [PersonalRecord] = []
    @Published var workoutHistory: [WorkoutHistory] = []
    @Published var isLoading: Bool = false
    @Published var analyticsEventsCount: Int = 0
    private let workoutStore = WorkoutPersistenceStore()
    
    // MARK: - Data Structures
    struct WeightData: Identifiable {
        let id = UUID()
        let date: Date
        let weight: Double
    }
    
    struct ExerciseProgress: Identifiable {
        let id = UUID()
        let exerciseName: String
        let currentWeight: Double
        let goalWeight: Double
        let progressPercentage: Double
    }
    
    struct PersonalRecord: Identifiable {
        let id = UUID()
        let exerciseName: String
        let weight: Double
        let reps: Int
        let date: Date
    }
    
    struct WorkoutHistory: Identifiable {
        let id: UUID
        let workoutName: String
        let date: Date
        let completedExercises: Int
        let totalExercises: Int
        let duration: TimeInterval

        init(
            id: UUID = UUID(),
            workoutName: String,
            date: Date,
            completedExercises: Int,
            totalExercises: Int,
            duration: TimeInterval
        ) {
            self.id = id
            self.workoutName = workoutName
            self.date = date
            self.completedExercises = completedExercises
            self.totalExercises = totalExercises
            self.duration = duration
        }
    }
    
    // MARK: - Initialization
    init() {
        // Инициализация свойств
        self.weightData = []
        self.exerciseProgress = []
        self.personalRecords = []
        self.workoutHistory = []
        self.isLoading = false
        
        loadProgressData()
    }
    
    // MARK: - Public Methods
    func loadProgressData() {
        isLoading = true
        let sessions = workoutStore.loadHistory()
        analyticsEventsCount = AnalyticsService.shared.recentEvents(limit: 10_000).count

        if sessions.isEmpty {
            loadMockData()
            isLoading = false
            return
        }

        applyHistorySessions(sessions)
        isLoading = false
    }
    
    func addWeightEntry(_ weight: Double, date: Date = Date()) {
        let newEntry = WeightData(date: date, weight: weight)
        weightData.append(newEntry)
        weightData.sort { $0.date < $1.date }
    }
    
    func addPersonalRecord(exerciseName: String, weight: Double, reps: Int) {
        let newRecord = PersonalRecord(
            exerciseName: exerciseName,
            weight: weight,
            reps: reps,
            date: Date()
        )
        personalRecords.append(newRecord)
        personalRecords.sort { $0.weight > $1.weight }
    }
    
    // MARK: - Analytics Methods
    func calculateMonthlyProgress() -> Double? {
        guard weightData.count >= 2,
              let firstWeight = weightData.first?.weight,
              let lastWeight = weightData.last?.weight else {
            return nil
        }
        return lastWeight - firstWeight
    }
    
    func getTopExercises(limit: Int = 3) -> [ExerciseProgress] {
        return Array(exerciseProgress.prefix(limit))
    }
    
    func getRecentPersonalRecords(limit: Int = 5) -> [PersonalRecord] {
        return Array(personalRecords.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    // MARK: - Mock Data
    private func loadMockData() {
        loadMockWeightData()
        loadMockExerciseProgress()
        loadMockPersonalRecords()
        loadMockWorkoutHistory()
    }
    
    private func loadMockWeightData() {
        let calendar = Calendar.current
        let today = Date()
        
        weightData = [
            WeightData(date: calendar.date(byAdding: .day, value: -30, to: today)!, weight: 78.5),
            WeightData(date: calendar.date(byAdding: .day, value: -25, to: today)!, weight: 78.0),
            WeightData(date: calendar.date(byAdding: .day, value: -20, to: today)!, weight: 77.8),
            WeightData(date: calendar.date(byAdding: .day, value: -15, to: today)!, weight: 77.2),
            WeightData(date: calendar.date(byAdding: .day, value: -10, to: today)!, weight: 76.5),
            WeightData(date: calendar.date(byAdding: .day, value: -5, to: today)!, weight: 76.0),
            WeightData(date: today, weight: 75.5)
        ]
    }
    
    private func loadMockExerciseProgress() {
        exerciseProgress = [
            ExerciseProgress(
                exerciseName: "Жим лежа",
                currentWeight: 85,
                goalWeight: 100,
                progressPercentage: 15.0
            ),
            ExerciseProgress(
                exerciseName: "Приседания",
                currentWeight: 120,
                goalWeight: 140,
                progressPercentage: 14.3
            ),
            ExerciseProgress(
                exerciseName: "Становая тяга",
                currentWeight: 140,
                goalWeight: 160,
                progressPercentage: 12.5
            ),
            ExerciseProgress(
                exerciseName: "Подтягивания",
                currentWeight: 0,
                goalWeight: 0,
                progressPercentage: 25.0
            ),
            ExerciseProgress(
                exerciseName: "Жим гантелей сидя",
                currentWeight: 32,
                goalWeight: 40,
                progressPercentage: 20.0
            )
        ]
    }
    
    private func loadMockPersonalRecords() {
        let calendar = Calendar.current
        let today = Date()
        
        personalRecords = [
            PersonalRecord(
                exerciseName: "Жим лежа",
                weight: 85,
                reps: 5,
                date: calendar.date(byAdding: .day, value: -7, to: today)!
            ),
            PersonalRecord(
                exerciseName: "Приседания",
                weight: 120,
                reps: 3,
                date: calendar.date(byAdding: .day, value: -14, to: today)!
            ),
            PersonalRecord(
                exerciseName: "Становая тяга",
                weight: 140,
                reps: 2,
                date: calendar.date(byAdding: .day, value: -10, to: today)!
            ),
            PersonalRecord(
                exerciseName: "Подтягивания",
                weight: 0,
                reps: 12,
                date: calendar.date(byAdding: .day, value: -3, to: today)!
            ),
            PersonalRecord(
                exerciseName: "Жим гантелей",
                weight: 35,
                reps: 8,
                date: calendar.date(byAdding: .day, value: -1, to: today)!
            )
        ]
    }
    
    private func loadMockWorkoutHistory() {
        let calendar = Calendar.current
        let today = Date()
        
        workoutHistory = [
            WorkoutHistory(
                workoutName: "Грудь и Трицепс",
                date: calendar.date(byAdding: .day, value: -1, to: today)!,
                completedExercises: 4,
                totalExercises: 4,
                duration: 45 * 60
            ),
            WorkoutHistory(
                workoutName: "Ноги",
                date: calendar.date(byAdding: .day, value: -3, to: today)!,
                completedExercises: 3,
                totalExercises: 4,
                duration: 55 * 60
            ),
            WorkoutHistory(
                workoutName: "Спина и Бицепс",
                date: calendar.date(byAdding: .day, value: -5, to: today)!,
                completedExercises: 5,
                totalExercises: 5,
                duration: 50 * 60
            ),
            WorkoutHistory(
                workoutName: "Плечи",
                date: calendar.date(byAdding: .day, value: -7, to: today)!,
                completedExercises: 4,
                totalExercises: 4,
                duration: 40 * 60
            )
        ]
    }

    private func applyHistorySessions(_ sessions: [StoredWorkoutHistorySession]) {
        workoutHistory = sessions.map {
            WorkoutHistory(
                id: $0.id,
                workoutName: $0.workoutName,
                date: $0.startDate,
                completedExercises: $0.completedExercises.count,
                totalExercises: $0.completedExercises.count,
                duration: $0.duration
            )
        }

        let allExercises = sessions.flatMap(\.completedExercises)

        personalRecords = allExercises.compactMap { exercise in
            guard let best = exercise.sets.max(by: { $0.completedWeight < $1.completedWeight }) else { return nil }
            return PersonalRecord(
                exerciseName: exercise.exerciseName,
                weight: best.completedWeight,
                reps: best.completedReps,
                date: sessions.first(where: { $0.completedExercises.contains(where: { $0.exerciseId == exercise.exerciseId }) })?.endDate ?? Date()
            )
        }
        .sorted { $0.weight > $1.weight }

        let grouped = Dictionary(grouping: allExercises, by: { $0.exerciseName })
        exerciseProgress = grouped.compactMap { name, exercises in
            let weights = exercises.compactMap { ex in
                ex.sets.map(\.completedWeight).max()
            }
            guard let current = weights.last ?? weights.max(),
                  let minValue = weights.min(),
                  current > 0 else { return nil }

            let baseline = max(minValue, 1)
            let progress = ((current - baseline) / baseline) * 100
            let goal = max(current * 1.15, current + 2.5)
            return ExerciseProgress(
                exerciseName: name,
                currentWeight: current,
                goalWeight: goal,
                progressPercentage: progress
            )
        }
        .sorted { $0.progressPercentage > $1.progressPercentage }
    }
}
