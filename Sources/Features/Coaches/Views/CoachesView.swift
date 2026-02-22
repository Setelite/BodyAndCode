//
//  CoachesView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

//
//  CoachesView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV
//

import SwiftUI

struct CoachesView: View {
    @StateObject private var viewModel = CoachListViewModel()
    @State private var searchText = ""
    
    // Управление навигацией
    @State private var path = NavigationPath()
    
    // Отдельное состояние для алерта об ошибке
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack(path: $path) {
            content
        }
        .onAppear {
            Task {
                if viewModel.coaches.isEmpty {
                    await viewModel.loadCoaches()
                }
            }
        }
        // Алерт ошибки
        .alert("Ошибка", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
        // Синхронизация состояния алерта
        .onChange(of: viewModel.errorMessage) { newValue in
            showErrorAlert = newValue != nil
        }
        .onChange(of: showErrorAlert) { newValue in
            if !newValue {
                viewModel.errorMessage = nil
            }
        }
    }
    
    // MARK: - Вспомогательные представления

    private var content: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.coaches.isEmpty && !viewModel.isLoading {
                emptyView
            } else {
                coachesListView
            }
        }
        .navigationTitle("Тренеры")
        .searchable(text: $searchText, prompt: "Поиск тренеров")
        .onChange(of: searchText) { newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.loadCoaches()
                }
            } else {
                viewModel.searchCoaches(query: newValue)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                filterMenu
            }
        }
        // Обработка всех маршрутов
        .navigationDestination(for: CoachRoute.self) { route in
            destinationView(for: route)
        }
    }

    @ViewBuilder
    private func destinationView(for route: CoachRoute) -> some View {
        switch route {
        case .list:
            EmptyView()

        case .detail(let coachID):
            if let coach = viewModel.coaches.first(where: { $0.id == coachID }) {
                CoachDetailView(coach: coach, path: $path)
            } else {
                Text("Тренер не найден")
                    .navigationTitle("Ошибка")
            }

        case .booking(let coachID, let type):
            if let coach = viewModel.coaches.first(where: { $0.id == coachID }) {
                BookingView(coach: coach, selectedType: type)
                    .navigationTitle("Запись на тренировку")
            } else {
                Text("Ошибка бронирования")
                    .navigationTitle("Ошибка")
            }

        case .reviews(let coachID):
            if let coach = viewModel.coaches.first(where: { $0.id == coachID }) {
                CoachReviewsView(coach: coach)
            } else {
                Text("Тренер не найден")
                    .navigationTitle("Ошибка")
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Загружаем список тренеров...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Тренеры не найдены")
                .font(.headline)
            
            Text("Попробуйте изменить параметры поиска")
                .foregroundColor(.secondary)
            
            Button("Обновить") {
                Task {
                    await viewModel.loadCoaches()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var coachesListView: some View {
        List {
            ForEach(viewModel.coaches) { coach in
                Button {
                    path.append(CoachRoute.detail(coachID: coach.id))
                } label: {
                    CoachRow(coach: coach)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filterMenu: some View {
        Menu {
            Button("Рейтинг 4.5+") {
                viewModel.filterByMinRating(4.5)
            }
            Button("Рейтинг 4.8+") {
                viewModel.filterByMinRating(4.8)
            }
            Divider()
            Button("Сбросить фильтры") {
                Task {
                    await viewModel.loadCoaches()
                }
                searchText = ""
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title3)
        }
    }
}

// MARK: - CoachRow (оставляем без изменений)
struct CoachRow: View {
    let coach: Coach
    
    var body: some View {
        HStack(spacing: 16) {
            // Аватар
            Circle()
                .fill(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(coach.name.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Информация
            VStack(alignment: .leading, spacing: 6) {
                Text(coach.name)
                    .font(.headline)
                
                Text(coach.specialization)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%.1f", coach.rating))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(coach.reviewCount) отзывов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Бейдж опыта
            Text(coach.experience)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CoachesView()
}
