//
//  WorkoutView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var programStore = TrainingProgramStore()
    @State private var selectedCategory = "Все"
    @State private var showingCreateWorkout = false
    
    let categories = ["Все", "Силовые", "Кардио", "Йога", "Домашние"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Категории
                    categoriesSection

                    // Программы от тренера
                    coachProgramsSection
                    
                    // Популярные тренировки
                    popularWorkoutsSection
                    
                    // Ваши тренировки
                    yourWorkoutsSection
                    
                    // Рекомендации
                    recommendationsSection
                }
                .padding()
            }
            .navigationTitle("Тренировки")
            .background(LinearGradient.appGlassGradient.opacity(0.42))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateWorkout = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView()
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Категории")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        CategoryChip(
                            title: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var coachProgramsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Программы от тренера")
                    .font(.headline)
                Spacer()
            }

            if clientAssignments.isEmpty {
                Text("Тренер пока не назначил вам программу")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(clientAssignments) { assignment in
                        if let plan = programStore.workoutPlan(for: assignment) {
                            NavigationLink(destination: ActiveWorkoutView(presetPlan: plan)) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 42, height: 42)
                                        .overlay(
                                            Image(systemName: "list.clipboard")
                                                .foregroundColor(.blue)
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(plan.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text("\(plan.exercises.count) упражнений")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var clientAssignments: [TrainingProgramAssignment] {
        guard let clientId = authViewModel.currentUser?.id else { return [] }
        return programStore.activeAssignmentsForClient(clientId)
    }
    
    private var popularWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Популярные тренировки")
                    .font(.headline)
                
                Spacer()
                
                Button("Все") {}
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                WorkoutPlanCard(
                    title: "Full Body",
                    duration: "45 мин",
                    difficulty: "Средняя",
                    exercises: 8,
                    color: .blue
                )
                
                WorkoutPlanCard(
                    title: "Cardio Blast",
                    duration: "30 мин",
                    difficulty: "Высокая",
                    exercises: 6,
                    color: .red
                )
                
                WorkoutPlanCard(
                    title: "Yoga Flow",
                    duration: "60 мин",
                    difficulty: "Легкая",
                    exercises: 10,
                    color: .green
                )
                
                WorkoutPlanCard(
                    title: "Arms & Abs",
                    duration: "40 мин",
                    difficulty: "Средняя",
                    exercises: 7,
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var yourWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ваши тренировки")
                    .font(.headline)
                
                Spacer()
                
                Button("История") {}
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                SimpleWorkoutHistoryRow(
                    title: "Утренняя зарядка",
                    time: "Сегодня, 8:00",
                    duration: "20 мин",
                    calories: "150"
                )
                
                Divider()
                
                SimpleWorkoutHistoryRow(
                    title: "Силовая тренировка",
                    time: "Вчера, 19:30",
                    duration: "55 мин",
                    calories: "420"
                )
                
                Divider()
                
                SimpleWorkoutHistoryRow(
                    title: "Вечерняя растяжка",
                    time: "2 дня назад",
                    duration: "25 мин",
                    calories: "90"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Рекомендуем")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
            }
            
            HStack(spacing: 16) {
                RecommendationCard(
                    title: "Интервальная тренировка",
                    description: "Сжигайте больше калорий",
                    icon: "bolt.fill",
                    color: .purple
                )
                
                RecommendationCard(
                    title: "Тренировка с тренером",
                    description: "Персональный подход",
                    icon: "person.fill",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// Компоненты для WorkoutView
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct WorkoutPlanCard: View {
    let title: String
    let duration: String
    let difficulty: String
    let exercises: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "dumbbell")
                            .foregroundColor(color)
                    )
                
                Spacer()
                
                Text(difficulty)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .cornerRadius(6)
            }
            
            Text(title)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 6) {
                Label(duration, systemImage: "clock")
                    .font(.caption)
                
                Label("\(exercises) упражнений", systemImage: "list.bullet")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            Button("Начать") {}
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white.opacity(0.58))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

// RENAMED to avoid redeclaration issue with ProgressDashboardView
struct SimpleWorkoutHistoryRow: View {
    let title: String
    let time: String
    let duration: String
    let calories: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(duration)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(calories) ккал")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RecommendationCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .padding(.bottom, 4)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
            
            Button("Попробовать") {}
                .font(.caption2)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(6)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding()
        .background(Color.white.opacity(0.58))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

struct CreateWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название тренировки", text: .constant(""))
                    Picker("Тип тренировки", selection: .constant(0)) {
                        Text("Силовая").tag(0)
                        Text("Кардио").tag(1)
                        Text("Растяжка").tag(2)
                    }
                }
                
                Section("Длительность") {
                    Stepper("45 минут", value: .constant(45), in: 10...180, step: 5)
                }
                
                Section("Упражнения") {
                    // Здесь будет список упражнений
                    Text("Добавьте упражнения")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Новая тренировка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#if DEBUG
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}
#endif
