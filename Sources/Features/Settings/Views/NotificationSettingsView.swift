//
//  NotificationSettingsView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

// Sources/Features/Settings/Views/NotificationSettingsView.swift
import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared
    @State private var notificationPreferences: [NotificationPreference] = [
        NotificationPreference(type: .workout, isEnabled: true, description: "Напоминания о тренировках"),
        NotificationPreference(type: .meal, isEnabled: true, description: "Напоминания о приемах пищи"),
        NotificationPreference(type: .water, isEnabled: true, description: "Напоминания пить воду"),
        NotificationPreference(type: .general, isEnabled: true, description: "Общие уведомления")
    ]
    
    @State private var workoutReminderTime = Date()
    @State private var breakfastTime = Date()
    @State private var lunchTime = Date()
    @State private var dinnerTime = Date()
    @State private var waterReminderInterval = 2
    
    var body: some View {
        List {
            // Разрешение уведомлений
            notificationPermissionSection
            
            // Настройки по типам
            ForEach($notificationPreferences) { $preference in
                notificationTypeSection(preference: $preference)
            }
            
            // Запланированные уведомления
            scheduledNotificationsSection
        }
        .navigationTitle("Уведомления")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await notificationService.checkPermissionStatus()
            }
        }
    }
    
    private var notificationPermissionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Разрешения")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(statusTitle)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(statusDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if notificationService.permissionStatus != .authorized {
                        Button("Разрешить") {
                            Task {
                                await notificationService.requestPermission()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func notificationTypeSection(preference: Binding<NotificationPreference>) -> some View {
        Section {
            Toggle(isOn: preference.isEnabled) {
                HStack {
                    Image(systemName: preference.wrappedValue.type.icon)
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(preference.wrappedValue.type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(preference.wrappedValue.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onChange(of: preference.wrappedValue.isEnabled) { _, newValue in
                handlePreferenceChange(type: preference.wrappedValue.type, isEnabled: newValue)
            }
            
            // Дополнительные настройки для каждого типа
            if preference.wrappedValue.isEnabled {
                switch preference.wrappedValue.type {
                case .workout:
                    workoutSettings
                case .meal:
                    mealSettings
                case .water:
                    waterSettings
                case .general:
                    generalSettings
                }
            }
        }
    }
    
    private var workoutSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Напоминание за")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker("", selection: $waterReminderInterval) {
                Text("15 минут").tag(15)
                Text("30 минут").tag(30)
                Text("1 час").tag(60)
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 8)
    }
    
    private var mealSettings: some View {
        VStack(spacing: 16) {
            timePickerRow(title: "Завтрак", time: $breakfastTime)
            timePickerRow(title: "Обед", time: $lunchTime)
            timePickerRow(title: "Ужин", time: $dinnerTime)
            
            Button("Установить напоминания") {
                scheduleMealReminders()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }
    
    private var waterSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Интервал напоминаний")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker("", selection: $waterReminderInterval) {
                Text("1 час").tag(1)
                Text("2 часа").tag(2)
                Text("3 часа").tag(3)
            }
            .pickerStyle(.segmented)
            
            Button("Установить") {
                scheduleWaterReminder()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }
    
    private var generalSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Эти уведомления включают:\n• Новости и обновления\n• Советы по тренировкам\n• Мотивационные сообщения")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
        }
    }
    
    private var scheduledNotificationsSection: some View {
        Section {
            if notificationService.scheduledNotifications.isEmpty {
                Text("Нет запланированных уведомлений")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(notificationService.scheduledNotifications, id: \.identifier) { notification in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(notification.content.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(notification.content.body)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        if let trigger = notification.trigger as? UNCalendarNotificationTrigger,
                           let nextTriggerDate = trigger.nextTriggerDate() {
                            Text("Следующее: \(nextTriggerDate.formatted(date: .omitted, time: .shortened))")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Button("Отменить все") {
                    Task {
                        await notificationService.cancelAllNotifications()
                    }
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        } header: {
            Text("Запланированные уведомления")
        }
    }
    
    private var statusTitle: String {
        switch notificationService.permissionStatus {
        case .authorized:
            return "Уведомления разрешены"
        case .denied:
            return "Уведомления запрещены"
        case .notDetermined:
            return "Разрешение не запрошено"
        case .provisional:
            return "Предварительный доступ"
        case .ephemeral:
            return "Временный доступ"
        @unknown default:
            return "Неизвестный статус"
        }
    }
    
    private var statusDescription: String {
        switch notificationService.permissionStatus {
        case .authorized:
            return "Вы будете получать важные напоминания"
        case .denied:
            return "Разрешите уведомления в настройках iOS"
        case .notDetermined:
            return "Нажмите кнопку чтобы разрешить"
        default:
            return ""
        }
    }
    
    private func timePickerRow(title: String, time: Binding<Date>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            
            DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
    }
    
    private func handlePreferenceChange(type: NotificationType, isEnabled: Bool) {
        print("\(type.rawValue) уведомления: \(isEnabled ? "включены" : "выключены")")
        
        if !isEnabled {
            Task {
                switch type {
                case .workout:
                    await notificationService.cancelNotification(identifier: "workout_reminder")
                case .meal:
                    await notificationService.cancelNotification(identifier: "breakfast_reminder")
                    await notificationService.cancelNotification(identifier: "lunch_reminder")
                    await notificationService.cancelNotification(identifier: "dinner_reminder")
                case .water:
                    await notificationService.cancelNotification(identifier: "water_reminder")
                case .general:
                    // Общие уведомления не отменяем
                    break
                }
            }
        }
    }
    
    private func scheduleMealReminders() {
        Task {
            let _ = await notificationService.scheduleMealReminder(
                time: breakfastTime,
                mealType: "Завтрак",
                reminderText: "Время завтракать! 🍳"
            )
            
            let _ = await notificationService.scheduleMealReminder(
                time: lunchTime,
                mealType: "Обед",
                reminderText: "Пора обедать! 🍲"
            )
            
            let _ = await notificationService.scheduleMealReminder(
                time: dinnerTime,
                mealType: "Ужин",
                reminderText: "Время ужинать! 🍽️"
            )
        }
    }
    
    private func scheduleWaterReminder() {
        Task {
            let _ = await notificationService.scheduleWaterReminder(every: waterReminderInterval)
        }
    }
}

#if DEBUG
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationSettingsView()
        }
    }
}
#endif
