//
//  CoachStore.swift
//  BodyCodeApp
//
//  Created by MAXIM GORNOSTAEV on 1/9/26.
//

import Foundation
import SwiftUI
import Combine


final class CoachStore: ObservableObject {

    @Published var coaches: [Coach]

    init() {
        self.coaches = Coach.mockData
    }

    func coach(by id: UUID) -> Coach? {
        coaches.first { $0.id == id }
    }
}
