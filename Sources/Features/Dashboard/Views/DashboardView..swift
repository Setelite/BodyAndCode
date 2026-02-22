//
//  DashboardView..swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/22/25.
//

// Sources/Features/Dashboard/Views/DashboardView.swift
import SwiftUI
import Combine

struct DashboardView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedDate = Date()
    @State private var showingStats = false
    @State private var showingNewWorkoutFlow = false
    @State private var showingActiveWorkout = false
    @State private var hasOngoingWorkout = false
    private let workoutPersistenceStore = WorkoutPersistenceStore()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Приветствие
                    headerSection

                    // Часы и быстрый доступ к таймерам
                    ClockToolsCard()
                    
                    // Быстрый доступ
                    quickActionsSection
                    
                    // Статистика
                    statsSection
                    
                    // Активные тренировки
                    activeWorkoutsSection
                    
                    // Советы дня
                    dailyTipsSection
                }
                .padding()
            }
            .navigationTitle("Главная")
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $showingNewWorkoutFlow) {
                NewWorkoutProgramLibraryView()
            }
            .navigationDestination(isPresented: $showingActiveWorkout) {
                ActiveWorkoutView()
            }
            .onAppear {
                refreshOngoingWorkoutState()
            }
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .active {
                    refreshOngoingWorkoutState()
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Привет, Максим!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Готов к тренировке?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Быстрый доступ")
                .font(.headline)

            if hasOngoingWorkout {
                Button {
                    showingActiveWorkout = true
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                        Text("Продолжить тренировку")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    title: "Новая тренировка",
                    icon: "plus.circle.fill",
                    color: .blue,
                    action: { showingNewWorkoutFlow = true }
                )
                
                QuickActionButton(
                    title: "Мой прогресс",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green,
                    action: { showingStats = true }
                )
                
                QuickActionButton(
                    title: "Питание",
                    icon: "leaf.fill",
                    color: .orange,
                    action: {}
                )
                
                QuickActionButton(
                    title: "Расписание",
                    icon: "calendar",
                    color: .purple,
                    action: {}
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private func refreshOngoingWorkoutState() {
        hasOngoingWorkout = workoutPersistenceStore.loadOngoing() != nil
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ваша статистика")
                    .font(.headline)
                
                Spacer()
                
                Text("За неделю")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Тренировки",
                    value: "8",
                    icon: "flame.fill",
                    color: .orange,
                    change: "+2"
                )
                
                StatCard(
                    title: "Калории",
                    value: "4,280",
                    icon: "bolt.fill",
                    color: .red,
                    change: "+12%"
                )
                
                StatCard(
                    title: "Вес",
                    value: "74 кг",
                    icon: "scalemass.fill",
                    color: .blue,
                    change: "-1.5"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var activeWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Активные тренировки")
                    .font(.headline)
                
                Spacer()
                
                Button("Все") {}
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    WorkoutCard(
                        title: "Силовая",
                        duration: "45 мин",
                        calories: "320",
                        color: .blue,
                        startDestination: AnyView(DailyProgramView())
                    )
                    
                    WorkoutCard(
                        title: "Кардио",
                        duration: "30 мин",
                        calories: "280",
                        color: .red,
                        startDestination: nil
                    )
                    
                    WorkoutCard(
                        title: "Йога",
                        duration: "60 мин",
                        calories: "180",
                        color: .green,
                        startDestination: nil
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var dailyTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Совет дня")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
            }
            
            Text("Пейте достаточно воды во время тренировки. 500мл за 2 часа до тренировки и по 150-200мл каждые 15 минут во время занятия.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// Компоненты для Dashboard
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let change: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(change)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(change.hasPrefix("+") ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(change.hasPrefix("+") ? .green : .red)
                    .cornerRadius(4)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

struct WorkoutCard: View {
    let title: String
    let duration: String
    let calories: String
    let color: Color
    let startDestination: AnyView?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                HStack {
                    Label(duration, systemImage: "clock")
                        .font(.caption)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(calories) ккал", systemImage: "flame")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            if let startDestination {
                NavigationLink(destination: startDestination) {
                    Text("Начать")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Button("Начать") {}
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(true)
            }
        }
        .padding()
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#if canImport(SwiftUI)
struct ClockToolsCard: View {
    @State private var showingToolsSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeString(from: context.date))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.white)

                    Text(dateString(from: context.date))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            Button {
                showingToolsSheet = true
            } label: {
                HStack {
                    Image(systemName: "timer")
                    Text("Секундомер или таймер")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.37, blue: 0.94), Color(red: 0.38, green: 0.17, blue: 0.84)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        .sheet(isPresented: $showingToolsSheet) {
            ClockToolsSheetView()
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: date).capitalized
    }
}

private struct ClockToolsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: ClockToolMode = .stopwatch

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Picker("Режим", selection: $selectedMode) {
                    ForEach(ClockToolMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Group {
                    switch selectedMode {
                    case .stopwatch:
                        StopwatchPanelView()
                    case .timer:
                        CountdownPanelView()
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Часы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private enum ClockToolMode: CaseIterable {
    case stopwatch
    case timer

    var title: String {
        switch self {
        case .stopwatch: return "Секундомер"
        case .timer: return "Таймер"
        }
    }
}

private struct StopwatchPanelView: View {
    @State private var isRunning = false
    @State private var startDate: Date?
    @State private var accumulated: TimeInterval = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let elapsed = elapsedTime(at: context.date)

            VStack(spacing: 18) {
                Text(formatStopwatch(elapsed))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()

                HStack(spacing: 12) {
                    Button(isRunning ? "Пауза" : (accumulated > 0 ? "Продолжить" : "Старт")) {
                        toggleRun(now: context.date)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isRunning ? Color.orange : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button("Сброс") {
                        reset()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14)
        }
    }

    private func elapsedTime(at now: Date) -> TimeInterval {
        guard isRunning, let startDate else { return accumulated }
        return accumulated + now.timeIntervalSince(startDate)
    }

    private func toggleRun(now: Date) {
        if isRunning {
            if let startDate {
                accumulated += now.timeIntervalSince(startDate)
            }
            self.startDate = nil
            isRunning = false
        } else {
            startDate = now
            isRunning = true
        }
    }

    private func reset() {
        isRunning = false
        startDate = nil
        accumulated = 0
    }

    private func formatStopwatch(_ total: TimeInterval) -> String {
        let minutes = Int(total) / 60
        let seconds = Int(total) % 60
        let tenths = Int((total * 10).truncatingRemainder(dividingBy: 10))
        return String(format: "%02d:%02d.%01d", minutes, seconds, tenths)
    }
}

private struct CountdownPanelView: View {
    @State private var selectedMinutes = 5
    @State private var remainingSeconds = 300
    @State private var isRunning = false
    @State private var hasStarted = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 18) {
            Text(formatTimer(remainingSeconds))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()

            Stepper("Длительность: \(selectedMinutes) мин", value: $selectedMinutes, in: 1...180)
                .disabled(hasStarted)

            HStack(spacing: 12) {
                Button(primaryButtonTitle) {
                    handlePrimaryAction()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isRunning ? Color.orange : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)

                Button("Сброс") {
                    reset()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .onReceive(ticker) { _ in
            guard isRunning else { return }

            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                isRunning = false
            }
        }
        .onChange(of: selectedMinutes) { _, newValue in
            if !hasStarted {
                remainingSeconds = newValue * 60
            }
        }
    }

    private var primaryButtonTitle: String {
        if isRunning { return "Пауза" }
        if hasStarted && remainingSeconds > 0 { return "Продолжить" }
        return "Старт"
    }

    private func handlePrimaryAction() {
        if isRunning {
            isRunning = false
            return
        }

        if !hasStarted {
            remainingSeconds = selectedMinutes * 60
            hasStarted = true
        }
        isRunning = true
    }

    private func reset() {
        isRunning = false
        hasStarted = false
        remainingSeconds = selectedMinutes * 60
    }

    private func formatTimer(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
#endif

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
#endif
