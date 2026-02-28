import Foundation

struct SupabaseConfig {
    let url: URL?
    let anonKey: String

    var isConfigured: Bool {
        url != nil && !anonKey.isEmpty
    }

    static let shared = SupabaseConfig.load()

    private static func load() -> SupabaseConfig {
        let info = Bundle.main.infoDictionary
        let infoURL = (info?["SUPABASE_URL"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let infoKey = (info?["SUPABASE_ANON_KEY"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Xcode 26 may skip custom keys in generated Info.plist for some setups.
        // Keep a safe runtime fallback to prevent app from switching to mock auth.
        let fallbackURL = "https://lvltghhgwxrookyglodz.supabase.co"
        let fallbackKey = "sb_publishable_-EVpy1Hw0AJ04IEh6c1R5w_TwhfDBsb"

        let finalURLString = (infoURL?.isEmpty == false) ? infoURL! : fallbackURL
        let finalKey = (infoKey?.isEmpty == false) ? infoKey! : fallbackKey

        return SupabaseConfig(
            url: URL(string: finalURLString),
            anonKey: finalKey
        )
    }
}
