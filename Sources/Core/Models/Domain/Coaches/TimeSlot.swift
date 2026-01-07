//
//  TimeSlot.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

import Foundation

struct TimeSlot: Identifiable, Codable, Hashable {
    let id: UUID
    let day: String
    let time: String?
    let dayOff: Bool
    
    init(day: String, time: String? = nil, dayOff: Bool = false) {
        self.id = UUID()
        self.day = day
        self.time = time
        self.dayOff = dayOff
    }
}
