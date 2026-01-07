//
//  AnalyticsService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

// Sources/Core/Services/Analytics/AnalyticsService.swift
import Foundation

enum AnalyticsEvent {
    case screenView(_ screen: String)
    case buttonTap(_ button: String, screen: String)
    case workoutStarted(_ type: String)
    case workoutCompleted(_ type: String, duration: TimeInterval)
    case coachBooked(_ coachId: String)
    case mealAdded(_ calories: Int)
    
    var name: String {
        switch self {
        case .screenView: return "screen_view"
        case .buttonTap: return "button_tap"
        case .workoutStarted: return "workout_started"
        case .workoutCompleted: return "workout_completed"
        case .coachBooked: return "coach_booked"
        case .mealAdded: return "meal_added"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .screenView(let screen):
            return ["screen": screen]
        case .buttonTap(let button, let screen):
            return ["button": button, "screen": screen]
        case .workoutStarted(let type):
            return ["type": type]
        case .workoutCompleted(let type, let duration):
            return ["type": type, "duration": duration]
        case .coachBooked(let coachId):
            return ["coach_id": coachId]
        case .mealAdded(let calories):
            return ["calories": calories]
        }
    }
}

class AnalyticsService {
    static let shared = AnalyticsService()
    
    func logEvent(_ event: AnalyticsEvent) {
        print("📊 Аналитика: \(event.name) - \(event.parameters)")
        
        // Здесь можно интегрировать с Firebase, Amplitude, Яндекс.Метрикой и т.д.
        // FirebaseAnalytics.logEvent(event.name, parameters: event.parameters)
    }
}
