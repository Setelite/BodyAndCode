//
//  MuscleGroup.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/24/25.
//

import Foundation

enum MuscleGroup: String, CaseIterable, Codable, Hashable {
    case chest = "chest"
    case back = "back"
    case legs = "legs"
    case shoulders = "shoulders"
    case arms = "arms"
    case core = "core"
    case fullBody = "fullBody"
    
    var localized: String {
        switch self {
        case .chest: return "Грудь"
        case .back: return "Спина"
        case .legs: return "Ноги"
        case .shoulders: return "Плечи"
        case .arms: return "Руки"
        case .core: return "Пресс"
        case .fullBody: return "Все тело"
        }
    }
    
    var icon: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .back: return "figure.rower"
        case .legs: return "figure.run"
        case .shoulders: return "figure.walk"
        case .arms: return "figure.curling"
        case .core: return "figure.core.training"
        case .fullBody: return "figure.mixed.cardio"
        }
    }
    
    var color: String {
        switch self {
        case .chest: return "FF6B6B"
        case .back: return "4ECDC4"
        case .legs: return "45B7D1"
        case .shoulders: return "96CEB4"
        case .arms: return "FFEAA7"
        case .core: return "DDA0DD"
        case .fullBody: return "98D8C8"
        }
    }
}
