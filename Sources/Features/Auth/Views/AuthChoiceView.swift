//
//  AuthChoiceView.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import SwiftUI

struct AuthChoiceView: View {
    var body: some View {
        ZStack {
            LinearGradient.appGlassGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Text("Body&Code")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .white.opacity(0.5), radius: 8, y: 2)

                Text("Вход или регистрация")
                    .foregroundColor(.white.opacity(0.9))

                VStack(spacing: 12) {
                    NavigationLink(value: AuthRoute.login) {
                        Text("Войти")
                            .fontWeight(.semibold)
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
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                    }

                    NavigationLink(value: AuthRoute.register) {
                        Text("Создать аккаунт")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.56))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .glassCardStyle()
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle("Авторизация")
        .navigationBarTitleDisplayMode(.inline)
    }
}
