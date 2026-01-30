import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var supabaseService: SupabaseService
    @EnvironmentObject var router: Router

    @State private var chunks: [AyahChunk] = []
    @State private var isLoading = true
    @State private var showLearn = false
    @State private var showPractice = false

    var surah: Surah? {
        appState.selectedSurah
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                Color.maeemBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HomeHeader()

                        // Current Surah Card
                        if let surah = surah {
                            CurrentSurahCard(
                                surah: surah,
                                progress: appState.currentSession?.progress ?? 0,
                                onLearn: { showLearn = true },
                                onPractice: { showPractice = true }
                            )
                        }

                        // Chunks overview
                        if !chunks.isEmpty {
                            ChunksOverview(
                                chunks: chunks,
                                completedChunks: appState.currentSession?.completedChunks ?? []
                            )
                        }

                        // Quick actions
                        QuickActionsSection(
                            onLearn: { showLearn = true },
                            onPractice: { showPractice = true }
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .maeemGold))
                }
            }
            .navigationDestination(isPresented: $showLearn) {
                if let surah = surah {
                    LearnView(surah: surah, chunks: chunks)
                }
            }
            .navigationDestination(isPresented: $showPractice) {
                if let surah = surah {
                    PracticeMenuView(surah: surah, chunks: chunks)
                }
            }
        }
        .task {
            await loadChunks()
        }
    }

    private func loadChunks() async {
        guard let surah = surah else {
            isLoading = false
            return
        }

        do {
            chunks = try await supabaseService.fetchChunks(surahId: surah.id)
            if appState.currentSession == nil {
                appState.startSession(surah: surah, chunks: chunks)
            }
        } catch {
            print("Error loading chunks: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Home Header

struct HomeHeader: View {
    @EnvironmentObject var appState: AppState

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "صباح الخير"
        } else if hour < 17 {
            return "مساء الخير"
        } else {
            return "مساء النور"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(MaeemTypography.body)
                    .foregroundColor(.maeemSoftWhite.opacity(0.7))

                Text("هيا نحفظ اليوم")
                    .font(MaeemTypography.titleMedium)
                    .foregroundColor(.maeemWhite)
            }

            Spacer()

            // Profile button
            Button(action: {}) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.maeemGold)
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - Current Surah Card

struct CurrentSurahCard: View {
    let surah: Surah
    let progress: Double
    let onLearn: () -> Void
    let onPractice: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Surah info
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("السورة الحالية")
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemSoftWhite.opacity(0.6))

                    Text("سورة \(surah.nameAr)")
                        .font(MaeemTypography.titleMedium)
                        .foregroundColor(.maeemWhite)

                    Text("\(surah.totalAyahs ?? 0) آيات")
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemGold)
                }

                Spacer()

                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.maeemWhite.opacity(0.1), lineWidth: 8)
                        .frame(width: 70, height: 70)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.maeemGold, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.maeemWhite)
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                MaeemButton("تعلّم", icon: "book.fill", action: onLearn)
                MaeemSecondaryButton("تدرّب", icon: "gamecontroller.fill", action: onPractice)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.maeemOrange.opacity(0.3), Color.maeemGold.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
    }
}

// MARK: - Chunks Overview

struct ChunksOverview: View {
    let chunks: [AyahChunk]
    let completedChunks: Set<UUID>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("المقاطع")
                .font(MaeemTypography.titleSmall)
                .foregroundColor(.maeemWhite)

            VStack(spacing: 12) {
                ForEach(Array(chunks.enumerated()), id: \.element.id) { index, chunk in
                    ChunkCard(
                        chunk: chunk,
                        index: index,
                        isCompleted: completedChunks.contains(chunk.id),
                        isCurrent: index == completedChunks.count
                    )
                }
            }
        }
    }
}

// MARK: - Quick Actions

struct QuickActionsSection: View {
    let onLearn: () -> Void
    let onPractice: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("التدريبات")
                .font(MaeemTypography.titleSmall)
                .foregroundColor(.maeemWhite)

            HStack(spacing: 16) {
                QuickActionCard(
                    title: "ترتيب المقاطع",
                    icon: "arrow.up.arrow.down",
                    color: .maeemOrange,
                    action: onPractice
                )

                QuickActionCard(
                    title: "أكمل الفراغ",
                    icon: "text.badge.plus",
                    color: .maeemAmber,
                    action: onPractice
                )
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)

                Text(title)
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemWhite)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.maeemWhite.opacity(0.05))
            .cornerRadius(16)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState.shared)
        .environmentObject(SupabaseService.shared)
        .environmentObject(Router())
}
