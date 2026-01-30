import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var supabaseService: SupabaseService
    @EnvironmentObject var router: Router

    @State private var chunks: [AyahChunk] = []
    @State private var dueReviews: [ReviewSchedule] = []
    @State private var isLoading = true
    @State private var showLearn = false
    @State private var showPractice = false
    @State private var showRecite = false
    @State private var errorMessage: String?

    var surah: Surah? {
        appState.selectedSurah
    }

    var dueChunks: [AyahChunk] {
        let dueChunkIds = Set(dueReviews.map { $0.chunkId })
        return chunks.filter { dueChunkIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                Color.maeemBackground.ignoresSafeArea()

                if isLoading {
                    // Skeleton loading state
                    ScrollView {
                        VStack(spacing: 24) {
                            HomeHeader()

                            // Skeleton Surah Card
                            SkeletonSurahCard()

                            // Skeleton Chunks
                            VStack(alignment: .leading, spacing: 16) {
                                MaeemSkeletonView(width: 80, height: 20)
                                SkeletonChunkCard()
                                SkeletonChunkCard()
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                } else if surah == nil {
                    // No surah selected state
                    MaeemEmptyStateView(
                        icon: "book.closed",
                        title: "لم يتم اختيار سورة",
                        message: "اختر سورة للبدء في الحفظ",
                        actionTitle: "اختر سورة",
                        action: {
                            appState.currentRoute = .onboarding
                        }
                    )
                } else {
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
                                    onPractice: { showPractice = true },
                                    onRecite: { showRecite = true }
                                )
                            }

                            // Due for Review Section
                            if !dueChunks.isEmpty {
                                DueReviewsSection(
                                    dueChunks: dueChunks,
                                    onPractice: { showPractice = true }
                                )
                            }

                            // Chunks overview
                            if chunks.isEmpty {
                                // Empty chunks state
                                VStack(spacing: 16) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 40))
                                        .foregroundColor(.maeemGold.opacity(0.5))

                                    Text("لا توجد مقاطع متاحة")
                                        .font(MaeemTypography.body)
                                        .foregroundColor(.maeemSoftWhite.opacity(0.6))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color.maeemWhite.opacity(0.05))
                                .cornerRadius(16)
                            } else {
                                ChunksOverview(
                                    chunks: chunks,
                                    completedChunks: appState.currentSession?.completedChunks ?? []
                                )
                            }

                            // Quick actions
                            QuickActionsSection(
                                onLearn: { showLearn = true },
                                onPractice: { showPractice = true },
                                onRecite: { showRecite = true }
                            )

                            // Error message
                            if let error = errorMessage {
                                ErrorBanner(message: error) {
                                    errorMessage = nil
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await loadChunks()
                    }
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
            .navigationDestination(isPresented: $showRecite) {
                if let surah = surah {
                    ReciteView(surah: surah, chunks: chunks)
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

            // Fetch due reviews if child is set
            if let childId = appState.currentChild?.id {
                dueReviews = try await supabaseService.fetchDueReviews(childId: childId)
            }
        } catch {
            print("Error loading chunks: \(error)")
            errorMessage = "حدث خطأ في تحميل البيانات"
        }
        isLoading = false
    }
}

// MARK: - Due Reviews Section

struct DueReviewsSection: View {
    let dueChunks: [AyahChunk]
    let onPractice: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundColor(.maeemOrange)

                Text("يحتاج مراجعة")
                    .font(MaeemTypography.titleSmall)
                    .foregroundColor(.maeemWhite)

                Spacer()

                Text("\(dueChunks.count) مقاطع")
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemOrange)
            }

            VStack(spacing: 12) {
                ForEach(dueChunks.prefix(3)) { chunk in
                    DueReviewCard(chunk: chunk)
                }

                if dueChunks.count > 3 {
                    Text("و \(dueChunks.count - 3) مقاطع أخرى...")
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemSoftWhite.opacity(0.6))
                }
            }

            MaeemButton("راجع الآن", icon: "arrow.counterclockwise") {
                onPractice()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.maeemOrange.opacity(0.2), Color.maeemAmber.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.maeemOrange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Due Review Card

struct DueReviewCard: View {
    let chunk: AyahChunk

    var visual: ChunkVisual {
        ChunkVisual.from(visualKey: chunk.visualKey)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: visual.iconName)
                .font(.system(size: 20))
                .foregroundColor(.maeemAmber)
                .frame(width: 40, height: 40)
                .background(Color.maeemAmber.opacity(0.2))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text("المقطع \(chunk.chunkIndex)")
                    .font(MaeemTypography.body)
                    .foregroundColor(.maeemWhite)

                Text("الآيات \(chunk.ayahStart)-\(chunk.ayahEnd)")
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemSoftWhite.opacity(0.6))
            }

            Spacer()

            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.maeemOrange)
        }
        .padding(12)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.maeemOrange)

            Text(message)
                .font(MaeemTypography.body)
                .foregroundColor(.maeemWhite)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.maeemSoftWhite)
            }
        }
        .padding(16)
        .background(Color.maeemOrange.opacity(0.2))
        .cornerRadius(12)
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
    let onRecite: () -> Void

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
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MaeemButton("تعلّم", icon: "book.fill", action: onLearn)
                    MaeemSecondaryButton("تدرّب", icon: "gamecontroller.fill", action: onPractice)
                }
                
                MaeemSecondaryButton("سمّع", icon: "mic.fill", action: onRecite)
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
    let onRecite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("التدريبات")
                .font(MaeemTypography.titleSmall)
                .foregroundColor(.maeemWhite)

            VStack(spacing: 12) {
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
                
                QuickActionCard(
                    title: "التسميع",
                    icon: "mic.fill",
                    color: .maeemGold,
                    action: onRecite
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

// MARK: - Skeleton Views

struct SkeletonSurahCard: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    MaeemSkeletonView(width: 80, height: 14)
                    MaeemSkeletonView(width: 120, height: 24)
                    MaeemSkeletonView(width: 60, height: 14)
                }

                Spacer()

                Circle()
                    .fill(Color.maeemWhite.opacity(0.05))
                    .frame(width: 70, height: 70)
            }

            HStack(spacing: 12) {
                MaeemSkeletonView(height: 50)
                MaeemSkeletonView(height: 50)
            }
        }
        .padding(20)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(24)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState.shared)
        .environmentObject(SupabaseService.shared)
        .environmentObject(Router())
}
