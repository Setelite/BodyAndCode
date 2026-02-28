//
//  WelcomeView.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import SwiftUI

struct WelcomeView: View {
    var onContinue: (() -> Void)?
    @State private var didScheduleTransition = false

    init(onContinue: (() -> Void)? = nil) {
        self.onContinue = onContinue
    }

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
        }
        .padding()
        .onAppear {
            guard !didScheduleTransition else { return }
            didScheduleTransition = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                onContinue?()
            }
        }
    }
}
