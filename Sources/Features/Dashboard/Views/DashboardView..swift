//
//  DashboardView..swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/22/25.
//

// Sources/Features/Dashboard/Views/DashboardView.swift
import SwiftUI

struct DashboardView: View {
    @State private var selectedDate = Date()
    @State private var showingStats = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Приветствие
                    headerSection
                    
                    // Быстрый доступ
                    quickActionsSection
                    
                    // Статистика
                    statsSection
                    
                    // Активные тренировки
                    activeWorkoutsSection
                    
                    // Советы дня
                    dailyTipsSection
                }
                .padding()
            }
            .navigationTitle("Главная")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Привет, Максим!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Готов к тренировке?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Быстрый доступ")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    title: "Новая тренировка",
                    icon: "plus.circle.fill",
                    color: .blue,
                    action: {}
                )
                
                QuickActionButton(
                    title: "Мой прогресс",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green,
                    action: { showingStats = true }
                )
                
                QuickActionButton(
                    title: "Питание",
                    icon: "leaf.fill",
                    color: .orange,
                    action: {}
                )
                
                QuickActionButton(
                    title: "Расписание",
                    icon: "calendar",
                    color: .purple,
                    action: {}
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ваша статистика")
                    .font(.headline)
                
                Spacer()
                
                Text("За неделю")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Тренировки",
                    value: "8",
                    icon: "flame.fill",
                    color: .orange,
                    change: "+2"
                )
                
                StatCard(
                    title: "Калории",
                    value: "4,280",
                    icon: "bolt.fill",
                    color: .red,
                    change: "+12%"
                )
                
                StatCard(
                    title: "Вес",
                    value: "74 кг",
                    icon: "scalemass.fill",
                    color: .blue,
                    change: "-1.5"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var activeWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Активные тренировки")
                    .font(.headline)
                
                Spacer()
                
                Button("Все") {}
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    WorkoutCard(
                        title: "Силовая",
                        duration: "45 мин",
                        calories: "320",
                        color: .blue
                    )
                    
                    WorkoutCard(
                        title: "Кардио",
                        duration: "30 мин",
                        calories: "280",
                        color: .red
                    )
                    
                    WorkoutCard(
                        title: "Йога",
                        duration: "60 мин",
                        calories: "180",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var dailyTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Совет дня")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
            }
            
            Text("Пейте достаточно воды во время тренировки. 500мл за 2 часа до тренировки и по 150-200мл каждые 15 минут во время занятия.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// Компоненты для Dashboard
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let change: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(change)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(change.hasPrefix("+") ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(change.hasPrefix("+") ? .green : .red)
                    .cornerRadius(4)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

struct WorkoutCard: View {
    let title: String
    let duration: String
    let calories: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                HStack {
                    Label(duration, systemImage: "clock")
                        .font(.caption)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(calories) ккал", systemImage: "flame")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Button("Начать") {}
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    DashboardView()
}
