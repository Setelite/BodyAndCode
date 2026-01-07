//
//  SetInputView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/23/25.
//

import SwiftUI

struct SetInputView: View {
    let targetWeight: Double
    let targetReps: Int
    let onSave: (Double, Int) -> Void
    let onCancel: () -> Void
    
    @State private var weight: String
    @State private var reps: String
    @State private var notes: String = ""
    @State private var difficulty: Difficulty = .medium
    @FocusState private var focusedField: Field?
    
    enum Field {
        case weight, reps, notes
    }
    
    enum Difficulty: String, CaseIterable {
        case easy = "Легко"
        case medium = "Средне"
        case hard = "Тяжело"
        case failure = "Отказ"
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .yellow
            case .hard: return .orange
            case .failure: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .easy: return "face.smiling"
            case .medium: return "face.neutral"
            case .hard: return "face.dashed"
            case .failure: return "xmark.circle"
            }
        }
    }
    
    init(targetWeight: Double, targetReps: Int, onSave: @escaping (Double, Int) -> Void, onCancel: @escaping () -> Void) {
        self.targetWeight = targetWeight
        self.targetReps = targetReps
        self.onSave = onSave
        self.onCancel = onCancel
        
        _weight = State(initialValue: String(format: "%.1f", targetWeight))
        _reps = State(initialValue: "\(targetReps)")
    }
    
    var body: some View {
        NavigationView {
            Form {
                sectionHeader
                weightSection
                repsSection
                difficultySection
                notesSection
                quickActionsSection
            }
            .navigationTitle("Ввод подхода")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена", action: onCancel)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveSet()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        focusedField = nil
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .weight
            }
        }
    }
    
    private var sectionHeader: some View {
        Section {
            HStack {
                VStack(alignment: .leading) {
                    Text("План")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(targetWeight, specifier: "%.1f") кг × \(targetReps) повт.")
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                if let actualWeight = Double(weight), let actualReps = Int(reps) {
                    VStack(alignment: .trailing) {
                        Text("Факт")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(actualWeight, specifier: "%.1f") кг × \(actualReps) повт.")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(actualColor)
                    }
                }
            }
        }
    }
    
    private var weightSection: some View {
        Section(header: Text("Вес (кг)")) {
            HStack {
                TextField("Вес", text: $weight)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .weight)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                VStack(spacing: 4) {
                    Button(action: { adjustWeight(by: 2.5) }) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .frame(width: 30, height: 15)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: { adjustWeight(by: -2.5) }) {
                        Image(systemName: "minus")
                            .font(.caption)
                            .frame(width: 30, height: 15)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled((Double(weight) ?? 0) <= 0)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(quickWeightOptions, id: \.self) { option in
                    Button(action: { weight = String(format: "%.1f", option) }) {
                        Text("\(option, specifier: "%.0f")")
                            .font(.caption)
                            .padding(6)
                            .frame(maxWidth: .infinity)
                            .background(quickOptionBackground(for: option))
                            .foregroundColor(quickOptionForeground(for: option))
                            .cornerRadius(6)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }
    
    private var repsSection: some View {
        Section(header: Text("Повторения")) {
            HStack {
                TextField("Повторения", text: $reps)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .reps)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                VStack(spacing: 4) {
                    Button(action: { adjustReps(by: 1) }) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .frame(width: 30, height: 15)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: { adjustReps(by: -1) }) {
                        Image(systemName: "minus")
                            .font(.caption)
                            .frame(width: 30, height: 15)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled((Int(reps) ?? 0) <= 0)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(quickRepOptions, id: \.self) { option in
                    Button(action: { reps = "\(option)" }) {
                        Text("\(option)")
                            .font(.caption)
                            .padding(6)
                            .frame(maxWidth: .infinity)
                            .background(quickOptionBackground(for: Double(option)))
                            .foregroundColor(quickOptionForeground(for: Double(option)))
                            .cornerRadius(6)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }
    
    private var difficultySection: some View {
        Section(header: Text("Сложность")) {
            Picker("Сложность", selection: $difficulty) {
                ForEach(Difficulty.allCases, id: \.self) { level in
                    HStack {
                        Image(systemName: level.icon)
                            .foregroundColor(level.color)
                        Text(level.rawValue)
                    }
                    .tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var notesSection: some View {
        Section(header: Text("Заметки (опционально)")) {
            TextField("Добавьте заметки о подходе...", text: $notes, axis: .vertical)
                .focused($focusedField, equals: .notes)
                .lineLimit(3...6)
        }
    }
    
    private var quickActionsSection: some View {
        Section {
            Button("Использовать плановые значения") {
                weight = String(format: "%.1f", targetWeight)
                reps = "\(targetReps)"
                difficulty = .medium
            }
            
            Button("Отметить как отказ") {
                reps = "0"
                difficulty = .failure
            }
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Computed Properties
    private var quickWeightOptions: [Double] { [20, 40, 60, 80, 100, 120, 140, 160] }
    private var quickRepOptions: [Int] { [5, 8, 10, 12, 15] }
    
    private var isFormValid: Bool {
        guard let weightValue = Double(weight),
              let repsValue = Int(reps),
              weightValue > 0,
              repsValue >= 0 else {
            return false
        }
        return true
    }
    
    private var actualColor: Color {
        guard let actualWeight = Double(weight),
              let actualReps = Int(reps) else {
            return .primary
        }
        
        if actualWeight >= targetWeight && actualReps >= targetReps {
            return .green
        } else if actualWeight >= targetWeight * 0.9 && actualReps >= targetReps - 1 {
            return .orange
        } else {
            return .red
        }
    }
    
    // MARK: - Methods
    private func adjustWeight(by amount: Double) {
        if let currentWeight = Double(weight) {
            let newWeight = max(0, currentWeight + amount)
            weight = String(format: "%.1f", newWeight)
        }
    }
    
    private func adjustReps(by amount: Int) {
        if let currentReps = Int(reps) {
            let newReps = max(0, currentReps + amount)
            reps = "\(newReps)"
        }
    }
    
    private func quickOptionBackground(for value: Double) -> Color {
        if let currentValue = Double(weight), currentValue == value {
            return .blue.opacity(0.3)
        } else if let currentReps = Int(reps), Double(currentReps) == value {
            return .blue.opacity(0.3)
        }
        return .gray.opacity(0.2)
    }
    
    private func quickOptionForeground(for value: Double) -> Color {
        if let currentValue = Double(weight), currentValue == value {
            return .blue
        } else if let currentReps = Int(reps), Double(currentReps) == value {
            return .blue
        }
        return .primary
    }
    
    private func saveSet() {
        guard let weightValue = Double(weight),
              let repsValue = Int(reps) else {
            return
        }
        
        onSave(weightValue, repsValue)
    }
}
