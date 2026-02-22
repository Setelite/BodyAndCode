// Sources/Application/App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appCoordinator = AppCoordinator()
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(appCoordinator)
            } else if hasSeenWelcome {
                AuthFlowView()
            } else {
                WelcomeView()
            }
        }
        .environmentObject(authViewModel)
    }
}

// В ContentView.swift, найдите MainTabView и обновите вкладку "Тренеры":
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Главная (Dashboard)
            DashboardView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
                .tag(0)
            
            // Тренировки
            WorkoutView()
                .tabItem {
                    Label("Тренировки", systemImage: "dumbbell.fill")
                }
                .tag(1)
            
            // Тренеры - ИСПОЛЬЗУЕМ НАШ РЕАЛЬНЫЙ CoachesView
            CoachesView()
                .tabItem {
                    Label("Тренеры", systemImage: "person.2.fill")
                }
                .tag(2)
            
            // Питание
            NutritionView()
                .tabItem {
                    Label("Питание", systemImage: "leaf.fill")
                }
                .tag(3)
            
            // Профиль
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}
