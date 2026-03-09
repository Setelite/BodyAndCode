//
//  ProgressView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/24/25.
//

import SwiftUI
import Charts

struct ProgressDashboardView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var selectedTimeFrame: TimeFrame = .month
    
    enum TimeFrame: String, CaseIterable {
        case week = "Неделя"
        case month = "Месяц"
        case threeMonths = "3 месяца"
        case year = "Год"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    analyticsStatusSection
                    timeFramePicker
                    weightProgressSection
                    workoutProgressSection
                    personalRecordsSection
                    workoutHistorySection
                }
                .padding()
            }
            .navigationTitle("Прогресс")
            .refreshable {
                viewModel.loadProgressData()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Загрузка данных...")
                }
            }
        }
    }
    
    private var timeFramePicker: some View {
        Picker("Период", selection: $selectedTimeFrame) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                Text(timeFrame.rawValue).tag(timeFrame)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var analyticsStatusSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.title3)
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text("Аналитика активности включена")
                    .font(.subheadline.weight(.semibold))
                Text("Событий зафиксировано: \(viewModel.analyticsEventsCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }
    
    private var weightProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Вес тела")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let progress = viewModel.calculateMonthlyProgress() {
                    Text("\(progress > 0 ? "+" : "")\(progress, specifier: "%.1f") кг")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(progress < 0 ? .green : .red)
                }
            }
            
            if viewModel.weightData.isEmpty {
                placeholderView(systemName: "scalemass", text: "Данные о весе появятся здесь")
            } else {
                Chart(viewModel.weightData) { data in
                    LineMark(
                        x: .value("Дата", data.date),
                        y: .value("Вес", data.weight)
                    )
                    .foregroundStyle(.blue.gradient)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Дата", data.date),
                        y: .value("Вес", data.weight)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(50)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel("\(value.as(Double.self)!, specifier: "%.0f") кг")
                    }
                }
            }
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }
    
    private var workoutProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Прогресс в упражнениях")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.exerciseProgress.isEmpty {
                placeholderView(systemName: "dumbbell", text: "Данные о тренировках появятся здесь")
            } else {
                ForEach(viewModel.getTopExercises(limit: 3)) { progress in
                    ExerciseProgressRow(progress: progress)
                }
            }
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }
    
    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Личные рекорды")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.personalRecords.isEmpty {
                placeholderView(systemName: "trophy", text: "Рекорды появятся здесь")
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(viewModel.getRecentPersonalRecords(limit: 4)) { record in
                        PersonalRecordCard(record: record)
                    }
                }
            }
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }
    
    private var workoutHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История тренировок")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.workoutHistory.isEmpty {
                placeholderView(systemName: "clock", text: "История тренировок появится здесь")
            } else {
                ForEach(viewModel.workoutHistory.prefix(3)) { history in
                    WorkoutHistoryRow(history: history)
                }
            }
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(12)
    }
    
    private func placeholderView(systemName: String, text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Supporting Views
struct ExerciseProgressRow: View {
    let progress: ProgressViewModel.ExerciseProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(progress.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("+\(progress.progressPercentage, specifier: "%.1f")%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(progress.progressPercentage >= 0 ? .green : .red)
            }
            
            ProgressView(value: progress.currentWeight, total: progress.goalWeight)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack {
                Text("\(progress.currentWeight, specifier: "%.1f") кг")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Цель: \(progress.goalWeight, specifier: "%.1f") кг")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PersonalRecordCard: View {
    let record: ProgressViewModel.PersonalRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(record.exerciseName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text("\(record.weight, specifier: "%.1f") кг")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primaryColor)
            
            Text("\(record.reps) повт.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(record.date, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.background)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.borderColor, lineWidth: 1)
        )
    }
}

struct WorkoutHistoryRow: View {
    let history: ProgressViewModel.WorkoutHistory
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(history.workoutName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(history.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(history.completedExercises)/\(history.totalExercises) упр.")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(formatDuration(history.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) мин"
    }
}
