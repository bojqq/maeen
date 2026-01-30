import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: OnboardingStep = .welcome

    var body: some View {
        NavigationStack {
            ZStack {
                Color.maeemBackground.ignoresSafeArea()

                switch currentStep {
                case .welcome:
                    WelcomeView(onContinue: { currentStep = .roleSelection })

                case .roleSelection:
                    RoleSelectionView(
                        onSelectRole: { role in
                            appState.currentUserRole = role
                            currentStep = role == .parent ? .parentSetup : .childSetup
                        },
                        onBack: { currentStep = .welcome }
                    )

                case .parentSetup:
                    ParentSetupView(
                        onComplete: {
                            appState.currentRoute = .parentDashboard
                        },
                        onBack: { currentStep = .roleSelection }
                    )

                case .childSetup:
                    ChildSetupView(
                        onContinue: { currentStep = .surahSelection },
                        onBack: { currentStep = .roleSelection }
                    )

                case .surahSelection:
                    SurahSelectionView(
                        onSelect: { surah in
                            appState.selectedSurah = surah
                            appState.currentRoute = .home
                        },
                        onBack: { currentStep = .childSetup }
                    )
                }
            }
        }
    }
}

enum OnboardingStep {
    case welcome
    case roleSelection
    case parentSetup
    case childSetup
    case surahSelection
}

// MARK: - Welcome View

struct WelcomeView: View {
    let onContinue: () -> Void
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo section
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.maeemOrange, .maeemAmber, .maeemGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .maeemGold.opacity(0.3), radius: 20)

                    Text("مَعين")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.maeemWhite)
                }

                VStack(spacing: 12) {
                    Text("أهلاً بك في مَعين")
                        .font(MaeemTypography.titleLarge)
                        .foregroundColor(.maeemWhite)

                    Text("رحلة ممتعة لحفظ القرآن الكريم\nمع التعلّم التفاعلي والتكرار الذكي")
                        .font(MaeemTypography.body)
                        .foregroundColor(.maeemSoftWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            Spacer()

            // Features list
            VStack(spacing: 16) {
                FeatureRow(icon: "book.fill", text: "مصحف تفاعلي مع مقاطع مرئية")
                FeatureRow(icon: "gamecontroller.fill", text: "ألعاب تعليمية لتثبيت الحفظ")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "متابعة ذكية للتقدم")
            }
            .padding(.horizontal, 32)

            Spacer()

            // Continue button
            MaeemButton("ابدأ الآن", icon: "arrow.left", action: onContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.maeemGold)
                .frame(width: 44, height: 44)
                .background(Color.maeemGold.opacity(0.15))
                .cornerRadius(12)

            Text(text)
                .font(MaeemTypography.body)
                .foregroundColor(.maeemWhite)

            Spacer()
        }
    }
}

// MARK: - Role Selection View

struct RoleSelectionView: View {
    let onSelectRole: (UserRole) -> Void
    let onBack: () -> Void

    @State private var selectedRole: UserRole?

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

            Spacer()

            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("من أنت؟")
                        .font(MaeemTypography.titleLarge)
                        .foregroundColor(.maeemWhite)

                    Text("اختر دورك لتخصيص تجربتك")
                        .font(MaeemTypography.body)
                        .foregroundColor(.maeemSoftWhite.opacity(0.7))
                }

                VStack(spacing: 16) {
                    MaeemSelectionCard(
                        title: "والد/والدة",
                        subtitle: "تابع تقدم طفلك وساعده في رحلة الحفظ",
                        icon: "person.2.fill",
                        isSelected: selectedRole == .parent
                    ) {
                        selectedRole = .parent
                    }

                    MaeemSelectionCard(
                        title: "طفل",
                        subtitle: "ابدأ رحلة حفظ القرآن بطريقة ممتعة",
                        icon: "face.smiling.fill",
                        isSelected: selectedRole == .child
                    ) {
                        selectedRole = .child
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            if let role = selectedRole {
                MaeemButton("متابعة", icon: "arrow.left") {
                    onSelectRole(role)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingFlow()
        .environmentObject(AppState.shared)
}
