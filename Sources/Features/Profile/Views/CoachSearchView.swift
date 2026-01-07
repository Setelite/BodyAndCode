//
//  CoachSearchView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/30/25.
//

import SwiftUI

struct CoachSearchView: View {
    @StateObject private var service = CoachClientService()
    @State private var searchText = ""
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            VStack {
                searchField
                
                if service.isLoading {
                    ProgressView("Поиск тренеров...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    coachesList
                }
            }
            .navigationTitle("Поиск тренеров")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Имя тренера или специализация...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: searchText) { newValue in
                    if newValue.count > 2 {
                        service.searchCoaches(query: newValue)
                    } else if newValue.isEmpty {
                        service.searchCoaches(query: "")
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    service.searchCoaches(query: "")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var coachesList: some View {
        List {
            ForEach(service.coaches) { coach in
                CoachCardView(coach: coach) {
                    showCoachDetail(coach)
                }
            }
        }
    }
    
    private func showCoachDetail(_ coach: User) {
        // TODO: Перейти к деталям тренера
        print("Показать детали тренера: \(coach.name)")
    }
}

// MARK: - Coach Card View
struct CoachCardView: View {
    let coach: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Аватар тренера
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                }
                
                // Информация о тренере
                VStack(alignment: .leading, spacing: 4) {
                    Text(coach.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let specialization = coach.specialization {
                        Text(specialization)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        if let experience = coach.experience {
                            Label("\(experience) лет опыта", systemImage: "star.fill")
                                .font(.caption)
                        }
                        
                        Text(coach.role.localized)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
