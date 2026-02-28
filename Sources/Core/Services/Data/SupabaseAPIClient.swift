import Foundation

enum SupabaseClientError: LocalizedError {
    case missingConfiguration
    case invalidResponse
    case serverError(String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Supabase не настроен. Добавьте SUPABASE_URL и SUPABASE_ANON_KEY."
        case .invalidResponse:
            return "Некорректный ответ сервера."
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Сессия истекла. Войдите снова."
        }
    }
}

struct SupabaseAuthSession: Decodable {
    let access_token: String
    let token_type: String
    let user: SupabaseAuthUser
}

struct SupabaseAuthUser: Decodable {
    let id: String
    let email: String?
}

struct SupabaseProfileDTO: Decodable {
    let id: String
    let name: String
    let email: String
    let role: String
    let gender: String?
    let current_weight: Double?
    let goal_weight: Double?
    let bio: String?
    let specialization: String?
    let experience_years: Int?
    let coach_id: String?
    let created_at: String?
}

struct SupabaseCoachFeedDTO: Decodable {
    let coach_id: String
    let name: String
    let specialization: String?
    let experience_years: Int?
    let rating: Double?
    let reviews_count: Int?
    let bio: String?
    let avatar_url: String?
}

final class SupabaseAPIClient {
    private let config: SupabaseConfig
    private let session: URLSession
    private let decoder: JSONDecoder

    init(config: SupabaseConfig = .shared, session: URLSession? = nil) {
        self.config = config
        if let session {
            self.session = session
        } else {
            let urlConfig = URLSessionConfiguration.default
            urlConfig.waitsForConnectivity = true
            urlConfig.timeoutIntervalForRequest = 30
            urlConfig.timeoutIntervalForResource = 60
            self.session = URLSession(configuration: urlConfig)
        }
        self.decoder = JSONDecoder()
    }

    var isConfigured: Bool { config.isConfigured }

    func signIn(email: String, password: String) async throws -> SupabaseAuthSession {
        try ensureConfigured()
        let requestBody: [String: String] = [
            "email": email,
            "password": password
        ]
        let request = try makeRequest(
            path: "/auth/v1/token?grant_type=password",
            method: "POST",
            bearerToken: nil,
            body: requestBody
        )
        let data = try await perform(request)
        return try decode(SupabaseAuthSession.self, from: data)
    }

    func signUp(name: String, email: String, password: String, role: UserRole, gender: UserGender?) async throws {
        try ensureConfigured()
        let requestBody: [String: Any] = [
            "email": email,
            "password": password,
            "data": [
                "name": name,
                "role": role.rawValue,
                "gender": (gender ?? .notSpecified).rawValue
            ]
        ]
        let request = try makeRequest(
            path: "/auth/v1/signup",
            method: "POST",
            bearerToken: nil,
            body: requestBody
        )
        _ = try await perform(request)
    }

    func fetchProfile(userID: String, accessToken: String) async throws -> SupabaseProfileDTO? {
        try ensureConfigured()
        let path = "/rest/v1/profiles?select=id,name,email,role,gender,current_weight,goal_weight,bio,specialization,experience_years,coach_id,created_at&id=eq.\(userID)&limit=1"
        let request = try makeRequest(path: path, method: "GET", bearerToken: accessToken, body: Optional<Int>.none)
        let data = try await perform(request)
        let profiles = try decode([SupabaseProfileDTO].self, from: data)
        return profiles.first
    }

    func upsertProfile(_ profile: SupabaseProfileDTO, accessToken: String) async throws {
        try ensureConfigured()
        let body: [String: Any] = [
            "id": profile.id,
            "name": profile.name,
            "email": profile.email,
            "role": profile.role,
            "gender": profile.gender as Any,
            "current_weight": profile.current_weight as Any,
            "goal_weight": profile.goal_weight as Any,
            "bio": profile.bio as Any,
            "specialization": profile.specialization as Any,
            "experience_years": profile.experience_years as Any,
            "coach_id": profile.coach_id as Any
        ]
        var request = try makeRequest(path: "/rest/v1/profiles", method: "POST", bearerToken: accessToken, body: body)
        request.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        _ = try await perform(request)
    }

    func fetchCoachFeed(accessToken: String? = nil) async throws -> [SupabaseCoachFeedDTO] {
        try ensureConfigured()
        let request = try makeRequest(
            path: "/rest/v1/coach_social_feed?select=coach_id,name,specialization,experience_years,rating,reviews_count,bio,avatar_url&order=rating.desc.nullslast",
            method: "GET",
            bearerToken: accessToken,
            body: Optional<Int>.none
        )
        let data = try await perform(request)
        return try decode([SupabaseCoachFeedDTO].self, from: data)
    }

    private func ensureConfigured() throws {
        guard config.isConfigured else {
            throw SupabaseClientError.missingConfiguration
        }
    }

    private func makeRequest(path: String, method: String, bearerToken: String?, body: Any?) throws -> URLRequest {
        guard let baseURL = config.url else {
            throw SupabaseClientError.missingConfiguration
        }
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw SupabaseClientError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        if let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        return request
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await performRequestWithRetry(request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseClientError.invalidResponse
        }
        switch http.statusCode {
        case 200...299:
            return data
        case 401:
            throw SupabaseClientError.unauthorized
        default:
            let message = parsedErrorMessage(from: data, statusCode: http.statusCode, request: request)
            throw SupabaseClientError.serverError(message ?? "Ошибка сервера: \(http.statusCode)")
        }
    }

    private func parsedErrorMessage(from data: Data, statusCode: Int, request: URLRequest) -> String? {
        let body = (try? JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
        let rawMessage = (body["message"] as? String)
            ?? (body["msg"] as? String)
            ?? (body["error_description"] as? String)
            ?? (body["error"] as? String)

        guard let rawMessage else { return nil }
        let message = rawMessage.lowercased()
        let path = request.url?.path ?? ""

        if statusCode == 400 {
            if message.contains("invalid login credentials") {
                return "Неверный email или пароль."
            }
            if message.contains("email not confirmed") {
                return "Подтвердите email и попробуйте снова."
            }
            if path.contains("/token") {
                return "Неверный email или пароль."
            }
            if path.contains("/signup") && message.contains("already registered") {
                return "Пользователь с таким email уже зарегистрирован."
            }
            if message.contains("password") && message.contains("6") {
                return "Пароль должен быть не короче 6 символов."
            }
        }

        if message.contains("invalid api key") || message.contains("apikey") {
            return "Неверный ключ Supabase API. Проверьте SUPABASE_ANON_KEY."
        }

        return rawMessage
    }

    private func performRequestWithRetry(_ request: URLRequest, maxRetries: Int = 2) async throws -> (Data, URLResponse) {
        var attempt = 0
        while true {
            do {
                return try await session.data(for: request)
            } catch let error as URLError {
                guard shouldRetry(error), attempt < maxRetries else {
                    throw SupabaseClientError.serverError(networkErrorMessage(for: error))
                }
                attempt += 1
                let delayNanos = UInt64(pow(2.0, Double(attempt - 1)) * 400_000_000)
                try await Task.sleep(nanoseconds: delayNanos)
            } catch {
                throw error
            }
        }
    }

    private func shouldRetry(_ error: URLError) -> Bool {
        switch error.code {
        case .networkConnectionLost, .timedOut, .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }

    private func networkErrorMessage(for error: URLError) -> String {
        switch error.code {
        case .networkConnectionLost:
            return "Сеть прервалась во время запроса. Проверьте интернет и повторите."
        case .timedOut:
            return "Сервер не ответил вовремя. Повторите попытку."
        case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return "Не удается подключиться к серверу Supabase. Проверьте сеть/VPN/DNS."
        default:
            return "Сетевая ошибка (\(error.code.rawValue)). Повторите попытку."
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw SupabaseClientError.invalidResponse
        }
    }
}
