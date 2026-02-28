//
//  RegisterView.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role: UserRole = .client
    @State private var gender: UserGender = .notSpecified

    var body: some View {
        ZStack {
            LinearGradient.appGlassGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    TextField("Имя", text: $name)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)

                    SecureField("Пароль", text: $password)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)

                    Picker("Роль", selection: $role) {
                        ForEach(UserRole.allCases, id: \.self) { userRole in
                            Text(userRole.localized).tag(userRole)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Пол", selection: $gender) {
                        ForEach(UserGender.allCases, id: \.self) { userGender in
                            Text(userGender.localized).tag(userGender)
                        }
                    }
                    .pickerStyle(.menu)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Text("Если включено подтверждение email в Supabase, после регистрации подтвердите почту и войдите.")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                }
                .padding()
                .glassCardStyle()

                Button(action: {
                    authViewModel.register(name: name, email: email, password: password, role: role, gender: gender)
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Создать аккаунт")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.glassBlue, .glassLavender],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .padding(.horizontal)
                .disabled(authViewModel.isLoading || name.isEmpty || email.isEmpty || password.isEmpty)

                Spacer()
            }
            .padding(.top, 20)
        }
    }
}
