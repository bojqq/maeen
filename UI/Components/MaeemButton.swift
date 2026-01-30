import SwiftUI

// MARK: - Primary Button

struct MaeemButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(MaeemTypography.button)
            }
            .foregroundColor(.maeemBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.maeemGold)
            .cornerRadius(16)
        }
    }
}

// MARK: - Secondary Button

struct MaeemSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(MaeemTypography.button)
            }
            .foregroundColor(.maeemWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.maeemGold, lineWidth: 2)
            )
        }
    }
}

// MARK: - Icon Button

struct MaeemIconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    init(_ icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.maeemWhite)
                .frame(width: size, height: size)
                .background(Color.maeemGold.opacity(0.2))
                .cornerRadius(size / 2)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.maeemBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            MaeemButton("ابدأ الآن", icon: "arrow.left") {}
            MaeemSecondaryButton("تسجيل الدخول") {}
            MaeemIconButton("play.fill") {}
        }
        .padding()
    }
}
