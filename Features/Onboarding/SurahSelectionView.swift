import SwiftUI

struct SurahSelectionView: View {
    let onSelect: (Surah) -> Void
    let onBack: () -> Void

    @EnvironmentObject var supabaseService: SupabaseService

    @State private var surahs: [Surah] = []
    @State private var selectedSurah: Surah?
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.maeemWhite)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Title
            VStack(spacing: 12) {
                Image(systemName: "book.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.maeemGold)

                Text("اختر سورة للبدء")
                    .font(MaeemTypography.titleLarge)
                    .foregroundColor(.maeemWhite)

                Text("ابدأ بسورة قصيرة لتعتاد على الطريقة")
                    .font(MaeemTypography.body)
                    .foregroundColor(.maeemSoftWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            // Surah list
            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .maeemGold))
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(surahs) { surah in
                            SurahCard(
                                surah: surah,
                                isSelected: selectedSurah?.id == surah.id
                            ) {
                                selectedSurah = surah
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 120)
                }
            }

            Spacer()

            // Continue button
            if let surah = selectedSurah {
                VStack(spacing: 8) {
                    Text("سورة \(surah.nameAr)")
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemSoftWhite.opacity(0.7))

                    MaeemButton("ابدأ الحفظ", icon: "arrow.left") {
                        onSelect(surah)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .background(
                    LinearGradient(
                        colors: [.clear, .maeemBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .offset(y: -60)
                )
            }
        }
        .task {
            await loadSurahs()
        }
    }

    private func loadSurahs() async {
        do {
            surahs = try await supabaseService.fetchSurahs()
        } catch {
            // Fallback to hardcoded surahs for MVP
            surahs = [
                Surah(id: 112, nameAr: "الإخلاص", nameEn: "Al-Ikhlas", totalAyahs: 4, revelationType: "meccan"),
                Surah(id: 93, nameAr: "الضحى", nameEn: "Ad-Duha", totalAyahs: 11, revelationType: "meccan")
            ]
        }
        isLoading = false
    }
}

#Preview {
    ZStack {
        Color.maeemBackground.ignoresSafeArea()
        SurahSelectionView(onSelect: { _ in }, onBack: {})
            .environmentObject(SupabaseService.shared)
    }
}
