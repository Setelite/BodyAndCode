//
//  CoachCabinetView.swift
//  Body&Code
//
//  Created by Codex on 2/22/26.
//

import SwiftUI

struct CoachCabinetView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var coachClientService = CoachClientService()
    @State private var selectedTab: CoachCabinetTab = .clients
    @State private var plans: [CoachPlan] = CoachPlan.sample
    @State private var events: [CoachEvent] = CoachEvent.sample
    @State private var showingCreatePlan = false
    @State private var profileName = ""
    @State private var profileEmail = ""
    @State private var profileSpecialization = ""
    @State private var profileExperience = ""
    @State private var profileBio = ""
    @State private var profileStatusMessage: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    coachHeader
                    ClockToolsCard()
                    sectionPicker

                    switch selectedTab {
                    case .clients:
                        clientsTab
                    case .calendar:
                        calendarTab
                    case .plans:
                        plansTab
                    case .profile:
                        profileTab
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Кабинет тренера")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Выйти") {
                        authViewModel.logout()
                    }
                }
            }
            .onAppear {
                if let user = authViewModel.currentUser {
                    coachClientService.setCurrentUser(user)
                    populateProfileForm(from: user)
                }
            }
            .onChange(of: authViewModel.currentUser?.id) { _, _ in
                if let user = authViewModel.currentUser {
                    populateProfileForm(from: user)
                    coachClientService.setCurrentUser(user)
                }
            }
            .sheet(isPresented: $showingCreatePlan) {
                CoachPlanEditorView { plan in
                    plans.insert(plan, at: 0)
                }
            }
        }
    }

    private var clientsTab: some View {
        VStack(spacing: 16) {
            cardSection(title: "Клиенты") {
                if coachClientService.isLoading {
                    ProgressView("Загрузка клиентов...")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if coachClientService.clients.isEmpty {
                    Text("Клиенты пока не назначены")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(coachClientService.clients.enumerated()), id: \.element.id) { index, client in
                            NavigationLink(destination: CoachClientDetailView(client: client)) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(initials(from: client.name))
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(client.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(client.fitnessLevel?.localized ?? "Уровень не указан")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 10)
                            }

                            if index < coachClientService.clients.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }

    private var calendarTab: some View {
        VStack(spacing: 16) {
            coachStats

            cardSection(title: "Сегодня") {
                eventList(events.filter { Calendar.current.isDateInToday($0.date) })
            }

            cardSection(title: "Эта неделя") {
                eventList(events.filter { !Calendar.current.isDateInToday($0.date) })
            }
        }
    }

    private var plansTab: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Button("Создать программу") {
                    showingCreatePlan = true
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .cardStyle()

            cardSection(title: "Программы") {
                ForEach(plans) { plan in
                    NavigationLink(destination: CoachPlanDetailView(plan: plan)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(plan.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(plan.weekdaysText) • \(plan.exerciseCount) упражнений")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }

    private var profileTab: some View {
        VStack(spacing: 16) {
            cardSection(title: "Данные тренера") {
                VStack(spacing: 12) {
                    coachField(title: "Имя", text: $profileName)
                    coachField(title: "Email", text: $profileEmail, keyboardType: .emailAddress)
                    coachField(title: "Специализация", text: $profileSpecialization)
                    coachField(title: "Опыт (лет)", text: $profileExperience, keyboardType: .numberPad)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("О себе")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Расскажите о себе", text: $profileBio, axis: .vertical)
                            .lineLimit(3...5)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
            }

            Button("Сохранить изменения") {
                saveProfile()
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            if let profileStatusMessage {
                Text(profileStatusMessage)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var coachHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)

                Text(initials(from: authViewModel.currentUser?.name ?? "Тренер"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .shadow(color: .blue.opacity(0.25), radius: 10)

            VStack(spacing: 4) {
                Text(authViewModel.currentUser?.name ?? "Тренер")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(authViewModel.currentUser?.specialization ?? "Добавьте специализацию в профиле")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let bio = authViewModel.currentUser?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Управляйте клиентами, расписанием и программами")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }

    private var coachStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)

            HStack(spacing: 12) {
                coachStat("Клиенты", "\(coachClientService.clients.count)")
                coachStat("Сегодня", "\(events.filter { Calendar.current.isDateInToday($0.date) }.count)")
                coachStat("Программы", "\(plans.count)")
            }
        }
        .cardStyle()
    }

    private func coachStat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func eventRow(_ event: CoachEvent) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.green)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(event.clientName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("\(timeText(event.date)) • \(event.title)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private var sectionPicker: some View {
        Picker("Раздел", selection: $selectedTab) {
            ForEach(CoachCabinetTab.allCases, id: \.self) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(12)
        .cardStyle()
    }

    private func cardSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .cardStyle()
    }

    @ViewBuilder
    private func eventList(_ items: [CoachEvent]) -> some View {
        if items.isEmpty {
            Text("Запланированных тренировок нет")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, event in
                    NavigationLink(destination: CoachEventDetailView(event: event)) {
                        eventRow(event)
                            .padding(.vertical, 8)
                    }

                    if index < items.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    private func coachField(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField(title, text: text)
                .textInputAutocapitalization(.sentences)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }

    private func saveProfile() {
        let trimmedName = profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = profileEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSpecialization = profileSpecialization.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = profileBio.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExperience = profileExperience.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty else {
            profileStatusMessage = "Заполните имя и email."
            return
        }

        let experienceValue = Int(trimmedExperience)
        if !trimmedExperience.isEmpty && experienceValue == nil {
            profileStatusMessage = "Опыт должен быть целым числом."
            return
        }

        let updatedUser = authViewModel.updateCoachProfile(
            name: trimmedName,
            email: trimmedEmail,
            specialization: trimmedSpecialization.isEmpty ? nil : trimmedSpecialization,
            experience: experienceValue,
            bio: trimmedBio.isEmpty ? nil : trimmedBio
        )

        if let updatedUser {
            coachClientService.setCurrentUser(updatedUser)
            profileStatusMessage = "Профиль обновлён."
        }
    }

    private func populateProfileForm(from user: User) {
        profileName = user.name
        profileEmail = user.email
        profileSpecialization = user.specialization ?? ""
        profileExperience = user.experience.map(String.init) ?? ""
        profileBio = user.bio ?? ""
        profileStatusMessage = nil
    }

    private func initials(from fullName: String) -> String {
        let parts = fullName
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        return parts.isEmpty ? "ТР" : parts.joined()
    }

    private func timeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#if DEBUG
struct CoachCabinetView_Previews: PreviewProvider {
    static var previews: some View {
        CoachCabinetView()
            .environmentObject(AuthViewModel())
    }
}
#endif

private enum CoachCabinetTab: CaseIterable {
    case clients
    case calendar
    case plans
    case profile

    var title: String {
        switch self {
        case .clients: return "Клиенты"
        case .calendar: return "Календарь"
        case .plans: return "Программы"
        case .profile: return "Профиль"
        }
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

private struct CoachClientDetailView: View {
    let client: User

    var body: some View {
        List {
            Section("Профиль") {
                LabeledContent("Имя", value: client.name)
                LabeledContent("Email", value: client.email)
                LabeledContent("Уровень", value: client.fitnessLevel?.localized ?? "Не указан")
            }
            Section("Параметры") {
                LabeledContent("Текущий вес", value: client.currentWeight.map { "\(String(format: "%.1f", $0)) кг" } ?? "Не указан")
                LabeledContent("Целевой вес", value: client.goalWeight.map { "\(String(format: "%.1f", $0)) кг" } ?? "Не указан")
            }
            Section("Цели") {
                if let goals = client.goals, !goals.isEmpty {
                    ForEach(goals, id: \.self) { goal in
                        Text(goal)
                    }
                } else {
                    Text("Цели не указаны")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(client.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CoachEventDetailView: View {
    let event: CoachEvent

    var body: some View {
        List {
            Section("Сессия") {
                LabeledContent("Клиент", value: event.clientName)
                LabeledContent("Тренировка", value: event.title)
                LabeledContent("Дата", value: formattedDate(event.date))
                LabeledContent("Длительность", value: "\(event.durationMinutes) мин")
            }
            Section("Заметки") {
                Text(event.notes)
            }
        }
        .navigationTitle("Тренировка")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct CoachPlanDetailView: View {
    let plan: CoachPlan

    var body: some View {
        List {
            Section("План") {
                LabeledContent("Название", value: plan.title)
                LabeledContent("Дни", value: plan.weekdaysText)
                LabeledContent("Упражнений", value: "\(plan.exerciseCount)")
            }
            Section("Описание") {
                Text(plan.notes)
            }
        }
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CoachPlanEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var notes: String = ""
    let onSave: (CoachPlan) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Название программы", text: $title)
                TextField("Описание", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("Новая программа")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let plan = CoachPlan(
                            id: UUID(),
                            title: title,
                            weekdays: ["Пн", "Ср", "Пт"],
                            exerciseCount: Int.random(in: 5...10),
                            notes: notes.isEmpty ? "Без описания" : notes
                        )
                        onSave(plan)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

private struct CoachPlan: Identifiable {
    let id: UUID
    let title: String
    let weekdays: [String]
    let exerciseCount: Int
    let notes: String

    var weekdaysText: String {
        weekdays.joined(separator: ", ")
    }

    static let sample: [CoachPlan] = [
        CoachPlan(id: UUID(), title: "Силовая база", weekdays: ["Пн", "Ср", "Пт"], exerciseCount: 8, notes: "Базовый цикл на силу"),
        CoachPlan(id: UUID(), title: "Снижение веса", weekdays: ["Вт", "Чт", "Сб"], exerciseCount: 7, notes: "Кардио + функциональный блок")
    ]
}

private struct CoachEvent: Identifiable {
    let id: UUID
    let clientName: String
    let title: String
    let date: Date
    let durationMinutes: Int
    let notes: String

    static let sample: [CoachEvent] = {
        let calendar = Calendar.current
        let now = Date()
        return [
            CoachEvent(
                id: UUID(),
                clientName: "Иван Козлов",
                title: "Силовая тренировка",
                date: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now) ?? now,
                durationMinutes: 60,
                notes: "Фокус на ноги и корпус"
            ),
            CoachEvent(
                id: UUID(),
                clientName: "Елена Смирнова",
                title: "Мобильность и растяжка",
                date: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: now) ?? now,
                durationMinutes: 50,
                notes: "Техника + дыхание"
            ),
            CoachEvent(
                id: UUID(),
                clientName: "Иван Козлов",
                title: "Контрольная тренировка",
                date: calendar.date(byAdding: .day, value: 2, to: now) ?? now,
                durationMinutes: 55,
                notes: "Проверка прогресса по прошлой неделе"
            )
        ]
    }()
}
