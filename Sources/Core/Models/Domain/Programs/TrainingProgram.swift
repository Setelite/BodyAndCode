import Foundation

enum TrainingProgramStatus: String, Codable, CaseIterable {
    case draft
    case published
    case archived

    var localized: String {
        switch self {
        case .draft: return "Черновик"
        case .published: return "Опубликована"
        case .archived: return "Архив"
        }
    }
}

struct TrainingProgramExercise: Identifiable, Codable, Hashable {
    let id: UUID
    let exercise: Exercise
    let sets: Int
    let reps: Int
    let restSeconds: Int
    let targetWeight: Double

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        sets: Int,
        reps: Int,
        restSeconds: Int = 90,
        targetWeight: Double = 0
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.targetWeight = targetWeight
    }
}

struct TrainingProgram: Identifiable, Codable, Hashable {
    let id: UUID
    let coachId: UUID
    var title: String
    var summary: String
    var status: TrainingProgramStatus
    var version: Int
    var exercises: [TrainingProgramExercise]
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        coachId: UUID,
        title: String,
        summary: String,
        status: TrainingProgramStatus = .draft,
        version: Int = 1,
        exercises: [TrainingProgramExercise],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.coachId = coachId
        self.title = title
        self.summary = summary
        self.status = status
        self.version = version
        self.exercises = exercises
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct TrainingProgramAssignment: Identifiable, Codable, Hashable {
    let id: UUID
    let programId: UUID
    let coachId: UUID
    let clientId: UUID
    var note: String?
    let assignedAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        programId: UUID,
        coachId: UUID,
        clientId: UUID,
        note: String? = nil,
        assignedAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.programId = programId
        self.coachId = coachId
        self.clientId = clientId
        self.note = note
        self.assignedAt = assignedAt
        self.isActive = isActive
    }
}

