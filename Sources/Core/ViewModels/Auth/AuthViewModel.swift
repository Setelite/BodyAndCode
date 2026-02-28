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
    @Published var registrationSucceeded: Bool = false
    @Published var lastRegisteredEmail: String?
    private let cloudIdentity = CloudIdentityService()
    
    // MARK: - Authentication Methods
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.isEmpty, !normalizedPassword.isEmpty else {
            isLoading = false
            errorMessage = "Введите email и пароль."
            return
        }

        if cloudIdentity.isConfigured {
            Task { @MainActor in
                do {
                    let result = try await cloudIdentity.login(email: normalizedEmail, password: normalizedPassword)
                    isLoading = false
                    isAuthenticated = true
                    currentUser = result.user
                } catch {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
            return
        }

        isLoading = false
        errorMessage = "Cloud авторизация не настроена. Проверьте SUPABASE_URL и SUPABASE_ANON_KEY."
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        cloudIdentity.clearSession()
    }
    
    func register(name: String, email: String, password: String, role: UserRole, gender: UserGender) {
        isLoading = true
        errorMessage = nil
        registrationSucceeded = false
        currentUser = nil
        isAuthenticated = false
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if cloudIdentity.isConfigured {
            Task { @MainActor in
                do {
                    let result = try await cloudIdentity.register(
                        name: normalizedName,
                        email: normalizedEmail,
                        password: normalizedPassword,
                        role: role,
                        gender: gender
                    )
                    isLoading = false
                    isAuthenticated = true
                    currentUser = result.user
                    lastRegisteredEmail = normalizedEmail
                    registrationSucceeded = true
                } catch {
                    isLoading = false
                    let message = error.localizedDescription
                    if message.contains("Подтвердите email") {
                        errorMessage = "Аккаунт создан. Подтвердите email и затем войдите."
                    } else {
                        errorMessage = message
                    }
                }
            }
            return
        }

        isLoading = false
        errorMessage = "Cloud авторизация не настроена. Проверьте SUPABASE_URL и SUPABASE_ANON_KEY."
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
        print("Auth mode: \(cloudIdentity.isConfigured ? "Supabase" : "Not configured")")
    }
}
