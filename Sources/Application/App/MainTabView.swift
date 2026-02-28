//
//  MainTabView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Application/App/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var coachClientService = CoachClientService()
    @StateObject private var chatStore = CoachClientChatStore.shared
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

            ClientChatsTabView()
                .tabItem {
                    Label(
                        unreadCoachMessagesCount > 0 ? "Чат (\(unreadCoachMessagesCount))" : "Чат",
                        systemImage: "bubble.left.and.bubble.right.fill"
                    )
                }
                .tag(3)
            
            // Питание
            NutritionView()
                .tabItem {
                    Label("Питание", systemImage: "leaf.fill")
                }
                .tag(4)
            
            // Профиль
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
                .tag(5)
        }
        .accentColor(.glassBlue) // Цвет акцента
        .onAppear {
            if let user = authViewModel.currentUser {
                coachClientService.setCurrentUser(user)
            }
        }
    }

    private var unreadCoachMessagesCount: Int {
        guard let viewer = authViewModel.currentUser,
              let coach = coachClientService.coachForClient(viewer.id) else { return 0 }
        return chatStore.unreadCount(for: viewer.id, coachId: coach.id, clientId: viewer.id)
    }
}

private struct ClientChatsTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var coachClientService = CoachClientService()
    @StateObject private var chatStore = CoachClientChatStore.shared

    var body: some View {
        NavigationStack {
            List {
                if let currentUser = authViewModel.currentUser,
                   let coach = coachClientService.coachForClient(currentUser.id) {
                    NavigationLink {
                        CoachClientChatScreen(
                            coach: coach,
                            client: currentUser,
                            viewer: currentUser
                        )
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.indigo.opacity(0.2))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Text(initials(from: coach.name))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.indigo)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(coach.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(lastMessagePreview(coachId: coach.id, clientId: currentUser.id))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()
                            let unread = chatStore.unreadCount(
                                for: currentUser.id,
                                coachId: coach.id,
                                clientId: currentUser.id
                            )
                            if unread > 0 {
                                Text("\(unread)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 6)
                    }
                } else {
                    Text("Тренер пока не назначен")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Чат")
            .onAppear {
                if let user = authViewModel.currentUser {
                    coachClientService.setCurrentUser(user)
                }
            }
        }
    }

    private func lastMessagePreview(coachId: UUID, clientId: UUID) -> String {
        guard let last = chatStore.lastMessage(coachId: coachId, clientId: clientId) else {
            return "Начните диалог"
        }
        if !last.text.isEmpty {
            return last.text
        }
        return "Вложение"
    }

    private func initials(from fullName: String) -> String {
        fullName.split(separator: " ").prefix(2).map { String($0.prefix(1)).uppercased() }.joined()
    }
}
