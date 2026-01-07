//
//  CoachFeature.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Features/Coaches/CoachFeature.swift
import SwiftUI

struct CoachFeature: View {
    var body: some View {
        NavigationView {
            CoachListView()
                .navigationTitle("Тренеры")
        }
    }
}

// Placeholder protocol to fix the build error.
// Replace with your actual analytics service protocol when available.
protocol AnalyticsServiceProtocol {}


// Группировка всех зависимостей для DI
struct CoachDependencies {
    let service: CoachServiceProtocol
    let analytics: AnalyticsServiceProtocol
}

// Конфигурация роутинга
enum CoachRoute: Hashable {
    case list
    case detail(Coach)
    case booking(Coach, TrainingType)
    case reviews(Coach)
}
