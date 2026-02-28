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
    @Published var elapsedSeconds: Int = 0
    @Published var isTimerRunning: Bool = false

    private var timerCancellable: AnyCancellable?
    private var timerStartedAt: Date?
    private var accumulatedElapsedSeconds: Int = 0
    private let customWorkoutDraftStore = CustomWorkoutDraftStore()
    private let workoutPersistenceStore = WorkoutPersistenceStore()
    private var exerciseSetPlan: [UUID: [CustomWorkoutSet]] = [:]
    private var stableSetIDs: [String: UUID] = [:]
    private let presetPlan: WorkoutPlan?
    
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
        guard currentWorkoutPlan != nil else { return false }
        let totalSets: Int
        if exerciseSetPlan.isEmpty {
            totalSets = (currentWorkoutPlan?.exercises.count ?? 0) * 3
        } else {
            totalSets = exerciseSetPlan.values.reduce(0) { $0 + $1.count }
        }
        return completedSets.count >= totalSets
    }
    
    init(presetPlan: WorkoutPlan? = nil) {
        self.presetPlan = presetPlan
        setupTimer()
        if !restoreOngoingWorkoutIfNeeded() {
            if let presetPlan {
                loadPresetWorkout(presetPlan)
            } else {
                loadTodaysWorkout()
            }
            startWorkout()
        }
    }

    private func loadPresetWorkout(_ plan: WorkoutPlan) {
        isLoading = false
        stableSetIDs.removeAll()
        currentWorkoutPlan = plan
        exerciseSetPlan = Dictionary(uniqueKeysWithValues: plan.exercises.map {
            ($0.id, [
                CustomWorkoutSet(setNumber: 1, targetReps: 12, targetWeight: 0),
                CustomWorkoutSet(setNumber: 2, targetReps: 10, targetWeight: 0),
                CustomWorkoutSet(setNumber: 3, targetReps: 8, targetWeight: 0)
            ])
        })
        completedSets.removeAll()
        persistOngoingWorkout()
    }
    
    func loadTodaysWorkout() {
        isLoading = true
        stableSetIDs.removeAll()

        if let draft = customWorkoutDraftStore.load() {
            currentWorkoutPlan = WorkoutPlan(
                id: draft.id,
                name: draft.name,
                description: "Собранная тренировка",
                dayOfWeek: DayOfWeek.from(Date()),
                exercises: draft.exercises.map(\.exercise),
                assignedTo: [UUID()],
                createdAt: draft.createdAt
            )
            exerciseSetPlan = Dictionary(uniqueKeysWithValues: draft.exercises.map { ($0.exercise.id, $0.sets) })
            completedSets.removeAll()
            isLoading = false
            customWorkoutDraftStore.clear()
            persistOngoingWorkout()
            return
        }
        
        // Имитация загрузки из сети/базы
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.currentWorkoutPlan = self.mockWorkoutPlan
            self.exerciseSetPlan = [:]
            self.generateInitialSets()
            self.persistOngoingWorkout()
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
        let plannedSets = exerciseSetPlan[exerciseId] ?? (1...3).map {
            CustomWorkoutSet(
                setNumber: $0,
                targetReps: 8 + ($0 - 1) * 2,
                targetWeight: 60.0 + Double($0 - 1) * 5.0
            )
        }

        for plannedSet in plannedSets {
            let setNumber = plannedSet.setNumber
            let isCompleted = completedSets.contains { $0.exerciseId == exerciseId && $0.setNumber == setNumber }
            let completedSet = completedSets.first { $0.exerciseId == exerciseId && $0.setNumber == setNumber }
            
            let set = WorkoutSet(
                id: stableSetID(for: exerciseId, setNumber: setNumber),
                exerciseId: exerciseId,
                workoutPlanId: workoutPlan.id,
                setNumber: setNumber,
                targetReps: plannedSet.targetReps,
                targetWeight: plannedSet.targetWeight,
                completedReps: completedSet?.completedReps,
                completedWeight: completedSet?.completedWeight,
                isCompleted: isCompleted,
                date: Date()
            )
            sets.append(set)
        }
        return sets
    }

    private func stableSetID(for exerciseId: UUID, setNumber: Int) -> UUID {
        let key = "\(exerciseId.uuidString)-\(setNumber)"
        if let existing = stableSetIDs[key] {
            return existing
        }
        let newID = UUID()
        stableSetIDs[key] = newID
        return newID
    }
    
    func completeSet(for exerciseId: UUID, setIndex: Int, weight: Double, reps: Int) {
        let setNumber = setIndex + 1
        let plannedSet = exerciseSetPlan[exerciseId]?.first(where: { $0.setNumber == setNumber })
        
        // Удаляем старую запись если есть
        completedSets.removeAll { $0.exerciseId == exerciseId && $0.setNumber == setNumber }
        
        // Добавляем новую completed запись
        let completedSet = WorkoutSet(
            id: UUID(),
            exerciseId: exerciseId,
            workoutPlanId: currentWorkoutPlan?.id ?? UUID(),
            setNumber: setNumber,
            targetReps: plannedSet?.targetReps ?? (8 + setIndex * 2),
            targetWeight: plannedSet?.targetWeight ?? (60.0 + Double(setIndex) * 5.0),
            completedReps: reps,
            completedWeight: weight,
            isCompleted: true,
            date: Date()
        )
        
        completedSets.append(completedSet)
        objectWillChange.send()
        persistOngoingWorkout()
    }
    
    // MARK: - Workout History Methods
    
    func startWorkout() {
        workoutStartTime = Date()
        elapsedSeconds = 0
        isTimerRunning = false
        timerStartedAt = nil
        accumulatedElapsedSeconds = 0
        print("Тренировка начата: \(workoutStartTime?.description ?? "неизвестно")")
        persistOngoingWorkout()
    }

    func startTimer() {
        guard !isTimerRunning else { return }
        timerStartedAt = Date()
        isTimerRunning = true
        syncElapsedFromClock()
        persistOngoingWorkout()
    }

    func pauseTimer() {
        guard isTimerRunning else { return }
        syncElapsedFromClock()
        accumulatedElapsedSeconds = elapsedSeconds
        timerStartedAt = nil
        isTimerRunning = false
        persistOngoingWorkout()
    }

    func stopTimer() {
        isTimerRunning = false
        timerStartedAt = nil
        accumulatedElapsedSeconds = 0
        elapsedSeconds = 0
        persistOngoingWorkout()
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            syncElapsedFromClock()
            if isTimerRunning {
                persistOngoingWorkout()
            }
        case .background:
            if isTimerRunning {
                syncElapsedFromClock()
                persistOngoingWorkout()
            }
        default:
            break
        }
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
        
        let storedSession = StoredWorkoutHistorySession(
            id: UUID(),
            workoutPlanId: workoutPlan.id,
            workoutName: workoutPlan.name,
            startDate: startTime,
            endDate: endTime,
            duration: duration,
            completedExercises: completedExercises.map { exercise in
                StoredWorkoutExercise(
                    exerciseId: exercise.exerciseId,
                    exerciseName: exercise.exerciseName,
                    sets: exercise.sets.map {
                        StoredWorkoutSet(
                            setNumber: $0.setNumber,
                            targetWeight: $0.targetWeight,
                            targetReps: $0.targetReps,
                            completedWeight: $0.completedWeight,
                            completedReps: $0.completedReps,
                            difficulty: $0.difficulty
                        )
                    },
                    weight: exercise.weight,
                    reps: exercise.reps
                )
            }
        )
        
        // Сохраняем в историю
        saveWorkoutToHistory(storedSession)
        
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
    
    private func saveWorkoutToHistory(_ session: StoredWorkoutHistorySession) {
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
        
        workoutPersistenceStore.appendHistory(session)
        saveToUserDefaults(session)
    }
    
    private func saveToUserDefaults(_ session: StoredWorkoutHistorySession) {
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
        stableSetIDs.removeAll()
        completedSets.removeAll()
        workoutStartTime = nil
        stopTimer()
        errorMessage = nil
        workoutPersistenceStore.clearOngoing()
        loadTodaysWorkout() // Перезагружаем для новой тренировки
    }

    private func setupTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isTimerRunning else { return }
                self.syncElapsedFromClock()
                if self.elapsedSeconds % 5 == 0 {
                    self.persistOngoingWorkout()
                }
            }
    }

    private func restoreOngoingWorkoutIfNeeded() -> Bool {
        guard let snapshot = workoutPersistenceStore.loadOngoing() else { return false }
        stableSetIDs.removeAll()
        currentWorkoutPlan = snapshot.workoutPlan
        completedSets = snapshot.completedSets
        workoutStartTime = snapshot.workoutStartTime
        exerciseSetPlan = snapshot.exerciseSetPlan
        accumulatedElapsedSeconds = snapshot.accumulatedElapsedBeforeCurrentRun ?? snapshot.elapsedSeconds
        if snapshot.isTimerRunning {
            if let previousStart = snapshot.timerStartedAt {
                let backgroundDelta = max(Int(Date().timeIntervalSince(previousStart)), 0)
                accumulatedElapsedSeconds += backgroundDelta
            }
            timerStartedAt = Date()
            isTimerRunning = true
        } else {
            timerStartedAt = nil
            isTimerRunning = false
        }
        syncElapsedFromClock()
        isLoading = false
        return true
    }

    private func persistOngoingWorkout() {
        guard let workoutPlan = currentWorkoutPlan else { return }
        if isTimerRunning {
            syncElapsedFromClock()
        }
        let snapshot = OngoingWorkoutSnapshot(
            workoutPlan: workoutPlan,
            completedSets: completedSets,
            workoutStartTime: workoutStartTime,
            elapsedSeconds: elapsedSeconds,
            isTimerRunning: isTimerRunning,
            exerciseSetPlan: exerciseSetPlan,
            timerStartedAt: timerStartedAt,
            accumulatedElapsedBeforeCurrentRun: accumulatedElapsedSeconds
        )
        workoutPersistenceStore.saveOngoing(snapshot)
    }

    private func syncElapsedFromClock() {
        if isTimerRunning, let timerStartedAt {
            let runElapsed = max(Int(Date().timeIntervalSince(timerStartedAt)), 0)
            elapsedSeconds = accumulatedElapsedSeconds + runElapsed
        } else {
            elapsedSeconds = accumulatedElapsedSeconds
        }
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
