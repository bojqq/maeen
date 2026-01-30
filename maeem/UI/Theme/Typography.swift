import SwiftUI

struct MaeemTypography {
    // MARK: - Quran Text (Arabic)

    /// Large Quran text for display
    static let quranLarge = Font.system(size: 32, weight: .regular, design: .serif)

    /// Medium Quran text for practice
    static let quranMedium = Font.system(size: 24, weight: .regular, design: .serif)

    /// Small Quran text for lists
    static let quranSmall = Font.system(size: 18, weight: .regular, design: .serif)

    // MARK: - UI Text

    /// Large title
    static let titleLarge = Font.system(size: 28, weight: .bold, design: .rounded)

    /// Medium title
    static let titleMedium = Font.system(size: 22, weight: .semibold, design: .rounded)

    /// Small title
    static let titleSmall = Font.system(size: 18, weight: .semibold, design: .rounded)

    /// Body text
    static let body = Font.system(size: 16, weight: .regular, design: .default)

    /// Caption text
    static let caption = Font.system(size: 14, weight: .regular, design: .default)

    /// Button text
    static let button = Font.system(size: 16, weight: .semibold, design: .rounded)
}

// MARK: - View Modifiers

extension View {
    func quranTextStyle(size: QuranTextSize = .medium) -> some View {
        self
            .font(size.font)
            .foregroundColor(.maeemWhite)
            .multilineTextAlignment(.trailing)
            .environment(\.layoutDirection, .rightToLeft)
    }
}

enum QuranTextSize {
    case large, medium, small

    var font: Font {
        switch self {
        case .large: return MaeemTypography.quranLarge
        case .medium: return MaeemTypography.quranMedium
        case .small: return MaeemTypography.quranSmall
        }
    }
}
