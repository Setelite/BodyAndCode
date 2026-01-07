//
//  CoachListViewModel.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Core/ViewModels/Coaches/CoachListViewModel.swift
import SwiftUI
import Combine

class CoachListViewModel: ObservableObject {
    @Published var coaches: [Coach] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var allCoaches: [Coach] = []
    
    init() {
        // Загружаем тестовые данные
        loadMockData()
    }
    
    @MainActor
    func loadCoaches() async {
        isLoading = true
        errorMessage = nil
        
        // Имитация загрузки
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        loadMockData()
        isLoading = false
    }
    
    func searchCoaches(query: String) {
        guard !query.isEmpty else {
            coaches = allCoaches
            return
        }
        
        let queryLowercased = query.lowercased()
        coaches = allCoaches.filter { coach in
            coach.name.lowercased().contains(queryLowercased) ||
            coach.specialization.lowercased().contains(queryLowercased)
        }
    }
    
    func filterByMinRating(_ minRating: Double) {
        coaches = allCoaches.filter { $0.rating >= minRating }
    }
    
    func refresh() async {
        await loadCoaches()
    }
    
    private func loadMockData() {
        allCoaches = [
            Coach(
                id: UUID(),
                name: "Алексей Иванов",
                specialization: "Персональный тренер",
                experience: "5 лет",
                rating: 4.8,
                reviewCount: 42,
                description: "Специалист по силовым тренировкам",
                imageName: String(),
                reviews: [],
                isFavorite: false,
                certifications: [],
                achievements: [],
                availableSlots: [],
                prices: [:]
            ),
            Coach(
                id: UUID(),
                name: "Мария Петрова",
                specialization: "Йога инструктор",
                experience: "3 года",
                rating: 4.9,
                reviewCount: 37,
                description: "Сертифицированный инструктор по йоге",
                imageName: String(),
                reviews: [],
                isFavorite: false,
                certifications: [],
                achievements: [],
                availableSlots: [],
                prices: [:]
            )
        ]
        
        coaches = allCoaches
    }
}
