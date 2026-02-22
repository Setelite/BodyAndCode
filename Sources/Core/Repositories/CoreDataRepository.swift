//
//  CoreDataRepository.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

//
//  CoreDataRepository.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

//
//  CoreDataRepository.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

internal import CoreData
import Foundation

struct RepositoryCoach: Identifiable, Codable {
    let id: UUID
    let name: String
    let specialization: String
    let experience: String
    let rating: Double
    let reviewCount: Int
    let description: String
    let imageName: String?
    let reviews: [CoachReview]?
    let isFavorite: Bool
}

struct RepositoryWorkout: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: String
    let duration: Int
    let calories: Int
    let date: Date
    let isCompleted: Bool
    let notes: String
    let coachId: UUID?
}

struct RepositoryNutrition: Identifiable, Codable {
    let id: UUID
    let mealType: String
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let date: Date
    let notes: String
}

struct RepositoryUserProgress: Identifiable, Codable {
    let id: UUID
    let date: Date
    let weight: Double?
    let bodyFat: Double?
    let muscleMass: Double?
    let caloriesBurned: Int
    let workoutMinutes: Int
}

struct CoachReview: Identifiable, Codable {
    let id: UUID
    let rating: Double
    let comment: String
    let author: String
    let date: Date
}

protocol CoreDataRepositoryProtocol {
    func saveCoach(_ coach: Coach) async throws
    func fetchCoaches() async throws -> [Coach]
    func fetchFavoriteCoaches() async throws -> [Coach]
    func toggleFavorite(coachId: UUID) async throws -> Bool
    func deleteCoach(_ coachId: UUID) async throws
    func saveWorkout(_ workout: Workout) async throws
    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout]
    func fetchTodayWorkouts() async throws -> [Workout]
    func deleteWorkout(_ workoutId: UUID) async throws
    func saveNutrition(_ nutrition: Nutrition) async throws
    func fetchNutrition(for date: Date) async throws -> [Nutrition]
    func deleteNutrition(_ nutritionId: UUID) async throws
    func saveUserProgress(_ progress: UserProgress) async throws
    func fetchUserProgress(from startDate: Date, to endDate: Date) async throws -> [UserProgress]
    func clearAllData() async throws
    func getDatabaseSize() -> String
}

final class CoreDataRepository: CoreDataRepositoryProtocol {
    
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }
    
    private func perform<T>(_ context: NSManagedObjectContext, _ block: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do { continuation.resume(returning: try block()) }
                catch { continuation.resume(throwing: error) }
            }
        }
    }
    
    func saveCoach(_ coach: Coach) async throws {
        let context = persistence.newBackgroundContext()
        try await perform(context) {
            let request: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", coach.id as CVarArg)
            let entity = try context.fetch(request).first ?? CoachEntity(context: context)
            entity.id = coach.id
            entity.name = coach.name
            entity.specialization = coach.specialization
            entity.experience = coach.experience
            entity.rating = coach.rating
            entity.reviewCount = Int32(coach.reviewCount)
            entity.descriptionText = coach.description
            entity.imageName = coach.imageName
            entity.isFavorite = coach.isFavorite
            entity.lastUpdated = Date()
            try context.save()
        }
    }
    
    func fetchCoaches() async throws -> [Coach] {
        try await perform(persistence.viewContext) { [self] in
            let request: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            return try persistence.viewContext.fetch(request).map { $0.toDomainModel() }
        }
    }
    
    func fetchFavoriteCoaches() async throws -> [Coach] {
        try await perform(persistence.viewContext) { [self] in
            let request: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isFavorite == true")
            return try persistence.viewContext.fetch(request).map { $0.toDomainModel() }
        }
    }
    
    func toggleFavorite(coachId: UUID) async throws -> Bool {
        let context = persistence.newBackgroundContext()
        return try await perform(context) {
            let request: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", coachId as CVarArg)
            guard let entity = try context.fetch(request).first else { throw CoreDataError.entityNotFound }
            entity.isFavorite.toggle()
            try context.save()
            return entity.isFavorite
        }
    }
    
    func deleteCoach(_ coachId: UUID) async throws {
        let context = persistence.newBackgroundContext()
        try await perform(context) {
            let request: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", coachId as CVarArg)
            guard let entity = try context.fetch(request).first else { throw CoreDataError.entityNotFound }
            context.delete(entity)
            try context.save()
        }
    }
    
    func saveWorkout(_ workout: Workout) async throws {
        let context = persistence.newBackgroundContext()
        try await perform(context) {
            let entity = WorkoutEntity(context: context)
            entity.id = workout.id
            entity.name = workout.name
            entity.type = workout.type
            entity.duration = Int32(workout.duration)
            entity.calories = Int32(workout.calories)
            entity.date = workout.date
            entity.isCompleted = workout.isCompleted
            entity.notes = workout.notes
            entity.coachId = workout.coachId
            try context.save()
        }
    }
    
    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] {
        try await perform(persistence.viewContext) { [self] in
            let request: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
            return try persistence.viewContext.fetch(request).map { $0.toDomainModel() }
        }
    }
    
    func fetchTodayWorkouts() async throws -> [Workout] {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return try await fetchWorkouts(from: start, to: end)
    }
    
    func deleteWorkout(_ workoutId: UUID) async throws {
        let context = persistence.newBackgroundContext()
        try await perform(context) {
            let request: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
            guard let entity = try context.fetch(request).first else { throw CoreDataError.entityNotFound }
            context.delete(entity)
            try context.save()
        }
    }
    
    func saveNutrition(_ nutrition: Nutrition) async throws {
        let context = persistence.newBackgroundContext()
        try await perform(context) {
            let entity = NutritionEntity(context: context)
            entity.id = nutrition.id
            entity.mealType = nutrition.mealType
            entity.name = nutrition.name
            entity.calories = Int32(nutrition.calories)
            entity.protein = nutrition.protein
            entity.carbs = nutrition.carbs
            entity.fat = nutrition.fat
            entity.date = nutrition.date
            entity.notes = nutrition.notes
            try context.save()
        }
    }
    
    func fetchNutrition(for date: Date) async throws -> [Nutrition] {
        try await perform(persistence.viewContext) { [self] in
            let start = Calendar.current.startOfDay(for: date)
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            let request: NSFetchRequest<NutritionEntity> = NutritionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as CVarArg, end as CVarArg)
            return try persistence.viewContext.fetch(request).map { $0.toDomainModel() }
        }
    }
    
    func deleteNutrition(_ nutritionId: UUID) async throws {
        let context = persistence.newBackgroundContext()
        try await perform(context) {
            let request: NSFetchRequest<NutritionEntity> = NutritionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", nutritionId as CVarArg)
            guard let entity = try context.fetch(request).first else { throw CoreDataError.entityNotFound }
            context.delete(entity)
            try context.save()
        }
    }
    
    func saveUserProgress(_ progress: UserProgress) async throws {
        let context = persistence.newBackgroundContext()
        try await perform(context) {
            let entity = UserProgressEntity(context: context)
            entity.id = progress.id
            entity.date = progress.date
            entity.weight = progress.weight
            entity.bodyFat = progress.bodyFat
            entity.muscleMass = progress.muscleMass
            entity.caloriesBurned = Int32(progress.caloriesBurned)
            entity.workoutMinutes = Int32(progress.workoutMinutes)
            try context.save()
        }
    }
    
    func fetchUserProgress(from startDate: Date, to endDate: Date) async throws -> [UserProgress] {
        try await perform(persistence.viewContext) { [self] in
            let request: NSFetchRequest<UserProgressEntity> = UserProgressEntity.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
            return try persistence.viewContext.fetch(request).map { $0.toDomainModel() }
        }
    }
    
    func clearAllData() async throws {
        let context = persistence.newBackgroundContext()
        try await perform(context) {
            let entityNames = ["CoachEntity", "WorkoutEntity", "NutritionEntity", "UserProgressEntity"]
            
            for entityName in entityNames {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try context.execute(deleteRequest)
            }
            
            try context.save()
        }
    }
    
    func getDatabaseSize() -> String {
        guard let storeURL = persistence.container.persistentStoreCoordinator.persistentStores.first?.url else {
            return "0 MB"
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: storeURL.path)
            if let size = attributes[.size] as? Int64 {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useMB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: size)
            }
        } catch {
            print("Failed to get database size: \(error)")
        }
        
        return "Unknown"
    }
}

enum CoreDataError: Error {
    case entityNotFound
}

extension CoachEntity {
    func toDomainModel() -> Coach {
        Coach(
            id: id ?? UUID(),
            name: name ?? "",
            specialization: specialization ?? "",
            experience: experience ?? "",
            rating: rating,
            reviewCount: Int(reviewCount),
            description: descriptionText ?? "",
            imageName: imageName ?? "",
            reviews: nil,
            isFavorite: isFavorite,
            certifications: [],
            achievements: [],
            availableSlots: [],
            prices: [:]
        )
    }
}

extension WorkoutEntity {
    func toDomainModel() -> Workout {
        Workout(
            id: id ?? UUID(),
            name: name ?? "",
            type: type ?? "",
            duration: Int(duration),
            calories: Int(calories),
            date: date ?? Date(),
            isCompleted: isCompleted,
            notes: notes ?? "",
            coachId: coachId
        )
    }
}

extension NutritionEntity {
    func toDomainModel() -> Nutrition {
        Nutrition(
            id: id ?? UUID(),
            mealType: mealType ?? "",
            name: name ?? "",
            calories: Int(calories),
            protein: protein,
            carbs: carbs,
            fat: fat,
            date: date ?? Date(),
            notes: notes ?? ""
        )
    }
}

extension UserProgressEntity {
    func toDomainModel() -> UserProgress {
        UserProgress(
            id: id ?? UUID(),
            date: date ?? Date(),
            weight: weight > 0 ? weight : Double.nan,
            bodyFat: bodyFat > 0 ? bodyFat : Double.nan,
            muscleMass: muscleMass > 0 ? muscleMass : Double.nan,
            caloriesBurned: Int(caloriesBurned),
            workoutMinutes: Int(workoutMinutes)
        )
    }
}
