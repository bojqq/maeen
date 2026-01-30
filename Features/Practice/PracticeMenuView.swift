import SwiftUI

struct PracticeMenuView: View {
    let surah: Surah
    let chunks: [AyahChunk]

    @Environment(\.dismiss) var dismiss

    @State private var showOrderGame = false
    @State private var showMissingGame = false

    var body: some View {
        ZStack {
            Color.maeemBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.maeemWhite)
                    }
                    Spacer()
                    Text("التدريبات")
                        .font(MaeemTypography.titleSmall)
                        .foregroundColor(.maeemWhite)
                    Spacer()
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        // Title section
                        VStack(spacing: 12) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.maeemGold)

                            Text("اختر لعبة للتدرب")
                                .font(MaeemTypography.titleLarge)
                                .foregroundColor(.maeemWhite)

                            Text("سورة \(surah.nameAr)")
                                .font(MaeemTypography.body)
                                .foregroundColor(.maeemSoftWhite.opacity(0.7))
                        }
                        .padding(.top, 40)

                        // Game cards
                        VStack(spacing: 16) {
                            GameCard(
                                title: "ترتيب المقاطع",
                                subtitle: "رتّب مقاطع السورة بالترتيب الصحيح",
                                icon: "arrow.up.arrow.down",
                                color: .maeemOrange,
                                action: { showOrderGame = true }
                            )

                            GameCard(
                                title: "أكمل الفراغ",
                                subtitle: "اختر الكلمة الناقصة من الآية",
                                icon: "text.badge.plus",
                                color: .maeemAmber,
                                action: { showMissingGame = true }
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showOrderGame) {
            OrderChunksGame(surah: surah, chunks: chunks)
        }
        .fullScreenCover(isPresented: $showMissingGame) {
            MissingSegmentGame(surah: surah, chunks: chunks)
        }
    }
}

// MARK: - Game Card

struct GameCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.maeemBackground)
                    .frame(width: 70, height: 70)
                    .background(color)
                    .cornerRadius(20)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(MaeemTypography.titleSmall)
                        .foregroundColor(.maeemWhite)

                    Text(subtitle)
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemSoftWhite.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.maeemGold)
            }
            .padding(20)
            .background(Color.maeemWhite.opacity(0.05))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    PracticeMenuView(
        surah: Surah(id: 112, nameAr: "الإخلاص", nameEn: "Al-Ikhlas", totalAyahs: 4, revelationType: "meccan"),
        chunks: []
    )
}
