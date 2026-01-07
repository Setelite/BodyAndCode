//
//  CoachService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Core/Services/Data/CoachService.swift
import Foundation

protocol CoachServiceProtocol {
    func fetchCoaches() async throws -> [Coach]
    func fetchCoachDetails(id: UUID) async throws -> Coach
    func bookSession(coachId: UUID, date: Date, type: TrainingType) async throws -> Bool
}

class CoachService: CoachServiceProtocol {
    
    // MARK: - Singleton (опционально)
    static let shared = CoachService()
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchCoaches() async throws -> [Coach] {
        // Имитация задержки сети
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        
        // Возвращаем тестовые данные
        return Coach.mockData
    }
    
    func fetchCoachDetails(id: UUID) async throws -> Coach {
        // Имитация задержки
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 секунды
        
        // Ищем тренера по ID в mock данных
        if let coach = Coach.mockData.first(where: { $0.id == id }) {
            return coach
        } else {
            throw CoachError.coachNotFound
        }
    }
    
    func bookSession(coachId: UUID, date: Date, type: TrainingType) async throws -> Bool {
        // Имитация отправки на сервер
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 секунды
        
        // В реальном приложении здесь был бы API call
        print("✅ Сессия забронирована:")
        print("   Тренер ID: \(coachId)")
        print("   Дата: \(date)")
        print("   Тип: \(type.rawValue)")
        
        return true
    }
}

// MARK: - Ошибки
enum CoachError: Error, LocalizedError {
    case coachNotFound
    case networkError
    case bookingFailed
    
    var errorDescription: String? {
        switch self {
        case .coachNotFound:
            return "Тренер не найден"
        case .networkError:
            return "Ошибка сети"
        case .bookingFailed:
            return "Не удалось забронировать сессию"
        }
    }
}
