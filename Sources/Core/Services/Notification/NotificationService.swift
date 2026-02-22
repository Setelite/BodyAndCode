//
//  NotificationService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

// Sources/Core/Services/Notification/NotificationService.swift
import Foundation
import UserNotifications
import UIKit
import Combine

@MainActor
class NotificationService: NSObject, ObservableObject {
    var objectWillChange: ObservableObjectPublisher
    
    static let shared = NotificationService()
    
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var scheduledNotifications: [UNNotificationRequest] = []
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        self.objectWillChange = ObservableObjectPublisher()
        super.init()
        notificationCenter.delegate = self
        // Cannot call async functions here!
        // Call prepare() after creating the instance instead.
    }
    
    /// Call this once after creating the instance to finish async setup
    func prepare() async {
        await loadScheduledNotifications()
    }
    
    // MARK: - Запрос разрешения
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            
            await MainActor.run {
                self.permissionStatus = granted ? .authorized : .denied
            }
            
            if granted {
                print("✅ Уведомления разрешены")
                await registerForRemoteNotifications()
            } else {
                print("❌ Уведомления запрещены")
            }
            
            return granted
        } catch {
            print("❌ Ошибка запроса разрешения: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Проверка статуса
    func checkPermissionStatus() async {
        let settings = await notificationCenter.notificationSettings()
        
        await MainActor.run {
            self.permissionStatus = settings.authorizationStatus
        }
        
        if settings.authorizationStatus == .authorized {
            await loadScheduledNotifications()
        }
    }
    
    // MARK: - Напоминание о тренировке
    func scheduleWorkoutReminder(
        date: Date,
        title: String,
        body: String,
        workoutId: String? = nil
    ) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        // Добавляем userInfo для идентификации
        if let workoutId = workoutId {
            content.userInfo = ["workoutId": workoutId, "type": "workout_reminder"]
        }
        
        // Создаем триггер (за 15 минут до тренировки)
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -15, to: date) ?? date
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        // Создаем уникальный идентификатор
        let identifier = "workout_reminder_\(workoutId ?? UUID().uuidString)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            print("✅ Напоминание о тренировке запланировано на \(date)")
            await loadScheduledNotifications()
            return true
        } catch {
            print("❌ Ошибка планирования уведомления: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Напоминание о приеме пищи
    func scheduleMealReminder(
        time: Date,
        mealType: String,
        reminderText: String = "Пора поесть!"
    ) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = "🍎 \(mealType)"
        content.body = reminderText
        content.sound = .default
        content.userInfo = ["type": "meal_reminder", "mealType": mealType]
        
        // Ежедневное повторение
        let triggerComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        
        let identifier = "meal_reminder_\(mealType)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            print("✅ Напоминание о приеме пищи запланировано на \(time)")
            await loadScheduledNotifications()
            return true
        } catch {
            print("❌ Ошибка планирования уведомления: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Напоминание о воде
    func scheduleWaterReminder(every hours: Int = 2) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = "💧 Время пить воду"
        content.body = "Не забывайте пить воду в течение дня"
        content.sound = .default
        content.userInfo = ["type": "water_reminder"]
        
        // Создаем триггер на каждые N часов
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(hours * 60 * 60), repeats: true)
        
        let identifier = "water_reminder"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            print("✅ Напоминание о воде запланировано каждые \(hours) часов")
            await loadScheduledNotifications()
            return true
        } catch {
            print("❌ Ошибка планирования уведомления: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Отмена уведомлений
    func cancelNotification(identifier: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        await loadScheduledNotifications()
        print("✅ Уведомление отменено: \(identifier)")
    }
    
    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        await MainActor.run {
            self.scheduledNotifications = []
        }
        print("✅ Все уведомления отменены")
    }
    
    // MARK: - Загрузка запланированных уведомлений
    private func loadScheduledNotifications() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        
        await MainActor.run {
            self.scheduledNotifications = requests
        }
    }
    
    // MARK: - Регистрация для пуш-уведомлений (если понадобится)
    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    // Вызывается когда уведомление получено и приложение активно
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        print("📲 Уведомление получено: \(notification.request.content.title)")
        
        // Показываем уведомление даже если приложение активно
        return [.banner, .sound, .badge]
    }
    
    // Вызывается когда пользователь тапает по уведомлению
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        
        print("👆 Пользователь тапнул по уведомлению: \(userInfo)")
        
        // Обработка разных типов уведомлений
        if let type = userInfo["type"] as? String {
            switch type {
            case "workout_reminder":
                if let workoutId = userInfo["workoutId"] as? String {
                    handleWorkoutReminderTap(workoutId: workoutId)
                }
            case "meal_reminder":
                if let mealType = userInfo["mealType"] as? String {
                    handleMealReminderTap(mealType: mealType)
                }
            case "water_reminder":
                handleWaterReminderTap()
            default:
                break
            }
        }
        
        // Сбрасываем бейдж
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(0)
        } catch {
            print("⚠️ Не удалось сбросить бейдж: \(error.localizedDescription)")
        }
    }
    
    private func handleWorkoutReminderTap(workoutId: String) {
        // Здесь можно открыть экран тренировки
        print("📌 Открываем тренировку с ID: \(workoutId)")
        // Post notification для навигации
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenWorkoutFromNotification"),
            object: nil,
            userInfo: ["workoutId": workoutId]
        )
    }
    
    private func handleMealReminderTap(mealType: String) {
        // Здесь можно открыть экран питания
        print("📌 Открываем прием пищи: \(mealType)")
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenNutritionFromNotification"),
            object: nil,
            userInfo: ["mealType": mealType]
        )
    }
    
    private func handleWaterReminderTap() {
        // Здесь можно открыть экран воды
        print("📌 Открываем трекер воды")
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenWaterTrackerFromNotification"),
            object: nil
        )
    }
}

// MARK: - Вспомогательные структуры
enum NotificationType: String, CaseIterable {
    case workout = "Тренировки"
    case meal = "Питание"
    case water = "Вода"
    case general = "Общие"
    
    var icon: String {
        switch self {
        case .workout: return "dumbbell.fill"
        case .meal: return "fork.knife"
        case .water: return "drop.fill"
        case .general: return "bell.fill"
        }
    }
}

struct NotificationPreference: Identifiable {
    let id = UUID()
    let type: NotificationType
    var isEnabled: Bool
    let description: String
}
