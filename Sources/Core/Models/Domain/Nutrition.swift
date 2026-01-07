//
//  Nutrition.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

// Sources/Core/Models/Domain/Nutrition.swift
import Foundation

struct Nutrition: Identifiable, Codable, Hashable {
    let id: UUID
    let mealType: String // breakfast, lunch, dinner, snack
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let date: Date
    let notes: String
    
    init(
        id: UUID = UUID(),
        mealType: String,
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        date: Date,
        notes: String = ""
    ) {
        self.id = id
        self.mealType = mealType
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
        self.notes = notes
    }
    
    var totalMacros: Double {
        return protein + carbs + fat
    }
    
    var proteinPercentage: Double {
        guard totalMacros > 0 else { return 0 }
        return (protein * 4) / Double(calories) * 100
    }
    
    var carbsPercentage: Double {
        guard totalMacros > 0 else { return 0 }
        return (carbs * 4) / Double(calories) * 100
    }
    
    var fatPercentage: Double {
        guard totalMacros > 0 else { return 0 }
        return (fat * 9) / Double(calories) * 100
    }
    
    var mealTypeIcon: String {
        switch mealType.lowercased() {
        case "breakfast", "завтрак": return "sunrise.fill"
        case "lunch", "обед": return "sun.max.fill"
        case "dinner", "ужин": return "moon.fill"
        default: return "leaf.fill"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
