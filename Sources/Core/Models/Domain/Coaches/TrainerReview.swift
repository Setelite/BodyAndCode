//
//  TrainerReview.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

//
import Foundation

struct TrainerReview: Identifiable, Codable, Hashable {
    let id: UUID
    let userName: String
    let rating: Int
    let date: String
    let text: String
    let coachId: UUID?
    
    init(id: UUID = UUID(),
         userName: String,
         rating: Int,
         date: String,
         text: String,
         coachId: UUID? = nil) {
        self.id = id
        self.userName = userName
        self.rating = rating
        self.date = date
        self.text = text
        self.coachId = coachId
    }
    
    static var sampleData: [TrainerReview] {
        return [
            TrainerReview(
                userName: "Анна",
                rating: 5,
                date: "15.12.2023",
                text: "Отличный тренер! За месяц помог достичь всех поставленных целей. Индивидуальный подход и профессиональные советы."
            ),
            TrainerReview(
                userName: "Михаил",
                rating: 5,
                date: "10.12.2023",
                text: "Профессионал своего дела. Всегда находит правильный подход. После 3 месяцев занятий результаты потрясающие!"
            ),
            TrainerReview(
                userName: "Екатерина",
                rating: 4,
                date: "05.12.2023",
                text: "Хороший тренер, эффективные тренировки. Единственный минус - иногда опаздывает на занятия на 5-10 минут."
            ),
            TrainerReview(
                userName: "Дмитрий",
                rating: 5,
                date: "01.12.2023",
                text: "Результат виден уже после первого месяца тренировок! Отличная мотивация и поддержка."
            ),
            TrainerReview(
                userName: "Ольга",
                rating: 5,
                date: "28.11.2023",
                text: "Лучший тренер в городе! Помог восстановиться после травмы и вернуться к тренировкам."
            ),
            TrainerReview(
                userName: "Андрей",
                rating: 4,
                date: "25.11.2023",
                text: "Качественные тренировки, хороший план питания. Рекомендую всем, кто хочет привести себя в форму."
            )
        ]
    }
    
    // Форматированная дата
    var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd.MM.yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "ru_RU")
        
        if let date = inputFormatter.date(from: date) {
            return outputFormatter.string(from: date)
        }
        return date
    }
    
    // Иконка пользователя (по первой букве имени)
    var userIcon: String {
        let firstChar = userName.prefix(1).uppercased()
        return firstChar
    }
    
    // Цвет для рейтинга
    var ratingColor: String {
        switch rating {
        case 5: return "excellent"
        case 4: return "good"
        case 3: return "average"
        default: return "poor"
        }
    }
}

// Расширение для работы с отзывами
extension Array where Element == TrainerReview {
    func averageRating() -> Double {
        guard !isEmpty else { return 0 }
        let total = reduce(0) { $0 + Double($1.rating) }
        return total / Double(count)
    }
    
    func reviewsForCoach(_ coachId: UUID) -> [TrainerReview] {
        filter { $0.coachId == coachId }
    }
    
    func recentReviews(limit: Int = 5) -> [TrainerReview] {
        let sortedReviews = sorted { review1, review2 in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            guard let date1 = formatter.date(from: review1.date),
                  let date2 = formatter.date(from: review2.date) else {
                return false
            }
            return date1 > date2
        }
        return Array(sortedReviews.prefix(limit))
    }
}

// Для отображения звезд рейтинга
extension Int {
    var starRating: String {
        switch self {
        case 5: return "★★★★★"
        case 4: return "★★★★☆"
        case 3: return "★★★☆☆"
        case 2: return "★★☆☆☆"
        case 1: return "★☆☆☆☆"
        default: return "☆☆☆☆☆"
        }
    }
}
