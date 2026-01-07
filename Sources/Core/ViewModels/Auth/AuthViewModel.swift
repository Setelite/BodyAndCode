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
            } else {
                self.errorMessage = "Invalid email or password"
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
    
    // MARK: - Initialization
    init() {
        // Для тестирования - можно установить true
        self.isAuthenticated = false
    }
}
