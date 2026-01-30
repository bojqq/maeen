import SwiftUI

struct LevelCheckView: View {
    let surah: Surah
    let chunks: [AyahChunk]
    let onComplete: (DifficultyLevel) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var questions: [LevelCheckQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var correctAnswers = 0
    @State private var isComplete = false
    @State private var startTime = Date()

    var currentQuestion: LevelCheckQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var determinedLevel: DifficultyLevel {
        let score = Double(correctAnswers) / Double(max(1, questions.count))
        if score >= 0.8 {
            return .advanced
        } else if score >= 0.5 {
            return .intermediate
        } else {
            return .beginner
        }
    }

    var body: some View {
        ZStack {
            Color.maeemBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                LevelCheckHeader(
                    progress: progress,
                    onSkip: {
                        onComplete(.beginner)
                    }
                )

                if isComplete {
                    // Results
                    LevelCheckResultView(
                        level: determinedLevel,
                        score: Double(correctAnswers) / Double(max(1, questions.count)),
                        onContinue: {
                            onComplete(determinedLevel)
                        }
                    )
                } else if let question = currentQuestion {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Question counter
                            Text("السؤال \(currentQuestionIndex + 1) من \(questions.count)")
                                .font(MaeemTypography.caption)
                                .foregroundColor(.maeemSoftWhite.opacity(0.6))
                                .padding(.top, 24)

                            // Question type indicator
                            HStack(spacing: 8) {
                                Image(systemName: question.type.icon)
                                    .foregroundColor(.maeemGold)
                                Text(question.type.displayName)
                                    .font(MaeemTypography.body)
                                    .foregroundColor(.maeemGold)
                            }

                            // Question content
                            QuestionContentView(question: question)

                            // Answer options
                            VStack(spacing: 12) {
                                ForEach(0..<question.options.count, id: \.self) { index in
                                    LevelCheckOption(
                                        text: question.options[index],
                                        isSelected: selectedAnswer == index,
                                        isCorrect: index == question.correctIndex,
                                        isRevealed: selectedAnswer != nil
                                    ) {
                                        if selectedAnswer == nil {
                                            selectAnswer(index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }

                    // Next button
                    if selectedAnswer != nil {
                        MaeemButton(
                            currentQuestionIndex == questions.count - 1 ? "النتيجة" : "التالي",
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
        .navigationBarHidden(true)
        .onAppear {
            setupQuestions()
        }
    }

    private func setupQuestions() {
        questions = generateQuestions()
        currentQuestionIndex = 0
        correctAnswers = 0
        selectedAnswer = nil
        isComplete = false
        startTime = Date()
    }

    private func generateQuestions() -> [LevelCheckQuestion] {
        var generatedQuestions: [LevelCheckQuestion] = []

        // Question 1: Recognition - Which ayah comes first?
        if chunks.count >= 2 {
            let shuffledChunks = chunks.shuffled()
            let firstChunk = shuffledChunks[0]
            let secondChunk = shuffledChunks[1]

            let options = [firstChunk.displayText, secondChunk.displayText].shuffled()
            let correctIndex = options.firstIndex(of: firstChunk.chunkIndex < secondChunk.chunkIndex ? firstChunk.displayText : secondChunk.displayText) ?? 0

            generatedQuestions.append(LevelCheckQuestion(
                type: .recognition,
                prompt: "أي آية تأتي أولاً؟",
                ayahText: nil,
                options: options,
                correctIndex: correctIndex
            ))
        }

        // Question 2: Completion - Fill in the missing word
        for chunk in chunks.prefix(2) {
            let words = chunk.displayText.components(separatedBy: " ")
            guard words.count >= 3 else { continue }

            let hideIndex = Int.random(in: 1..<(words.count - 1))
            let correctWord = words[hideIndex]

            var options = [correctWord]
            for otherChunk in chunks where otherChunk.id != chunk.id {
                let otherWords = otherChunk.displayText.components(separatedBy: " ")
                if let randomWord = otherWords.randomElement(), !options.contains(randomWord) {
                    options.append(randomWord)
                }
                if options.count >= 3 { break }
            }
            while options.count < 3 {
                options.append("---")
            }
            options.shuffle()

            let displayText = words.enumerated().map { index, word in
                index == hideIndex ? "______" : word
            }.joined(separator: " ")

            generatedQuestions.append(LevelCheckQuestion(
                type: .completion,
                prompt: "أكمل الفراغ:",
                ayahText: displayText,
                options: options,
                correctIndex: options.firstIndex(of: correctWord) ?? 0
            ))
        }

        // Question 3: Order - Which chunk comes next?
        if chunks.count >= 3 {
            let startIndex = Int.random(in: 0..<(chunks.count - 2))
            let currentChunk = chunks[startIndex]
            let nextChunk = chunks[startIndex + 1]

            var options = [nextChunk.displayText]
            for i in 0..<chunks.count where i != startIndex && i != startIndex + 1 {
                if options.count < 3 {
                    options.append(chunks[i].displayText)
                }
            }
            options.shuffle()

            generatedQuestions.append(LevelCheckQuestion(
                type: .ordering,
                prompt: "ما المقطع التالي بعد هذه الآية؟",
                ayahText: currentChunk.displayText,
                options: options,
                correctIndex: options.firstIndex(of: nextChunk.displayText) ?? 0
            ))
        }

        return generatedQuestions.shuffled()
    }

    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        if index == currentQuestion?.correctIndex {
            correctAnswers += 1
        }
    }

    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
        } else {
            isComplete = true
        }
    }
}

// MARK: - Question Types

enum LevelCheckQuestionType {
    case recognition
    case completion
    case ordering

    var displayName: String {
        switch self {
        case .recognition: return "التعرّف"
        case .completion: return "إكمال"
        case .ordering: return "ترتيب"
        }
    }

    var icon: String {
        switch self {
        case .recognition: return "eye.fill"
        case .completion: return "text.badge.plus"
        case .ordering: return "arrow.up.arrow.down"
        }
    }
}

struct LevelCheckQuestion {
    let type: LevelCheckQuestionType
    let prompt: String
    let ayahText: String?
    let options: [String]
    let correctIndex: Int
}

// MARK: - Level Check Header

struct LevelCheckHeader: View {
    let progress: Double
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("اختبار المستوى")
                    .font(MaeemTypography.titleSmall)
                    .foregroundColor(.maeemWhite)

                Spacer()

                Button(action: onSkip) {
                    Text("تخطي")
                        .font(MaeemTypography.body)
                        .foregroundColor(.maeemSoftWhite.opacity(0.6))
                }
            }

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
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Question Content View

struct QuestionContentView: View {
    let question: LevelCheckQuestion

    var body: some View {
        VStack(spacing: 16) {
            Text(question.prompt)
                .font(MaeemTypography.titleMedium)
                .foregroundColor(.maeemWhite)
                .multilineTextAlignment(.center)

            if let ayahText = question.ayahText {
                Text(ayahText)
                    .font(MaeemTypography.quranMedium)
                    .foregroundColor(.maeemWhite)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color.maeemWhite.opacity(0.05))
                    .cornerRadius(16)
            }
        }
    }
}

// MARK: - Level Check Option

struct LevelCheckOption: View {
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
                    .multilineTextAlignment(.trailing)

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

// MARK: - Level Check Result View

struct LevelCheckResultView: View {
    let level: DifficultyLevel
    let score: Double
    let onContinue: () -> Void

    var levelColor: Color {
        switch level {
        case .beginner: return .maeemGold
        case .intermediate: return .maeemAmber
        case .advanced: return .success
        }
    }

    var levelIcon: String {
        switch level {
        case .beginner: return "leaf.fill"
        case .intermediate: return "star.fill"
        case .advanced: return "crown.fill"
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Level badge
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(levelColor.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: levelIcon)
                        .font(.system(size: 48))
                        .foregroundColor(levelColor)
                }

                Text("مستواك: \(level.displayNameAr)")
                    .font(MaeemTypography.titleLarge)
                    .foregroundColor(.maeemWhite)

                Text("نتيجتك: \(Int(score * 100))%")
                    .font(MaeemTypography.body)
                    .foregroundColor(.maeemSoftWhite.opacity(0.7))
            }

            // Description
            Text(levelDescription)
                .font(MaeemTypography.body)
                .foregroundColor(.maeemSoftWhite.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Continue button
            MaeemButton("ابدأ التعلّم", icon: "arrow.left") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    var levelDescription: String {
        switch level {
        case .beginner:
            return "سنبدأ معك من الأساسيات. لا تقلق، معين سيساعدك خطوة بخطوة!"
        case .intermediate:
            return "عندك أساس جيد! سنركز على تثبيت الحفظ وتقوية المراجعة."
        case .advanced:
            return "ماشاء الله! مستواك متقدم. سنركز على الإتقان والمراجعة المتقدمة."
        }
    }
}

#Preview {
    LevelCheckView(
        surah: Surah(id: 112, nameAr: "الإخلاص", nameEn: "Al-Ikhlas", totalAyahs: 4, revelationType: "meccan"),
        chunks: [],
        onComplete: { _ in }
    )
}
