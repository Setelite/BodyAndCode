//
//  CoachFeature.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

import SwiftUI

// Placeholder protocol to fix the build error.
// Replace with your actual analytics service protocol when available.
protocol AnalyticsServiceProtocol {}


// Группировка всех зависимостей для DI
struct CoachDependencies {
    let service: CoachServiceProtocol
    let analytics: AnalyticsServiceProtocol
}

// Конфигурация роутинга
// CoachRoute is now only declared in CoachRout.swift.
