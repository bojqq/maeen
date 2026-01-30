import SwiftUI

struct MissingSegmentGame: View {
    let surah: Surah
    let chunks: [AyahChunk]

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var supabaseService: SupabaseService

    @State private var questions: [MissingSegmentQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var isAnswerRevealed = false
    @State private var correctAnswers = 0
    @State private var isComplete = false
    @State private var startTime = Date()
    @State private var questionResults: [(chunkId: UUID, isCorrect: Bool)] = []

    var currentQuestion: MissingSegmentQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var body: some View {
        ZStack {
            Color.maeemBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                GameHeader(
                    title: "أكمل الفراغ",
                    surahName: surah.nameAr,
                    onClose: { dismiss() }
                )

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.maeemWhite.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.maeemGold)
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 24)

                if isComplete {
                    GameResultView(
                        score: Double(correctAnswers) / Double(questions.count),
                        activityType: .missingSegment,
                        onRetry: { resetGame() },
                        onContinue: { dismiss() }
                    )
                } else if let question = currentQuestion {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Question counter
                            Text("السؤال \(currentQuestionIndex + 1) من \(questions.count)")
                                .font(MaeemTypography.caption)
                                .foregroundColor(.maeemSoftWhite.opacity(0.6))
                                .padding(.top, 24)

                            // Ayah with missing word
                            AyahWithMissing(
                                beforeMissing: question.beforeMissing,
                                afterMissing: question.afterMissing,
                                selectedAnswer: selectedAnswer,
                                correctAnswer: question.correctAnswer,
                                isRevealed: isAnswerRevealed
                            )

                            // Answer options
                            VStack(spacing: 12) {
                                ForEach(question.options, id: \.self) { option in
                                    AnswerOption(
                                        text: option,
                                        isSelected: selectedAnswer == option,
                                        isCorrect: option == question.correctAnswer,
                                        isRevealed: isAnswerRevealed
                                    ) {
                                        if !isAnswerRevealed {
                                            selectAnswer(option)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }

                    // Next button
                    if isAnswerRevealed {
                        MaeemButton(
                            currentQuestionIndex == questions.count - 1 ? "النتائج" : "التالي",
                            icon: "arrow.left"
                        ) {
                            nextQuestion()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            setupGame()
        }
    }

    private func setupGame() {
        questions = generateQuestions()
        currentQuestionIndex = 0
        correctAnswers = 0
        isComplete = false
    }

    private func resetGame() {
        isComplete = false
        setupGame()
    }

    private func generateQuestions() -> [MissingSegmentQuestion] {
        var generatedQuestions: [MissingSegmentQuestion] = []

        for chunk in chunks {
            let words = chunk.displayText.components(separatedBy: " ")
            guard words.count >= 3 else { continue }

            // Pick a word to hide (not first or last)
            let hideIndex = Int.random(in: 1..<(words.count - 1))
            let correctWord = words[hideIndex]

            // Generate wrong options from other chunks
            var options = [correctWord]
            for otherChunk in chunks where otherChunk.id != chunk.id {
                let otherWords = otherChunk.displayText.components(separatedBy: " ")
                if let randomWord = otherWords.randomElement(), !options.contains(randomWord) {
                    options.append(randomWord)
                }
                if options.count >= 3 { break }
            }

            // Fill with dummy options if needed
            while options.count < 3 {
                options.append("---")
            }

            let beforeMissing = words[0..<hideIndex].joined(separator: " ")
            let afterMissing = words[(hideIndex + 1)...].joined(separator: " ")

            generatedQuestions.append(MissingSegmentQuestion(
                chunkId: chunk.id,
                beforeMissing: beforeMissing,
                afterMissing: afterMissing,
                correctAnswer: correctWord,
                options: options.shuffled()
            ))
        }

        return generatedQuestions.shuffled()
    }

    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isAnswerRevealed = true

        let isCorrect = answer == currentQuestion?.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }

        // Track result for this question
        if let question = currentQuestion {
            questionResults.append((chunkId: question.chunkId, isCorrect: isCorrect))
        }
    }

    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            isAnswerRevealed = false
        } else {
            isComplete = true
            // Save all attempts
            Task {
                await saveAttempts()
            }
        }
    }

    private func saveAttempts() async {
        guard let childId = appState.currentChild?.id else { return }

        let timeSpent = Int(Date().timeIntervalSince(startTime))
        let timePerQuestion = timeSpent / max(1, questions.count)

        // Group results by chunk
        var chunkScores: [UUID: (correct: Int, total: Int)] = [:]
        for result in questionResults {
            if var existing = chunkScores[result.chunkId] {
                existing.total += 1
                if result.isCorrect { existing.correct += 1 }
                chunkScores[result.chunkId] = existing
            } else {
                chunkScores[result.chunkId] = (correct: result.isCorrect ? 1 : 0, total: 1)
            }
        }

        // Save attempt for each chunk
        for (chunkId, scores) in chunkScores {
            let chunkScore = Double(scores.correct) / Double(scores.total)
            let attempt = AttemptInsert(
                childId: childId,
                chunkId: chunkId,
                activityType: ActivityType.missingSegment.rawValue,
                score: chunkScore,
                timeSpentSeconds: timePerQuestion
            )

            do {
                try await supabaseService.saveAttempt(attempt)

                // Update review schedule
                await updateReviewSchedule(for: chunkId, score: chunkScore, childId: childId)
            } catch {
                print("Error saving attempt: \(error)")
            }
        }
    }

    private func updateReviewSchedule(for chunkId: UUID, score: Double, childId: UUID) async {
        do {
            let schedules = try await supabaseService.fetchReviewSchedule(childId: childId)
            if let existing = schedules.first(where: { $0.chunkId == chunkId }) {
                let newSchedule = SchedulerService.shared.updateSchedule(
                    current: existing,
                    score: score
                )
                try await supabaseService.upsertReviewSchedule(newSchedule)
            } else {
                let newSchedule = SchedulerService.shared.initialSchedule(
                    chunkId: chunkId,
                    childId: childId
                )
                try await supabaseService.upsertReviewSchedule(newSchedule)
            }
        } catch {
            print("Error updating review schedule: \(error)")
        }
    }
}

// MARK: - Question Model

struct MissingSegmentQuestion {
    let chunkId: UUID
    let beforeMissing: String
    let afterMissing: String
    let correctAnswer: String
    let options: [String]
}

// MARK: - Ayah With Missing

struct AyahWithMissing: View {
    let beforeMissing: String
    let afterMissing: String
    let selectedAnswer: String?
    let correctAnswer: String
    let isRevealed: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Before missing
            if !beforeMissing.isEmpty {
                Text(beforeMissing)
                    .font(MaeemTypography.quranMedium)
                    .foregroundColor(.maeemWhite)
                    .multilineTextAlignment(.center)
            }

            // Missing word placeholder
            if let answer = selectedAnswer, isRevealed {
                Text(answer)
                    .font(MaeemTypography.quranMedium)
                    .foregroundColor(answer == correctAnswer ? .success : .maeemOrange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        (answer == correctAnswer ? Color.success : Color.maeemOrange)
                            .opacity(0.2)
                    )
                    .cornerRadius(8)
            } else {
                Text("؟؟؟")
                    .font(MaeemTypography.quranMedium)
                    .foregroundColor(.maeemGold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.maeemGold.opacity(0.2))
                    .cornerRadius(8)
            }

            // After missing
            if !afterMissing.isEmpty {
                Text(afterMissing)
                    .font(MaeemTypography.quranMedium)
                    .foregroundColor(.maeemWhite)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - Answer Option

struct AnswerOption: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isRevealed: Bool
    let action: () -> Void

    var backgroundColor: Color {
        if isRevealed {
            if isCorrect {
                return Color.success.opacity(0.2)
            } else if isSelected {
                return Color.maeemOrange.opacity(0.2)
            }
        }
        return isSelected ? Color.maeemGold.opacity(0.2) : Color.maeemWhite.opacity(0.05)
    }

    var borderColor: Color {
        if isRevealed {
            if isCorrect {
                return Color.success
            } else if isSelected {
                return Color.maeemOrange
            }
        }
        return isSelected ? Color.maeemGold : Color.clear
    }

    var textColor: Color {
        if isRevealed && isCorrect {
            return .success
        } else if isRevealed && isSelected && !isCorrect {
            return .maeemOrange
        }
        return .maeemWhite
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(MaeemTypography.quranSmall)
                    .foregroundColor(textColor)

                Spacer()

                if isRevealed && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.success)
                } else if isRevealed && isSelected && !isCorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.maeemOrange)
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled(isRevealed)
    }
}

#Preview {
    MissingSegmentGame(
        surah: Surah(id: 112, nameAr: "الإخلاص", nameEn: "Al-Ikhlas", totalAyahs: 4, revelationType: "meccan"),
        chunks: []
    )
    .environmentObject(AppState.shared)
}
