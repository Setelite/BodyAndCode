//
//  CoachDetailView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/1/25.
//

import SwiftUI

struct CoachDetailView: View {
    let coach: Coach
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Аватар
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(String(coach.name.prefix(1)))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 10)
                
                // Информация
                VStack(spacing: 8) {
                    Text(coach.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(coach.specialization)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Статистика
                HStack(spacing: 30) {
                    VStack {
                        Text(String(format: "%.1f", coach.rating))
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Рейтинг")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(coach.reviewCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Отзывов")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text(coach.experience)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Опыт")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical)
                
                // Описание - description теперь НЕ опциональное поле
                if !coach.description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("О тренере")
                            .font(.headline)
                        
                        Text(coach.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Профиль тренера")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CoachDetailView(coach: Coach(
            id: UUID(),
            name: "Алексей Иванов",
            specialization: "Персональный тренер",
            experience: "5 лет",
            rating: 4.8,
            reviewCount: 42,
            description: "Специалист по силовым тренировкам. Сертифицированный тренер с международной аккредитацией.",
            imageName: "",
            reviews: [],
            isFavorite: false,
            certifications: [],
            achievements: [],
            availableSlots: [],
            prices: [:]
        ))
    }
}
