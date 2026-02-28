//
//  CoachReviewsView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

// Sources/Features/Coaches/Views/CoachReviewsView.swift
import SwiftUI

struct CoachReviewsView: View {
    let coach: Coach
    @Environment(\.dismiss) private var dismiss
    
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
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var reviewsListSection: some View {
        VStack(spacing: 16) {
            ForEach(coach.coachReviews) { review in
                TrainerReviewRow(review: review)
            }
        }
    }
}

struct TrainerReviewRow: View {
    let review: TrainerReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Аватар пользователя
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(review.userIcon)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(.headline)
                    
                    Text(review.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Рейтинг звездами
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
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#if DEBUG
struct CoachReviewsView_Previews: PreviewProvider {
    static var previews: some View {
        CoachReviewsView(coach: Coach.mockData[0])
    }
}
#endif
