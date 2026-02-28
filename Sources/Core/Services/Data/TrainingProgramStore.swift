import Foundation
import Combine

@MainActor
final class TrainingProgramStore: ObservableObject {
    static let shared = TrainingProgramStore()

    @Published private(set) var programs: [TrainingProgram] = []
    @Published private(set) var assignments: [TrainingProgramAssignment] = []

    private let defaults: UserDefaults
    private let programsKey = "training_programs_v1"
    private let assignmentsKey = "training_program_assignments_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func programsForCoach(_ coachId: UUID) -> [TrainingProgram] {
        programs
            .filter { $0.coachId == coachId }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    func activeAssignmentsForClient(_ clientId: UUID) -> [TrainingProgramAssignment] {
        assignments
            .filter { $0.clientId == clientId && $0.isActive }
            .sorted(by: { $0.assignedAt > $1.assignedAt })
    }

    func program(by id: UUID) -> TrainingProgram? {
        programs.first(where: { $0.id == id })
    }

    @discardableResult
    func createProgram(coachId: UUID, title: String, summary: String) -> TrainingProgram {
        let program = TrainingProgram(
            coachId: coachId,
            title: title,
            summary: summary,
            status: .draft,
            version: 1,
            exercises: defaultExercises(for: title)
        )
        programs.insert(program, at: 0)
        persist()
        return program
    }

    func publishProgram(_ programId: UUID) {
        guard let index = programs.firstIndex(where: { $0.id == programId }) else { return }
        programs[index].status = .published
        programs[index].updatedAt = Date()
        persist()
    }

    func updateProgram(
        _ programId: UUID,
        title: String,
        summary: String,
        exercises: [TrainingProgramExercise]
    ) {
        guard let index = programs.firstIndex(where: { $0.id == programId }) else { return }
        programs[index].title = title
        programs[index].summary = summary
        programs[index].exercises = exercises
        programs[index].updatedAt = Date()
        if programs[index].status == .published {
            programs[index].version += 1
        }
        persist()
    }

    func assignProgram(_ programId: UUID, coachId: UUID, to clientIDs: [UUID], note: String?) {
        let existingClientIDs = Set(
            assignments
                .filter { $0.programId == programId && $0.isActive }
                .map(\.clientId)
        )
        let newIDs = clientIDs.filter { !existingClientIDs.contains($0) }

        for clientId in newIDs {
            assignments.insert(
                TrainingProgramAssignment(
                    programId: programId,
                    coachId: coachId,
                    clientId: clientId,
                    note: note
                ),
                at: 0
            )
        }
        persist()
    }

    func deactivateAssignment(_ assignmentId: UUID) {
        guard let index = assignments.firstIndex(where: { $0.id == assignmentId }) else { return }
        assignments[index].isActive = false
        persist()
    }

    func workoutPlan(for assignment: TrainingProgramAssignment) -> WorkoutPlan? {
        guard let program = program(by: assignment.programId) else { return nil }
        return WorkoutPlan(
            id: program.id,
            name: program.title,
            description: program.summary,
            dayOfWeek: DayOfWeek.from(Date()),
            exercises: program.exercises.map(\.exercise),
            assignedTo: [assignment.clientId],
            createdAt: program.createdAt
        )
    }

    private func load() {
        programs = decode([TrainingProgram].self, key: programsKey) ?? []
        assignments = decode([TrainingProgramAssignment].self, key: assignmentsKey) ?? []

        if programs.isEmpty {
            seedDemoData()
        }
    }

    private func persist() {
        encode(programs, key: programsKey)
        encode(assignments, key: assignmentsKey)
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func defaultExercises(for title: String) -> [TrainingProgramExercise] {
        let lowercased = title.lowercased()
        if lowercased.contains("кардио") {
            return [
                TrainingProgramExercise(exercise: Exercise(name: "Бег на дорожке", muscleGroup: .fullBody), sets: 1, reps: 20, restSeconds: 60),
                TrainingProgramExercise(exercise: Exercise(name: "Велотренажер", muscleGroup: .legs), sets: 1, reps: 15, restSeconds: 60),
                TrainingProgramExercise(exercise: Exercise(name: "Берпи", muscleGroup: .fullBody), sets: 4, reps: 12, restSeconds: 90)
            ]
        }

        return [
            TrainingProgramExercise(exercise: Exercise(name: "Присед со штангой", muscleGroup: .legs), sets: 4, reps: 8, targetWeight: 60),
            TrainingProgramExercise(exercise: Exercise(name: "Жим лежа", muscleGroup: .chest), sets: 4, reps: 8, targetWeight: 50),
            TrainingProgramExercise(exercise: Exercise(name: "Тяга штанги в наклоне", muscleGroup: .back), sets: 4, reps: 10, targetWeight: 45)
        ]
    }

    private func seedDemoData() {
        let demoProgram = TrainingProgram(
            coachId: AppUserIDs.coachDemo,
            title: "Базовая силовая программа",
            summary: "3 тренировки в неделю, акцент на базовые упражнения",
            status: .published,
            version: 1,
            exercises: defaultExercises(for: "силовая")
        )
        programs = [demoProgram]
        assignments = [
            TrainingProgramAssignment(
                programId: demoProgram.id,
                coachId: AppUserIDs.coachDemo,
                clientId: AppUserIDs.clientIvan,
                note: "Начни с умеренного веса"
            )
        ]
        persist()
    }
}
