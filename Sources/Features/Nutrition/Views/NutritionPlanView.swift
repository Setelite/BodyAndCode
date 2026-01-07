//
//  NutritionPlanView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/23/25.
//

import SwiftUI

struct NutritionPlanView: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    var body: some View {
        NavigationView {
            VStack {
                Text("План питания")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Функциональность питания в разработке")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Заглушки для будущих функций
                VStack(spacing: 15) {
                    NutritionCard(title: "Завтрак", calories: "400 ккал")
                    NutritionCard(title: "Обед", calories: "600 ккал")
                    NutritionCard(title: "Ужин", calories: "500 ккал")
                    NutritionCard(title: "Перекусы", calories: "200 ккал")
                }
                .padding()
                
                Spacer()
                
                Button("Добавить прием пищи") {
                    // TODO: Реализовать добавление приема пищи
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Питание")
        }
    }
}

struct NutritionCard: View {
    let title: String
    let calories: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(calories)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(10)
    }
}
