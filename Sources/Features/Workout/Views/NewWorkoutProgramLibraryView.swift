//
//  NewWorkoutProgramLibraryView.swift
//  Body&Code
//
//  Created by Codex on 2/22/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct NewWorkoutProgramLibraryView: View {
    private enum UploadedSortOption: String, CaseIterable, Identifiable {
        case newest = "Сначала новые"
        case oldest = "Сначала старые"
        case name = "По названию"

        var id: String { rawValue }
    }

    private let draftStore = CustomWorkoutDraftStore()
    @State private var templates = WorkoutProgramTemplate.sampleLibrary
    @State private var catalog: [ExerciseCatalogItem] = ExerciseCatalogLibrary.defaultExercises
    @State private var uploadedWorkouts: [UploadedWorkout] = []
    @State private var uploadedSearchText = ""
    @State private var uploadedSortOption: UploadedSortOption = .newest
    @State private var isImportingFile = false
    @State private var importedWorkoutName = "Импортированная тренировка"
    @State private var importedItems: [PlannedWorkoutItem] = []
    @State private var navigateToImportedWorkout = false
    @State private var importErrorMessage: String?

    private var displayedUploadedWorkouts: [UploadedWorkout] {
        let query = uploadedSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered: [UploadedWorkout]
        if query.isEmpty {
            filtered = uploadedWorkouts
        } else {
            filtered = uploadedWorkouts.filter {
                $0.name.lowercased().contains(query) || $0.sourceFileName.lowercased().contains(query)
            }
        }

        switch uploadedSortOption {
        case .newest:
            return filtered.sorted { $0.importedAt > $1.importedAt }
        case .oldest:
            return filtered.sorted { $0.importedAt < $1.importedAt }
        case .name:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }

    var body: some View {
        List {
            Section("Конструктор") {
                NavigationLink(destination: CustomWorkoutBuilderView(catalog: catalog)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Собрать тренировку с нуля")
                            .font(.headline)
                        Text("Выберите упражнения по группам мышц")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Button {
                    isImportingFile = true
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Импорт из заметок/текста")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Загрузите .txt и соберите тренировку автоматически")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }

            Section("Загруженные тренировки") {
                if uploadedWorkouts.isEmpty {
                    Text("Здесь появятся тренировки, импортированные из файлов в «Загрузках».")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    TextField("Поиск по загруженным тренировкам", text: $uploadedSearchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    Picker("Сортировка", selection: $uploadedSortOption) {
                        ForEach(UploadedSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)

                    ForEach(displayedUploadedWorkouts) { workout in
                        NavigationLink(destination: WorkoutAssemblyView(workoutName: workout.name, items: workout.asPlannedItems)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(workout.name)
                                    .font(.headline)
                                Text(workout.sourceFileName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(workout.items.count) упражнений")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                removeUploadedWorkout(workout.id)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }

                            Button {
                                duplicateUploadedWorkout(workout)
                            } label: {
                                Label("Дублировать", systemImage: "plus.square.on.square")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }

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
        .fileImporter(
            isPresented: $isImportingFile,
            allowedContentTypes: [.plainText, .text],
            allowsMultipleSelection: false,
            onCompletion: handleFileImport
        )
        .navigationDestination(isPresented: $navigateToImportedWorkout) {
            WorkoutAssemblyView(workoutName: importedWorkoutName, items: importedItems)
        }
        .alert(
            "Ошибка импорта",
            isPresented: Binding(
                get: { importErrorMessage != nil },
                set: { newValue in
                    if !newValue {
                        importErrorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importErrorMessage ?? "")
        }
        .task {
            uploadedWorkouts = draftStore.loadImportedWorkouts()
            let remote = await ExerciseCatalogService().loadMergedCatalog()
            if !remote.isEmpty {
                catalog = remote
                templates = WorkoutProgramTemplate.sampleLibrary(using: remote)
            }
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            importErrorMessage = "Не удалось открыть файл: \(error.localizedDescription)"
        case .success(let urls):
            guard let url = urls.first else {
                importErrorMessage = "Файл не выбран."
                return
            }

            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let data = try Data(contentsOf: url)
                let text = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
                let parsed = WorkoutNotesImporter.makeItems(from: text, catalog: catalog)
                guard !parsed.isEmpty else {
                    importErrorMessage = "Не удалось распознать упражнения. Используйте формат: 'Жим лежа 4x8 60 кг' или по одному упражнению в строке."
                    return
                }
                importedItems = parsed
                importedWorkoutName = url.deletingPathExtension().lastPathComponent
                let imported = draftStore.saveImportedWorkout(
                    name: importedWorkoutName,
                    sourceFileName: url.lastPathComponent,
                    items: parsed.map {
                        UploadedWorkoutItem(
                            id: $0.id,
                            exercise: $0.exercise,
                            sets: $0.sets,
                            reps: $0.reps,
                            weight: $0.weight
                        )
                    }
                )
                uploadedWorkouts = draftStore.loadImportedWorkouts()
                if imported.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    importErrorMessage = "Файл импортирован, но имя тренировки пустое. Переименуйте файл и импортируйте заново."
                }
                navigateToImportedWorkout = true
            } catch {
                importErrorMessage = "Ошибка чтения файла: \(error.localizedDescription)"
            }
        }
    }

    private func removeUploadedWorkout(_ id: UUID) {
        draftStore.removeImportedWorkout(id: id)
        uploadedWorkouts = draftStore.loadImportedWorkouts()
    }

    private func duplicateUploadedWorkout(_ workout: UploadedWorkout) {
        _ = draftStore.saveImportedWorkout(
            name: "\(workout.name) (копия)",
            sourceFileName: workout.sourceFileName,
            items: workout.items
        )
        uploadedWorkouts = draftStore.loadImportedWorkouts()
    }
}

struct CustomWorkoutBuilderView: View {
    let catalog: [ExerciseCatalogItem]

    @State private var searchText = ""
    @State private var selectedIDs: Set<UUID> = []

    private var filteredCatalog: [ExerciseCatalogItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return catalog }

        return catalog.filter {
            $0.name.lowercased().contains(query) || $0.aliases.contains(where: { $0.lowercased().contains(query) })
        }
    }

    private var groupedCatalog: [(MuscleGroup, [ExerciseCatalogItem])] {
        MuscleGroup.allCases.compactMap { group in
            let items = filteredCatalog.filter { $0.muscleGroup == group }
            if items.isEmpty {
                return nil
            }
            return (group, items)
        }
    }

    private var selectedTemplates: [WorkoutExerciseTemplate] {
        catalog
            .filter { selectedIDs.contains($0.id) }
            .sorted { $0.name < $1.name }
            .map {
                WorkoutExerciseTemplate(
                    exercise: $0.asExercise,
                    defaultSets: 3,
                    defaultReps: 10,
                    defaultWeight: 0
                )
            }
    }

    var body: some View {
        List {
            Section {
                TextField("Поиск упражнения", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                Text("Выбрано: \(selectedIDs.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(groupedCatalog, id: \.0) { group, items in
                Section(group.localized) {
                    ForEach(items) { item in
                        Button {
                            toggle(item.id)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: item.muscleGroup.icon)
                                    .foregroundColor(.secondary)
                                Text(item.name)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: selectedIDs.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedIDs.contains(item.id) ? .green : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Section {
                NavigationLink(
                    destination: WorkoutAssemblyView(templateName: "Своя тренировка", selectedExercises: selectedTemplates)
                ) {
                    Text("Собрать тренировку")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .disabled(selectedTemplates.isEmpty)
            }
        }
        .navigationTitle("Конструктор")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggle(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
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

    init(workoutName: String, items: [PlannedWorkoutItem]) {
        _workoutName = State(initialValue: workoutName)
        _items = State(initialValue: items)
    }

    var body: some View {
        List {
            Section("Тренировка") {
                TextField("Название тренировки", text: $workoutName)
            }

            Section("Выбранные упражнения") {
                ForEach(Array(items.indices), id: \.self) { index in
                    NavigationLink {
                        ExerciseSetupView(item: $items[index])
                    } label: {
                        PlannedWorkoutItemRow(item: $items[index])
                    }
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
        VStack(alignment: .leading, spacing: 8) {
            Text(item.exercise.name)
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 10) {
                summaryPill(title: "Подходы", value: "\(item.sets)")
                summaryPill(title: "Повторы", value: "\(item.reps)")
                summaryPill(title: "Вес", value: "\(String(format: "%.1f", item.weight)) кг")
            }

            Text("Открыть настройки упражнения")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func summaryPill(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.appCardSurface)
        )
    }
}

struct ExerciseSetupView: View {
    @Binding var item: PlannedWorkoutItem

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                exerciseHeader

                MetricAdjusterCard(
                    title: "Подходы",
                    valueText: "\(item.sets)",
                    decrementTitle: "−1",
                    incrementTitle: "+1",
                    decrementAction: { item.sets = max(1, item.sets - 1) },
                    incrementAction: { item.sets = min(20, item.sets + 1) }
                )

                MetricAdjusterCard(
                    title: "Повторения",
                    valueText: "\(item.reps)",
                    decrementTitle: "−1",
                    incrementTitle: "+1",
                    decrementAction: { item.reps = max(1, item.reps - 1) },
                    incrementAction: { item.reps = min(50, item.reps + 1) }
                )

                MetricAdjusterCard(
                    title: "Вес",
                    valueText: "\(String(format: "%.1f", item.weight)) кг",
                    decrementTitle: "−2.5",
                    incrementTitle: "+2.5",
                    decrementAction: { item.weight = max(0, item.weight - 2.5) },
                    incrementAction: { item.weight = min(500, item.weight + 2.5) }
                )
            }
            .padding()
        }
        .background(Color.appSurface.ignoresSafeArea())
        .navigationTitle("Настройки упражнения")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.exercise.name)
                .font(.title3)
                .fontWeight(.semibold)
            Text(item.exercise.muscleGroup.localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appCardSurface)
        )
    }
}

private struct MetricAdjusterCard: View {
    let title: String
    let valueText: String
    let decrementTitle: String
    let incrementTitle: String
    let decrementAction: () -> Void
    let incrementAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)

            Text(valueText)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                largeControlButton(title: decrementTitle, action: decrementAction)
                largeControlButton(title: incrementTitle, action: incrementAction)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.appCardSurface)
        )
    }

    private func largeControlButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.appButtonSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.appButtonBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
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

private extension UploadedWorkout {
    var asPlannedItems: [PlannedWorkoutItem] {
        items.map {
            PlannedWorkoutItem(
                id: $0.id,
                exercise: $0.exercise,
                sets: $0.sets,
                reps: $0.reps,
                weight: $0.weight
            )
        }
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

    static func sampleLibrary(using catalog: [ExerciseCatalogItem] = ExerciseCatalogLibrary.defaultExercises) -> [WorkoutProgramTemplate] {
        func find(_ name: String, fallbackGroup: MuscleGroup, sets: Int, reps: Int, weight: Double) -> WorkoutExerciseTemplate {
            if let item = catalog.first(where: { $0.name == name }) {
                return WorkoutExerciseTemplate(exercise: item.asExercise, defaultSets: sets, defaultReps: reps, defaultWeight: weight)
            }
            return WorkoutExerciseTemplate(exercise: Exercise(name: name, muscleGroup: fallbackGroup), defaultSets: sets, defaultReps: reps, defaultWeight: weight)
        }

        return [
            WorkoutProgramTemplate(
                name: "Силовая база",
                summary: "Грудь, спина, ноги",
                exercises: [
                    find("Присед со штангой", fallbackGroup: .legs, sets: 4, reps: 8, weight: 80),
                    find("Жим лежа", fallbackGroup: .chest, sets: 4, reps: 8, weight: 60),
                    find("Тяга штанги в наклоне", fallbackGroup: .back, sets: 4, reps: 10, weight: 50),
                    find("Планка", fallbackGroup: .core, sets: 3, reps: 1, weight: 0)
                ]
            ),
            WorkoutProgramTemplate(
                name: "Верх тела",
                summary: "Плечи, спина, руки",
                exercises: [
                    find("Жим гантелей сидя", fallbackGroup: .shoulders, sets: 4, reps: 10, weight: 20),
                    find("Подтягивания", fallbackGroup: .back, sets: 4, reps: 8, weight: 0),
                    find("Подъем на бицепс", fallbackGroup: .arms, sets: 3, reps: 12, weight: 12.5),
                    find("Французский жим", fallbackGroup: .arms, sets: 3, reps: 12, weight: 20)
                ]
            ),
            WorkoutProgramTemplate(
                name: "Функциональная",
                summary: "Все тело и кардио",
                exercises: [
                    find("Берпи", fallbackGroup: .fullBody, sets: 4, reps: 12, weight: 0),
                    find("Выпады", fallbackGroup: .legs, sets: 3, reps: 12, weight: 20),
                    find("Тяга горизонтального блока", fallbackGroup: .back, sets: 3, reps: 15, weight: 0),
                    find("Скручивания", fallbackGroup: .core, sets: 3, reps: 20, weight: 0)
                ]
            )
        ]
    }

    static let sampleLibrary: [WorkoutProgramTemplate] = sampleLibrary(using: ExerciseCatalogLibrary.defaultExercises)
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

struct ExerciseCatalogItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let muscleGroup: MuscleGroup
    let aliases: [String]

    var asExercise: Exercise {
        Exercise(id: id, name: name, muscleGroup: muscleGroup)
    }

    init(id: UUID = UUID(), name: String, muscleGroup: MuscleGroup, aliases: [String] = []) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.aliases = aliases
    }
}

enum ExerciseCatalogLibrary {
    static let defaultExercises: [ExerciseCatalogItem] = [
        ExerciseCatalogItem(name: "Жим лежа", muscleGroup: .chest, aliases: ["bench press"]),
        ExerciseCatalogItem(name: "Жим гантелей на наклонной", muscleGroup: .chest, aliases: ["incline dumbbell press"]),
        ExerciseCatalogItem(name: "Сведения в кроссовере", muscleGroup: .chest, aliases: ["cable fly"]),
        ExerciseCatalogItem(name: "Отжимания", muscleGroup: .chest, aliases: ["push up", "push-up"]),
        ExerciseCatalogItem(name: "Пуловер", muscleGroup: .chest, aliases: ["pullover"]),

        ExerciseCatalogItem(name: "Подтягивания", muscleGroup: .back, aliases: ["pull up", "pull-up"]),
        ExerciseCatalogItem(name: "Тяга штанги в наклоне", muscleGroup: .back, aliases: ["barbell row"]),
        ExerciseCatalogItem(name: "Тяга гантели к поясу", muscleGroup: .back, aliases: ["dumbbell row"]),
        ExerciseCatalogItem(name: "Тяга горизонтального блока", muscleGroup: .back, aliases: ["seated row"]),
        ExerciseCatalogItem(name: "Тяга верхнего блока", muscleGroup: .back, aliases: ["lat pulldown"]),

        ExerciseCatalogItem(name: "Присед со штангой", muscleGroup: .legs, aliases: ["back squat"]),
        ExerciseCatalogItem(name: "Фронтальные приседания", muscleGroup: .legs, aliases: ["front squat"]),
        ExerciseCatalogItem(name: "Жим ногами", muscleGroup: .legs, aliases: ["leg press"]),
        ExerciseCatalogItem(name: "Румынская тяга", muscleGroup: .legs, aliases: ["romanian deadlift"]),
        ExerciseCatalogItem(name: "Выпады", muscleGroup: .legs, aliases: ["lunges"]),
        ExerciseCatalogItem(name: "Подъемы на носки", muscleGroup: .legs, aliases: ["calf raise"]),

        ExerciseCatalogItem(name: "Жим гантелей сидя", muscleGroup: .shoulders, aliases: ["seated dumbbell press"]),
        ExerciseCatalogItem(name: "Жим штанги стоя", muscleGroup: .shoulders, aliases: ["overhead press"]),
        ExerciseCatalogItem(name: "Подъемы гантелей в стороны", muscleGroup: .shoulders, aliases: ["lateral raise"]),
        ExerciseCatalogItem(name: "Тяга к подбородку", muscleGroup: .shoulders, aliases: ["upright row"]),
        ExerciseCatalogItem(name: "Обратные разведения", muscleGroup: .shoulders, aliases: ["rear delt fly"]),

        ExerciseCatalogItem(name: "Подъем на бицепс", muscleGroup: .arms, aliases: ["biceps curl"]),
        ExerciseCatalogItem(name: "Молотковые сгибания", muscleGroup: .arms, aliases: ["hammer curl"]),
        ExerciseCatalogItem(name: "Французский жим", muscleGroup: .arms, aliases: ["french press", "skull crusher"]),
        ExerciseCatalogItem(name: "Разгибание на блоке", muscleGroup: .arms, aliases: ["triceps pushdown"]),
        ExerciseCatalogItem(name: "Отжимания на брусьях", muscleGroup: .arms, aliases: ["dips"]),

        ExerciseCatalogItem(name: "Планка", muscleGroup: .core, aliases: ["plank"]),
        ExerciseCatalogItem(name: "Скручивания", muscleGroup: .core, aliases: ["crunches"]),
        ExerciseCatalogItem(name: "Подъем ног в висе", muscleGroup: .core, aliases: ["hanging leg raise"]),
        ExerciseCatalogItem(name: "Русский твист", muscleGroup: .core, aliases: ["russian twist"]),
        ExerciseCatalogItem(name: "Боковая планка", muscleGroup: .core, aliases: ["side plank"]),

        ExerciseCatalogItem(name: "Берпи", muscleGroup: .fullBody, aliases: ["burpee"]),
        ExerciseCatalogItem(name: "Трастеры", muscleGroup: .fullBody, aliases: ["thruster"]),
        ExerciseCatalogItem(name: "Скакалка", muscleGroup: .fullBody, aliases: ["jump rope"]),
        ExerciseCatalogItem(name: "Гребля", muscleGroup: .fullBody, aliases: ["rowing"]),
        ExerciseCatalogItem(name: "Спринт", muscleGroup: .fullBody, aliases: ["sprint"])
    ]
}

final class ExerciseCatalogService {
    private struct WgerResponse: Decodable {
        let results: [WgerExercise]
    }

    private struct WgerExercise: Decodable {
        let name: String
        let category: WgerCategory?
    }

    private struct WgerCategory: Decodable {
        let name: String?
    }

    func loadMergedCatalog() async -> [ExerciseCatalogItem] {
        let local = ExerciseCatalogLibrary.defaultExercises
        guard let url = URL(string: "https://wger.de/api/v2/exerciseinfo/?language=2&limit=200") else {
            return local
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return local
            }
            let remote = try JSONDecoder().decode(WgerResponse.self, from: data).results
            let mapped = remote.compactMap(mapRemoteExercise)
            return deduplicated(local + mapped)
        } catch {
            return local
        }
    }

    private func mapRemoteExercise(_ dto: WgerExercise) -> ExerciseCatalogItem? {
        let trimmed = dto.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let categoryText = dto.category?.name ?? ""
        return ExerciseCatalogItem(name: trimmed, muscleGroup: resolveMuscleGroup(name: trimmed, category: categoryText))
    }

    private func resolveMuscleGroup(name: String, category: String) -> MuscleGroup {
        let token = "\(name) \(category)".lowercased()

        if token.contains("груд") || token.contains("chest") || token.contains("bench") || token.contains("fly") {
            return .chest
        }
        if token.contains("спин") || token.contains("back") || token.contains("row") || token.contains("lat") || token.contains("pull") {
            return .back
        }
        if token.contains("ног") || token.contains("leg") || token.contains("squat") || token.contains("lunge") || token.contains("calf") {
            return .legs
        }
        if token.contains("плеч") || token.contains("shoulder") || token.contains("deltoid") || token.contains("overhead") {
            return .shoulders
        }
        if token.contains("рук") || token.contains("arm") || token.contains("biceps") || token.contains("triceps") || token.contains("curl") {
            return .arms
        }
        if token.contains("пресс") || token.contains("core") || token.contains("abs") || token.contains("plank") {
            return .core
        }
        return .fullBody
    }

    private func deduplicated(_ input: [ExerciseCatalogItem]) -> [ExerciseCatalogItem] {
        var seen: Set<String> = []
        var output: [ExerciseCatalogItem] = []

        for item in input {
            let key = normalized(item.name)
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            output.append(item)
        }

        return output.sorted { $0.name < $1.name }
    }

    private func normalized(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: "")
    }
}

enum WorkoutNotesImporter {
    static func makeItems(from text: String, catalog: [ExerciseCatalogItem]) -> [PlannedWorkoutItem] {
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var items: [PlannedWorkoutItem] = []

        for line in lines {
            let parsed = parseLine(line, catalog: catalog)
            items.append(parsed)
        }

        return items
    }

    private static func parseLine(_ line: String, catalog: [ExerciseCatalogItem]) -> PlannedWorkoutItem {
        let name = resolveExerciseName(from: line, catalog: catalog)
        let matched = catalog.first { normalized(line).contains(normalized($0.name)) || $0.aliases.contains(where: { normalized(line).contains(normalized($0)) }) }

        let setsReps = parseSetsReps(line)
        let weight = parseWeight(line)

        let exercise: Exercise
        if let matched {
            exercise = matched.asExercise
        } else {
            exercise = Exercise(name: name, muscleGroup: .fullBody)
        }

        return PlannedWorkoutItem(
            exercise: exercise,
            sets: setsReps.sets,
            reps: setsReps.reps,
            weight: weight
        )
    }

    private static func resolveExerciseName(from line: String, catalog: [ExerciseCatalogItem]) -> String {
        if let matched = catalog.first(where: {
            normalized(line).contains(normalized($0.name)) || $0.aliases.contains(where: { normalized(line).contains(normalized($0)) })
        }) {
            return matched.name
        }

        let parts = line.components(separatedBy: CharacterSet.decimalDigits)
        let maybeName = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let maybeName, !maybeName.isEmpty {
            return maybeName
        }

        return line
    }

    private static func parseSetsReps(_ line: String) -> (sets: Int, reps: Int) {
        let fallback = (sets: 3, reps: 10)
        guard let regex = try? NSRegularExpression(pattern: "(\\d{1,2})\\s*[xх*]\\s*(\\d{1,2})", options: [.caseInsensitive]) else {
            return fallback
        }

        let nsLine = line as NSString
        let range = NSRange(location: 0, length: nsLine.length)
        guard let match = regex.firstMatch(in: line, options: [], range: range), match.numberOfRanges == 3 else {
            return fallback
        }

        let setsString = nsLine.substring(with: match.range(at: 1))
        let repsString = nsLine.substring(with: match.range(at: 2))
        return (sets: Int(setsString) ?? fallback.sets, reps: Int(repsString) ?? fallback.reps)
    }

    private static func parseWeight(_ line: String) -> Double {
        guard let regex = try? NSRegularExpression(pattern: "(\\d+(?:[\\.,]\\d+)?)\\s*(кг|kg)", options: [.caseInsensitive]) else {
            return 0
        }

        let nsLine = line as NSString
        let range = NSRange(location: 0, length: nsLine.length)
        guard let match = regex.firstMatch(in: line, options: [], range: range), match.numberOfRanges >= 2 else {
            return 0
        }

        let raw = nsLine.substring(with: match.range(at: 1)).replacingOccurrences(of: ",", with: ".")
        return Double(raw) ?? 0
    }

    private static func normalized(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: "")
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
