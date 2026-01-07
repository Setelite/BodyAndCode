//
//  Coach.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

import Foundation

struct Coach: Identifiable {
    let id = UUID()
    let name: String
    let specialization: String
    let experience: String
    let rating: Double
    let reviewCount: Int
    let description: String
    let imageName: String
    let certifications: [String]
    let achievements: [String]
    
    // Расписание доступности
    let availableSlots: [TimeSlot]
    
    // Цены за разные типы тренировок
    let prices: [TrainingType: Double]
    
    static let sample = Coach(
        name: "Александр Иванов",
        specialization: "Функциональный тренинг, Кроссфит",
        experience: "8 лет",
        rating: 4.9,
        reviewCount: 127,
        description: "Сертифицированный тренер с опытом подготовки чемпионов. Специализируюсь на функциональном тренинге, реабилитации после травм и составлении индивидуальных программ питания.",
        imageName: "coach_alex",
        certifications: [
            "ACE Certified Personal Trainer",
            "NASM Performance Enhancement Specialist",
            "FMS Level 2",
            "Диетолог-нутрициолог"
        ],
        achievements: [
            "Чемпион России по кроссфиту 2022",
            "Мастер спорта по тяжёлой атлетике",
            "Автор 50+ программ тренировок"
        ],
        availableSlots: [
            TimeSlot(day: "Пн", time: "09:00-11:00"),
            TimeSlot(day: "Вт", time: "15:00-18:00"),
            TimeSlot(day: "Ср", time: "10:00-12:00"),
            TimeSlot(day: "Чт", time: "16:00-20:00"),
            TimeSlot(day: "Пт", dayOff: true),
            TimeSlot(day: "Сб", time: "11:00-15:00"),
            TimeSlot(day: "Вс", dayOff: true)
        ],
        prices: [
            .individual: 2500,
            .group: 1200,
            .online: 1500,
            .monthly: 18000
        ]
    )
}

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

enum TrainingType: String, CaseIterable {
    case individual = "Индивидуальная"
    case group = "Групповая"
    case online = "Онлайн"
    case monthly = "Абонемент на месяц"
    
    
    // В файле Coach.swift или отдельном файле
extension TimeSlot {
        static var sampleWeek: [TimeSlot] {
            return [
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
    
    
    
}
