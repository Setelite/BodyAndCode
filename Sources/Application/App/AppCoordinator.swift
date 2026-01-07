//
//  AppCoordinator.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/19/25.
//
import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var navigationPath = NavigationPath()
    @Published var selectedTab: AppTab = .dashboard
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    // MARK: - App Routes
    enum Route: Hashable {
        case login
        case dashboard
        case workoutDetail(workoutId: UUID)
        case workoutHistory
        case exerciseDetail(exerciseId: UUID)
        case exerciseHistory(exerciseId: UUID)
        case nutritionPlan
        case profile
        case settings
        case weightTracking
        case workoutActive
        case coachSearch
        case coachDetail(coachId: UUID)    }
    
    // MARK: - App Tabs
    enum AppTab: CaseIterable {
        case dashboard
        case workout
        case coaches
        case nutrition
        case profile
        
        var title: String {
            switch self {
            case .dashboard: return "Главная"
            case .workout: return "Тренировки"
            case .coaches: return "Тренеры"
            case .nutrition: return "Питание"
            case .profile: return "Профиль"
            }
        }
        
        var icon: String {
            switch self {
            case .dashboard: return "chart.line.uptrend.xyaxis"
            case .workout: return "dumbbell"
            case .coaches: return "person.2.circlepath.circle"
            case .nutrition: return "fork.knife"
            case .profile: return "person.circle"
            }
        }
    }
    
    // MARK: - Navigation Methods
    func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    // MARK: - Specific Navigation Methods
    
    // Workout Navigation
    func showWorkoutDetail(_ workoutId: UUID) {
        navigate(to: .workoutDetail(workoutId: workoutId))
    }
    
    func showWorkoutHistory() {
        navigate(to: .workoutHistory)
    }
    
    func showActiveWorkout() {
        navigate(to: .workoutActive)
    }
    
    // Exercise Navigation
    func showExerciseDetail(_ exerciseId: UUID) {
        navigate(to: .exerciseDetail(exerciseId: exerciseId))
    }
    
    func showExerciseHistory(_ exerciseId: UUID) {
        navigate(to: .exerciseHistory(exerciseId: exerciseId))
    }
    
    // Profile Navigation
    func showWeightTracking() {
        navigate(to: .weightTracking)
    }
    
    func showSettings() {
        navigate(to: .settings)
    }
    
    func showNutritionPlan() {
        navigate(to: .nutritionPlan)
    }
    
    // Auth Navigation
    func showLogin() {
        navigate(to: .login)
        selectedTab = .dashboard
    }
    
    func showDashboard() {
        navigate(to: .dashboard)
        selectedTab = .dashboard
    }
    
    func showCoachSearch() {
        navigate(to: .coachSearch)
    }

    func showCoachDetail(_ coachId: UUID) {
        navigate(to: .coachDetail(coachId: coachId))
    }

    // MARK: - Tab Management
    func switchToTab(_ tab: AppTab) {
        selectedTab = tab
        popToRoot() // Сбрасываем навигацию при переключении табов
    }
    
    func switchToWorkoutWithHistory() {
        selectedTab = .workout
        showWorkoutHistory()
    }
    
    func switchToProfileWithWeightTracking() {
        selectedTab = .profile
        showWeightTracking()
    }
    
    // MARK: - Complex Navigation Flows
    
    func startNewWorkout() {
        selectedTab = .workout
        showActiveWorkout()
    }
    
    func viewExerciseProgress(_ exerciseId: UUID) {
        selectedTab = .dashboard
        showExerciseHistory(exerciseId)
    }
    
    func viewWorkoutDetails(_ workoutId: UUID) {
        selectedTab = .workout
        showWorkoutDetail(workoutId)
    }
    
    // MARK: - Loading State
    func showLoading() {
        isLoading = true
    }
    
    func hideLoading() {
        isLoading = false
    }
    
    // MARK: - Alerts
    func showAlert(_ alertItem: AlertItem) {
        self.alertItem = alertItem
    }
    
    func showError(_ message: String) {
        showAlert(AlertItem(
            title: "Ошибка",
            message: message,
            primaryButton: .default(Text("OK"))
        ))
    }
    
    func showSuccess(_ message: String) {
        showAlert(AlertItem(
            title: "Успех",
            message: message,
            primaryButton: .default(Text("OK"))
        ))
    }
    
    func showConfirmation(_ title: String, message: String? = nil, action: @escaping () -> Void) {
        showAlert(AlertItem(
            title: title,
            message: message,
            primaryButton: .default(Text("Да"), action: action),
            secondaryButton: .cancel(Text("Нет"))
        ))
    }
    
    // MARK: - Initialization
    init() {
        // Инициализация координатора
        print("AppCoordinator initialized")
    }
}

// MARK: - Alert Item
struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?
    
    init(title: String, message: String? = nil, primaryButton: Alert.Button, secondaryButton: Alert.Button? = nil) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

// MARK: - Environment Key
struct AppCoordinatorKey: EnvironmentKey {
    static let defaultValue: AppCoordinator? = nil
}

extension EnvironmentValues {
    var appCoordinator: AppCoordinator? {
        get { self[AppCoordinatorKey.self] }
        set { self[AppCoordinatorKey.self] = newValue }
    }
}

// MARK: - View Extensions for Navigation
extension View {
    func withAppCoordinator() -> some View {
        self.environmentObject(AppCoordinator())
    }
}
