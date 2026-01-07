//
//  MainTabView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Application/App/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Главная
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
            
            // Тренеры (НОВЫЙ ЭКРАН)
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
        .accentColor(.blue) // Цвет акцента
    }
}
