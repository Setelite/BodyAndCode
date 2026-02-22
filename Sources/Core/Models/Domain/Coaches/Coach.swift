//
//  Coach.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

import Foundation
internal import CoreData

struct Coach: Identifiable {
    let id: UUID
    let name: String
    let specialization: String
    let experience: String
    let rating: Double
    let reviewCount: Int
    let description: String
    let imageName: String
    var reviews: [TrainerReview]?
    var isFavorite: Bool = false

    // New properties for extended mock data
    let certifications: [String]
    let achievements: [String]
    let availableSlots: [TimeSlot]
    let prices: [TrainingType: Double]
    
    // Изменяем CoachReview на TrainerReview
    //var reviews: [TrainerReview]?
    // Обновляем вычисляемое свойство
    var coachReviews: [TrainerReview] {
        reviews ?? TrainerReview.sampleData
    }

    // Mock данные для тестирования
    static var mockData: [Coach] {
        return [
            Coach(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
                name: "Александр Иванов",
                specialization: "Функциональный тренинг, Кроссфит",
                experience: "8 лет",
                rating: 4.9,
                reviewCount: 127,
                description: "Сертифицированный тренер с опытом подготовки чемпионов. Специализируюсь на функциональном тренинге, реабилитации после травм.",
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
            ),
            Coach(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
                name: "Елена Петрова",
                specialization: "Йога, Пилатес, Стретчинг",
                experience: "6 лет",
                rating: 4.8,
                reviewCount: 89,
                description: "Сертифицированный инструктор по йоге и пилатесу. Помогаю обрести гармонию тела и духа.",
                imageName: "coach_elena",
                certifications: [
                    "Yoga Alliance Certified",
                    "Pilates Instructor International",
                    "Stretch Therapy Expert"
                ],
                achievements: [
                    "Победитель YogaFest 2023",
                    "Автор методики расслабления"
                ],
                availableSlots: [
                    TimeSlot(day: "Пн", time: "09:00-12:00"),
                    TimeSlot(day: "Вт", time: "13:00-16:00"),
                    TimeSlot(day: "Ср", time: "10:00-12:00"),
                    TimeSlot(day: "Чт", time: "15:00-18:00"),
                    TimeSlot(day: "Пт", dayOff: true),
                    TimeSlot(day: "Сб", time: "11:00-14:00"),
                    TimeSlot(day: "Вс", dayOff: true)
                ],
                prices: [
                    .individual: 2000,
                    .group: 1000,
                    .online: 1100,
                    .monthly: 16000
                ]
            ),
            Coach(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
                name: "Михаил Сидоров",
                specialization: "Бодибилдинг, Пауэрлифтинг",
                experience: "10 лет",
                rating: 4.7,
                reviewCount: 156,
                description: "Мастер спорта по пауэрлифтингу. Специализируюсь на силовых тренировках и наборе мышечной массы.",
                imageName: "coach_mikhail",
                certifications: [
                    "IFBB Certified Coach",
                    "Powerlifting Specialist"
                ],
                achievements: [
                    "Мастер спорта России",
                    "Призер чемпионата Европы по бодибилдингу"
                ],
                availableSlots: [
                    TimeSlot(day: "Пн", time: "08:00-11:00"),
                    TimeSlot(day: "Вт", time: "16:00-20:00"),
                    TimeSlot(day: "Ср", time: "09:00-11:00"),
                    TimeSlot(day: "Чт", time: "14:00-18:00"),
                    TimeSlot(day: "Пт", dayOff: true),
                    TimeSlot(day: "Сб", time: "11:00-15:00"),
                    TimeSlot(day: "Вс", dayOff: true)
                ],
                prices: [
                    .individual: 2700,
                    .group: 1300,
                    .online: 1200,
                    .monthly: 19500
                ]
            ),
            Coach(
                id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
                name: "Анна Козлова",
                specialization: "Кардио, Похудение, Здоровье",
                experience: "5 лет",
                rating: 4.6,
                reviewCount: 94,
                description: "Помогаю достичь идеальной формы через кардио тренировки и правильное питание.",
                imageName: "coach_anna",
                certifications: [
                    "Cardio Instructor Pro",
                    "Nutrition Specialist"
                ],
                achievements: [
                    "Похудение 100+ клиентов",
                    "Автор курса 'Здоровое питание'"
                ],
                availableSlots: [
                    TimeSlot(day: "Пн", time: "10:00-13:00"),
                    TimeSlot(day: "Вт", time: "12:00-15:00"),
                    TimeSlot(day: "Ср", dayOff: true),
                    TimeSlot(day: "Чт", time: "17:00-20:00"),
                    TimeSlot(day: "Пт", time: "09:00-12:00"),
                    TimeSlot(day: "Сб", time: "10:00-13:00"),
                    TimeSlot(day: "Вс", dayOff: true)
                ],
                prices: [
                    .individual: 1800,
                    .group: 800,
                    .online: 900,
                    .monthly: 14000
                ]
            )
        ]
    }
    
    // Для быстрого доступа к sample тренеру
    static let sample = mockData[0]
}

