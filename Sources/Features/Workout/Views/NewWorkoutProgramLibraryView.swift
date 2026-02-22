//
//  NewWorkoutProgramLibraryView.swift
//  Body&Code
//
//  Created by Codex on 2/22/26.
//

import SwiftUI

struct NewWorkoutProgramLibraryView: View {
    private let templates = WorkoutProgramTemplate.sampleLibrary

    var body: some View {
        List {
            Section("База программ") {
                ForEach(templates) { template in
                    NavigationLink(destination: WorkoutProgramDetailView(template: template)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(template.name)
                                .font(.headline)
                            Text(template.summary)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(template.exercises.count) упражнений")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Новая тренировка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WorkoutProgramDetailView: View {
    let template: WorkoutProgramTemplate
    @State private var selectedExerciseIDs: Set<UUID>

    init(template: WorkoutProgramTemplate) {
        self.template = template
        _selectedExerciseIDs = State(initialValue: Set(template.exercises.map(\.id)))
    }

    private var selectedExercises: [WorkoutExerciseTemplate] {
        template.exercises.filter { selectedExerciseIDs.contains($0.id) }
    }

    var body: some View {
        List {
            Section("Упражнения программы") {
                ForEach(template.exercises) { exercise in
                    Button {
                        toggle(exerciseID: exercise.id)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.exercise.name)
                                    .foregroundColor(.primary)
                                Text("\(exercise.defaultSets) x \(exercise.defaultReps), \(exercise.defaultWeight, specifier: "%.1f") кг")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: selectedExerciseIDs.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedExerciseIDs.contains(exercise.id) ? .blue : .gray)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Section {
                NavigationLink(
                    destination: WorkoutAssemblyView(
                        templateName: template.name,
                        selectedExercises: selectedExercises
                    )
                ) {
                    Text("Собрать тренировку")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .disabled(selectedExercises.isEmpty)
            }
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggle(exerciseID: UUID) {
        if selectedExerciseIDs.contains(exerciseID) {
            selectedExerciseIDs.remove(exerciseID)
        } else {
            selectedExerciseIDs.insert(exerciseID)
        }
    }
}

struct WorkoutAssemblyView: View {
    private let draftStore = CustomWorkoutDraftStore()
    @State private var workoutName: String
    @State private var items: [PlannedWorkoutItem]
    @State private var navigateToActiveWorkout = false

    init(templateName: String, selectedExercises: [WorkoutExerciseTemplate]) {
        _workoutName = State(initialValue: templateName)
        _items = State(initialValue: selectedExercises.map {
            PlannedWorkoutItem(
                exercise: $0.exercise,
                sets: $0.defaultSets,
                reps: $0.defaultReps,
                weight: $0.defaultWeight
            )
        })
    }

    var body: some View {
        List {
            Section("Тренировка") {
                TextField("Название тренировки", text: $workoutName)
            }

            Section("Выбранные упражнения") {
                ForEach($items) { $item in
                    PlannedWorkoutItemRow(item: $item)
                }
            }

            Section {
                Button {
                    startWorkout()
                } label: {
                    Text("Начать тренировку")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .disabled(items.isEmpty || workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Сборка тренировки")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToActiveWorkout) {
            ActiveWorkoutView()
        }
    }

    private func startWorkout() {
        let draft = CustomWorkoutDraft(
            id: UUID(),
            name: workoutName,
            createdAt: Date(),
            exercises: items.map { item in
                CustomWorkoutExercise(
                    id: item.id,
                    exercise: item.exercise,
                    sets: (1...item.sets).map { setNumber in
                        CustomWorkoutSet(
                            setNumber: setNumber,
                            targetReps: item.reps,
                            targetWeight: item.weight
                        )
                    }
                )
            }
        )
        draftStore.save(draft)
        navigateToActiveWorkout = true
    }
}

struct PlannedWorkoutItemRow: View {
    @Binding var item: PlannedWorkoutItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.exercise.name)
                .font(.headline)

            Stepper("Подходы: \(item.sets)", value: $item.sets, in: 1...12)
            Stepper("Повторения: \(item.reps)", value: $item.reps, in: 1...30)
            Stepper("Вес: \(item.weight, specifier: "%.1f") кг", value: $item.weight, in: 0...400, step: 2.5)
        }
        .padding(.vertical, 4)
    }
}

struct PlannedWorkoutItem: Identifiable, Hashable {
    let id: UUID
    let exercise: Exercise
    var sets: Int
    var reps: Int
    var weight: Double

    init(id: UUID = UUID(), exercise: Exercise, sets: Int, reps: Int, weight: Double) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        self.weight = weight
    }
}

struct WorkoutProgramTemplate: Identifiable, Hashable {
    let id: UUID
    let name: String
    let summary: String
    let exercises: [WorkoutExerciseTemplate]

    init(id: UUID = UUID(), name: String, summary: String, exercises: [WorkoutExerciseTemplate]) {
        self.id = id
        self.name = name
        self.summary = summary
        self.exercises = exercises
    }

    static let sampleLibrary: [WorkoutProgramTemplate] = [
        WorkoutProgramTemplate(
            name: "Силовая база",
            summary: "Грудь, спина, ноги",
            exercises: [
                WorkoutExerciseTemplate(exercise: Exercise(name: "Присед со штангой", muscleGroup: .legs), defaultSets: 4, defaultReps: 8, defaultWeight: 80),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Жим лежа", muscleGroup: .chest), defaultSets: 4, defaultReps: 8, defaultWeight: 60),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Тяга в наклоне", muscleGroup: .back), defaultSets: 4, defaultReps: 10, defaultWeight: 50),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Планка", muscleGroup: .core), defaultSets: 3, defaultReps: 1, defaultWeight: 0)
            ]
        ),
        WorkoutProgramTemplate(
            name: "Верх тела",
            summary: "Плечи, спина, руки",
            exercises: [
                WorkoutExerciseTemplate(exercise: Exercise(name: "Жим гантелей сидя", muscleGroup: .shoulders), defaultSets: 4, defaultReps: 10, defaultWeight: 20),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Подтягивания", muscleGroup: .back), defaultSets: 4, defaultReps: 8, defaultWeight: 0),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Подъем на бицепс", muscleGroup: .arms), defaultSets: 3, defaultReps: 12, defaultWeight: 12.5),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Французский жим", muscleGroup: .arms), defaultSets: 3, defaultReps: 12, defaultWeight: 20)
            ]
        ),
        WorkoutProgramTemplate(
            name: "Функциональная",
            summary: "Все тело и кардио",
            exercises: [
                WorkoutExerciseTemplate(exercise: Exercise(name: "Бёрпи", muscleGroup: .fullBody), defaultSets: 4, defaultReps: 12, defaultWeight: 0),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Выпады", muscleGroup: .legs), defaultSets: 3, defaultReps: 12, defaultWeight: 20),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Тяга резинки", muscleGroup: .back), defaultSets: 3, defaultReps: 15, defaultWeight: 0),
                WorkoutExerciseTemplate(exercise: Exercise(name: "Скручивания", muscleGroup: .core), defaultSets: 3, defaultReps: 20, defaultWeight: 0)
            ]
        )
    ]
}

struct WorkoutExerciseTemplate: Identifiable, Hashable {
    let id: UUID
    let exercise: Exercise
    let defaultSets: Int
    let defaultReps: Int
    let defaultWeight: Double

    init(id: UUID = UUID(), exercise: Exercise, defaultSets: Int, defaultReps: Int, defaultWeight: Double) {
        self.id = id
        self.exercise = exercise
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultWeight = defaultWeight
    }
}

#if DEBUG
struct NewWorkoutProgramLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewWorkoutProgramLibraryView()
        }
    }
}
#endif
