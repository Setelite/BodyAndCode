//
//  CoachFiltersView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/4/26.
//

import SwiftUI

// Sources/Features/Coaches/Views/CoachFiltersView.swift


struct CoachFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Специализация") {
                    // Фильтры по специализации
                }
                
                Section("Время") {
                    // Фильтры по времени
                }
                
                Section("Стоимость") {
                    // Фильтры по цене
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        // Сброс фильтров
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}
