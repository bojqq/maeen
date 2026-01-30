import SwiftUI

struct OrderChunksGame: View {
    let surah: Surah
    let chunks: [AyahChunk]

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var supabaseService: SupabaseService

    @State private var shuffledChunks: [AyahChunk] = []
    @State private var userOrder: [AyahChunk] = []
    @State private var isComplete = false
    @State private var score: Double = 0
    @State private var startTime = Date()
    @State private var isSaving = false

    var body: some View {
        ZStack {
            Color.maeemBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                GameHeader(
                    title: "ترتيب المقاطع",
                    surahName: surah.nameAr,
                    onClose: { dismiss() }
                )

                if isComplete {
                    // Results
                    GameResultView(
                        score: score,
                        activityType: .orderGame,
                        onRetry: { resetGame() },
                        onContinue: { dismiss() }
                    )
                } else {
                    // Game content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Instructions
                            Text("اسحب المقاطع لترتيبها بالترتيب الصحيح")
                                .font(MaeemTypography.body)
                                .foregroundColor(.maeemSoftWhite.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.top, 24)

                            // Drop zone (user's ordered chunks)
                            VStack(spacing: 12) {
                                Text("الترتيب الخاص بك")
                                    .font(MaeemTypography.caption)
                                    .foregroundColor(.maeemGold)

                                if userOrder.isEmpty {
                                    DropPlaceholder()
                                } else {
                                    ForEach(Array(userOrder.enumerated()), id: \.element.id) { index, chunk in
                                        OrderedChunkRow(
                                            chunk: chunk,
                                            index: index + 1,
                                            onRemove: { removeChunk(chunk) }
                                        )
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.maeemGold.opacity(0.1))
                            .cornerRadius(20)

                            // Available chunks
                            if !shuffledChunks.isEmpty {
                                VStack(spacing: 12) {
                                    Text("المقاطع المتاحة")
                                        .font(MaeemTypography.caption)
                                        .foregroundColor(.maeemSoftWhite.opacity(0.6))

                                    ForEach(shuffledChunks) { chunk in
                                        AvailableChunkRow(chunk: chunk) {
                                            addChunk(chunk)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }

                    // Check button
                    if userOrder.count == chunks.count {
                        MaeemButton("تحقق من الإجابة", icon: "checkmark") {
                            checkAnswer()
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
        shuffledChunks = chunks.shuffled()
        userOrder = []
        startTime = Date()
    }

    private func resetGame() {
        isComplete = false
        setupGame()
    }

    private func addChunk(_ chunk: AyahChunk) {
        withAnimation(.spring(response: 0.3)) {
            userOrder.append(chunk)
            shuffledChunks.removeAll { $0.id == chunk.id }
        }
    }

    private func removeChunk(_ chunk: AyahChunk) {
        withAnimation(.spring(response: 0.3)) {
            userOrder.removeAll { $0.id == chunk.id }
            shuffledChunks.append(chunk)
        }
    }

    private func checkAnswer() {
        var correctCount = 0
        for (index, chunk) in userOrder.enumerated() {
            if chunk.chunkIndex == index + 1 {
                correctCount += 1
            }
        }
        score = Double(correctCount) / Double(chunks.count)
        isComplete = true

        // Save attempt to Supabase
        Task {
            await saveAttempt()
        }
    }

    private func saveAttempt() async {
        guard let childId = appState.currentChild?.id else { return }
        isSaving = true

        let timeSpent = Int(Date().timeIntervalSince(startTime))

        // Save attempt for each chunk
        for chunk in chunks {
            let attempt = AttemptInsert(
                childId: childId,
                chunkId: chunk.id,
                activityType: ActivityType.orderGame.rawValue,
                score: score,
                timeSpentSeconds: timeSpent / chunks.count
            )

            do {
                try await supabaseService.saveAttempt(attempt)

                // Update review schedule based on performance
                await updateReviewSchedule(for: chunk, score: score, childId: childId)
            } catch {
                print("Error saving attempt: \(error)")
            }
        }
        isSaving = false
    }

    private func updateReviewSchedule(for chunk: AyahChunk, score: Double, childId: UUID) async {
        do {
            let schedules = try await supabaseService.fetchReviewSchedule(childId: childId)
            if let existing = schedules.first(where: { $0.chunkId == chunk.id }) {
                // Update existing schedule
                let newSchedule = SchedulerService.shared.updateSchedule(
                    current: existing,
                    score: score
                )
                try await supabaseService.upsertReviewSchedule(newSchedule)
            } else {
                // Create initial schedule
                let newSchedule = SchedulerService.shared.initialSchedule(
                    chunkId: chunk.id,
                    childId: childId
                )
                try await supabaseService.upsertReviewSchedule(newSchedule)
            }
        } catch {
            print("Error updating review schedule: \(error)")
        }
    }
}

// MARK: - Game Header

struct GameHeader: View {
    let title: String
    let surahName: String
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.maeemWhite)
                    .frame(width: 40, height: 40)
                    .background(Color.maeemWhite.opacity(0.1))
                    .cornerRadius(20)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(title)
                    .font(MaeemTypography.titleSmall)
                    .foregroundColor(.maeemWhite)

                Text("سورة \(surahName)")
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemSoftWhite.opacity(0.6))
            }

            Spacer()

            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Drop Placeholder

struct DropPlaceholder: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 32))
                .foregroundColor(.maeemGold.opacity(0.5))

            Text("اضغط على المقاطع لإضافتها هنا")
                .font(MaeemTypography.caption)
                .foregroundColor(.maeemSoftWhite.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundColor(.maeemGold.opacity(0.3))
        )
    }
}

// MARK: - Ordered Chunk Row

struct OrderedChunkRow: View {
    let chunk: AyahChunk
    let index: Int
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.maeemBackground)
                .frame(width: 32, height: 32)
                .background(Color.maeemGold)
                .cornerRadius(8)

            Text(chunk.displayText)
                .font(MaeemTypography.quranSmall)
                .foregroundColor(.maeemWhite)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.maeemOrange)
            }
        }
        .padding(12)
        .background(Color.maeemWhite.opacity(0.08))
        .cornerRadius(12)
    }
}

// MARK: - Available Chunk Row

struct AvailableChunkRow: View {
    let chunk: AyahChunk
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.maeemGold)

                Text(chunk.displayText)
                    .font(MaeemTypography.quranSmall)
                    .foregroundColor(.maeemWhite)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)

                Spacer()
            }
            .padding(12)
            .background(Color.maeemWhite.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Game Result View

struct GameResultView: View {
    let score: Double
    let activityType: ActivityType
    let onRetry: () -> Void
    let onContinue: () -> Void

    var percentage: Int {
        Int(score * 100)
    }

    var feedbackMessage: String {
        switch score {
        case 0.9...1.0:
            return "ممتاز! أحسنت"
        case 0.7..<0.9:
            return "جيد جداً"
        case 0.5..<0.7:
            return "جيد، حاول مرة أخرى"
        default:
            return "تحتاج مراجعة"
        }
    }

    var feedbackColor: Color {
        switch score {
        case 0.7...1.0:
            return .success
        case 0.5..<0.7:
            return .maeemAmber
        default:
            return .maeemOrange
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Score circle
            ZStack {
                Circle()
                    .stroke(Color.maeemWhite.opacity(0.1), lineWidth: 12)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: score)
                    .stroke(feedbackColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(percentage)%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.maeemWhite)

                    Text(feedbackMessage)
                        .font(MaeemTypography.body)
                        .foregroundColor(feedbackColor)
                }
            }

            // Activity type
            Text(activityType.displayName)
                .font(MaeemTypography.caption)
                .foregroundColor(.maeemSoftWhite.opacity(0.6))

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                if score < 0.9 {
                    MaeemSecondaryButton("حاول مرة أخرى", icon: "arrow.counterclockwise", action: onRetry)
                }
                MaeemButton("متابعة", icon: "arrow.left", action: onContinue)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    OrderChunksGame(
        surah: Surah(id: 112, nameAr: "الإخلاص", nameEn: "Al-Ikhlas", totalAyahs: 4, revelationType: "meccan"),
        chunks: []
    )
    .environmentObject(AppState.shared)
}
