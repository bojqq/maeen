import SwiftUI

// MARK: - Loading View

struct MaeemLoadingView: View {
    var message: String = "جاري التحميل..."

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .maeemGold))
                .scaleEffect(1.5)

            Text(message)
                .font(MaeemTypography.body)
                .foregroundColor(.maeemSoftWhite.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.maeemBackground)
    }
}

// MARK: - Error View

struct MaeemErrorView: View {
    let message: String
    let onRetry: (() -> Void)?

    init(message: String = "حدث خطأ غير متوقع", onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.maeemOrange)

            VStack(spacing: 8) {
                Text("عذراً")
                    .font(MaeemTypography.titleMedium)
                    .foregroundColor(.maeemWhite)

                Text(message)
                    .font(MaeemTypography.body)
                    .foregroundColor(.maeemSoftWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            if let onRetry = onRetry {
                MaeemButton("حاول مرة أخرى", icon: "arrow.counterclockwise") {
                    onRetry()
                }
                .padding(.horizontal, 48)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.maeemBackground)
    }
}

// MARK: - Empty State View

struct MaeemEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String = "tray",
        title: String = "لا توجد بيانات",
        message: String = "لم يتم العثور على محتوى",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.maeemGold.opacity(0.5))

            VStack(spacing: 8) {
                Text(title)
                    .font(MaeemTypography.titleMedium)
                    .foregroundColor(.maeemWhite)

                Text(message)
                    .font(MaeemTypography.body)
                    .foregroundColor(.maeemSoftWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                MaeemSecondaryButton(actionTitle, icon: "plus") {
                    action()
                }
                .padding(.horizontal, 48)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.maeemBackground)
    }
}

// MARK: - Inline Loading Indicator

struct MaeemInlineLoading: View {
    var message: String?

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .maeemGold))

            if let message = message {
                Text(message)
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemSoftWhite.opacity(0.7))
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Skeleton Loading View

struct MaeemSkeletonView: View {
    let width: CGFloat?
    let height: CGFloat

    @State private var isAnimating = false

    init(width: CGFloat? = nil, height: CGFloat = 20) {
        self.width = width
        self.height = height
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [
                        Color.maeemWhite.opacity(0.05),
                        Color.maeemWhite.opacity(0.1),
                        Color.maeemWhite.opacity(0.05)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .shimmering()
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.maeemWhite.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Toast View

struct MaeemToast: View {
    enum ToastType {
        case success
        case error
        case info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return .success
            case .error: return .maeemOrange
            case .info: return .maeemGold
            }
        }
    }

    let message: String
    let type: ToastType

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)

            Text(message)
                .font(MaeemTypography.body)
                .foregroundColor(.maeemWhite)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.maeemWhite.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Skeleton Card

struct SkeletonChunkCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                MaeemSkeletonView(width: 24, height: 24)
                Spacer()
            }

            MaeemSkeletonView(height: 60)

            HStack {
                MaeemSkeletonView(width: 80, height: 16)
                Spacer()
                MaeemSkeletonView(width: 60, height: 16)
            }
        }
        .padding(16)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.maeemBackground.ignoresSafeArea()

        VStack(spacing: 24) {
            MaeemLoadingView()

            MaeemToast(message: "تم الحفظ بنجاح", type: .success)

            SkeletonChunkCard()
        }
    }
}
