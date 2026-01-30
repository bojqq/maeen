import SwiftUI

struct ReciteView: View {
    let surah: Surah
    let chunks: [AyahChunk]

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var supabaseService: SupabaseService

    @State private var currentChunkIndex = 0
    @State private var isRecording = false
    @State private var showNextWord = false
    @State private var revealedWords: Set<Int> = []
    @State private var score: Double = 0
    @State private var isComplete = false
    @State private var startTime = Date()
    @State private var chunkScores: [(chunkId: UUID, score: Double)] = []
    
    var currentChunk: AyahChunk? {
        guard currentChunkIndex < chunks.count else { return nil }
        return chunks[currentChunkIndex]
    }
    
    var words: [String] {
        currentChunk?.displayText.components(separatedBy: " ") ?? []
    }
    
    var body: some View {
        ZStack {
            Color.maeemBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ReciteHeader(
                    surahName: surah.nameAr,
                    onClose: { dismiss() }
                )
                
                if isComplete {
                    // Results
                    GameResultView(
                        score: score,
                        activityType: .recite,
                        onRetry: { resetRecitation() },
                        onContinue: { dismiss() }
                    )
                } else if let chunk = currentChunk {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Instructions
                            VStack(spacing: 12) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.maeemGold)
                                
                                Text("اضغط على الكلمات لإظهارها")
                                    .font(MaeemTypography.body)
                                    .foregroundColor(.maeemSoftWhite.opacity(0.7))
                                
                                Text("المقطع \(currentChunkIndex + 1) من \(chunks.count)")
                                    .font(MaeemTypography.caption)
                                    .foregroundColor(.maeemGold)
                            }
                            .padding(.top, 24)
                            
                            // Ayah with reveal
                            ReciteTextView(
                                words: words,
                                revealedWords: revealedWords,
                                onRevealWord: { index in
                                    withAnimation {
                                        revealedWords.insert(index)
                                    }
                                }
                            )
                            
                            // Hint button
                            if revealedWords.count < words.count {
                                Button(action: revealNextWord) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lightbulb.fill")
                                        Text("أظهر الكلمة التالية")
                                    }
                                    .font(MaeemTypography.body)
                                    .foregroundColor(.maeemAmber)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.maeemAmber.opacity(0.15))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Recording button (placeholder)
                            RecordingButton(
                                isRecording: $isRecording,
                                onToggle: toggleRecording
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                    }
                    
                    // Next button
                    if revealedWords.count == words.count {
                        MaeemButton(
                            currentChunkIndex == chunks.count - 1 ? "إنهاء" : "التالي",
                            icon: "arrow.left"
                        ) {
                            nextChunk()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func revealNextWord() {
        for i in 0..<words.count {
            if !revealedWords.contains(i) {
                withAnimation {
                    revealedWords.insert(i)
                }
                break
            }
        }
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        // TODO: Implement actual recording logic
    }
    
    private func nextChunk() {
        // Calculate score based on hints used
        let hintsUsed = revealedWords.count
        let chunkScore = max(0, 1.0 - (Double(hintsUsed) / Double(words.count) * 0.5))
        score = (score * Double(currentChunkIndex) + chunkScore) / Double(currentChunkIndex + 1)

        // Track chunk score
        if let chunk = currentChunk {
            chunkScores.append((chunkId: chunk.id, score: chunkScore))
        }

        if currentChunkIndex < chunks.count - 1 {
            currentChunkIndex += 1
            revealedWords.removeAll()
        } else {
            isComplete = true
            // Save attempts
            Task {
                await saveAttempts()
            }
        }
    }

    private func resetRecitation() {
        currentChunkIndex = 0
        revealedWords.removeAll()
        score = 0
        isComplete = false
        chunkScores.removeAll()
        startTime = Date()
    }

    private func saveAttempts() async {
        guard let childId = appState.currentChild?.id else { return }

        let timeSpent = Int(Date().timeIntervalSince(startTime))
        let timePerChunk = timeSpent / max(1, chunks.count)

        for (chunkId, chunkScore) in chunkScores {
            let attempt = AttemptInsert(
                childId: childId,
                chunkId: chunkId,
                activityType: ActivityType.recite.rawValue,
                score: chunkScore,
                timeSpentSeconds: timePerChunk
            )

            do {
                try await supabaseService.saveAttempt(attempt)
                await updateReviewSchedule(for: chunkId, score: chunkScore, childId: childId)
            } catch {
                print("Error saving recite attempt: \(error)")
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

// MARK: - Recite Header

struct ReciteHeader: View {
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
                Text("التسميع")
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

// MARK: - Recite Text View

struct ReciteTextView: View {
    let words: [String]
    let revealedWords: Set<Int>
    let onRevealWord: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            FlowLayout(spacing: 12) {
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    ReciteWordButton(
                        word: word,
                        isRevealed: revealedWords.contains(index),
                        onTap: { onRevealWord(index) }
                    )
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - Recite Word Button

struct ReciteWordButton: View {
    let word: String
    let isRevealed: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(isRevealed ? word : "•••")
                .font(MaeemTypography.quranMedium)
                .foregroundColor(isRevealed ? .maeemWhite : .maeemGold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isRevealed
                        ? Color.maeemGold.opacity(0.15)
                        : Color.maeemGold.opacity(0.3)
                )
                .cornerRadius(8)
        }
        .disabled(isRevealed)
    }
}

// MARK: - Recording Button

struct RecordingButton: View {
    @Binding var isRecording: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("أو سجّل تسميعك")
                .font(MaeemTypography.caption)
                .foregroundColor(.maeemSoftWhite.opacity(0.6))
            
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(isRecording ? Color.maeemOrange : Color.maeemGold)
                        .frame(width: 80, height: 80)
                        .shadow(color: (isRecording ? Color.maeemOrange : Color.maeemGold).opacity(0.3), radius: 20)
                    
                    if isRecording {
                        Circle()
                            .fill(Color.maeemWhite)
                            .frame(width: 30, height: 30)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.maeemBackground)
                    }
                }
            }
            
            Text(isRecording ? "اضغط للإيقاف" : "اضغط للتسجيل")
                .font(MaeemTypography.caption)
                .foregroundColor(isRecording ? .maeemOrange : .maeemGold)
        }
        .padding(.vertical, 24)
    }
}

// MARK: - Flow Layout (for wrapping words)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    ReciteView(
        surah: Surah(id: 112, nameAr: "الإخلاص", nameEn: "Al-Ikhlas", totalAyahs: 4, revelationType: "meccan"),
        chunks: []
    )
    .environmentObject(AppState.shared)
}
