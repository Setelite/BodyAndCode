// Sources/Application/App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appCoordinator = AppCoordinator()
    @State private var shouldShowWelcome = true
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.currentUser?.role == .coach {
                    CoachCabinetView()
                        .environmentObject(authViewModel)
                } else {
                    MainTabView()
                        .environmentObject(appCoordinator)
                }
            } else if shouldShowWelcome {
                WelcomeView {
                    shouldShowWelcome = false
                }
            } else {
                AuthFlowView()
            }
        }
        .environmentObject(authViewModel)
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if !isAuthenticated {
                shouldShowWelcome = true
            }
        }
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
