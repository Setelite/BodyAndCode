//
//  TimeSlot.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

import Foundation

struct TimeSlot: Identifiable {
    let id = UUID()
    let day: String
    let time: String?
    let dayOff: Bool
    
    init(day: String, time: String? = nil, dayOff: Bool = false) {
        self.day = day
        self.time = time
        self.dayOff = dayOff
    }
}

extension TimeSlot {
    static var sampleWeek: [TimeSlot] {
        [
            TimeSlot(day: "Пн", time: "09:00-12:00"),
            TimeSlot(day: "Вт", time: "14:00-18:00"),
            TimeSlot(day: "Ср", time: "10:00-13:00"),
            TimeSlot(day: "Чт", time: "15:00-19:00"),
            TimeSlot(day: "Пт", dayOff: true),
            TimeSlot(day: "Сб", time: "11:00-16:00"),
            TimeSlot(day: "Вс", dayOff: true)
        ]
    }
}
