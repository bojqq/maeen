import Foundation
import Supabase

/// Main service for Supabase operations
/// Add Supabase Swift SDK via SPM: https://github.com/supabase/supabase-swift
@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    let client: SupabaseClient

    @Published var currentUser: User?
    @Published var currentProfile: Profile?
    @Published var isAuthenticated = false

    private init() {
        // Load from Config.xcconfig via Info.plist
        let supabaseURL = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
        let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""

        self.client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )

        Task {
            await checkSession()
        }
    }

    // MARK: - Auth

    func checkSession() async {
        do {
            let session = try await client.auth.session
            self.currentUser = session.user
            self.isAuthenticated = true
            await fetchProfile()
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }

    func signUp(email: String, password: String, role: String, name: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        self.currentUser = response.user

        // Create profile
        let profile = ProfileInsert(id: response.user.id, role: role, name: name)
        try await client.from("profiles").insert(profile).execute()

        self.isAuthenticated = true
        await fetchProfile()
    }

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        self.currentUser = session.user
        self.isAuthenticated = true
        await fetchProfile()
    }

    func signOut() async throws {
        try await client.auth.signOut()
        self.currentUser = nil
        self.currentProfile = nil
        self.isAuthenticated = false
    }

    func fetchProfile() async {
        guard let userId = currentUser?.id else { return }
        do {
            let profile: Profile = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            self.currentProfile = profile
        } catch {
            print("Error fetching profile: \(error)")
        }
    }

    // MARK: - Children

    func fetchChildren() async throws -> [Child] {
        try await client
            .from("children")
            .select()
            .execute()
            .value
    }

    func addChild(_ child: ChildInsert) async throws {
        try await client.from("children").insert(child).execute()
    }

    func updateChildLevel(childId: UUID, level: String) async throws {
        try await client
            .from("children")
            .update(["level": level])
            .eq("id", value: childId)
            .execute()
    }

    // MARK: - Surahs & Chunks

    func fetchSurahs() async throws -> [Surah] {
        try await client
            .from("surahs")
            .select()
            .execute()
            .value
    }

    func fetchChunks(surahId: Int) async throws -> [AyahChunk] {
        try await client
            .from("ayah_chunks")
            .select()
            .eq("surah_id", value: surahId)
            .order("chunk_index")
            .execute()
            .value
    }

    // MARK: - Attempts

    func saveAttempt(_ attempt: AttemptInsert) async throws {
        try await client.from("attempts").insert(attempt).execute()
    }

    func fetchAttempts(childId: UUID) async throws -> [Attempt] {
        try await client
            .from("attempts")
            .select()
            .eq("child_id", value: childId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Review Schedule

    func fetchReviewSchedule(childId: UUID) async throws -> [ReviewSchedule] {
        try await client
            .from("review_schedule")
            .select()
            .eq("child_id", value: childId)
            .execute()
            .value
    }

    func fetchDueReviews(childId: UUID) async throws -> [ReviewSchedule] {
        let now = ISO8601DateFormatter().string(from: Date())
        return try await client
            .from("review_schedule")
            .select()
            .eq("child_id", value: childId)
            .lte("next_review_at", value: now)
            .execute()
            .value
    }

    func upsertReviewSchedule(_ schedule: ReviewScheduleInsert) async throws {
        try await client.from("review_schedule").upsert(schedule).execute()
    }
}

// MARK: - Database Models

struct Profile: Codable, Identifiable {
    let id: UUID
    let role: String
    let name: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, role, name
        case createdAt = "created_at"
    }
}

struct ProfileInsert: Codable {
    let id: UUID
    let role: String
    let name: String
}

struct Child: Codable, Identifiable {
    let id: UUID
    let parentId: UUID
    let name: String
    let age: Int
    let level: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, age, level
        case parentId = "parent_id"
        case createdAt = "created_at"
    }
}

struct ChildInsert: Codable {
    let parentId: UUID
    let name: String
    let age: Int
    let level: String

    enum CodingKeys: String, CodingKey {
        case name, age, level
        case parentId = "parent_id"
    }
}

struct Surah: Codable, Identifiable {
    let id: Int
    let nameAr: String
    let nameEn: String
    let totalAyahs: Int?
    let revelationType: String?

    enum CodingKeys: String, CodingKey {
        case id
        case nameAr = "name_ar"
        case nameEn = "name_en"
        case totalAyahs = "total_ayahs"
        case revelationType = "revelation_type"
    }
}

struct AyahChunk: Codable, Identifiable {
    let id: UUID
    let surahId: Int
    let chunkIndex: Int
    let ayahStart: Int
    let ayahEnd: Int
    let displayText: String
    let visualKey: String?
    let audioUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case surahId = "surah_id"
        case chunkIndex = "chunk_index"
        case ayahStart = "ayah_start"
        case ayahEnd = "ayah_end"
        case displayText = "display_text"
        case visualKey = "visual_key"
        case audioUrl = "audio_url"
    }
}

struct Attempt: Codable, Identifiable {
    let id: UUID
    let childId: UUID
    let chunkId: UUID
    let activityType: String
    let score: Double
    let mistakes: [String: Any]?
    let timeSpentSeconds: Int?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case chunkId = "chunk_id"
        case activityType = "activity_type"
        case score
        case mistakes
        case timeSpentSeconds = "time_spent_seconds"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        childId = try container.decode(UUID.self, forKey: .childId)
        chunkId = try container.decode(UUID.self, forKey: .chunkId)
        activityType = try container.decode(String.self, forKey: .activityType)
        score = try container.decode(Double.self, forKey: .score)
        timeSpentSeconds = try container.decodeIfPresent(Int.self, forKey: .timeSpentSeconds)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        mistakes = nil // JSONB decoded separately if needed
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(childId, forKey: .childId)
        try container.encode(chunkId, forKey: .chunkId)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(score, forKey: .score)
        try container.encodeIfPresent(timeSpentSeconds, forKey: .timeSpentSeconds)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

struct AttemptInsert: Codable {
    let childId: UUID
    let chunkId: UUID
    let activityType: String
    let score: Double
    let timeSpentSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case childId = "child_id"
        case chunkId = "chunk_id"
        case activityType = "activity_type"
        case score
        case timeSpentSeconds = "time_spent_seconds"
    }
}

struct ReviewSchedule: Codable, Identifiable {
    let id: UUID
    let childId: UUID
    let chunkId: UUID
    let nextReviewAt: Date
    let intervalDays: Int
    let easeFactor: Double
    let repetitions: Int

    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case chunkId = "chunk_id"
        case nextReviewAt = "next_review_at"
        case intervalDays = "interval_days"
        case easeFactor = "ease_factor"
        case repetitions
    }
}

struct ReviewScheduleInsert: Codable {
    let childId: UUID
    let chunkId: UUID
    let nextReviewAt: Date
    let intervalDays: Int
    let easeFactor: Double
    let repetitions: Int

    enum CodingKeys: String, CodingKey {
        case childId = "child_id"
        case chunkId = "chunk_id"
        case nextReviewAt = "next_review_at"
        case intervalDays = "interval_days"
        case easeFactor = "ease_factor"
        case repetitions
    }
}
