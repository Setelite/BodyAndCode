//
//  User.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/19/25.
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case client = "client"
    case coach = "coach"
    
    var localized: String {
        switch self {
        case .client: return "Клиент"
        case .coach: return "Тренер"
        }
    }
}

struct User: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let role: UserRole
    var currentWeight: Double?
    var goalWeight: Double?
    var profileImageUrl: String?
    let createdAt: Date
    
    // Для тренера
    var clients: [UUID]? // ID клиентов
    var specialization: String? // Специализация тренера
    var experience: Int? // Опыт в годах
    
    // Для клиента
    var coachId: UUID? // ID тренера
    var fitnessLevel: FitnessLevel? // Уровень подготовки
    var goals: [String]? // Цели клиента
    
    init(id: UUID = UUID(),
         name: String,
         email: String,
         role: UserRole,
         currentWeight: Double? = nil,
         goalWeight: Double? = nil,
         profileImageUrl: String? = nil,
         clients: [UUID]? = nil,
         specialization: String? = nil,
         experience: Int? = nil,
         coachId: UUID? = nil,
         fitnessLevel: FitnessLevel? = nil,
         goals: [String]? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.currentWeight = currentWeight
        self.goalWeight = goalWeight
        self.profileImageUrl = profileImageUrl
        self.clients = clients
        self.specialization = specialization
        self.experience = experience
        self.coachId = coachId
        self.fitnessLevel = fitnessLevel
        self.goals = goals
        self.createdAt = createdAt
    }
}

enum FitnessLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var localized: String {
        switch self {
        case .beginner: return "Начинающий"
        case .intermediate: return "Средний"
        case .advanced: return "Продвинутый"
        }
    }
}
