import Foundation

// MARK: - User Role

enum UserRole: String, Codable, CaseIterable {
    case parent
    case child

    var displayName: String {
        switch self {
        case .parent: return "والد/والدة"
        case .child: return "طفل"
        }
    }

    var icon: String {
        switch self {
        case .parent: return "person.2.fill"
        case .child: return "face.smiling.fill"
        }
    }
}

// MARK: - Difficulty Level

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced

    var displayNameAr: String {
        switch self {
        case .beginner: return "مبتدئ"
        case .intermediate: return "متوسط"
        case .advanced: return "متقدم"
        }
    }

    var displayNameEn: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

// MARK: - Activity Type

enum ActivityType: String, Codable {
    case orderGame = "order_game"
    case missingSegment = "missing_segment"
    case recite

    var displayName: String {
        switch self {
        case .orderGame: return "ترتيب المقاطع"
        case .missingSegment: return "أكمل الفراغ"
        case .recite: return "التسميع"
        }
    }
}

// MARK: - Chunk Visual Theme

struct ChunkVisual {
    let iconName: String
    let color: String

    static func from(visualKey: String?) -> ChunkVisual {
        guard let key = visualKey else {
            return ChunkVisual(iconName: "star.fill", color: "maeemGold")
        }

        switch key {
        case "unity_light":
            return ChunkVisual(iconName: "sun.max.fill", color: "maeemGold")
        case "eternal_star":
            return ChunkVisual(iconName: "star.fill", color: "maeemAmber")
        case "dawn_moon":
            return ChunkVisual(iconName: "moon.fill", color: "maeemOrange")
        case "gift_heart":
            return ChunkVisual(iconName: "heart.fill", color: "maeemGold")
        case "shelter_path":
            return ChunkVisual(iconName: "house.fill", color: "maeemAmber")
        case "kindness_blessing":
            return ChunkVisual(iconName: "hands.sparkles.fill", color: "maeemOrange")
        default:
            return ChunkVisual(iconName: "circle.fill", color: "maeemGold")
        }
    }
}

// MARK: - Game Result

struct GameResult {
    let activityType: ActivityType
    let score: Double
    let totalQuestions: Int
    let correctAnswers: Int
    let timeSpent: TimeInterval
    let mistakes: [String]

    var percentage: Int {
        Int(score * 100)
    }

    var isPassing: Bool {
        score >= 0.7
    }

    var feedbackMessage: String {
        switch score {
        case 0.9...1.0:
            return "ممتاز! أحسنت"
        case 0.7..<0.9:
            return "جيد جداً، استمر"
        case 0.5..<0.7:
            return "جيد، تحتاج مراجعة"
        default:
            return "حاول مرة أخرى"
        }
    }
}

// MARK: - Learning Session

struct LearningSession {
    let surahId: Int
    let surahName: String
    var currentChunkIndex: Int = 0
    var chunks: [AyahChunk] = []
    var completedChunks: Set<UUID> = []

    var progress: Double {
        guard !chunks.isEmpty else { return 0 }
        return Double(completedChunks.count) / Double(chunks.count)
    }

    var currentChunk: AyahChunk? {
        guard currentChunkIndex < chunks.count else { return nil }
        return chunks[currentChunkIndex]
    }

    var isComplete: Bool {
        completedChunks.count == chunks.count
    }
}

// MARK: - Review Item

struct ReviewItem: Identifiable {
    let id: UUID
    let chunk: AyahChunk
    let schedule: ReviewSchedule
    let surahName: String

    var isOverdue: Bool {
        schedule.nextReviewAt < Date()
    }

    var daysUntilReview: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: schedule.nextReviewAt).day ?? 0
        return max(0, days)
    }
}
