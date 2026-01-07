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
    @State private var notes = ""
    @Environment(\.dismiss) private var dismiss
    
    // Новые состояния для выбора времени
    @State private var selectedTime = "10:00"
    @State private var showingConfirmation = false
    @State private var bookingCreated = false
    
    let availableTimes = ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00", "17:00", "18:00"]
    
    // Для работы с оффлайн данными
    @EnvironmentObject private var offlineService: OfflineService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Информация о тренере
                    coachInfoCard
                    
                    // Детали тренировки
                    workoutDetailsCard
                    
                    // Выбор даты
                    dateSelectionCard
                    
                    // Выбор времени
                    timeSelectionCard
                    
                    // Примечания
                    notesCard
                    
                    // Кнопка подтверждения
                    confirmButton
                }
                .padding()
            }
            .navigationTitle("Запись на тренировку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        bookTraining()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Бронирование создано!", isPresented: $showingConfirmation) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Ваша тренировка с \(coach.name) запланирована на \(formattedBookingDateTime). Напоминание установлено.")
            }
        }
    }
    
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
                Text(coach.name)
                    .font(.headline)
                
                Text(coach.specialization)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var workoutDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Детали тренировки")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(title: "Тренер", value: coach.name)
                    DetailRow(title: "Тип тренировки", value: selectedType.rawValue)
                    DetailRow(title: "Длительность", value: "60 минут")
                    DetailRow(title: "Место", value: "Зал Body&Code")
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(Int(coach.prices[selectedType] ?? 0)) ₽")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("за занятие")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var dateSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Выберите дату")
                .font(.headline)
            
            DatePicker("", 
                      selection: $selectedDate,
                      in: Date()...Date().addingTimeInterval(60*60*24*30),
                      displayedComponents: .date)
                .datePickerStyle(.graphical)
                .frame(maxHeight: 400)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var timeSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Выберите время")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableTimes, id: \.self) { time in
                        TimeSlotButton(
                            time: time,
                            isSelected: selectedTime == time,
                            action: { selectedTime = time }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Дополнительно")
                .font(.headline)
            
            TextField("Примечания (опционально)", text: $notes, axis: .vertical)
                .padding()
                .frame(minHeight: 80, alignment: .top)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var confirmButton: some View {
        Button(action: bookTraining) {
            HStack {
                Spacer()
                
                if bookingCreated {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                    Text("Забронировано!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                } else {
                    Text("Подтвердить запись")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .frame(height: 56)
            .background(bookingCreated ? Color.green : (isDateAvailable() ? Color.blue : Color.gray))
            .cornerRadius(16)
        }
        .disabled(!isDateAvailable() || bookingCreated)
        .padding(.top, 8)
    }
    
    // Форматированная дата и время для отображения
    private var formattedBookingDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        let dateString = formatter.string(from: selectedDate)
        return "\(dateString) в \(selectedTime)"
    }
    
    private func bookTraining() {
        // Создаем полную дату тренировки
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        
        // Добавляем выбранное время
        let timeComponents = selectedTime.components(separatedBy: ":")
        guard let hour = Int(timeComponents[0]), let minute = Int(timeComponents[1]),
              let workoutDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: selectedDate) else {
            print("❌ Не удалось создать дату тренировки")
            return
        }
        
        // Создаем объект бронирования
        let booking = Booking(
            coachId: coach.id,
            trainingType: selectedType,
            date: selectedDate,
            time: selectedTime,
            notes: notes,
            status: .confirmed
        )
        
        print("✅ Бронирование создано:")
        print("   ID: \(booking.id)")
        print("   Тренер: \(coach.name)")
        print("   Тип: \(selectedType.rawValue)")
        print("   Дата и время: \(booking.formattedDateTime)")
        print("   Статус: \(booking.status.rawValue)")
        
        // 1. Сохраняем в оффлайн хранилище (Core Data)
        saveBookingToOffline(booking)
        
        // 2. Устанавливаем напоминание
        scheduleWorkoutReminder(workoutDate: workoutDate, booking: booking)
        
        // 3. Показываем подтверждение
        bookingCreated = true
        showingConfirmation = true
        
        // 4. Обновляем тренера в избранное
        addCoachToFavoritesIfNeeded()
        
        // Если онлайн - можно отправить на сервер
        if !offlineService.isOfflineMode {
            sendBookingToServer(booking)
        }
    }
    
    private func saveBookingToOffline(_ booking: Booking) {
        Task {
            // Здесь будем сохранять в Core Data
            // Сначала нужно создать сущность BookingEntity в Core Data модели
            
            print("💾 Сохранение бронирования в оффлайн хранилище...")
            
            // Временная реализация - сохранение в UserDefaults
            var bookings = UserDefaults.standard.array(forKey: "user_bookings") as? [[String: Any]] ?? []
            
            let bookingDict: [String: Any] = [
                "id": booking.id.uuidString,
                "coachId": booking.coachId.uuidString,
                "trainingType": booking.trainingType.rawValue,
                "date": booking.date,
                "time": booking.time,
                "notes": booking.notes,
                "status": booking.status.rawValue,
                "createdAt": booking.createdAt,
                "updatedAt": booking.updatedAt
            ]
            
            bookings.append(bookingDict)
            UserDefaults.standard.set(bookings, forKey: "user_bookings")
            
            print("✅ Бронирование сохранено локально")
        }
    }
    
    private func scheduleWorkoutReminder(workoutDate: Date, booking: Booking) {
        Task {
            let success = await NotificationService.shared.scheduleWorkoutReminder(
                date: workoutDate,
                title: "🏋️ Тренировка с \(coach.name)",
                body: "Тренировка \(selectedType.rawValue.lowercased()) через 15 минут",
                workoutId: booking.id.uuidString
            )
            
            if success {
                print("✅ Напоминание о тренировке установлено на \(workoutDate)")
            } else {
                print("❌ Не удалось установить напоминание")
            }
        }
    }
    
    private func addCoachToFavoritesIfNeeded() {
        Task {
            do {
                _ = try await offlineService.toggleFavoriteOffline(coachId: coach.id)
                print("⭐ Тренер добавлен в избранное")
            } catch {
                print("❌ Ошибка добавления в избранное: \(error)")
            }
        }
    }
    
    private func sendBookingToServer(_ booking: Booking) {
        // Здесь будет отправка на сервер
        print("🌐 Отправка бронирования на сервер...")
        
        // Имитация отправки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("✅ Бронирование отправлено на сервер")
        }
    }
    
    private func isDateAvailable() -> Bool {
        // Проверяем что выбранное время доступно у тренера
        let calendar = Calendar.current
        
        // Простая проверка: доступно время с 9:00 до 19:00
        let hour = calendar.component(.hour, from: selectedDate)
        let minute = calendar.component(.minute, from: selectedDate)
        let totalMinutes = hour * 60 + minute
        
        return totalMinutes >= 9 * 60 && totalMinutes <= 19 * 60
    }
}

// MARK: - Вспомогательные компоненты

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct TimeSlotButton: View {
    let time: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(time)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
        }
    }
}

#Preview {
    BookingView(
        coach: Coach.mockData[0],
        selectedType: .individual
    )
    .environmentObject(OfflineService())
}
