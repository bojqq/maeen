import SwiftUI

struct ChildSetupView: View {
    let onContinue: () -> Void
    let onBack: () -> Void

    @EnvironmentObject var appState: AppState

    @State private var childName = ""
    @State private var selectedAge: Int = 7
    @State private var selectedLevel: DifficultyLevel = .beginner

    let ageRange = 4...15

    var isFormValid: Bool {
        !childName.isEmpty
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
                        Image(systemName: "face.smiling.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.maeemGold)

                        Text("أخبرنا عن نفسك")
                            .font(MaeemTypography.titleLarge)
                            .foregroundColor(.maeemWhite)

                        Text("لنخصص تجربة التعلم لك")
                            .font(MaeemTypography.body)
                            .foregroundColor(.maeemSoftWhite.opacity(0.7))
                    }
                    .padding(.top, 40)

                    // Form
                    VStack(spacing: 24) {
                        // Name field
                        MaeemTextField(
                            title: "ما اسمك؟",
                            placeholder: "أدخل اسمك",
                            text: $childName,
                            icon: "person.fill"
                        )

                        // Age picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("كم عمرك؟")
                                .font(MaeemTypography.caption)
                                .foregroundColor(.maeemSoftWhite.opacity(0.7))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(ageRange), id: \.self) { age in
                                        AgeButton(
                                            age: age,
                                            isSelected: selectedAge == age
                                        ) {
                                            selectedAge = age
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }

                        // Level selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("مستواك في الحفظ")
                                .font(MaeemTypography.caption)
                                .foregroundColor(.maeemSoftWhite.opacity(0.7))

                            VStack(spacing: 12) {
                                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                    LevelSelectionRow(
                                        level: level,
                                        isSelected: selectedLevel == level
                                    ) {
                                        selectedLevel = level
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Continue button
                    MaeemButton("التالي", icon: "arrow.left") {
                        // Save child info to app state
                        onContinue()
                    }
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.6)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Age Button

struct AgeButton: View {
    let age: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(age)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .maeemBackground : .maeemWhite)
                .frame(width: 50, height: 50)
                .background(isSelected ? Color.maeemGold : Color.maeemWhite.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

// MARK: - Level Selection Row

struct LevelSelectionRow: View {
    let level: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void

    var levelDescription: String {
        switch level {
        case .beginner:
            return "أبدأ من البداية"
        case .intermediate:
            return "أحفظ بعض السور القصيرة"
        case .advanced:
            return "أحفظ عدة أجزاء"
        }
    }

    var levelIcon: String {
        switch level {
        case .beginner:
            return "star"
        case .intermediate:
            return "star.leadinghalf.filled"
        case .advanced:
            return "star.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: levelIcon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .maeemBackground : .maeemGold)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.maeemGold : Color.maeemGold.opacity(0.15))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayNameAr)
                        .font(MaeemTypography.titleSmall)
                        .foregroundColor(.maeemWhite)

                    Text(levelDescription)
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemSoftWhite.opacity(0.6))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.maeemGold)
                }
            }
            .padding(12)
            .background(Color.maeemWhite.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.maeemGold : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    ZStack {
        Color.maeemBackground.ignoresSafeArea()
        ChildSetupView(onContinue: {}, onBack: {})
            .environmentObject(AppState.shared)
    }
}
