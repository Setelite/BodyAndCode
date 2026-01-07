//
//  ReviewsView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Features/Coaches/Views/ReviewsView.swift
import SwiftUI

struct ReviewsView: View {
    let coach: Coach
    @Environment(\.dismiss) private var dismiss
    
    // Используем TrainerReview вместо CoachReview
    let sampleReviews = [
        TrainerReview(userName: "Анна", rating: 5, date: "15.12.2023", text: "Отличный тренер! За месяц помог достичь всех поставленных целей."),
        TrainerReview(userName: "Михаил", rating: 5, date: "10.12.2023", text: "Профессионал своего дела. Индивидуальный подход к каждому клиенту."),
        TrainerReview(userName: "Екатерина", rating: 4, date: "05.12.2023", text: "Хороший тренер, но иногда опаздывает на занятия."),
        TrainerReview(userName: "Дмитрий", rating: 5, date: "01.12.2023", text: "Результат виден уже после первого месяца тренировок!"),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Общий рейтинг
                    overallRatingSection
                    
                    // Список отзывов
                    reviewsListSection
                }
                .padding()
            }
            .navigationTitle("Отзывы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var overallRatingSection: some View {
        VStack(spacing: 12) {
            Text(String(format: "%.1f", coach.rating))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.orange)
            
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < Int(coach.rating) ? "star.fill" : "star")
                        .foregroundColor(.orange)
                        .font(.title3)
                }
            }
            
            Text("На основе \(coach.reviewCount) отзывов")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var reviewsListSection: some View {
        VStack(spacing: 16) {
            ForEach(sampleReviews) { review in
                ReviewRow(review: review) // Используем ReviewRow (не TrainerReviewRow)
            }
        }
    }
}

// УДАЛИТЕ ЭТУ СТРУКТУРУ - она дублирует TrainerReview
// struct CoachReview: Identifiable {
//     let id = UUID()
//     let userName: String
//     let rating: Int
//     let date: String
//     let text: String
// }

// Обновляем ReviewRow для работы с TrainerReview
struct ReviewRow: View {
    let review: TrainerReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.headline)
                    
                    Text(review.date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
            }
            
            Text(review.text)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    ReviewsView(coach: Coach.mockData[0])
}
