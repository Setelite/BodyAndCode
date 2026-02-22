//
//  CoachDetailView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/1/25.
//

//
//  CoachDetailView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV
//

import SwiftUI

struct CoachDetailView: View {
    let coach: Coach
    @Binding var path: NavigationPath  // ← обязательно для навигации через path
    
    // Выбор типа тренировки
    @State private var selectedTrainingType: TrainingType = .individual  // дефолтный тип
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Аватар
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(String(coach.name.prefix(1)))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 10)
                
                // MARK: - Имя и специализация
                VStack(spacing: 6) {
                    Text(coach.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(coach.specialization)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Статистика
                HStack(spacing: 30) {
                    statView(value: String(format: "%.1f", coach.rating), title: "Рейтинг")
                    statView(value: "\(coach.reviewCount)", title: "Отзывов")
                    statView(value: coach.experience, title: "Опыт")
                }
                .padding(.vertical)
                
                // MARK: - Выбор типа тренировки (новое!)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Выберите тип тренировки")
                        .font(.headline)
                    
                    Picker("Тип тренировки", selection: $selectedTrainingType) {
                        ForEach(TrainingType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // MARK: - Подробное описание
                VStack(alignment: .leading, spacing: 12) {
                    Text("О тренере")
                        .font(.headline)
                    
                    Text(coach.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Label("Специализация: \(coach.specialization)",
                          systemImage: "figure.strengthtraining.traditional")
                    
                    Label("Опыт работы: \(coach.experience)",
                          systemImage: "clock")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // MARK: - Квалификация
                if !coach.certifications.isEmpty || !coach.achievements.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Квалификация")
                            .font(.headline)
                        
                        ForEach(coach.certifications, id: \.self) { cert in
                            Label(cert, systemImage: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                        
                        ForEach(coach.achievements, id: \.self) { achievement in
                            Label(achievement, systemImage: "star.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
                
                // MARK: - Стоимость
                if !coach.prices.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Стоимость тренировок")
                            .font(.headline)
                        
                        ForEach(coach.prices.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { type in
                            HStack {
                                Text(type.rawValue)
                                Spacer()
                                Text("\(Int(coach.prices[type] ?? 0)) ₽")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
                
                // MARK: - Кнопка записи (правильная версия!)
                Button {
                    path.append(
                        CoachRoute.booking(
                            coachID: coach.id,
                            type: selectedTrainingType
                        )
                    )
                } label: {
                    Text("Записаться на тренировку")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.top, 12)
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Профиль тренера")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Статистика
    private func statView(value: String, title: String) -> some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        CoachDetailView(
            coach: Coach.mockData[0],
            path: .constant(NavigationPath())
        )
    }
}
