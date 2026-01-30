import SwiftUI

struct ParentSetupView: View {
    let onComplete: () -> Void
    let onBack: () -> Void

    @EnvironmentObject var supabaseService: SupabaseService

    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isSignIn = false

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && (isSignIn || !name.isEmpty)
    }

    var body: some View {
        ScrollView {
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

                VStack(spacing: 32) {
                    // Title
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.maeemGold)

                        Text(isSignIn ? "تسجيل الدخول" : "إنشاء حساب الوالدين")
                            .font(MaeemTypography.titleLarge)
                            .foregroundColor(.maeemWhite)

                        Text("لمتابعة تقدم طفلك")
                            .font(MaeemTypography.body)
                            .foregroundColor(.maeemSoftWhite.opacity(0.7))
                    }
                    .padding(.top, 40)

                    // Form
                    VStack(spacing: 20) {
                        if !isSignIn {
                            MaeemTextField(
                                title: "الاسم",
                                placeholder: "أدخل اسمك",
                                text: $name,
                                icon: "person.fill"
                            )
                        }

                        MaeemTextField(
                            title: "البريد الإلكتروني",
                            placeholder: "example@email.com",
                            text: $email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress
                        )

                        MaeemTextField(
                            title: "كلمة المرور",
                            placeholder: "••••••••",
                            text: $password,
                            icon: "lock.fill",
                            isSecure: true
                        )

                        if let error = errorMessage {
                            Text(error)
                                .font(MaeemTypography.caption)
                                .foregroundColor(.maeemOrange)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Submit button
                    VStack(spacing: 16) {
                        MaeemButton(isSignIn ? "تسجيل الدخول" : "إنشاء الحساب") {
                            Task {
                                await submitForm()
                            }
                        }
                        .disabled(!isFormValid || isLoading)
                        .opacity(isFormValid ? 1 : 0.6)

                        Button(action: { isSignIn.toggle() }) {
                            Text(isSignIn ? "ليس لديك حساب؟ أنشئ حساباً" : "لديك حساب؟ سجل الدخول")
                                .font(MaeemTypography.body)
                                .foregroundColor(.maeemGold)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func submitForm() async {
        isLoading = true
        errorMessage = nil

        do {
            if isSignIn {
                try await supabaseService.signIn(email: email, password: password)
            } else {
                try await supabaseService.signUp(email: email, password: password, role: "parent", name: name)
            }
            onComplete()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Text Field Component

struct MaeemTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(MaeemTypography.caption)
                .foregroundColor(.maeemSoftWhite.opacity(0.7))

            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.maeemGold)
                        .frame(width: 20)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(.maeemWhite)
                } else {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.maeemWhite)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                }
            }
            .padding(16)
            .background(Color.maeemWhite.opacity(0.08))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.maeemWhite.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ZStack {
        Color.maeemBackground.ignoresSafeArea()
        ParentSetupView(onComplete: {}, onBack: {})
            .environmentObject(SupabaseService.shared)
    }
}
