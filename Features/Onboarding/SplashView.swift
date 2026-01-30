import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var isAnimating = false
    @State private var showLogo = false

    var body: some View {
        ZStack {
            Color.maeemBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Logo
                ZStack {
                    // Decorative circles
                    Circle()
                        .stroke(Color.maeemGold.opacity(0.2), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)

                    Circle()
                        .stroke(Color.maeemAmber.opacity(0.15), lineWidth: 2)
                        .frame(width: 220, height: 220)
                        .scaleEffect(isAnimating ? 1.15 : 1.0)

                    // Main logo circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.maeemOrange, .maeemAmber, .maeemGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: .maeemGold.opacity(0.3), radius: 20)

                    // App name in Arabic
                    Text("مَعين")
                        .font(.system(size: 48, weight: .bold, design: .serif))
                        .foregroundColor(.maeemWhite)
                }
                .opacity(showLogo ? 1 : 0)
                .scaleEffect(showLogo ? 1 : 0.8)

                // Tagline
                VStack(spacing: 8) {
                    Text("رفيقك في حفظ القرآن")
                        .font(MaeemTypography.titleMedium)
                        .foregroundColor(.maeemWhite)

                    Text("تعلّم • تدرّب • احفظ")
                        .font(MaeemTypography.body)
                        .foregroundColor(.maeemSoftWhite.opacity(0.7))
                }
                .opacity(showLogo ? 1 : 0)
                .offset(y: showLogo ? 0 : 20)
            }

            // Loading indicator
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .maeemGold))
                    .scaleEffect(1.2)
                    .padding(.bottom, 60)
            }
            .opacity(showLogo ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showLogo = true
            }

            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }

            // Navigate after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    appState.currentRoute = .onboarding
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState.shared)
}
