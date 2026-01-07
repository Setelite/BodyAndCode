//
//  PersistenceController.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

import Foundation
internal import CoreData

final class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "BodyCodeModel")
        
        // Настраиваем автоматическое слияние изменений
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        container.loadPersistentStores { [weak self] description, error in
            if let error = error as NSError? {
                print("❌ Ошибка загрузки Core Data: \(error.localizedDescription)")
                print("Подробности: \(error.userInfo)")
                
                // Пересоздаем store при ошибке
                self?.recreatePersistentStore()
            } else {
                print("✅ Core Data успешно загружен")
                print("📁 Store location: \(description.url?.absoluteString ?? "Неизвестно")")
            }
        }
        
        // Предварительно загружаем тестовые данные для дебага
        #if DEBUG
        preloadSampleDataIfNeeded()
        #endif
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Сохранение контекста
    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            print("✅ Core Data сохранен")
        } catch {
            print("❌ Ошибка сохранения Core Data: \(error.localizedDescription)")
            context.rollback()
        }
    }
    
    // MARK: - Создание фонового контекста
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Пересоздание store при ошибке
    private func recreatePersistentStore() {
        guard let storeURL = container.persistentStoreCoordinator.persistentStores.first?.url else {
            return
        }
        
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType)
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL)
            print("✅ Core Data store пересоздан")
        } catch {
            print("❌ Не удалось пересоздать store: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Очистка всех данных
    func clearAllData() {
        let context = newBackgroundContext()
        
        context.perform {
            do {
                let entityNames = [
                    "CoachEntity",
                    "WorkoutEntity",
                    "NutritionEntity",
                    "UserProgressEntity"
                ]
                
                for entityName in entityNames {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(deleteRequest)
                }
                
                try context.save()
                print("✅ Все данные Core Data удалены")
            } catch {
                print("❌ Ошибка удаления данных: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Предварительная загрузка тестовых данных
    #if DEBUG
    private func preloadSampleDataIfNeeded() {
        let context = container.viewContext
        
        // Проверяем есть ли уже данные тренеров
        let coachRequest: NSFetchRequest<CoachEntity> = CoachEntity.fetchRequest()
        
        do {
            let coachCount = try context.count(for: coachRequest)
            if coachCount == 0 {
                print("📥 Загружаем тестовые данные в Core Data...")
                loadSampleData()
            }
        } catch {
            print("❌ Ошибка проверки данных: \(error)")
        }
    }
    
    private func loadSampleData() {
        let context = container.viewContext
        
        // Создаем простые структуры для тестовых данных
        struct MockCoach {
            let id: UUID
            let name: String
            let specialization: String
            let experience: String
            let rating: Double
            let reviewCount: Int
            let description: String
            let imageName: String?
        }
        
        let coaches = [
            MockCoach(
                id: UUID(),
                name: "Алексей Иванов",
                specialization: "Персональный тренер",
                experience: "5 лет",
                rating: 4.8,
                reviewCount: 42,
                description: "Специалист по силовым тренировкам",
                imageName: nil
            ),
            MockCoach(
                id: UUID(),
                name: "Мария Петрова",
                specialization: "Йога инструктор",
                experience: "3 года",
                rating: 4.9,
                reviewCount: 37,
                description: "Сертифицированный инструктор по йоге",
                imageName: nil
            ),
            MockCoach(
                id: UUID(),
                name: "Дмитрий Сидоров",
                specialization: "Кардио тренер",
                experience: "7 лет",
                rating: 4.7,
                reviewCount: 28,
                description: "Эксперт в кардио тренировках",
                imageName: nil
            )
        ]
        
        // Загружаем тренеров
        for coach in coaches {
            let coachEntity = CoachEntity(context: context)
            coachEntity.id = coach.id
            coachEntity.name = coach.name
            coachEntity.specialization = coach.specialization
            coachEntity.experience = coach.experience
            coachEntity.rating = coach.rating
            coachEntity.reviewCount = Int32(coach.reviewCount)
            coachEntity.descriptionText = coach.description
            coachEntity.imageName = coach.imageName
            coachEntity.lastUpdated = Date()
            coachEntity.isFavorite = false
        }
        
        // Загружаем тренировки
        let workouts = [
            ("Утренняя зарядка", "Кардио", 30, 200),
            ("Силовая тренировка", "Силовая", 60, 450),
            ("Йога", "Растяжка", 45, 150)
        ]
        
        for (index, workout) in workouts.enumerated() {
            let workoutEntity = WorkoutEntity(context: context)
            workoutEntity.id = UUID()
            workoutEntity.name = workout.0
            workoutEntity.type = workout.1
            workoutEntity.duration = Int32(workout.2)
            workoutEntity.calories = Int32(workout.3)
            workoutEntity.date = Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date()
            workoutEntity.isCompleted = true
            workoutEntity.notes = "Отличная тренировка"
            // workoutEntity.coachId = nil // Раскомментируйте если свойство есть
        }
        
        // Загружаем данные питания
        let meals = [
            ("Завтрак", "Омлет с овощами", 320, 25, 10, 20),
            ("Обед", "Куриная грудка с гречкой", 480, 40, 60, 15),
            ("Ужин", "Рыба с салатом", 380, 30, 20, 25)
        ]
        
        for (index, meal) in meals.enumerated() {
            let nutritionEntity = NutritionEntity(context: context)
            nutritionEntity.id = UUID()
            nutritionEntity.mealType = meal.0
            nutritionEntity.name = meal.1
            nutritionEntity.calories = Int32(meal.2)
            nutritionEntity.protein = Double(meal.3)
            nutritionEntity.carbs = Double(meal.4)
            nutritionEntity.fat = Double(meal.5)
            nutritionEntity.date = Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date()
            nutritionEntity.notes = nil
        }
        
        save()
        print("✅ Тестовые данные загружены")
    }
    #endif
}
