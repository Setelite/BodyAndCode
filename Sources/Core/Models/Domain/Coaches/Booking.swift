//
//  Booking.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Core/Models/Domain/Coaches/Booking.swift
import Foundation

struct Booking: Identifiable, Codable {
    let id: UUID
    let coachId: UUID
    let trainingType: TrainingType
    let date: Date
    let time: String
    let notes: String
    let status: BookingStatus
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: UUID = UUID(),
        coachId: UUID,
        trainingType: TrainingType,
        date: Date,
        time: String,
        notes: String = "",
        status: BookingStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.coachId = coachId
        self.trainingType = trainingType
        self.date = date
        self.time = time
        self.notes = notes
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var fullDateTime: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString = "\(date.formatted(date: .numeric, time: .omitted)) \(time)"
        return dateFormatter.date(from: dateString)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    var formattedDateTime: String {
        return "\(formattedDate) в \(time)"
    }
    
    var isUpcoming: Bool {
        guard let bookingDate = fullDateTime else { return false }
        return bookingDate > Date()
    }
    
    var isPast: Bool {
        guard let bookingDate = fullDateTime else { return false }
        return bookingDate <= Date()
    }
}

enum BookingStatus: String, Codable, CaseIterable {
    case pending = "Ожидает подтверждения"
    case confirmed = "Подтверждена"
    case cancelled = "Отменена"
    case completed = "Завершена"
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "green"
        case .cancelled: return "red"
        case .completed: return "blue"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

// Расширение для работы с бронированиями
extension Array where Element == Booking {
    func upcomingBookings() -> [Booking] {
        filter { $0.isUpcoming }
            .sorted { ($0.fullDateTime ?? Date()) < ($1.fullDateTime ?? Date()) }
    }
    
    func pastBookings() -> [Booking] {
        filter { $0.isPast }
            .sorted { ($0.fullDateTime ?? Date()) > ($1.fullDateTime ?? Date()) }
    }
    
    func bookingsForCoach(_ coachId: UUID) -> [Booking] {
        filter { $0.coachId == coachId }
    }
    
    func bookingsForDate(_ date: Date) -> [Booking] {
        let calendar = Calendar.current
        return filter { booking in
            calendar.isDate(booking.date, inSameDayAs: date)
        }
    }
}

// Пример данных для тестирования
extension Booking {
    static var sampleData: [Booking] {
        let calendar = Calendar.current
        
        return [
            Booking(
                coachId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
                trainingType: .individual,
                date: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                time: "10:00",
                notes: "Первая тренировка",
                status: .confirmed
            ),
            Booking(
                coachId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
                trainingType: .group,
                date: calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                time: "14:00",
                notes: "Групповая тренировка",
                status: .pending
            ),
            Booking(
                coachId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
                trainingType: .online,
                date: calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                time: "16:00",
                notes: "Онлайн консультация",
                status: .completed
            )
        ]
    }
}
