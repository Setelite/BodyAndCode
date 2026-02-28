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
    @StateObject private var programStore = TrainingProgramStore()
    @StateObject private var chatStore = CoachClientChatStore.shared
    @State private var selectedTab: CoachCabinetTab = .clients
    @State private var events: [CoachEvent] = CoachEvent.sample
    @State private var showingCreatePlan = false
    @State private var selectedProgramForEditing: TrainingProgram?
    @State private var selectedProgramForAssignment: TrainingProgram?
    @State private var assignmentNote = ""
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
                    case .chat:
                        chatTab
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
                TrainingProgramEditorSheetView { title, summary in
                    guard let coachId = authViewModel.currentUser?.id else { return }
                    _ = programStore.createProgram(coachId: coachId, title: title, summary: summary)
                }
            }
            .sheet(item: $selectedProgramForEditing) { program in
                TrainingProgramDetailEditorSheetView(program: program) { title, summary, exercises in
                    programStore.updateProgram(
                        program.id,
                        title: title,
                        summary: summary,
                        exercises: exercises
                    )
                }
            }
            .sheet(item: $selectedProgramForAssignment) { program in
                TrainingProgramAssignmentSheetView(
                    program: program,
                    clients: coachClientService.clients,
                    note: $assignmentNote
                ) { selectedClientIDs in
                    guard let coachId = authViewModel.currentUser?.id else { return }
                    programStore.assignProgram(
                        program.id,
                        coachId: coachId,
                        to: selectedClientIDs,
                        note: assignmentNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : assignmentNote
                    )
                    assignmentNote = ""
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
                if coachPrograms.isEmpty {
                    Text("Программ пока нет")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                ForEach(coachPrograms) { program in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(program.title)
                                .font(.headline)
                            Spacer()
                            Text(program.status.localized)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(program.status == .published ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                                .cornerRadius(8)
                        }

                        Text(program.summary)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if !program.exercises.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(program.exercises.prefix(3))) { exercise in
                                    Text("• \(exercise.exercise.name): \(exercise.sets)x\(exercise.reps)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                if program.exercises.count > 3 {
                                    Text("и ещё \(program.exercises.count - 3)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        HStack {
                            Text("\(program.exercises.count) упражнений")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Menu {
                                Button("Редактировать") {
                                    selectedProgramForEditing = program
                                }
                                if program.status == .draft {
                                    Button("Опубликовать") {
                                        programStore.publishProgram(program.id)
                                    }
                                }
                                Button("Назначить клиентам") {
                                    selectedProgramForAssignment = program
                                }
                            } label: {
                                Label("Действия", systemImage: "ellipsis.circle")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }

    private var chatTab: some View {
        cardSection(title: "Диалоги с клиентами") {
            if coachClientService.clients.isEmpty {
                Text("Нет клиентов для переписки")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(coachClientService.clients.enumerated()), id: \.element.id) { index, client in
                        NavigationLink {
                            if let coach = authViewModel.currentUser {
                                CoachClientChatScreen(
                                    coach: coach,
                                    client: client,
                                    viewer: coach
                                )
                            } else {
                                Text("Пользователь не найден")
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.indigo.opacity(0.18))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.indigo)
                                    )

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(client.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text(lastMessagePreview(for: client))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()
                                let unreadCount = unreadMessagesCount(for: client)
                                if unreadCount > 0 {
                                    Text("\(unreadCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 4)
                                        .background(Color.red)
                                        .clipShape(Capsule())
                                }
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
                coachStat("Программы", "\(coachPrograms.count)")
            }
        }
        .cardStyle()
    }

    private var coachPrograms: [TrainingProgram] {
        guard let coachId = authViewModel.currentUser?.id else { return [] }
        return programStore.programsForCoach(coachId)
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

    private func lastMessagePreview(for client: User) -> String {
        guard let coachId = authViewModel.currentUser?.id else { return "Начните диалог" }
        guard let lastMessage = chatStore.lastMessage(coachId: coachId, clientId: client.id) else {
            return "Начните диалог"
        }
        if !lastMessage.text.isEmpty {
            return lastMessage.text
        }
        return "Вложение"
    }

    private func unreadMessagesCount(for client: User) -> Int {
        guard let coachId = authViewModel.currentUser?.id else { return 0 }
        return chatStore.unreadCount(for: coachId, coachId: coachId, clientId: client.id)
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
    case chat
    case profile

    var title: String {
        switch self {
        case .clients: return "Клиенты"
        case .calendar: return "Календарь"
        case .plans: return "Программы"
        case .chat: return "Чат"
        case .profile: return "Профиль"
        }
    }
}

private extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.white.opacity(0.58))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

private struct TrainingProgramEditorSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var summary = ""
    let onSave: (String, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Новая программа") {
                    TextField("Название", text: $title)
                    TextField("Описание", text: $summary, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Создать программу")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave(
                            title.trimmingCharacters(in: .whitespacesAndNewlines),
                            summary.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct TrainingProgramDetailEditorSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let program: TrainingProgram
    let onSave: (String, String, [TrainingProgramExercise]) -> Void

    @State private var title: String
    @State private var summary: String
    @State private var draftExercises: [DraftExercise]
    @State private var selectedDraftExerciseID: UUID?
    @State private var showingNewExerciseSheet = false

    init(
        program: TrainingProgram,
        onSave: @escaping (String, String, [TrainingProgramExercise]) -> Void
    ) {
        self.program = program
        self.onSave = onSave
        _title = State(initialValue: program.title)
        _summary = State(initialValue: program.summary)
        _draftExercises = State(initialValue: program.exercises.map(DraftExercise.init))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Программа") {
                    TextField("Название", text: $title)
                    TextField("Описание", text: $summary, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Упражнения") {
                    if draftExercises.isEmpty {
                        Text("Добавьте упражнения")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(draftExercises) { exercise in
                            Button {
                                selectedDraftExerciseID = exercise.id
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(exercise.name)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Text("\(exercise.sets)x\(exercise.reps) • отдых \(exercise.restSeconds)с • \(exercise.muscleGroup.localized)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteExercises)
                    }

                    Button {
                        showingNewExerciseSheet = true
                    } label: {
                        Label("Добавить упражнение", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave(
                            title.trimmingCharacters(in: .whitespacesAndNewlines),
                            summary.trimmingCharacters(in: .whitespacesAndNewlines),
                            draftExercises.map(\.asTrainingExercise)
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draftExercises.isEmpty)
                }
            }
            .sheet(item: selectedExerciseBinding) { exercise in
                TrainingProgramExerciseEditorSheetView(
                    draftExercise: exercise,
                    onSave: { updated in
                        updateExercise(updated)
                    }
                )
            }
            .sheet(isPresented: $showingNewExerciseSheet) {
                TrainingProgramExerciseEditorSheetView(
                    draftExercise: DraftExercise(
                        id: UUID(),
                        sourceExerciseId: UUID(),
                        name: "",
                        muscleGroup: .fullBody,
                        sets: 3,
                        reps: 10,
                        restSeconds: 90,
                        targetWeight: 0
                    ),
                    onSave: { newExercise in
                        draftExercises.append(newExercise)
                    }
                )
            }
        }
    }

    private var selectedExerciseBinding: Binding<DraftExercise?> {
        Binding<DraftExercise?>(
            get: {
                guard let id = selectedDraftExerciseID else { return nil }
                return draftExercises.first(where: { $0.id == id })
            },
            set: { newValue in
                selectedDraftExerciseID = newValue?.id
            }
        )
    }

    private func deleteExercises(at offsets: IndexSet) {
        draftExercises.remove(atOffsets: offsets)
    }

    private func updateExercise(_ updated: DraftExercise) {
        guard let index = draftExercises.firstIndex(where: { $0.id == updated.id }) else {
            draftExercises.append(updated)
            return
        }
        draftExercises[index] = updated
    }
}

private struct TrainingProgramExerciseEditorSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draftExercise: DraftExercise
    let onSave: (DraftExercise) -> Void

    init(draftExercise: DraftExercise, onSave: @escaping (DraftExercise) -> Void) {
        _draftExercise = State(initialValue: draftExercise)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Упражнение") {
                    TextField("Название упражнения", text: $draftExercise.name)
                    Picker("Мышечная группа", selection: $draftExercise.muscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Text(group.localized).tag(group)
                        }
                    }
                }

                Section("Параметры") {
                    Stepper("Подходы: \(draftExercise.sets)", value: $draftExercise.sets, in: 1...12)
                    Stepper("Повторы: \(draftExercise.reps)", value: $draftExercise.reps, in: 1...50)
                    Stepper("Отдых: \(draftExercise.restSeconds) сек", value: $draftExercise.restSeconds, in: 15...300, step: 15)
                    Stepper("Вес: \(Int(draftExercise.targetWeight)) кг", value: $draftExercise.targetWeight, in: 0...300, step: 2.5)
                }
            }
            .navigationTitle("Упражнение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        onSave(draftExercise)
                        dismiss()
                    }
                    .disabled(draftExercise.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct DraftExercise: Identifiable, Hashable {
    let id: UUID
    let sourceExerciseId: UUID
    var name: String
    var muscleGroup: MuscleGroup
    var sets: Int
    var reps: Int
    var restSeconds: Int
    var targetWeight: Double

    init(trainingExercise: TrainingProgramExercise) {
        id = trainingExercise.id
        sourceExerciseId = trainingExercise.exercise.id
        name = trainingExercise.exercise.name
        muscleGroup = trainingExercise.exercise.muscleGroup
        sets = trainingExercise.sets
        reps = trainingExercise.reps
        restSeconds = trainingExercise.restSeconds
        targetWeight = trainingExercise.targetWeight
    }

    init(
        id: UUID,
        sourceExerciseId: UUID,
        name: String,
        muscleGroup: MuscleGroup,
        sets: Int,
        reps: Int,
        restSeconds: Int,
        targetWeight: Double
    ) {
        self.id = id
        self.sourceExerciseId = sourceExerciseId
        self.name = name
        self.muscleGroup = muscleGroup
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.targetWeight = targetWeight
    }

    var asTrainingExercise: TrainingProgramExercise {
        TrainingProgramExercise(
            id: id,
            exercise: Exercise(
                id: sourceExerciseId,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                muscleGroup: muscleGroup
            ),
            sets: sets,
            reps: reps,
            restSeconds: restSeconds,
            targetWeight: targetWeight
        )
    }
}

private struct TrainingProgramAssignmentSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let program: TrainingProgram
    let clients: [User]
    @Binding var note: String
    let onAssign: ([UUID]) -> Void
    @State private var selectedClientIDs: Set<UUID> = []

    var body: some View {
        NavigationView {
            Form {
                Section("Программа") {
                    Text(program.title)
                        .font(.headline)
                    Text(program.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Клиенты") {
                    if clients.isEmpty {
                        Text("Нет доступных клиентов")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(clients) { client in
                            Button {
                                toggle(client.id)
                            } label: {
                                HStack {
                                    Text(client.name)
                                    Spacer()
                                    Image(systemName: selectedClientIDs.contains(client.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedClientIDs.contains(client.id) ? .blue : .gray)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Комментарий") {
                    TextField("Комментарий для клиентов", text: $note, axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .navigationTitle("Назначение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Назначить") {
                        onAssign(Array(selectedClientIDs))
                        dismiss()
                    }
                    .disabled(selectedClientIDs.isEmpty)
                }
            }
        }
    }

    private func toggle(_ clientId: UUID) {
        if selectedClientIDs.contains(clientId) {
            selectedClientIDs.remove(clientId)
        } else {
            selectedClientIDs.insert(clientId)
        }
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
