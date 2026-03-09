import Foundation

struct CloudIdentityResult {
    let user: User
    let accessToken: String
}

final class CloudIdentityService {
    private let api: SupabaseAPIClient
    private let tokenKey = "supabase_access_token_v1"
    private let userKey = "supabase_current_user_v1"

    init(api: SupabaseAPIClient = SupabaseAPIClient()) {
        self.api = api
    }

    var isConfigured: Bool { api.isConfigured }

    func login(email: String, password: String) async throws -> CloudIdentityResult {
        let session = try await api.signIn(email: email, password: password)
        let profile = try await api.fetchProfile(userID: session.user.id, accessToken: session.access_token)
        let appUser = mapUser(session: session, profile: profile)
        saveSession(token: session.access_token, user: appUser)
        return CloudIdentityResult(user: appUser, accessToken: session.access_token)
    }

    func register(name: String, email: String, password: String, role: UserRole, gender: UserGender) async throws -> CloudIdentityResult {
        try await api.signUp(name: name, email: email, password: password, role: role, gender: gender)
        let session = try await api.signIn(email: email, password: password)

        let profileToUpsert = SupabaseProfileDTO(
            id: session.user.id,
            name: name,
            email: email,
            role: role.rawValue,
            gender: gender.rawValue,
            current_weight: nil,
            goal_weight: nil,
            bio: nil,
            specialization: nil,
            experience_years: nil,
            coach_id: nil,
            created_at: nil
        )
        try await api.upsertProfile(profileToUpsert, accessToken: session.access_token)
        let profile = try await api.fetchProfile(userID: session.user.id, accessToken: session.access_token)

        let appUser = mapUser(session: session, profile: profile)
        saveSession(token: session.access_token, user: appUser)
        return CloudIdentityResult(user: appUser, accessToken: session.access_token)
    }

    func registerOnly(name: String, email: String, password: String, role: UserRole, gender: UserGender) async throws {
        try await api.signUp(name: name, email: email, password: password, role: role, gender: gender)
    }

    func storedAccessToken() -> String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    func restoreUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func persistUser(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else {
            return
        }
        UserDefaults.standard.set(data, forKey: userKey)
    }

    func clearSession() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }

    private func saveAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    private func saveSession(token: String, user: User) {
        saveAccessToken(token)
        persistUser(user)
    }

    private func mapUser(session: SupabaseAuthSession, profile: SupabaseProfileDTO?) -> User {
        let userID = UUID(uuidString: session.user.id) ?? UUID()
        let roleRaw = profile?.role ?? UserRole.client.rawValue
        let role = UserRole(rawValue: roleRaw) ?? .client
        let gender = UserGender(rawValue: profile?.gender ?? UserGender.notSpecified.rawValue) ?? .notSpecified

        let createdAt: Date
        if let createdRaw = profile?.created_at {
            createdAt = ISO8601DateFormatter().date(from: createdRaw) ?? Date()
        } else {
            createdAt = Date()
        }

        return User(
            id: userID,
            name: profile?.name ?? "Пользователь",
            email: profile?.email ?? (session.user.email ?? ""),
            role: role,
            gender: gender,
            currentWeight: profile?.current_weight,
            goalWeight: profile?.goal_weight,
            profileImageUrl: nil,
            bio: profile?.bio,
            clients: nil,
            specialization: profile?.specialization,
            experience: profile?.experience_years,
            coachId: profile?.coach_id.flatMap(UUID.init(uuidString:)),
            fitnessLevel: nil,
            goals: nil,
            createdAt: createdAt
        )
    }
}
