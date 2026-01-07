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
                
                ForEach(workoutPlan.exercises) { exercise in
                    ExerciseSectionView(
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
                
                completionSection
            }
            .padding()
        }
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
        .background(Color.secondaryBackground)
        .cornerRadius(12)
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

// MARK: - Exercise Section View
struct ExerciseSectionView: View {
    let exercise: Exercise
    let sets: [WorkoutSet]
    let onSetComplete: (Int, Double, Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            exerciseHeader
            
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
        .background(Color.background)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Text(exercise.muscleGroup.localized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                if exercise.description != nil {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
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
        .padding(.vertical, 8)
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
