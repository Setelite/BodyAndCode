// Sources/Application/App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appCoordinator = AppCoordinator()
    @State private var shouldShowWelcome = true
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            backgroundGradient
                .opacity(colorScheme == .dark ? 0.28 : 0.45)
                .ignoresSafeArea()

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
        }
        .environmentObject(authViewModel)
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            if !isAuthenticated {
                shouldShowWelcome = true
            }
        }
    }

    private var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.18),
                    Color(red: 0.13, green: 0.15, blue: 0.24),
                    Color(red: 0.16, green: 0.13, blue: 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return .appGlassGradient
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
        .accentColor(.glassBlue)
    }
}
