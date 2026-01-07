//
//  CoreDataRepository.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

internal import CoreData
import Foundation

// MARK: - Domain Models (Удалите эти структуры если они уже есть в другом файле)

// Если у вас уже есть эти структуры в другом файле, удалите эти определения
// и добавьте импорт нужного файла

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
    let notes: String?
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
    let notes: String?
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

// MARK: - Protocol

protocol CoreDataRepositoryProtocol {
    // Coach
    func saveCoach(_ coach: Coach) async throws
    func fetchCoaches() async throws -> [Coach]
    func fetchFavoriteCoaches() async throws -> [Coach]
    func toggleFavorite(coachId: UUID) async throws -> Bool
    func deleteCoach(_ coachId: UUID) async throws
    
    // Workout
    func saveWorkout(_ workout: Workout) async throws
    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout]
    func fetchTodayWorkouts() async throws -> [Workout]
    func deleteWorkout(_ workoutId: UUID) async throws
    
    // Nutrition
    func saveNutrition(_ nutrition: Nutrition) async throws
    func fetchNutrition(for date: Date) async throws -> [Nutrition]
    func deleteNutrition(_ nutritionId: UUID) async throws
    
    // User Progress
    func saveUserProgress(_ progress: UserProgress) async throws
    func fetchUserProgress(from startDate: Date, to endDate: Date) async throws -> [UserProgress]
    
    // Общие
    func clearAllData() async throws
    func getDatabaseSize() -> String
}

class CoreDataRepository: CoreDataRepositoryProtocol {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }
    
    // MARK: - Helper Methods for Async Context
    
    private func performOnContext<T>(_ context: NSManagedObjectContext, _ block: @escaping () throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let result = try block()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Coach Operations
    
    func saveCoach(_ coach: Coach) async throws {
        let context = persistence.newBackgroundContext()
        
        try await performOnContext(context) {
            // Проверяем существует ли уже тренер
            let fetchRequest: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", coach.id as CVarArg)
            
            let existingCoaches = try context.fetch(fetchRequest)
            let coachEntity: CoachEntity
            
            if let existing = existingCoaches.first {
                coachEntity = existing
            } else {
                coachEntity = CoachEntity(context: context)
                coachEntity.id = coach.id
            }
            
            // Обновляем данные
            coachEntity.name = coach.name
            coachEntity.specialization = coach.specialization
            coachEntity.experience = coach.experience
            coachEntity.rating = coach.rating
            coachEntity.reviewCount = Int32(coach.reviewCount)
            coachEntity.descriptionText = coach.description
            coachEntity.imageName = coach.imageName
            coachEntity.lastUpdated = Date()
            
            try context.save()
        }
    }
    
    func fetchCoaches() async throws -> [Coach] {
        let context = persistence.viewContext
        
        return try await performOnContext(context) {
            let fetchRequest: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toDomainModel() }
        }
    }
    
    func fetchFavoriteCoaches() async throws -> [Coach] {
        let context = persistence.viewContext
        
        return try await performOnContext(context) {
            let fetchRequest: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isFavorite == true")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toDomainModel() }
        }
    }
    
    func toggleFavorite(coachId: UUID) async throws -> Bool {
        let context = persistence.newBackgroundContext()
        
        return try await performOnContext(context) {
            let fetchRequest: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", coachId as CVarArg)
            
            guard let coachEntity = try context.fetch(fetchRequest).first else {
                throw CoreDataError.entityNotFound
            }
            
            coachEntity.isFavorite.toggle()
            coachEntity.lastUpdated = Date()
            
            try context.save()
            return coachEntity.isFavorite
        }
    }
    
    func deleteCoach(_ coachId: UUID) async throws {
        let context = persistence.newBackgroundContext()
        
        try await performOnContext(context) {
            let fetchRequest: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", coachId as CVarArg)
            
            guard let coachEntity = try context.fetch(fetchRequest).first else {
                throw CoreDataError.entityNotFound
            }
            
            context.delete(coachEntity)
            try context.save()
        }
    }
    
    // MARK: - Workout Operations
    
    func saveWorkout(_ workout: Workout) async throws {
        let context = persistence.newBackgroundContext()
        
        try await performOnContext(context) {
            let workoutEntity = WorkoutEntity(context: context)
            workoutEntity.id = workout.id
            workoutEntity.name = workout.name
            workoutEntity.type = workout.type
            workoutEntity.duration = Int32(workout.duration)
            workoutEntity.calories = Int32(workout.calories)
            workoutEntity.date = workout.date
            workoutEntity.isCompleted = workout.isCompleted
            workoutEntity.notes = workout.notes
            workoutEntity.coachId = workout.coachId
            
            try context.save()
        }
    }
    
    func fetchWorkouts(from startDate: Date, to endDate: Date) async throws -> [Workout] {
        let context = persistence.viewContext
        
        return try await performOnContext(context) {
            let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toDomainModel() }
        }
    }
    
    func fetchTodayWorkouts() async throws -> [Workout] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return try await fetchWorkouts(from: startOfDay, to: endOfDay)
    }
    
    func deleteWorkout(_ workoutId: UUID) async throws {
        let context = persistence.newBackgroundContext()
        
        try await performOnContext(context) {
            let fetchRequest: NSFetchRequest<WorkoutEntity> = WorkoutEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", workoutId as CVarArg)
            
            guard let workoutEntity = try context.fetch(fetchRequest).first else {
                throw CoreDataError.entityNotFound
            }
            
            context.delete(workoutEntity)
            try context.save()
        }
    }
    
    // MARK: - Nutrition Operations
    
    func saveNutrition(_ nutrition: Nutrition) async throws {
        let context = persistence.newBackgroundContext()
        
        try await performOnContext(context) {
            let nutritionEntity = NutritionEntity(context: context)
            nutritionEntity.id = nutrition.id
            nutritionEntity.mealType = nutrition.mealType
            nutritionEntity.name = nutrition.name
            nutritionEntity.calories = Int32(nutrition.calories)
            nutritionEntity.protein = nutrition.protein
            nutritionEntity.carbs = nutrition.carbs
            nutritionEntity.fat = nutrition.fat
            nutritionEntity.date = nutrition.date
            nutritionEntity.notes = nutrition.notes
            
            try context.save()
        }
    }
    
    func fetchNutrition(for date: Date) async throws -> [Nutrition] {
        let context = persistence.viewContext
        
        return try await performOnContext(context) {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let fetchRequest: NSFetchRequest<NutritionEntity> = NutritionEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as CVarArg, endOfDay as CVarArg)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "mealType", ascending: true),
                NSSortDescriptor(key: "date", ascending: true)
            ]
            
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toDomainModel() }
        }
    }
    
    func deleteNutrition(_ nutritionId: UUID) async throws {
        let context = persistence.newBackgroundContext()
        
        try await performOnContext(context) {
            let fetchRequest: NSFetchRequest<NutritionEntity> = NutritionEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", nutritionId as CVarArg)
            
            guard let nutritionEntity = try context.fetch(fetchRequest).first else {
                throw CoreDataError.entityNotFound
            }
            
            context.delete(nutritionEntity)
            try context.save()
        }
    }
    
    // MARK: - User Progress Operations
    
    func saveUserProgress(_ progress: UserProgress) async throws {
        let context = persistence.newBackgroundContext()
        
        try await performOnContext(context) {
            let progressEntity = UserProgressEntity(context: context)
            progressEntity.id = progress.id
            progressEntity.date = progress.date
            progressEntity.weight = progress.weight
            progressEntity.bodyFat = progress.bodyFat
            progressEntity.muscleMass = progress.muscleMass
            progressEntity.caloriesBurned = Int32(progress.caloriesBurned)
            progressEntity.workoutMinutes = Int32(progress.workoutMinutes)
            
            try context.save()
        }
    }
    
    func fetchUserProgress(from startDate: Date, to endDate: Date) async throws -> [UserProgress] {
        let context = persistence.viewContext
        
        return try await performOnContext(context) {
            let fetchRequest: NSFetchRequest<UserProgressEntity> = UserProgressEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as CVarArg, endDate as CVarArg)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toDomainModel() }
        }
    }
    
    // MARK: - Общие операции
    
    func clearAllData() async throws {
        let context = persistence.newBackgroundContext()
        
        try await performOnContext(context) {
            let entities = [
                "CoachEntity",
                "WorkoutEntity",
                "NutritionEntity",
                "UserProgressEntity"
            ]
            
            for entityName in entities {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                try context.execute(deleteRequest)
            }
            
            try context.save()
        }
    }
    
    func getDatabaseSize() -> String {
        guard let storeURL = persistence.container.persistentStoreCoordinator.persistentStores.first?.url else {
            return "Неизвестно"
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: storeURL.path)
            if let size = attributes[.size] as? NSNumber {
                let byteCountFormatter = ByteCountFormatter()
                byteCountFormatter.countStyle = .file
                return byteCountFormatter.string(fromByteCount: size.int64Value)
            }
        } catch {
            print("❌ Ошибка получения размера БД: \(error)")
        }
        
        return "Неизвестно"
    }
}

// MARK: - Ошибки Core Data

enum CoreDataError: Error, LocalizedError {
    case entityNotFound
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .entityNotFound:
            return "Запись не найдена"
        case .saveFailed(let error):
            return "Ошибка сохранения: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Ошибка загрузки: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Ошибка удаления: \(error.localizedDescription)"
        }
    }
}

// MARK: - Расширения для Entity → Domain Model

extension CoachEntity {
    func toDomainModel() -> Coach {
        return Coach(
            id: id ?? UUID(),
            name: name ?? "Неизвестный тренер",
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
    
    static var entityName: String {
        return "CoachEntity"
    }
}

extension WorkoutEntity {
    func toDomainModel() -> Workout {
        return Workout(
            id: id ?? UUID(),
            name: name ?? "Без названия",
            type: type ?? "Другое",
            duration: Int(duration),
            calories: Int(calories),
            date: date ?? Date(),
            isCompleted: isCompleted,
            notes: notes!,
            coachId: coachId
        )
    }
    
    static var entityName: String {
        return "WorkoutEntity"
    }
}

extension NutritionEntity {
    func toDomainModel() -> Nutrition {
        return Nutrition(
            id: id ?? UUID(),
            mealType: mealType ?? "snack",
            name: name ?? "Прием пищи",
            calories: Int(calories),
            protein: protein,
            carbs: carbs,
            fat: fat,
            date: date ?? Date(),
            notes: notes!
        )
    }
    
    static var entityName: String {
        return "NutritionEntity"
    }
}

extension UserProgressEntity {
    func toDomainModel() -> UserProgress {
        return UserProgress(
            id: id ?? UUID(),
            date: date ?? Date(),
            weight: weight > 0 ? weight : Double.nan,
            bodyFat: bodyFat > 0 ? bodyFat : Double.nan,
            muscleMass: muscleMass > 0 ? muscleMass : Double.nan,
            caloriesBurned: Int(caloriesBurned),
            workoutMinutes: Int(workoutMinutes)
        )
    }
    
    static var entityName: String {
        return "UserProgressEntity"
    }
}
