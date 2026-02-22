//
//  AuthViewModel.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/22/25.
//

import SwiftUI
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Authentication Methods
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // Имитация сетевого запроса
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            if email == "user@example.com" && password == "password" {
                self.isAuthenticated = true
                self.currentUser = User(
                    id: UUID(),
                    name: "Test User",
                    email: email,
                    role: .client,
                    currentWeight: 75.0,
                    goalWeight: 70.0,
                    createdAt: Date()
                )
            } else if email == "coach@example.com" && password == "password" {
                self.isAuthenticated = true
                self.currentUser = User(
                    id: UUID(),
                    name: "Coach User",
                    email: email,
                    role: .coach,
                    currentWeight: nil,
                    goalWeight: nil,
                    createdAt: Date()
                )
            } else {
                self.errorMessage = "Неверный email или пароль"
            }
        }
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
    }
    
    func register(name: String, email: String, password: String, role: UserRole) {
        isLoading = true
        errorMessage = nil
        
        // Имитация регистрации
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            self.isAuthenticated = true
            self.currentUser = User(
                id: UUID(),
                name: name,
                email: email,
                role: role,
                currentWeight: nil,
                goalWeight: nil,
                createdAt: Date()
            )
        }
    }

    @discardableResult
    func updateCurrentUser(_ transform: (inout User) -> Void) -> User? {
        guard var user = currentUser else { return nil }
        transform(&user)
        currentUser = user
        return user
    }

    @discardableResult
    func updateCoachProfile(
        name: String,
        email: String,
        specialization: String?,
        experience: Int?,
        bio: String?
    ) -> User? {
        updateCurrentUser { user in
            user.name = name
            user.email = email
            user.specialization = specialization
            user.experience = experience
            user.bio = bio
        }
    }
    
    // MARK: - Initialization
    init() {
        // Для тестирования - можно установить true
        self.isAuthenticated = false
    }
}
