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
    case exerciseCompleted(_ exercise: String, sets: Int)
    case setCompleted(_ exercise: String, setNumber: Int)
    case workoutCompleted(_ type: String, duration: TimeInterval)
    case coachBooked(_ coachId: String)
    case mealAdded(_ calories: Int)
    
    var name: String {
        switch self {
        case .screenView: return "screen_view"
        case .buttonTap: return "button_tap"
        case .workoutStarted: return "workout_started"
        case .exerciseCompleted: return "exercise_completed"
        case .setCompleted: return "set_completed"
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
        case .exerciseCompleted(let exercise, let sets):
            return ["exercise": exercise, "sets": sets]
        case .setCompleted(let exercise, let setNumber):
            return ["exercise": exercise, "set_number": setNumber]
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
    private let key = "analytics_events_v1"

    struct StoredAnalyticsEvent: Codable, Identifiable {
        let id: UUID
        let name: String
        let parameters: [String: String]
        let timestamp: Date
    }

    private(set) var events: [StoredAnalyticsEvent] = []

    init() {
        loadEvents()
    }

    func logEvent(_ event: AnalyticsEvent) {
        print("📊 Аналитика: \(event.name) - \(event.parameters)")

        let stored = StoredAnalyticsEvent(
            id: UUID(),
            name: event.name,
            parameters: event.parameters.reduce(into: [:]) { partialResult, pair in
                partialResult[pair.key] = String(describing: pair.value)
            },
            timestamp: Date()
        )
        events.insert(stored, at: 0)
        if events.count > 1000 {
            events = Array(events.prefix(1000))
        }
        saveEvents()

        // Здесь можно интегрировать с Firebase, Amplitude, Яндекс.Метрикой и т.д.
        // FirebaseAnalytics.logEvent(event.name, parameters: event.parameters)
    }

    func recentEvents(limit: Int = 50) -> [StoredAnalyticsEvent] {
        Array(events.prefix(limit))
    }

    private func loadEvents() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([StoredAnalyticsEvent].self, from: data) else {
            events = []
            return
        }
        events = decoded
    }

    private func saveEvents() {
        guard let data = try? JSONEncoder().encode(events) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
