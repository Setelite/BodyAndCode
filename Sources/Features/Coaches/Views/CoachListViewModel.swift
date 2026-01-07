//
//  CoachListViewModel.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/7/26.
//

import SwiftUI
import Combine

class CoachListViewModel: ObservableObject {
    @Published var coaches: [Coach] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var allCoaches: [Coach] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Пример тестовых данных
        loadMockCoaches()
    }
    
    func loadMockCoaches() {
        isLoading = true
        
        // Имитация загрузки данных
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.allCoaches = [
                Coach(
                    id: UUID(),
                    name: "Алексей Иванов",
                    specialization: "Персональный тренер",
                    experience: "5 лет",
                    rating: 4.8,
                    reviewCount: 42,
                    description: "Специалист по силовым тренировкам",
                    imageName: nil,
                    isFavorite: false
                ),
                Coach(
                    id: UUID(),
                    name: "Мария Петрова",
                    specialization: "Йога инструктор",
                    experience: "3 года",
                    rating: 4.9,
                    reviewCount: 37,
                    description: "Сертифицированный инструктор по йоге",
                    imageName: nil,
                    isFavorite: false
                ),
                Coach(
                    id: UUID(),
                    name: "Дмитрий Сидоров",
                    specialization: "Кардио тренер",
                    experience: "7 лет",
                    rating: 4.7,
                    reviewCount: 28,
                    description: "Эксперт в кардио тренировках",
                    imageName: nil,
                    isFavorite: false
                ),
                Coach(
                    id: UUID(),
                    name: "Екатерина Волкова",
                    specialization: "Фитнес инструктор",
                    experience: "4 года",
                    rating: 4.6,
                    reviewCount: 31,
                    description: "Специалист по функциональному тренингу",
                    imageName: nil,
                    isFavorite: false
                ),
                Coach(
                    id: UUID(),
                    name: "Иван Кузнецов",
                    specialization: "Боксерский тренер",
                    experience: "8 лет",
                    rating: 4.9,
                    reviewCount: 56,
                    description: "Чемпион России по боксу",
                    imageName: nil,
                    isFavorite: false
                )
            ]
            
            self.coaches = self.allCoaches
            self.isLoading = false
        }
    }
    
    func loadCoaches() {
        isLoading = true
        errorMessage = nil
        
        // В реальном приложении здесь будет загрузка из Core Data
        loadMockCoaches()
    }
    
    func searchCoaches(query: String) {
        guard !query.isEmpty else {
            coaches = allCoaches
            return
        }
        
        let filtered = allCoaches.filter { coach in
            let query = query.lowercased()
            return coach.name.lowercased().contains(query) ||
                   coach.specialization.lowercased().contains(query)
        }
        
        coaches = filtered
    }
    
    func filterByMinRating(_ minRating: Double) {
        let filtered = allCoaches.filter { $0.rating >= minRating }
        coaches = filtered
    }
    
    func refresh() async {
        await MainActor.run {
            isLoading = true
        }
        
        // Имитация сетевого запроса
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            // В реальном приложении здесь будет обновление из сети/базы
            loadMockCoaches()
            isLoading = false
        }
    }
    
    func toggleFavorite(for coachId: UUID) {
        if let index = allCoaches.firstIndex(where: { $0.id == coachId }) {
            var coach = allCoaches[index]
            coach.isFavorite.toggle()
            allCoaches[index] = coach
            
            // Обновляем отображаемый список
            if let displayIndex = coaches.firstIndex(where: { $0.id == coachId }) {
                coaches[displayIndex] = coach
            }
        }
    }
}
