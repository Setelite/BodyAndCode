//
//  CoachClientService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/30/25.
//

import Foundation
import Combine

@MainActor
final class CoachClientService: ObservableObject {
    @Published var coaches: [User] = []
    @Published var clients: [User] = []
    @Published var isLoading: Bool = false
    
    // Текущий пользователь (из Auth)
    private var currentUser: User?
    
    init() {
        loadMockData()
    }
    
    // Установка текущего пользователя
    func setCurrentUser(_ user: User) {
        self.currentUser = user
        loadDataForCurrentUser()
    }
    
    // Загрузка данных в зависимости от роли
    private func loadDataForCurrentUser() {
        guard let user = currentUser else { return }
        
        switch user.role {
        case .coach:
            loadClientsForCoach(user.id)
        case .client:
            loadCoachForClient(user.id)
        }
    }
    
    // Загрузка клиентов для тренера
    private func loadClientsForCoach(_ coachId: UUID) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.clients = self.createMockClients()
            self.isLoading = false
        }
    }
    
    // Загрузка тренера для клиента
    private func loadCoachForClient(_ clientId: UUID) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.coaches = self.createMockCoaches()
            self.isLoading = false
        }
    }
    
    // Поиск тренеров
    func searchCoaches(query: String) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            // В реальном приложении здесь будет поиск по API
            self.coaches = self.createMockCoaches().filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.specialization?.localizedCaseInsensitiveContains(query) == true
            }
            self.isLoading = false
        }
    }
    
    // Отправка запроса тренеру
    func sendCoachRequest(clientId: UUID, coachId: UUID, message: String? = nil) {
        print("Запрос отправлен тренеру: \(coachId)")
        print("Сообщение: \(message ?? "Без сообщения")")
        // В реальном приложении здесь будет API вызов
    }
    
    // Принять клиента (для тренера)
    func acceptClient(clientId: UUID, coachId: UUID) {
        print("Клиент \(clientId) принят тренером \(coachId)")
        // В реальном приложении здесь будет обновление в базе
    }
    
    // MARK: - Mock Data
    private func loadMockData() {
        coaches = createMockCoaches()
        clients = createMockClients()
    }
    
    private func createMockCoaches() -> [User] {
        return [
            User(
                name: "Алексей Иванов",
                email: "alexey@fitness.com",
                role: .coach,
                profileImageUrl: nil, specialization: "Силовые тренировки",
                experience: 5
            ),
            User(
                name: "Мария Петрова",
                email: "maria@fitness.com",
                role: .coach,
                profileImageUrl: nil, specialization: "Йога и стретчинг",
                experience: 3
            ),
            User(
                name: "Дмитрий Сидоров",
                email: "dmitry@fitness.com",
                role: .coach,
                profileImageUrl: nil, specialization: "Функциональный тренинг",
                experience: 7
              
            )
        ]
    }
    
    private func createMockClients() -> [User] {
        return [
            User(
                name: "Иван Козлов",
                email: "ivan@client.com",
                role: .client,
                currentWeight: 80.0,
                goalWeight: 75.0,
                fitnessLevel: .intermediate,
                goals: ["Похудение", "Увеличение выносливости"]
            ),
            User(
                name: "Елена Смирнова",
                email: "elena@client.com",
                role: .client,
                currentWeight: 65.0,
                goalWeight: 60.0,
                fitnessLevel: .beginner,
                goals: ["Тонус мышц", "Общее оздоровление"]
            )
        ]
    }
}
