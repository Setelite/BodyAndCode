//
//  CoachesView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Features/Coaches/Views/CoachesView.swift
import SwiftUI

struct CoachesView: View {
    @StateObject private var viewModel = CoachListViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterMenu
                }
            }
        }
        .onAppear {
            Task {
                if viewModel.coaches.isEmpty {
                    await viewModel.loadCoaches()
                }
            }
        }
        .alert("Ошибка", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
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
                NavigationLink(destination: CoachDetailView(coach: coach)) {
                    CoachRow(coach: coach)
                }
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

// MARK: - CoachRow View
struct CoachRow: View {
    let coach: Coach
    
    var body: some View {
        HStack(spacing: 16) {
            // Аватар
            coachAvatar
            
            coachInfo
            
            Spacer()
            
            experienceBadge
        }
        .padding(.vertical, 8)
    }
    
    private var coachAvatar: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .shadow(color: .blue.opacity(0.3), radius: 5)
            
            Text(String(coach.name.prefix(1)))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var coachInfo: some View {
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
    }
    
    private var experienceBadge: some View {
        Text(coach.experience)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(6)
    }
}

#Preview {
    CoachesView()
}
