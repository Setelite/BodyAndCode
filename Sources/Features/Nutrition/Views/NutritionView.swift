//
//  NutritionView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

// Sources/Features/Nutrition/Views/NutritionView.swift
import SwiftUI

struct NutritionView: View {
    @State private var selectedDay = Date()
    @State private var showingAddMeal = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Верхняя навигация по дням
                    daySelectorSection
                    
                    // Калории и макросы
                    caloriesSection
                    
                    // Приемы пищи сегодня
                    mealsSection
                    
                    // Водный баланс
                    waterSection
                    
                    // Рекомендации по питанию
                    recommendationsSection
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .navigationTitle("Питание")
            .background(LinearGradient.appGlassGradient.opacity(0.42))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMeal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealView()
            }
        }
    }
    
    private var daySelectorSection: some View {
        VStack(spacing: 8) {
            DatePicker("", selection: $selectedDay, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(.horizontal, 8)
            
            // Быстрые дни
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    DayButton(title: "Сегодня", isSelected: true)
                    DayButton(title: "Вчера", isSelected: false)
                    DayButton(title: "Пт", isSelected: false)
                    DayButton(title: "Чт", isSelected: false)
                    DayButton(title: "Ср", isSelected: false)
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.58))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
    
    private var caloriesSection: some View {
        VStack(spacing: 16) {
            // Прогресс калорий
            VStack(spacing: 8) {
                HStack {
                    Text("Калории сегодня")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("1,280 / 2,200")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: 1280, total: 2200)
                    .tint(.blue)
                    .scaleEffect(x: 1, y: 1.2, anchor: .center)
                
                HStack {
                    Text("Осталось: 920 ккал")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("-58%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
            
            // Макросы - адаптивная сетка для мобильных
            LazyVGrid(columns: [
                GridItem(.flexible(minimum: 100)),
                GridItem(.flexible(minimum: 100)),
                GridItem(.flexible(minimum: 100))
            ], spacing: 12) {
                MacroCard(
                    title: "Белки",
                    value: "68г",
                    target: "110г",
                    progress: 0.62,
                    color: .blue
                )
                
                MacroCard(
                    title: "Жиры",
                    value: "42г",
                    target: "73г",
                    progress: 0.58,
                    color: .orange
                )
                
                MacroCard(
                    title: "Углеводы",
                    value: "145г",
                    target: "275г",
                    progress: 0.53,
                    color: .green
                )
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Приемы пищи")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Добавить") {
                    showingAddMeal = true
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 0) {
                MealRow(
                    time: "Завтрак",
                    name: "Омлет с овощами",
                    calories: "320 ккал",
                    icon: "sunrise.fill",
                    color: .orange
                )
                
                Divider()
                    .padding(.leading, 48)
                
                MealRow(
                    time: "Обед",
                    name: "Куриная грудка с гречкой",
                    calories: "480 ккал",
                    icon: "sun.max.fill",
                    color: .yellow
                )
                
                Divider()
                    .padding(.leading, 48)
                
                MealRow(
                    time: "Ужин",
                    name: "Рыба с салатом",
                    calories: "380 ккал",
                    icon: "moon.fill",
                    color: .blue
                )
                
                Divider()
                    .padding(.leading, 48)
                
                MealRow(
                    time: "Перекус",
                    name: "Йогурт с орехами",
                    calories: "180 ккал",
                    icon: "leaf.fill",
                    color: .green
                )
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var waterSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Водный баланс")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("1.2л / 2л")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            // Адаптивные стаканы воды
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<8, id: \.self) { index in
                        WaterGlass(
                            isFilled: index < 3,
                            size: 250
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
            
            HStack(spacing: 12) {
                Button {
                    // Добавить 250мл
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("250мл")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                
                Button {
                    // Добавить 500мл
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("500мл")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Рекомендации")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                RecommendationRow(
                    title: "Добавьте больше белка",
                    description: "Рекомендуется 110г в день",
                    icon: "bolt.fill",
                    action: {}
                )
                
                RecommendationRow(
                    title: "Выпейте больше воды",
                    description: "Выпито 1.2л из 2л",
                    icon: "drop.fill",
                    action: {}
                )
                
                RecommendationRow(
                    title: "Ограничьте сахар",
                    description: "Превышена дневная норма",
                    icon: "xmark.circle.fill",
                    action: {}
                )
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.58))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Компоненты
struct DayButton: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
    }
}

struct MacroCard: View {
    let title: String
    let value: String
    let target: String
    let progress: CGFloat
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("из \(target)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Прогресс бар
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding(12)
        .background(Color.white.opacity(0.58))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct MealRow: View {
    let time: String
    let name: String
    let calories: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(time)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(calories)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}

struct WaterGlass: View {
    let isFilled: Bool
    let size: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: isFilled ? "drop.fill" : "drop")
                .font(.title3)
                .foregroundColor(isFilled ? .blue : .gray.opacity(0.3))
            
            Text("\(size)мл")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 44, height: 60)
        .padding(8)
        .background(isFilled ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct RecommendationRow: View {
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AddMealView (исправленный для мобильных)
struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mealName = ""
    @State private var selectedMealType = 0
    @State private var calories = ""
    @State private var protein = ""
    @State private var fat = ""
    @State private var carbs = ""
    
    let mealTypes = ["Завтрак", "Обед", "Ужин", "Перекус"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Выбор типа приема пищи
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Тип приема пищи")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<mealTypes.count, id: \.self) { index in
                                    MealTypeButton(
                                        title: mealTypes[index],
                                        icon: mealIcon(for: index),
                                        isSelected: selectedMealType == index,
                                        action: { selectedMealType = index }
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.58))
                    .cornerRadius(16)
                    
                    // Название блюда
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Название блюда")
                            .font(.headline)
                        
                        TextField("Например: Омлет с овощами", text: $mealName)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(Color.white.opacity(0.58))
                    .cornerRadius(16)
                    
                    // Питательные вещества
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Питательные вещества")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            NutrientInput(
                                title: "Калории",
                                value: $calories,
                                unit: "ккал",
                                icon: "flame.fill",
                                color: .orange
                            )
                            
                            NutrientInput(
                                title: "Белки",
                                value: $protein,
                                unit: "г",
                                icon: "bolt.fill",
                                color: .blue
                            )
                            
                            NutrientInput(
                                title: "Жиры",
                                value: $fat,
                                unit: "г",
                                icon: "drop.fill",
                                color: .yellow
                            )
                            
                            NutrientInput(
                                title: "Углеводы",
                                value: $carbs,
                                unit: "г",
                                icon: "leaf.fill",
                                color: .green
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.58))
                    .cornerRadius(16)
                    
                    // Кнопка сохранения
                    Button(action: saveMeal) {
                        Text("Добавить прием пищи")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(LinearGradient.appGlassGradient.opacity(0.42))
            .navigationTitle("Добавить прием пищи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func mealIcon(for index: Int) -> String {
        switch index {
        case 0: return "sunrise.fill"
        case 1: return "sun.max.fill"
        case 2: return "moon.fill"
        case 3: return "leaf.fill"
        default: return "fork.knife"
        }
    }
    
    private func saveMeal() {
        // Сохранение приема пищи
        dismiss()
    }
}

struct MealTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct NutrientInput: View {
    let title: String
    @Binding var value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
            }
            
            Spacer()
            
            TextField("0", text: $value)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
            
            Text(unit)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#if DEBUG
struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
#endif
