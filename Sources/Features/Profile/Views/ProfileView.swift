//
//  ProfileView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/23/25.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Профиль пользователя
                    profileHeaderSection
                    
                    // Статистика
                    profileStatsSection
                    
                    // Настройки
                    settingsSection
                    
                    // Достижения
                    achievementsSection
                    
                    // Выход
                    logoutSection
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Аватар
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text("МГ")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .shadow(color: .blue.opacity(0.3), radius: 10)
            
            // Имя и информация
            VStack(spacing: 4) {
                Text("Максим Горностаев")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("@maximgorno")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label("28 лет", systemImage: "calendar")
                        .font(.caption)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("Мужчина", systemImage: "person.fill")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            // Кнопка редактирования
            Button("Редактировать профиль") {}
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var profileStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)
            
            HStack(spacing: 16) {
                ProfileStatCard(
                    title: "Тренировок",
                    value: "48",
                    icon: "flame.fill",
                    color: .orange
                )
                
                ProfileStatCard(
                    title: "Дней подряд",
                    value: "21",
                    icon: "calendar.badge.clock",
                    color: .green
                )
                
                ProfileStatCard(
                    title: "Сожжено ккал",
                    value: "18.5K",
                    icon: "bolt.fill",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Настройки")
                .font(.headline)
            
            VStack(spacing: 0) {
                NavigationLink(destination: NotificationSettingsView()) {
                    SettingsRow(
                        title: "Уведомления",
                        icon: "bell.fill",
                        color: .blue
                    )
                }
                
                Divider()
                
                SettingsRow(
                    title: "Цели и задачи",
                    icon: "target",
                    color: .green
                )
                
                Divider()
                
                SettingsRow(
                    title: "Приватность",
                    icon: "lock.fill",
                    color: .purple
                )
                
                Divider()
                
                SettingsRow(
                    title: "О приложении",
                    icon: "info.circle.fill",
                    color: .gray
                )
            }
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Достижения")
                    .font(.headline)
                
                Spacer()
                
                Button("Все") {}
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    AchievementBadge(
                        title: "Новичок",
                        icon: "star.fill",
                        color: .blue,
                        isUnlocked: true
                    )
                    
                    AchievementBadge(
                        title: "21 день",
                        icon: "flame.fill",
                        color: .orange,
                        isUnlocked: true
                    )
                    
                    AchievementBadge(
                        title: "Мастер",
                        icon: "crown.fill",
                        color: .yellow,
                        isUnlocked: false
                    )
                    
                    AchievementBadge(
                        title: "Марафонец",
                        icon: "figure.run",
                        color: .green,
                        isUnlocked: true
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var logoutSection: some View {
        Button(action: viewModel.logout) {
            HStack {
                Spacer()
                Text("Выйти")
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// Компоненты для ProfileView

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
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

struct SettingsRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.caption)
                )
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(isUnlocked ? color.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isUnlocked ? color : .gray)
                )
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? .primary : .gray)
        }
        .frame(width: 90)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
        .opacity(isUnlocked ? 1 : 0.6)
    }
}

// ViewModel для Profile
class ProfileViewModel: ObservableObject {
    func logout() {
        print("Выход из аккаунта")
        // Здесь будет логика выхода
    }
}

// Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Аккаунт") {
                    NavigationLink("Редактировать профиль") {
                        Text("Редактирование профиля")
                    }
                    
                    NavigationLink("Изменить пароль") {
                        Text("Изменение пароля")
                    }
                }
                
                Section("Приложение") {
                    Toggle("Уведомления", isOn: .constant(true))
                    Toggle("Темная тема", isOn: .constant(false))
                    Picker("Единицы измерения", selection: .constant(0)) {
                        Text("Метрические").tag(0)
                        Text("Имперские").tag(1)
                    }
                }
                
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Политика конфиденциальности") {}
                    Button("Условия использования") {}
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Stub for NotificationSettingsView for compilation
/*struct NotificationSettingsView: View {
    var body: some View {
        Text("Настройки уведомлений")
    }
}*/

#Preview {
    ProfileView()
}
