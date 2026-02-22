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
    @State private var selectedSession: StoredWorkoutHistorySession?
    
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
                    selectedSession = session
                }
            }
        }
        .refreshable {
            viewModel.loadWorkoutHistory()
        }
        .sheet(item: $selectedSession) { session in
            WorkoutSessionDetailView(session: session)
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

struct WorkoutSessionDetailView: View {
    let session: StoredWorkoutHistorySession

    var body: some View {
        NavigationView {
            List {
                Section("Обзор") {
                    LabeledContent("Название", value: session.workoutName)
                    LabeledContent("Дата", value: formattedDate(session.startDate))
                    LabeledContent("Длительность", value: "\(Int(session.duration) / 60) мин")
                    LabeledContent("Упражнений", value: "\(session.completedExercises.count)")
                }

                ForEach(session.completedExercises, id: \.exerciseId) { exercise in
                    Section(exercise.exerciseName) {
                        LabeledContent("Макс. вес", value: "\(formatWeight(exercise.weight)) кг")
                        LabeledContent("Макс. повторения", value: "\(exercise.reps)")

                        ForEach(exercise.sets, id: \.setNumber) { set in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Подход \(set.setNumber)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("План: \(formatWeight(set.targetWeight)) кг × \(set.targetReps)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Факт: \(formatWeight(set.completedWeight)) кг × \(set.completedReps)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Детали тренировки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatWeight(_ weight: Double) -> String {
        String(format: "%.1f", weight)
    }
}

// MARK: - Workout Session Row
struct WorkoutSessionRow: View {
    let session: StoredWorkoutHistorySession
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
    @Published var workoutSessions: [StoredWorkoutHistorySession] = []
    @Published var isLoading: Bool = false
    private let workoutPersistenceStore = WorkoutPersistenceStore()
    
    init() {
        loadWorkoutHistory()
    }
    
    func loadWorkoutHistory() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.workoutSessions = self.workoutPersistenceStore.loadHistory()
            self.isLoading = false
        }
    }
    
}
