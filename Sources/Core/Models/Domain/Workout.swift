//
//  Workout.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

// Sources/Core/Models/Domain/Workout.swift
import Foundation

struct Workout: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let type: String
    let duration: Int // в минутах
    let calories: Int
    let date: Date
    var isCompleted: Bool
    let notes: String
    let coachId: UUID?
    
    init(
        id: UUID = UUID(),
        name: String,
        type: String,
        duration: Int,
        calories: Int,
        date: Date,
        isCompleted: Bool = false,
        notes: String = "",
        coachId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.duration = duration
        self.calories = calories
        self.date = date
        self.isCompleted = isCompleted
        self.notes = notes
        self.coachId = coachId
    }
    
    var formattedDuration: String {
        let hours = duration / 60
        let minutes = duration % 60
        
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
