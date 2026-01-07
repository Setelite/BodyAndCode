//
//  ActiveWorkoutViewModel.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/23/25.
//

import SwiftUI
import Combine
import Foundation

@MainActor
final class ActiveWorkoutViewModel: ObservableObject {
    @Published var currentWorkoutPlan: WorkoutPlan?
    @Published var completedSets: [WorkoutSet] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var workoutStartTime: Date?
    
    private var mockWorkoutPlan: WorkoutPlan {
        WorkoutPlan(
            id: UUID(),
            name: "Грудь и Трицепс",
            description: "Фокус на верхнюю часть тела",
            dayOfWeek: .monday,
            exercises: [
                Exercise(
                    id: UUID(),
                    name: "Жим штанги лежа",
                    muscleGroup: .chest,
                    description: "Жим штанги на горизонтальной скамье"
                ),
                Exercise(
                    id: UUID(),
                    name: "Жим гантелей на наклонной",
                    muscleGroup: .chest,
                    description: "Жим гантелей на наклонной скамье"
                ),
                Exercise(
                    id: UUID(),
                    name: "Разгибания на трицепс",
                    muscleGroup: .arms,
                    description: "Разгибания рук на блоке для трицепса"
                )
            ],
            assignedTo: [UUID()],
            createdAt: Date()
        )
    }
    
    var completedSetsCount: String {
        "\(completedSets.count) подходов выполнено"
    }
    
    var isWorkoutCompleted: Bool {
        guard let workoutPlan = currentWorkoutPlan else { return false }
        let totalSets = workoutPlan.exercises.count * 3 // 3 sets per exercise
        return completedSets.count >= totalSets
    }
    
    init() {
        loadTodaysWorkout()
        startWorkout()
    }
    
    func loadTodaysWorkout() {
        isLoading = true
        
        // Имитация загрузки из сети/базы
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.currentWorkoutPlan = self.mockWorkoutPlan
            self.generateInitialSets()
        }
    }
    
    private func generateInitialSets() {
        guard let workoutPlan = currentWorkoutPlan else { return }
        
        completedSets.removeAll()
        
        for exercise in workoutPlan.exercises {
            for setNumber in 1...3 { // 3 подхода на упражнение
                _ = WorkoutSet(
                    id: UUID(),
                    exerciseId: exercise.id,
                    workoutPlanId: workoutPlan.id,
                    setNumber: setNumber,
                    targetReps: 8 + (setNumber - 1) * 2, // 8, 10, 12 reps
                    targetWeight: 60.0 + Double(setNumber - 1) * 5.0, // 60, 65, 70 kg
                    completedReps: nil,
                    completedWeight: nil,
                    isCompleted: false,
                    date: Date()
                )
                // Здесь мы не добавляем в completedSets, только когда пользователь выполнит
            }
        }
    }
    
    func setsForExercise(_ exerciseId: UUID) -> [WorkoutSet] {
        // В реальном приложении здесь будет логика получения сетов из базы
        // Сейчас возвращаем mock данные
        guard let workoutPlan = currentWorkoutPlan else { return [] }
        
        var sets: [WorkoutSet] = []
        for setNumber in 1...3 {
            let isCompleted = completedSets.contains { $0.exerciseId == exerciseId && $0.setNumber == setNumber }
            let completedSet = completedSets.first { $0.exerciseId == exerciseId && $0.setNumber == setNumber }
            
            let set = WorkoutSet(
                id: UUID(),
                exerciseId: exerciseId,
                workoutPlanId: workoutPlan.id,
                setNumber: setNumber,
                targetReps: 8 + (setNumber - 1) * 2,
                targetWeight: 60.0 + Double(setNumber - 1) * 5.0,
                completedReps: completedSet?.completedReps,
                completedWeight: completedSet?.completedWeight,
                isCompleted: isCompleted,
                date: Date()
            )
            sets.append(set)
        }
        return sets
    }
    
    func completeSet(for exerciseId: UUID, setIndex: Int, weight: Double, reps: Int) {
        let setNumber = setIndex + 1
        
        // Удаляем старую запись если есть
        completedSets.removeAll { $0.exerciseId == exerciseId && $0.setNumber == setNumber }
        
        // Добавляем новую completed запись
        let completedSet = WorkoutSet(
            id: UUID(),
            exerciseId: exerciseId,
            workoutPlanId: currentWorkoutPlan?.id ?? UUID(),
            setNumber: setNumber,
            targetReps: 8 + (setIndex) * 2,
            targetWeight: 60.0 + Double(setIndex) * 5.0,
            completedReps: reps,
            completedWeight: weight,
            isCompleted: true,
            date: Date()
        )
        
        completedSets.append(completedSet)
        objectWillChange.send()
    }
    
    // MARK: - Workout History Methods
    
    func startWorkout() {
        workoutStartTime = Date()
        print("Тренировка начата: \(workoutStartTime?.description ?? "неизвестно")")
    }
    
    func finishWorkout() {
        guard let startTime = workoutStartTime,
              let workoutPlan = currentWorkoutPlan else {
            errorMessage = "Не удалось завершить тренировку"
            return
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // Создаем завершенные упражнения
        let completedExercises = createCompletedExercises()
        
        // Создаем сессию тренировки (используем WorkoutHistorySession)
        let workoutSession = WorkoutHistorySession(
            workoutPlanId: workoutPlan.id,
            workoutName: workoutPlan.name,
            startDate: startTime,
            endDate: endTime,
            duration: duration,
            completedExercises: completedExercises
        )
        
        // Сохраняем в историю (пока просто выводим в консоль)
        saveWorkoutToHistory(workoutSession)
        
        // Показываем успешное сообщение
        errorMessage = "Тренировка завершена и сохранена! 🎉"
        
        // Сбрасываем состояние
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.resetWorkout()
        }
    }
    
    private func createCompletedExercises() -> [WorkoutCompletedExercise] {
        var exercises: [WorkoutCompletedExercise] = []
        
        guard let workoutPlan = currentWorkoutPlan else { return [] }
        
        for exercise in workoutPlan.exercises {
            let exerciseSets = completedSets.filter { $0.exerciseId == exercise.id }
            
            // Создаем завершенные подходы
            let completedSetsData = exerciseSets.map { set in
                WorkoutCompletedSet(
                    setNumber: set.setNumber,
                    targetWeight: set.targetWeight,
                    targetReps: set.targetReps,
                    completedWeight: set.completedWeight ?? 0,
                    completedReps: set.completedReps ?? 0,
                    difficulty: calculateDifficulty(for: set)
                )
            }
            
            // Находим максимальные показатели
            let maxWeight = exerciseSets.compactMap { $0.completedWeight }.max() ?? 0
            let maxReps = exerciseSets.compactMap { $0.completedReps }.max() ?? 0
            
            let completedExercise = WorkoutCompletedExercise(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
                sets: completedSetsData,
                weight: maxWeight,
                reps: maxReps
            )
            
            exercises.append(completedExercise)
        }
        
        return exercises
    }
    
    private func calculateDifficulty(for set: WorkoutSet) -> String {
        guard let completedWeight = set.completedWeight,
              let completedReps = set.completedReps else {
            return "medium"
        }
        
        let targetCompletion = (completedWeight / set.targetWeight) * Double(completedReps) / Double(set.targetReps)
        
        switch targetCompletion {
        case ..<0.8:
            return "hard"
        case 0.8..<1.2:
            return "medium"
        default:
            return "easy"
        }
    }
    
    private func saveWorkoutToHistory(_ session: WorkoutHistorySession) {
        // Временная реализация - выводим в консоль
        // В реальном приложении здесь будет сохранение в базу данных
        
        print("""
        💾 СОХРАНЕНИЕ ТРЕНИРОВКИ:
        Название: \(session.workoutName)
        Длительность: \(Int(session.duration / 60)) минут
        Упражнений: \(session.completedExercises.count)
        Подходов: \(session.completedExercises.reduce(0) { $0 + $1.sets.count })
        Дата: \(session.startDate)
        
        ДЕТАЛИ:
        """)
        
        for exercise in session.completedExercises {
            print("""
            🏋️ \(exercise.exerciseName)
            Макс. вес: \(exercise.weight) кг
            Макс. повторения: \(exercise.reps)
            Подходов: \(exercise.sets.count)
            """)
            
            for set in exercise.sets {
                print("   Подход \(set.setNumber): \(set.completedWeight) кг × \(set.completedReps) повт.")
            }
            print("")
        }
        
        // Здесь можно добавить сохранение в UserDefaults, SwiftData или другую базу
        saveToUserDefaults(session)
    }
    
    private func saveToUserDefaults(_ session: WorkoutHistorySession) {
        // Временное сохранение в UserDefaults для демонстрации
        var savedWorkouts = UserDefaults.standard.array(forKey: "savedWorkouts") as? [String] ?? []
        
        let workoutInfo = """
        \(session.startDate): \(session.workoutName) - \(session.completedExercises.count) упражнений
        """
        
        savedWorkouts.append(workoutInfo)
        UserDefaults.standard.set(savedWorkouts, forKey: "savedWorkouts")
        
        print("✅ Тренировка сохранена в UserDefaults. Всего тренировок: \(savedWorkouts.count)")
    }
    
    private func resetWorkout() {
        completedSets.removeAll()
        workoutStartTime = nil
        errorMessage = nil
        loadTodaysWorkout() // Перезагружаем для новой тренировки
    }
    
    // MARK: - Workout Statistics
    
    func getWorkoutStatistics() -> WorkoutStatistics {
        let totalExercises = currentWorkoutPlan?.exercises.count ?? 0
        let completedExercises = Set(completedSets.map { $0.exerciseId }).count
        let totalVolume = completedSets.reduce(0) { $0 + ($1.completedWeight ?? 0) * Double($1.completedReps ?? 0) }
        
        return WorkoutStatistics(
            totalExercises: totalExercises,
            completedExercises: completedExercises,
            totalSets: completedSets.count,
            totalVolume: totalVolume,
            startTime: workoutStartTime ?? Date()
        )
    }
}

// MARK: - Supporting Structures

struct WorkoutStatistics {
    let totalExercises: Int
    let completedExercises: Int
    let totalSets: Int
    let totalVolume: Double
    let startTime: Date
    
    var completionPercentage: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(completedExercises) / Double(totalExercises) * 100
    }
    
    var duration: TimeInterval {
        Date().timeIntervalSince(startTime)
    }
}
