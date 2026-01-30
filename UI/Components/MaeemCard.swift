import SwiftUI

// MARK: - Selection Card

struct MaeemSelectionCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .maeemBackground : .maeemGold)
                    .frame(width: 60, height: 60)
                    .background(isSelected ? Color.maeemGold : Color.maeemGold.opacity(0.2))
                    .cornerRadius(16)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(MaeemTypography.titleSmall)
                        .foregroundColor(.maeemWhite)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(MaeemTypography.caption)
                            .foregroundColor(.maeemSoftWhite.opacity(0.7))
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.maeemGold)
                }
            }
            .padding(16)
            .background(Color.maeemWhite.opacity(0.05))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.maeemGold : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Surah Card

struct SurahCard: View {
    let surah: Surah
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text("\(surah.id)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .maeemBackground : .maeemGold)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.maeemGold : Color.maeemGold.opacity(0.2))
                    .cornerRadius(25)

                Text(surah.nameAr)
                    .font(MaeemTypography.quranMedium)
                    .foregroundColor(.maeemWhite)

                Text(surah.nameEn)
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemSoftWhite.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.maeemWhite.opacity(0.05))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.maeemGold : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Chunk Card

struct ChunkCard: View {
    let chunk: AyahChunk
    let index: Int
    let isCompleted: Bool
    let isCurrent: Bool

    var visual: ChunkVisual {
        ChunkVisual.from(visualKey: chunk.visualKey)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: visual.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.maeemGold)

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.success)
                }
            }

            Text(chunk.displayText)
                .font(MaeemTypography.quranSmall)
                .foregroundColor(.maeemWhite)
                .multilineTextAlignment(.trailing)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .trailing)

            HStack {
                Text("الآيات \(chunk.ayahStart)-\(chunk.ayahEnd)")
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemSoftWhite.opacity(0.6))

                Spacer()

                Text("المقطع \(index + 1)")
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemGold)
            }
        }
        .padding(16)
        .background(isCurrent ? Color.maeemGold.opacity(0.15) : Color.maeemWhite.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrent ? Color.maeemGold : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.maeemBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            MaeemSelectionCard(
                title: "والد/والدة",
                subtitle: "متابعة تقدم طفلك",
                icon: "person.2.fill",
                isSelected: true
            ) {}

            MaeemSelectionCard(
                title: "طفل",
                subtitle: "ابدأ رحلة الحفظ",
                icon: "face.smiling.fill",
                isSelected: false
            ) {}
        }
        .padding()
    }
}
