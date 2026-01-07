//
//  WorkoutListView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/22/25.
//

import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            List {
                Section("Тренировка на сегодня") {
                    NavigationLink(destination: ActiveWorkoutView()) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.green)
                            VStack(alignment: .leading) {
                                Text("Начать сегодняшнюю тренировку")
                                    .fontWeight(.semibold)
                                Text("Грудь и Трицепс • 45 мин")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("Быстрые действия") {
                    Button("Создать свою тренировку") {
                        // TODO: Перейти к созданию тренировки
                    }
                    
                    Button("Библиотека упражнений") {
                        // TODO: Перейти к библиотеке упражнений
                    }
                }
                
                Section("Недавние тренировки") {
                    Text("Понедельник - День ног")
                    Text("Пятница - Верхняя часть тела")
                    Text("Прошлая неделя - Все тело")
                }
            }
            
            
            Section("История тренировок") {
                NavigationLink(destination: WorkoutHistoryView()) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("Просмотр истории")
                            .fontWeight(.medium)
                    }
                }
            }
            
            
            .navigationTitle("Тренировки")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("История") {
                        appCoordinator.showWorkoutHistory()
                    }
                }
            }
        }
    }
}
