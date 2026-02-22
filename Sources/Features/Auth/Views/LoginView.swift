//
//  LoginView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/22/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var email: String = "user@example.com"
    @State private var password: String = "password"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Body&Code")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Text("Тест: client `user@example.com` / coach `coach@example.com`, пароль `password`")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Button(action: {
                authViewModel.login(email: email, password: password)
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Войти")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(authViewModel.isLoading)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Вход")
        .navigationBarTitleDisplayMode(.inline)
    }
}
