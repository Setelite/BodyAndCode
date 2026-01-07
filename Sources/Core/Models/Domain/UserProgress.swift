//
//  UserProgress.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

// Sources/Core/Models/Domain/UserProgress.swift
import Foundation

struct UserProgress: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let weight: Double
    let bodyFat: Double
    let muscleMass: Double
    let caloriesBurned: Int
    let workoutMinutes: Int
    
    init(
        id: UUID = UUID(),
        date: Date,
        weight: Double,
        bodyFat: Double,
        muscleMass: Double,
        caloriesBurned: Int,
        workoutMinutes: Int
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.bodyFat = bodyFat
        self.muscleMass = muscleMass
        self.caloriesBurned = caloriesBurned
        self.workoutMinutes = workoutMinutes
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    var bmi: Double {
        // Простой расчет BMI (вес в кг / (рост в м)^2)
        // Здесь нужно добавить рост пользователя
        let height = 1.75 // средний рост
        return weight / (height * height)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Недостаточный вес"
        case 18.5..<25: return "Нормальный вес"
        case 25..<30: return "Избыточный вес"
        default: return "Ожирение"
        }
    }
}
