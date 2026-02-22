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

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                TextField("Имя", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Пароль", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Picker("Роль", selection: $role) {
                    ForEach(UserRole.allCases, id: \.self) { userRole in
                        Text(userRole.localized).tag(userRole)
                    }
                }
                .pickerStyle(.segmented)

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.horizontal)

            Button(action: {
                authViewModel.register(name: name, email: email, password: password, role: role)
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
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .disabled(authViewModel.isLoading || name.isEmpty || email.isEmpty || password.isEmpty)

            Spacer()
        }
        .padding(.top, 20)
    }
}
