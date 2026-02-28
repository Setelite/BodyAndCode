//
//  CoachClientService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/30/25.
//

import Foundation
import Combine
import UserNotifications

@MainActor
final class CoachClientService: ObservableObject {
    @Published var coaches: [User] = []
    @Published var clients: [User] = []
    @Published var isLoading: Bool = false
    
    // Текущий пользователь (из Auth)
    private var currentUser: User?
    
    init() {
        loadMockData()
    }
    
    // Установка текущего пользователя
    func setCurrentUser(_ user: User) {
        self.currentUser = user
        loadDataForCurrentUser()
    }
    
    // Загрузка данных в зависимости от роли
    private func loadDataForCurrentUser() {
        guard let user = currentUser else { return }
        
        switch user.role {
        case .coach:
            loadClientsForCoach(user.id)
        case .client:
            loadCoachForClient(user.id)
        }
    }
    
    // Загрузка клиентов для тренера
    private func loadClientsForCoach(_ coachId: UUID) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.clients = self.createMockClients().filter { $0.coachId == coachId }
            self.isLoading = false
        }
    }
    
    // Загрузка тренера для клиента
    private func loadCoachForClient(_ clientId: UUID) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let clients = self.createMockClients()
            let clientCoachId = clients.first(where: { $0.id == clientId })?.coachId
            self.coaches = self.createMockCoaches().filter {
                clientCoachId == nil ? true : $0.id == clientCoachId
            }
            self.isLoading = false
        }
    }
    
    // Поиск тренеров
    func searchCoaches(query: String) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            // В реальном приложении здесь будет поиск по API
            self.coaches = self.createMockCoaches().filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.specialization?.localizedCaseInsensitiveContains(query) == true
            }
            self.isLoading = false
        }
    }
    
    // Отправка запроса тренеру
    func sendCoachRequest(clientId: UUID, coachId: UUID, message: String? = nil) {
        print("Запрос отправлен тренеру: \(coachId)")
        print("Сообщение: \(message ?? "Без сообщения")")
        // В реальном приложении здесь будет API вызов
    }
    
    // Принять клиента (для тренера)
    func acceptClient(clientId: UUID, coachId: UUID) {
        print("Клиент \(clientId) принят тренером \(coachId)")
        // В реальном приложении здесь будет обновление в базе
    }

    func coachForClient(_ clientId: UUID) -> User? {
        let clientCoachId = createMockClients().first(where: { $0.id == clientId })?.coachId
        guard let coachId = clientCoachId else { return nil }
        return createMockCoaches().first(where: { $0.id == coachId })
    }

    func client(by id: UUID) -> User? {
        createMockClients().first(where: { $0.id == id })
    }

    func coach(by id: UUID) -> User? {
        createMockCoaches().first(where: { $0.id == id })
    }
    
    // MARK: - Mock Data
    private func loadMockData() {
        coaches = createMockCoaches()
        clients = createMockClients()
    }
    
    private func createMockCoaches() -> [User] {
        return [
            User(
                id: AppUserIDs.coachDemo,
                name: "Алексей Иванов",
                email: "alexey@fitness.com",
                role: .coach,
                profileImageUrl: nil, specialization: "Силовые тренировки",
                experience: 5
            ),
            User(
                id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                name: "Мария Петрова",
                email: "maria@fitness.com",
                role: .coach,
                profileImageUrl: nil, specialization: "Йога и стретчинг",
                experience: 3
            ),
            User(
                id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
                name: "Дмитрий Сидоров",
                email: "dmitry@fitness.com",
                role: .coach,
                profileImageUrl: nil, specialization: "Функциональный тренинг",
                experience: 7
              
            )
        ]
    }
    
    private func createMockClients() -> [User] {
        return [
            User(
                id: AppUserIDs.clientIvan,
                name: "Иван Козлов",
                email: "ivan@client.com",
                role: .client,
                currentWeight: 80.0,
                goalWeight: 75.0,
                coachId: AppUserIDs.coachDemo,
                fitnessLevel: .intermediate,
                goals: ["Похудение", "Увеличение выносливости"]
            ),
            User(
                id: AppUserIDs.clientElena,
                name: "Елена Смирнова",
                email: "elena@client.com",
                role: .client,
                currentWeight: 65.0,
                goalWeight: 60.0,
                coachId: AppUserIDs.coachDemo,
                fitnessLevel: .beginner,
                goals: ["Тонус мышц", "Общее оздоровление"]
            )
        ]
    }
}

struct CoachClientChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let coachId: UUID
    let clientId: UUID
    let senderId: UUID
    let senderName: String
    let senderRole: UserRole
    let text: String
    let attachments: [CoachClientChatAttachment]
    var readByUserIDs: [UUID]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        coachId: UUID,
        clientId: UUID,
        senderId: UUID,
        senderName: String,
        senderRole: UserRole,
        text: String,
        attachments: [CoachClientChatAttachment] = [],
        readByUserIDs: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.coachId = coachId
        self.clientId = clientId
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = senderRole
        self.text = text
        self.attachments = attachments
        self.readByUserIDs = readByUserIDs
        self.createdAt = createdAt
    }
}

enum CoachClientChatAttachmentKind: String, Codable, Hashable {
    case image
    case file
}

struct CoachClientChatAttachment: Identifiable, Codable, Hashable {
    let id: UUID
    let kind: CoachClientChatAttachmentKind
    let fileName: String
    let data: Data

    init(
        id: UUID = UUID(),
        kind: CoachClientChatAttachmentKind,
        fileName: String,
        data: Data
    ) {
        self.id = id
        self.kind = kind
        self.fileName = fileName
        self.data = data
    }
}

@MainActor
final class CoachClientChatStore: ObservableObject {
    static let shared = CoachClientChatStore()

    @Published private(set) var messages: [CoachClientChatMessage] = []

    private let defaults: UserDefaults
    private let storageKey = "coach_client_chat_messages_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func messages(coachId: UUID, clientId: UUID) -> [CoachClientChatMessage] {
        messages
            .filter { $0.coachId == coachId && $0.clientId == clientId }
            .sorted(by: { $0.createdAt < $1.createdAt })
    }

    func lastMessage(coachId: UUID, clientId: UUID) -> CoachClientChatMessage? {
        messages(coachId: coachId, clientId: clientId).last
    }

    func sendMessage(
        coachId: UUID,
        clientId: UUID,
        sender: User,
        recipient: User,
        text: String,
        attachments: [CoachClientChatAttachment] = []
    ) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty || !attachments.isEmpty else { return }

        let message = CoachClientChatMessage(
            coachId: coachId,
            clientId: clientId,
            senderId: sender.id,
            senderName: sender.name,
            senderRole: sender.role,
            text: trimmedText,
            attachments: attachments,
            readByUserIDs: [sender.id]
        )
        messages.append(message)
        persist()

        Task { @MainActor in
            let notificationService = NotificationService.shared
            await notificationService.checkPermissionStatus()
            if notificationService.permissionStatus == .authorized || notificationService.permissionStatus == .provisional {
                await notificationService.scheduleChatMessageNotification(
                    senderName: sender.name,
                    recipientName: recipient.name,
                    previewText: trimmedText,
                    conversationId: "\(coachId.uuidString)_\(clientId.uuidString)"
                )
            }
        }
    }

    func markConversationRead(coachId: UUID, clientId: UUID, readerId: UUID) {
        var updated = false
        for index in messages.indices {
            guard messages[index].coachId == coachId,
                  messages[index].clientId == clientId,
                  messages[index].senderId != readerId else { continue }
            if !messages[index].readByUserIDs.contains(readerId) {
                messages[index].readByUserIDs.append(readerId)
                updated = true
            }
        }
        if updated {
            persist()
        }
    }

    func unreadCount(for userId: UUID, coachId: UUID, clientId: UUID) -> Int {
        messages(coachId: coachId, clientId: clientId)
            .filter { $0.senderId != userId && !$0.readByUserIDs.contains(userId) }
            .count
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey) else {
            seed()
            return
        }
        if let decoded = try? JSONDecoder().decode([CoachClientChatMessage].self, from: data) {
            messages = decoded
        } else {
            seed()
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func seed() {
        messages = [
            CoachClientChatMessage(
                coachId: AppUserIDs.coachDemo,
                clientId: AppUserIDs.clientIvan,
                senderId: AppUserIDs.coachDemo,
                senderName: "Алексей Иванов",
                senderRole: .coach,
                text: "Иван, как самочувствие после последней тренировки?",
                readByUserIDs: [AppUserIDs.coachDemo]
            ),
            CoachClientChatMessage(
                coachId: AppUserIDs.coachDemo,
                clientId: AppUserIDs.clientIvan,
                senderId: AppUserIDs.clientIvan,
                senderName: "Иван Козлов",
                senderRole: .client,
                text: "Все отлично, можно добавить вес в приседе.",
                readByUserIDs: [AppUserIDs.clientIvan]
            )
        ]
        persist()
    }
}
