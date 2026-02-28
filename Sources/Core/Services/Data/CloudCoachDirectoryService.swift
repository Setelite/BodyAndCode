import Foundation

final class CloudCoachDirectoryService {
    private let api: SupabaseAPIClient

    init(api: SupabaseAPIClient = SupabaseAPIClient()) {
        self.api = api
    }

    var isConfigured: Bool { api.isConfigured }

    func loadCoaches(accessToken: String?) async throws -> [Coach] {
        let feed = try await api.fetchCoachFeed(accessToken: accessToken)
        return feed.compactMap { row in
            guard let id = UUID(uuidString: row.coach_id) else { return nil }
            return Coach(
                id: id,
                name: row.name,
                specialization: row.specialization ?? "Персональный тренер",
                experience: "\(row.experience_years ?? 0) лет",
                rating: row.rating ?? 0,
                reviewCount: row.reviews_count ?? 0,
                description: row.bio ?? "Тренер Body&Code",
                imageName: row.avatar_url ?? "",
                reviews: [],
                isFavorite: false,
                certifications: [],
                achievements: [],
                availableSlots: [],
                prices: [:]
            )
        }
    }
}

