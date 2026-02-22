//
//  BookingView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

import SwiftUI

struct BookingView: View {
    let coach: Coach
    let selectedType: TrainingType
    
    @State private var selectedDate = Date()
    @State private var selectedTime: String? = nil
    @State private var notes = ""
    
    @State private var bookingCreated = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var offlineService: OfflineService
    
    // MARK: - Доступные часы
    private let baseTimes = ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00", "17:00", "18:00"]
    
    private var availableTimes: [String] {
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        if weekday == 1 || weekday == 7 { // воскресенье или суббота
            return ["10:00", "11:00", "14:00", "15:00"]
        }
        return baseTimes
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                coachInfoCard
                workoutDetailsCard
                dateSelectionCard
                timeSelectionCard
                notesCard
                confirmButton
            }
            .padding()
        }
        .navigationTitle("Запись на тренировку")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Отмена") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Готово") {
                    bookTraining()
                }
                .disabled(selectedTime == nil || bookingCreated)
            }
        }
        .confirmationDialog(
            "Бронирование создано!",
            isPresented: $bookingCreated,
            titleVisibility: .visible
        ) {
            Button("OK") { dismiss() }
        } message: {
            Text("Тренировка с \(coach.name)\n\(formattedBookingDateTime)")
        }
    }
    
    // MARK: - Карточки
    
    private var coachInfoCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(coach.name.prefix(1))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coach.name).font(.headline)
                Text(coach.specialization)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
    
    private struct DetailRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Text(value).foregroundColor(.secondary)
            }
        }
    }
    
    private var workoutDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Детали тренировки").font(.headline)
            
            DetailRow(title: "Тип", value: selectedType.rawValue)
            DetailRow(title: "Длительность", value: "60 минут")
            DetailRow(title: "Стоимость", value: "\(Int(coach.prices[selectedType] ?? 0)) ₽")
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var dateSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Дата").font(.headline)
            
            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .onChange(of: selectedDate) { _, _ in selectedTime = nil }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var timeSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Время").font(.headline)
            
            if availableTimes.isEmpty {
                Text("Нет доступного времени на эту дату")
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(availableTimes, id: \.self) { time in
                            TimeSlotButton(time: time, isSelected: selectedTime == time) {
                                selectedTime = time
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
    
    private struct TimeSlotButton: View {
        let time: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(time) {
                action()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
    
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Комментарий").font(.headline)
            
            TextField("Например: есть травмы", text: $notes, axis: .vertical)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .lineLimit(5...)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var confirmButton: some View {
        Button {
            bookTraining()
        } label: {
            Text(bookingCreated ? "Готово" : "Подтвердить запись")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background((selectedTime == nil || bookingCreated) ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
        }
        .disabled(selectedTime == nil || bookingCreated)
    }
    
    // MARK: - Логика
    
    private var formattedBookingDateTime: String {
        guard let selectedTime = selectedTime else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return "\(formatter.string(from: selectedDate)) в \(selectedTime)"
    }
    
    private func bookTraining() {
        guard let selectedTime = selectedTime else { return }
        
        let booking = Booking(
            coachId: coach.id,
            trainingType: selectedType,
            date: selectedDate,
            time: selectedTime,
            notes: notes,
            status: .confirmed
        )
        
        saveBookingToOffline(booking)
        bookingCreated = true
    }
    
    private func saveBookingToOffline(_ booking: Booking) {
        print("💾 Booking saved locally:", booking.id)
        // Здесь подключи реальное сохранение в Core Data / OfflineService
    }
}

// MARK: - Preview Helpers (только для preview)
fileprivate extension BookingView {
    static var previewCoach: Coach {
        Coach(
            id: UUID(),
            name: "Алексей Иванов",
            specialization: "Силовые тренировки и кроссфит",
            experience: "8 лет",            // Изменил на String — теперь нет ошибки Int → String
            rating: 4.9,
            reviewCount: 127,               // Оставил Int (если ошибка переместится сюда — измени на "127")
            description: "Опытный тренер с многолетней практикой в силовых дисциплинах и функциональном тренинге.",
            imageName: "coach_placeholder",
            reviews: [],
            isFavorite: false,
            certifications: ["CrossFit Level 2", "FMS Certified"],
            achievements: ["Чемпион России по пауэрлифтингу 2023", "Тренер года"],
            availableSlots: [],
            prices: [:]
        )
    }
}

#if DEBUG
struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BookingView(
                coach: BookingView.previewCoach,
                selectedType: TrainingType(rawValue: "Персональная тренировка")!
            )
            .environmentObject(OfflineService())
        }
    }
}
#endif
