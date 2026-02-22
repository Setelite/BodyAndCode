//
//  CoachCabinetView.swift
//  Body&Code
//
//  Created by Codex on 2/22/26.
//

import SwiftUI

struct CoachCabinetView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    statsCard
                    quickActionsCard
                    todayPlanCard
                    clientsCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Кабинет тренера")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Выйти") {
                        authViewModel.logout()
                    }
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Здравствуйте, \(authViewModel.currentUser?.name ?? "Тренер")")
                .font(.title3)
                .fontWeight(.bold)
            Text("Управляйте клиентами и расписанием")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    private var statsCard: some View {
        HStack(spacing: 12) {
            coachStat("Клиенты", "12")
            coachStat("Тренировки сегодня", "5")
            coachStat("Активные планы", "9")
        }
    }

    private func coachStat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Быстрые действия")
                .font(.headline)
            Button("Создать программу") {}
                .buttonStyle(.borderedProminent)
            Button("Добавить клиента") {}
                .buttonStyle(.bordered)
            Button("Открыть календарь") {}
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    private var todayPlanCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("План на сегодня")
                .font(.headline)
            Text("10:00 - Иван Петров (силовая)")
            Text("12:30 - Анна Смирнова (растяжка)")
            Text("18:00 - Групповая тренировка")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    private var clientsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Клиенты")
                .font(.headline)
            clientRow("Иван Петров", "Прогресс: +5 кг в жиме")
            clientRow("Анна Смирнова", "Прогресс: -3 кг веса")
            clientRow("Олег Крылов", "Новая программа на неделю")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    private func clientRow(_ name: String, _ progress: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(progress)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CoachCabinetView()
        .environmentObject(AuthViewModel())
}
