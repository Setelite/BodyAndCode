//
//  DailyProgramView.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import SwiftUI

struct DailyProgramView: View {
    @StateObject private var store = DailyProgramStore()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection

                ForEach($store.program.exercises) { $exercise in
                    ExercisePlanCard(exercise: $exercise)
                }
            }
            .padding()
        }
        .navigationTitle("Программа на день")
        .navigationBarTitleDisplayMode(.inline)
        .background(LinearGradient.appGlassGradient.opacity(0.42))
        .onAppear {
            store.refreshForToday()
        }
        .onChange(of: store.program) { _, _ in
            store.persist()
        }
    }

    private var headerSection: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let date = context.date
            VStack(alignment: .leading, spacing: 6) {
                Text(dayOfWeek(from: date))
                    .font(.title2)
                    .fontWeight(.bold)

                Text(fullDate(from: date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(timeString(from: date))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(store.program.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.58))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4)
        }
    }

    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }

    private func fullDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "Время: \(formatter.string(from: date))"
    }
}

struct ExercisePlanCard: View {
    @Binding var exercise: DailyExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exercise.name)
                        .font(.headline)

                    Text(exercise.exercise.muscleGroup.localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("Активировать", isOn: $exercise.isActive)
                    .labelsHidden()
            }

            VStack(spacing: 8) {
                ForEach(exercise.sets.indices, id: \.self) { index in
                    SetEditorRow(set: $exercise.sets[index], number: index + 1)
                }
            }

            HStack {
                Button {
                    addSet()
                } label: {
                    Label("Добавить подход", systemImage: "plus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    removeSet()
                } label: {
                    Label("Убрать подход", systemImage: "minus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .disabled(exercise.sets.count <= 1)
            }
        }
        .padding()
        .background(Color.white.opacity(0.58))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    private func addSet() {
        exercise.sets.append(DailySet(weight: 0, reps: 0))
    }

    private func removeSet() {
        guard exercise.sets.count > 1 else { return }
        exercise.sets.removeLast()
    }
}

struct SetEditorRow: View {
    @Binding var set: DailySet
    let number: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("Подход \(number)")
                .font(.caption)
                .frame(width: 70, alignment: .leading)

            TextField("Вес", value: $set.weight, format: .number.precision(.fractionLength(1)))
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Повт.", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#if DEBUG
struct DailyProgramView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DailyProgramView()
        }
    }
}
#endif
