//
//  WelcomeView.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            Text("Добро пожаловать в Body&Code")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Тренировки, тренеры и питание в одном месте.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                hasSeenWelcome = true
            } label: {
                Text("Начать")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding()
    }
}
