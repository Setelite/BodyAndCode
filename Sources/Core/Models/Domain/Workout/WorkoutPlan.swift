//
//  WorkoutPlan.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/19/25.
//

import Foundation

struct WorkoutPlan: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String?
    let dayOfWeek: DayOfWeek
    let exercises: [Exercise]
    let assignedTo: [UUID] // User IDs
    let createdAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         description: String? = nil,
         dayOfWeek: DayOfWeek,
         exercises: [Exercise],
         assignedTo: [UUID],
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.dayOfWeek = dayOfWeek
        self.exercises = exercises
        self.assignedTo = assignedTo
        self.createdAt = createdAt
    }
}

enum DayOfWeek: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}
