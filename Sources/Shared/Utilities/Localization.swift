//
//  Localization.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/23/25.
//

import Foundation

class Localization {
    static let shared = Localization()
    
    private var russianStrings: [String: String] = [
        // Common
        "save": "Сохранить",
        "cancel": "Отмена",
        "delete": "Удалить",
        "edit": "Редактировать",
        "done": "Готово",
        "loading": "Загрузка...",
        "yes": "Да",
        "no": "Нет",
        
        // Auth
        "login": "Вход",
        "register": "Регистрация",
        "email": "Email",
        "password": "Пароль",
        "name": "Имя",
        "welcome": "Добро пожаловать",
        "logout": "Выйти",
        
        // Roles
        "client": "Клиент",
        "coach": "Тренер",
        
        // Workout
        "workout": "Тренировка",
        "workouts": "Тренировки",
        "exercise": "Упражнение",
        "exercises": "Упражнения",
        "set": "Подход",
        "sets": "Подходы",
        "reps": "Повторения",
        "weight": "Вес",
        "startWorkout": "Начать тренировку",
        "todayWorkout": "Тренировка на сегодня",
        "workoutHistory": "История тренировок",
        "finishWorkout": "Завершить тренировку",
        "workoutCompleted": "Тренировка завершена! 🎉",
        "noWorkoutPlanned": "Тренировка не запланирована",
        "activeWorkout": "Активная тренировка",
        
        // Progress
        "progress": "Прогресс",
        "statistics": "Статистика",
        "charts": "Графики",
        "bodyWeight": "Вес тела",
        "personalRecords": "Личные рекорды",
        "progressOverview": "Обзор прогресса",
        
        // Nutrition
        "nutrition": "Питание",
        "meals": "Приемы пищи",
        "calories": "Калории",
        "proteins": "Белки",
        "carbs": "Углеводы",
        "fats": "Жиры",
        "nutritionPlan": "План питания",
        
        // Profile
        "profile": "Профиль",
        "settings": "Настройки",
        "myProfile": "Мой профиль",
        
        // Muscle Groups
        "chest": "Грудь",
        "back": "Спина",
        "legs": "Ноги",
        "shoulders": "Плечи",
        "arms": "Руки",
        "core": "Пресс",
        "fullBody": "Все тело",
        
        // Days of week
        "monday": "Понедельник",
        "tuesday": "Вторник",
        "wednesday": "Среда",
        "thursday": "Четверг",
        "friday": "Пятница",
        "saturday": "Суббота",
        "sunday": "Воскресенье",
        
        // Difficulty
        "easy": "Легко",
        "medium": "Средне",
        "hard": "Тяжело",
        "failure": "Отказ"
    ]
    
    func string(for key: String) -> String {
        return russianStrings[key] ?? key
    }
}

// Shortcut function
func NSLocalizedString(_ key: String) -> String {
    return Localization.shared.string(for: key)
}

// String extension for easy access
extension String {
    var localized: String {
        return NSLocalizedString(self)
    }
}
