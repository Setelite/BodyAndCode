//
//  Untitled.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 12/28/25.
//

// Sources/Features/Coaches/Components/EmptyCoachesView.swift
import SwiftUI

struct EmptyCoachesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Тренеры не найдены")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Попробуйте изменить параметры поиска или зайдите позже")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}
