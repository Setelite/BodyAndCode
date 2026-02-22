//
//  AuthChoiceView.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import SwiftUI

struct AuthChoiceView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Body&Code")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Вход или регистрация")
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                NavigationLink(value: AuthRoute.login) {
                    Text("Войти")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                NavigationLink(value: AuthRoute.register) {
                    Text("Создать аккаунт")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Авторизация")
        .navigationBarTitleDisplayMode(.inline)
    }
}
