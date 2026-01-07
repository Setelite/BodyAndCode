//
//  OfflineService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

// Sources/Core/Services/Data/OfflineService.swift
import Foundation
import Combine

@MainActor
class OfflineService: ObservableObject {
    @Published var isOfflineMode = false
    @Published var lastSyncDate: Date?
    @Published var syncInProgress = false
    @Published var offlineDataCount: OfflineDataCount = .zero
    
    private let repository: CoreDataRepositoryProtocol
    private let networkMonitor = NetworkMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    struct OfflineDataCount {
        var coaches: Int = 0
        var workouts: Int = 0
        var nutrition: Int = 0
        var progress: Int = 0
        
        static let zero = OfflineDataCount()
        
        var total: Int {
            coaches + workouts + nutrition + progress
        }
    }
    
    init(repository: CoreDataRepositoryProtocol = CoreDataRepository()) {
        self.repository = repository
        setupNetworkMonitoring()
        loadOfflineStatus()
    }
    
    // MARK: - Настройка мониторинга сети
    private func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOfflineMode = !isConnected
                
                if isConnected && self?.lastSyncDate != nil {
                    // Есть соединение и были оффлайн данные - можно синхронизировать
                    Task {
                        await self?.syncIfNeeded()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Загрузка статуса
    private func loadOfflineStatus() {
        Task {
            await updateOfflineDataCount()
            lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
        }
    }
    
    // MARK: - Обновление счетчика данных
    func updateOfflineDataCount() async {
        do {
            let coaches = try await repository.fetchCoaches()
            let todayWorkouts = try await repository.fetchTodayWorkouts()
            let todayNutrition = try await repository.fetchNutrition(for: Date())
            let recentProgress = try await repository.fetchUserProgress(
                from: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                to: Date()
            )
            
            await MainActor.run {
                offlineDataCount = OfflineDataCount(
                    coaches: coaches.count,
                    workouts: todayWorkouts.count,
                    nutrition: todayNutrition.count,
                    progress: recentProgress.count
                )
            }
        } catch {
            print("❌ Ошибка обновления счетчика данных: \(error)")
        }
    }
    
    // MARK: - Синхронизация
    func syncIfNeeded() async {
        guard !syncInProgress else { return }
        
        syncInProgress = true
        
        do {
            // Здесь будет синхронизация с бэкендом
            // Пока просто обновляем дату последней синхронизации
            
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
            
            await updateOfflineDataCount()
            
            print("✅ Синхронизация завершена")
        } catch {
            print("❌ Ошибка синхронизации: \(error)")
        }
        
        syncInProgress = false
    }
    
    // MARK: - Очистка оффлайн данных
    func clearOfflineData() async throws {
        try await repository.clearAllData()
        lastSyncDate = nil
        UserDefaults.standard.removeObject(forKey: "lastSyncDate")
        
        await MainActor.run {
            offlineDataCount = .zero
        }
    }
    
    // MARK: - Получение размера БД
    func getDatabaseSize() -> String {
        return repository.getDatabaseSize()
    }
    
    // MARK: - Сохранение в оффлайн
    func saveCoachOffline(_ coach: Coach) async throws {
        try await repository.saveCoach(coach)
        await updateOfflineDataCount()
    }
    
    func saveWorkoutOffline(_ workout: Workout) async throws {
        try await repository.saveWorkout(workout)
        await updateOfflineDataCount()
    }
    
    func saveNutritionOffline(_ nutrition: Nutrition) async throws {
        try await repository.saveNutrition(nutrition)
        await updateOfflineDataCount()
    }
    
    func saveUserProgressOffline(_ progress: UserProgress) async throws {
        try await repository.saveUserProgress(progress)
        await updateOfflineDataCount()
    }
    
    // MARK: - Загрузка из оффлайн
    func loadCoachesOffline() async throws -> [Coach] {
        return try await repository.fetchCoaches()
    }
    
    func loadFavoriteCoachesOffline() async throws -> [Coach] {
        return try await repository.fetchFavoriteCoaches()
    }
    
    func loadTodayWorkoutsOffline() async throws -> [Workout] {
        return try await repository.fetchTodayWorkouts()
    }
    
    func loadTodayNutritionOffline() async throws -> [Nutrition] {
        return try await repository.fetchNutrition(for: Date())
    }
    
    func loadRecentProgressOffline() async throws -> [UserProgress] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return try await repository.fetchUserProgress(from: weekAgo, to: Date())
    }
    
    // MARK: - Избранное
    func toggleFavoriteOffline(coachId: UUID) async throws -> Bool {
        return try await repository.toggleFavorite(coachId: coachId)
    }
}

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    
    init() {
        // В реальном приложении здесь будет мониторинг сети
        // Для примера всегда true
        self.isConnected = true
    }
}
