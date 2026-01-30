import SwiftUI

struct LearnView: View {
    let surah: Surah
    let chunks: [AyahChunk]

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var showCompletionAlert = false

    var currentChunk: AyahChunk? {
        guard currentIndex < chunks.count else { return nil }
        return chunks[currentIndex]
    }

    var progress: Double {
        guard !chunks.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(chunks.count)
    }

    var body: some View {
        ZStack {
            Color.maeemBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                LearnHeader(
                    surahName: surah.nameAr,
                    progress: progress,
                    onClose: { dismiss() }
                )

                // Content
                if let chunk = currentChunk {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Chunk indicator
                            ChunkIndicator(
                                currentIndex: currentIndex,
                                totalChunks: chunks.count
                            )

                            // Visual card
                            ChunkVisualCard(chunk: chunk)

                            // Ayah text
                            AyahTextCard(chunk: chunk)

                            // Audio controls
                            AudioControlsView(isPlaying: $isPlaying)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 32)
                    }

                    // Navigation buttons
                    NavigationButtons(
                        currentIndex: currentIndex,
                        totalChunks: chunks.count,
                        onPrevious: { currentIndex -= 1 },
                        onNext: {
                            if currentIndex < chunks.count - 1 {
                                appState.completeChunk(chunk.id)
                                currentIndex += 1
                            } else {
                                appState.completeChunk(chunk.id)
                                showCompletionAlert = true
                            }
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .alert("أحسنت!", isPresented: $showCompletionAlert) {
            Button("تدرّب الآن") {
                dismiss()
            }
            Button("العودة للرئيسية") {
                dismiss()
            }
        } message: {
            Text("لقد أكملت تعلم جميع المقاطع!\nهل تريد التدرب عليها؟")
        }
    }
}

// MARK: - Learn Header

struct LearnHeader: View {
    let surahName: String
    let progress: Double
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
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

                Text("سورة \(surahName)")
                    .font(MaeemTypography.titleSmall)
                    .foregroundColor(.maeemWhite)

                Spacer()

                // Placeholder for balance
                Color.clear.frame(width: 40, height: 40)
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

// MARK: - Chunk Indicator

struct ChunkIndicator: View {
    let currentIndex: Int
    let totalChunks: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalChunks, id: \.self) { index in
                Circle()
                    .fill(index <= currentIndex ? Color.maeemGold : Color.maeemWhite.opacity(0.2))
                    .frame(width: 10, height: 10)
            }
        }
    }
}

// MARK: - Chunk Visual Card

struct ChunkVisualCard: View {
    let chunk: AyahChunk

    var visual: ChunkVisual {
        ChunkVisual.from(visualKey: chunk.visualKey)
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: visual.iconName)
                .font(.system(size: 48))
                .foregroundColor(.maeemGold)

            Text("المقطع \(chunk.chunkIndex)")
                .font(MaeemTypography.caption)
                .foregroundColor(.maeemSoftWhite.opacity(0.6))

            Text("الآيات \(chunk.ayahStart) - \(chunk.ayahEnd)")
                .font(MaeemTypography.body)
                .foregroundColor(.maeemWhite)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [Color.maeemGold.opacity(0.2), Color.maeemOrange.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(24)
    }
}

// MARK: - Ayah Text Card

struct AyahTextCard: View {
    let chunk: AyahChunk

    var body: some View {
        VStack(spacing: 16) {
            Text(chunk.displayText)
                .font(MaeemTypography.quranLarge)
                .foregroundColor(.maeemWhite)
                .multilineTextAlignment(.center)
                .lineSpacing(12)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - Audio Controls

struct AudioControlsView: View {
    @Binding var isPlaying: Bool

    var body: some View {
        HStack(spacing: 24) {
            Button(action: {}) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.maeemSoftWhite.opacity(0.6))
            }

            Button(action: { isPlaying.toggle() }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.maeemGold)
            }

            Button(action: {}) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.maeemSoftWhite.opacity(0.6))
            }
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Navigation Buttons

struct NavigationButtons: View {
    let currentIndex: Int
    let totalChunks: Int
    let onPrevious: () -> Void
    let onNext: () -> Void

    var isFirst: Bool { currentIndex == 0 }
    var isLast: Bool { currentIndex == totalChunks - 1 }

    var body: some View {
        HStack(spacing: 16) {
            if !isFirst {
                MaeemSecondaryButton("السابق", icon: "arrow.right") {
                    onPrevious()
                }
            }

            MaeemButton(isLast ? "إنهاء" : "التالي", icon: isLast ? "checkmark" : "arrow.left") {
                onNext()
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

#Preview {
    LearnView(
        surah: Surah(id: 112, nameAr: "الإخلاص", nameEn: "Al-Ikhlas", totalAyahs: 4, revelationType: "meccan"),
        chunks: []
    )
    .environmentObject(AppState.shared)
}
