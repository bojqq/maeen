import Foundation

/// Service for fetching Quran data from quranapi.pages.dev
/// API Documentation: https://quranapi.pages.dev/docs
actor QuranAPIService {
    static let shared = QuranAPIService()

    private let baseURL = "https://quranapi.pages.dev/api"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Chapters

    /// Fetch list of all surahs/chapters
    func fetchChapters() async throws -> [QuranChapter] {
        let url = URL(string: "\(baseURL)/chapters")!
        return try await fetch(url)
    }

    /// Fetch a specific surah by number (1-114)
    func fetchSurah(_ surahNumber: Int) async throws -> QuranSurah {
        let url = URL(string: "\(baseURL)/\(surahNumber)")!
        return try await fetch(url)
    }

    // MARK: - Verses

    /// Fetch a specific verse
    func fetchVerse(surah: Int, ayah: Int) async throws -> QuranVerse {
        let url = URL(string: "\(baseURL)/\(surah)/\(ayah)")!
        return try await fetch(url)
    }

    // MARK: - Audio

    /// Fetch available reciters
    func fetchReciters() async throws -> [QuranReciter] {
        let url = URL(string: "\(baseURL)/reciters")!
        return try await fetch(url)
    }

    /// Get audio URL for a verse
    func audioURL(reciter: String, surah: Int, ayah: Int) -> URL? {
        URL(string: "\(baseURL)/audio/\(reciter)/\(surah)/\(ayah)")
    }

    // MARK: - Private

    private func fetch<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QuranAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw QuranAPIError.httpError(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw QuranAPIError.decodingError(error)
        }
    }
}

// MARK: - Error Types

enum QuranAPIError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Models

struct QuranChapter: Codable, Identifiable {
    let id: Int
    let name: String
    let transliteration: String?
    let translation: String?
    let totalVerses: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case transliteration
        case translation
        case totalVerses = "total_verses"
    }
}

struct QuranSurah: Codable {
    let id: Int
    let name: String
    let transliteration: String?
    let translation: String?
    let totalVerses: Int?
    let verses: [QuranVerse]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case transliteration
        case translation
        case totalVerses = "total_verses"
        case verses
    }
}

struct QuranVerse: Codable, Identifiable {
    var id: String { "\(surahId ?? 0):\(verseNumber ?? 0)" }
    let surahId: Int?
    let verseNumber: Int?
    let text: String?
    let textArabic: String?
    let translation: String?

    enum CodingKeys: String, CodingKey {
        case surahId = "surah_id"
        case verseNumber = "verse_number"
        case text
        case textArabic = "text_arabic"
        case translation
    }
}

struct QuranReciter: Codable, Identifiable {
    let id: String
    let name: String
    let style: String?
}
