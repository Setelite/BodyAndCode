//
//  ActiveWorkoutView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/23/25.
//

import SwiftUI

struct ActiveWorkoutView: View {
    @StateObject private var viewModel = ActiveWorkoutViewModel()
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedExercise: Exercise?

    init(presetPlan: WorkoutPlan? = nil) {
        _viewModel = StateObject(wrappedValue: ActiveWorkoutViewModel(presetPlan: presetPlan))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка тренировки...")
                } else if let workoutPlan = viewModel.currentWorkoutPlan {
                    workoutContentView(workoutPlan)
                } else {
                    noWorkoutView
                }
            }
            .navigationTitle("Текущая тренировка")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.handleScenePhaseChange(scenePhase)
            }
            .onChange(of: scenePhase) { _, newValue in
                viewModel.handleScenePhaseChange(newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("История") {
                        appCoordinator.showWorkoutHistory()
                    }
                }
            }
        }
    }
    
    private func workoutContentView(_ workoutPlan: WorkoutPlan) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection(workoutPlan)
                timerSection
                
                ForEach(workoutPlan.exercises) { exercise in
                    ExerciseSummaryCard(
                        exercise: exercise,
                        setsCount: viewModel.totalSetCount(for: exercise.id),
                        completedSetsCount: viewModel.completedSetCount(for: exercise.id),
                        isCompleted: viewModel.isExerciseCompleted(exercise.id)
                    ) {
                        selectedExercise = exercise
                    }
                }
                
                completionSection
            }
            .padding()
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseEditorSheetView(
                exercise: exercise,
                sets: viewModel.setsForExercise(exercise.id),
                onSetComplete: { setIndex, weight, reps in
                    viewModel.completeSet(
                        for: exercise.id,
                        setIndex: setIndex,
                        weight: weight,
                        reps: reps
                    )
                }
            )
        }
    }

    private var timerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(formattedTime(viewModel.elapsedSeconds))
                .font(.system(size: 54, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .glassIce],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            HStack(spacing: 12) {
                timerActionButton(title: "Старт", color: .green) {
                    viewModel.startTimer()
                }
                timerActionButton(title: "Пауза", color: .orange) {
                    viewModel.pauseTimer()
                }
                timerActionButton(title: "Стоп", color: .red) {
                    viewModel.stopTimer()
                }
            }

            timerActionButton(title: "Закончить тренировку", color: .primaryColor) {
                viewModel.finishWorkout()
            }
        }
        .padding()
        .glassCardStyle()
    }

    private func timerActionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [color.opacity(0.95), color.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func headerSection(_ workoutPlan: WorkoutPlan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workoutPlan.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            if let description = workoutPlan.description {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(workoutPlan.exercises.count) упражнений", systemImage: "dumbbell")
                Spacer()
                Label(viewModel.completedSetsCount, systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .glassCardStyle()
    }
    
    private var completionSection: some View {
        VStack(spacing: 15) {
            if viewModel.isWorkoutCompleted {
                Text("Тренировка завершена! 🎉")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Button(action: {
                viewModel.finishWorkout()
            }) {
                Text(viewModel.isWorkoutCompleted ? "Сохранить тренировку" : "Завершить тренировку")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isWorkoutCompleted ? Color.green : Color.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .glassCardStyle()
    }

    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    private var noWorkoutView: some View {
        VStack(spacing: 20) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Тренировка не запланирована")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Вернитесь позже или попросите тренера назначить план тренировок.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Библиотека упражнений") {
                // TODO: Перейти к библиотеке упражнений
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Exercise Summary Card
struct ExerciseSummaryCard: View {
    let exercise: Exercise
    let setsCount: Int
    let completedSetsCount: Int
    let isCompleted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        Text(exercise.muscleGroup.localized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)

                        Text("\(completedSetsCount)/\(setsCount) подходов")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.glassIce.opacity(0.36),
                                        Color.glassBlue.opacity(0.16),
                                        Color.glassLavender.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Exercise Editor Sheet
struct ExerciseEditorSheetView: View {
    let exercise: Exercise
    let sets: [WorkoutSet]
    let onSetComplete: (Int, Double, Int) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                        SetRowView(
                            set: set,
                            setNumber: index + 1,
                            onComplete: { weight, reps in
                                onSetComplete(index, weight, reps)
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Set Row View
struct SetRowView: View {
    let set: WorkoutSet
    let setNumber: Int
    let onComplete: (Double, Int) -> Void
    
    @State private var showingInput = false
    @State private var enteredWeight: String = ""
    @State private var enteredReps: String = ""
    
    var body: some View {
        HStack {
            // Номер подхода
            Text("\(setNumber)")
                .font(.callout)
                .fontWeight(.medium)
                .frame(width: 25)
            
            // Плановые значения
            VStack(alignment: .leading) {
                Text("\(set.targetWeight, specifier: "%.1f") кг")
                    .font(.callout)
                Text("\(set.targetReps) повт.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Статус выполнения
            if set.isCompleted {
                completionBadge
            } else {
                completeButton
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .sheet(isPresented: $showingInput) {
            SetInputView(
                targetWeight: set.targetWeight,
                targetReps: set.targetReps,
                onSave: { weight, reps in
                    onComplete(weight, reps)
                    showingInput = false
                },
                onCancel: {
                    showingInput = false
                }
            )
        }
    }
    
    private var completeButton: some View {
        Button(action: {
            enteredWeight = String(format: "%.1f", set.targetWeight)
            enteredReps = "\(set.targetReps)"
            showingInput = true
        }) {
            Image(systemName: "circle")
                .foregroundColor(.secondary)
                .font(.title3)
        }
        .buttonStyle(.plain)
    }
    
    private var completionBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            VStack(alignment: .trailing) {
                Text("\(set.completedWeight ?? 0, specifier: "%.1f") кг")
                    .font(.callout)
                    .fontWeight(.medium)
                Text("\(set.completedReps ?? 0) повт.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
