import Foundation

/// Service for Spaced Repetition scheduling (SM-2 algorithm based)
/// Handles review scheduling and adaptive learning
class SchedulerService {
    static let shared = SchedulerService()

    private init() {}

    // MARK: - SM-2 Algorithm Constants

    private let minimumEaseFactor: Double = 1.3
    private let defaultEaseFactor: Double = 2.5

    // MARK: - Calculate Next Review

    /// Calculate next review schedule based on performance
    /// - Parameters:
    ///   - score: Performance score (0.0 - 1.0)
    ///   - currentInterval: Current interval in days
    ///   - easeFactor: Current ease factor
    ///   - repetitions: Number of successful repetitions
    /// - Returns: Updated schedule parameters
    func calculateNextReview(
        score: Double,
        currentInterval: Int,
        easeFactor: Double,
        repetitions: Int
    ) -> (nextReviewAt: Date, intervalDays: Int, easeFactor: Double, repetitions: Int) {

        // Convert score (0-1) to quality (0-5) for SM-2
        let quality = Int(score * 5)

        var newEaseFactor = easeFactor
        var newInterval = currentInterval
        var newRepetitions = repetitions

        if quality >= 3 {
            // Successful recall
            switch newRepetitions {
            case 0:
                newInterval = 1
            case 1:
                newInterval = 6
            default:
                newInterval = Int(Double(currentInterval) * easeFactor)
            }
            newRepetitions += 1

            // Update ease factor
            newEaseFactor = easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
            newEaseFactor = max(minimumEaseFactor, newEaseFactor)
        } else {
            // Failed recall - reset
            newRepetitions = 0
            newInterval = 1
        }

        let nextReviewAt = Calendar.current.date(byAdding: .day, value: newInterval, to: Date()) ?? Date()

        return (nextReviewAt, newInterval, newEaseFactor, newRepetitions)
    }

    // MARK: - Helpers

    /// Get initial schedule for a new chunk
    func initialSchedule(chunkId: UUID, childId: UUID) -> ReviewScheduleInsert {
        ReviewScheduleInsert(
            childId: childId,
            chunkId: chunkId,
            nextReviewAt: Date(), // Review immediately for first time
            intervalDays: 0,
            easeFactor: defaultEaseFactor,
            repetitions: 0
        )
    }

    /// Update schedule after an attempt
    func updateSchedule(
        current: ReviewSchedule,
        score: Double
    ) -> ReviewScheduleInsert {
        let result = calculateNextReview(
            score: score,
            currentInterval: current.intervalDays,
            easeFactor: current.easeFactor,
            repetitions: current.repetitions
        )

        return ReviewScheduleInsert(
            childId: current.childId,
            chunkId: current.chunkId,
            nextReviewAt: result.nextReviewAt,
            intervalDays: result.intervalDays,
            easeFactor: result.easeFactor,
            repetitions: result.repetitions
        )
    }

    /// Determine difficulty level based on performance history
    func suggestedDifficulty(attempts: [Attempt]) -> DifficultyLevel {
        guard !attempts.isEmpty else { return .beginner }

        let averageScore = attempts.map { $0.score }.reduce(0, +) / Double(attempts.count)
        let recentAttempts = attempts.prefix(5)
        let recentAverage = recentAttempts.map { $0.score }.reduce(0, +) / Double(recentAttempts.count)

        if recentAverage >= 0.9 && averageScore >= 0.8 {
            return .advanced
        } else if recentAverage >= 0.7 && averageScore >= 0.6 {
            return .intermediate
        } else {
            return .beginner
        }
    }

    /// Get chunks that need review today
    func filterDueChunks(_ schedules: [ReviewSchedule]) -> [ReviewSchedule] {
        let now = Date()
        return schedules.filter { $0.nextReviewAt <= now }
    }

    /// Sort chunks by priority (most overdue first)
    func prioritizeReviews(_ schedules: [ReviewSchedule]) -> [ReviewSchedule] {
        schedules.sorted { $0.nextReviewAt < $1.nextReviewAt }
    }
}

// MARK: - Supporting Types

enum DifficultyLevel: String, Codable {
    case beginner
    case intermediate
    case advanced

    var displayName: String {
        switch self {
        case .beginner: return "مبتدئ"
        case .intermediate: return "متوسط"
        case .advanced: return "متقدم"
        }
    }
}
