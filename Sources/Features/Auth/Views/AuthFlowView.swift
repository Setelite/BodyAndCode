//
//  AuthFlowView.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import SwiftUI

enum AuthRoute: Hashable {
    case login
    case register
}

struct AuthFlowView: View {
    var body: some View {
        NavigationStack {
            AuthChoiceView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView()
                            .navigationTitle("Вход")
                            .navigationBarTitleDisplayMode(.inline)
                    case .register:
                        RegisterView()
                            .navigationTitle("Регистрация")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
        }
    }
}
