//
//  WorkoutHistoryView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/30/25.
//

import SwiftUI
import Combine

struct WorkoutHistoryView: View {
    @StateObject private var viewModel = WorkoutHistoryViewModel()
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка истории...")
                } else if viewModel.workoutSessions.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("История тренировок")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Статистика") {
                        // TODO: Перейти к детальной статистике
                    }
                }
            }
        }
    }
    
    private var historyListView: some View {
        List {
            ForEach(viewModel.workoutSessions) { session in
                WorkoutSessionRow(session: session) {
                    viewModel.showSessionDetail(session)
                }
            }
        }
        .refreshable {
            viewModel.loadWorkoutHistory()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("История тренировок пуста")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Завершите первую тренировку, и она появится здесь.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Начать тренировку") {
                appCoordinator.switchToTab(.workout)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Workout Session Row
struct WorkoutSessionRow: View {
    let session: WorkoutHistorySession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Иконка тренировки
                VStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.blue)
                        .cornerRadius(8)
                    
                    Spacer()
                }
                
                // Информация о тренировке
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.workoutName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(session.startDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("\(session.completedExercises.count) упр.", systemImage: "dumbbell")
                        Label(formatDuration(session.duration), systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Статус завершения
                VStack(alignment: .trailing) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Завершено")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) мин"
    }
}

// MARK: - ViewModel для истории тренировок
@MainActor
class WorkoutHistoryViewModel: ObservableObject {
    @Published var workoutSessions: [WorkoutHistorySession] = []
    @Published var isLoading: Bool = false
    
    init() {
        loadWorkoutHistory()
    }
    
    func loadWorkoutHistory() {
        isLoading = true
        
        // Временные mock данные
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.workoutSessions = self.createMockWorkoutSessions()
            self.isLoading = false
        }
    }
    
    func showSessionDetail(_ session: WorkoutHistorySession) {
        print("Показать детали тренировки: \(session.workoutName)")
    }
    
    // MARK: - Mock Data
    private func createMockWorkoutSessions() -> [WorkoutHistorySession] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            WorkoutHistorySession(
                workoutPlanId: UUID(),
                workoutName: "Грудь и Трицепс",
                startDate: calendar.date(byAdding: .day, value: -1, to: today)!,
                endDate: calendar.date(byAdding: .hour, value: 1, to: calendar.date(byAdding: .day, value: -1, to: today)!)!,
                duration: 3600,
                completedExercises: [
                    WorkoutCompletedExercise(
                        exerciseId: UUID(),
                        exerciseName: "Жим лежа",
                        sets: [
                            WorkoutCompletedSet(
                                setNumber: 1,
                                targetWeight: 60,
                                targetReps: 8,
                                completedWeight: 65,
                                completedReps: 8,
                                difficulty: "medium"
                            )
                        ],
                        weight: 65,
                        reps: 8
                    )
                ]
            ),
            WorkoutHistorySession(
                workoutPlanId: UUID(),
                workoutName: "Ноги",
                startDate: calendar.date(byAdding: .day, value: -3, to: today)!,
                endDate: calendar.date(byAdding: .hour, value: 1, to: calendar.date(byAdding: .day, value: -3, to: today)!)!,
                duration: 3300,
                completedExercises: [
                    WorkoutCompletedExercise(
                        exerciseId: UUID(),
                        exerciseName: "Приседания",
                        sets: [
                            WorkoutCompletedSet(
                                setNumber: 1,
                                targetWeight: 80,
                                targetReps: 8,
                                completedWeight: 85,
                                completedReps: 8,
                                difficulty: "medium"
                            )
                        ],
                        weight: 85,
                        reps: 8
                    )
                ]
            ),
            WorkoutHistorySession(
                workoutPlanId: UUID(),
                workoutName: "Спина и Бицепс",
                startDate: calendar.date(byAdding: .day, value: -5, to: today)!,
                endDate: calendar.date(byAdding: .hour, value: 1, to: calendar.date(byAdding: .day, value: -5, to: today)!)!,
                duration: 3000,
                completedExercises: [
                    WorkoutCompletedExercise(
                        exerciseId: UUID(),
                        exerciseName: "Подтягивания",
                        sets: [
                            WorkoutCompletedSet(
                                setNumber: 1,
                                targetWeight: 0,
                                targetReps: 8,
                                completedWeight: 0,
                                completedReps: 10,
                                difficulty: "easy"
                            )
                        ],
                        weight: 0,
                        reps: 10
                    )
                ]
            )
        ]
    }
}
