import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var supabaseService: SupabaseService

    @State private var children: [Child] = []
    @State private var isLoading = true
    @State private var showAddChild = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.maeemBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        ParentHeader(
                            name: supabaseService.currentProfile?.name ?? "الوالد",
                            onLogout: {
                                Task {
                                    try? await supabaseService.signOut()
                                    appState.logout()
                                }
                            }
                        )

                        // Overview stats
                        if !children.isEmpty {
                            OverviewStatsSection(children: children)
                        }

                        // Children list
                        ChildrenSection(
                            children: children,
                            isLoading: isLoading,
                            onAddChild: { showAddChild = true }
                        )

                        // Tips section
                        ParentTipsSection()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .sheet(isPresented: $showAddChild) {
                AddChildSheet(onComplete: {
                    showAddChild = false
                    Task { await loadChildren() }
                })
            }
        }
        .task {
            await loadChildren()
        }
    }

    private func loadChildren() async {
        do {
            children = try await supabaseService.fetchChildren()
        } catch {
            print("Error loading children: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Parent Header

struct ParentHeader: View {
    let name: String
    let onLogout: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("مرحباً")
                    .font(MaeemTypography.body)
                    .foregroundColor(.maeemSoftWhite.opacity(0.7))

                Text(name)
                    .font(MaeemTypography.titleMedium)
                    .foregroundColor(.maeemWhite)
            }

            Spacer()

            Menu {
                Button(action: onLogout) {
                    Label("تسجيل الخروج", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.maeemGold)
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - Overview Stats

struct OverviewStatsSection: View {
    let children: [Child]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("نظرة عامة")
                .font(MaeemTypography.titleSmall)
                .foregroundColor(.maeemWhite)

            HStack(spacing: 12) {
                StatCard(
                    title: "الأطفال",
                    value: "\(children.count)",
                    icon: "person.2.fill",
                    color: .maeemGold
                )

                StatCard(
                    title: "المراجعات اليوم",
                    value: "٣",
                    icon: "clock.fill",
                    color: .maeemAmber
                )

                StatCard(
                    title: "أيام متتالية",
                    value: "٥",
                    icon: "flame.fill",
                    color: .maeemOrange
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.maeemWhite)

            Text(title)
                .font(MaeemTypography.caption)
                .foregroundColor(.maeemSoftWhite.opacity(0.6))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Children Section

struct ChildrenSection: View {
    let children: [Child]
    let isLoading: Bool
    let onAddChild: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("الأطفال")
                    .font(MaeemTypography.titleSmall)
                    .foregroundColor(.maeemWhite)

                Spacer()

                Button(action: onAddChild) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("إضافة")
                    }
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemGold)
                }
            }

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .maeemGold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if children.isEmpty {
                EmptyChildrenView(onAddChild: onAddChild)
            } else {
                ForEach(children) { child in
                    ChildProgressCard(child: child)
                }
            }
        }
    }
}

struct EmptyChildrenView: View {
    let onAddChild: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.maeemGold.opacity(0.5))

            Text("لم تضف أي طفل بعد")
                .font(MaeemTypography.body)
                .foregroundColor(.maeemSoftWhite.opacity(0.6))

            MaeemButton("إضافة طفل", icon: "plus", action: onAddChild)
                .frame(width: 200)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(20)
    }
}

struct ChildProgressCard: View {
    let child: Child

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.maeemGold.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Text(String(child.name.prefix(1)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.maeemGold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(child.name)
                        .font(MaeemTypography.titleSmall)
                        .foregroundColor(.maeemWhite)

                    Text("\(child.age) سنوات • \(child.level)")
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemSoftWhite.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.left")
                    .foregroundColor(.maeemGold)
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("التقدم الكلي")
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemSoftWhite.opacity(0.6))

                    Spacer()

                    Text("٦٥%")
                        .font(MaeemTypography.caption)
                        .foregroundColor(.maeemGold)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.maeemWhite.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.maeemGold)
                            .frame(width: geometry.size.width * 0.65, height: 8)
                    }
                }
                .frame(height: 8)
            }

            // Suggestion
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.maeemAmber)

                Text("راجع المقطع ٢ مع طفلك اليوم")
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemSoftWhite.opacity(0.8))

                Spacer()
            }
            .padding(12)
            .background(Color.maeemAmber.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(16)
        .background(Color.maeemWhite.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - Parent Tips

struct ParentTipsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("نصائح للوالدين")
                .font(MaeemTypography.titleSmall)
                .foregroundColor(.maeemWhite)

            VStack(spacing: 12) {
                TipCard(
                    icon: "clock",
                    title: "الوقت المناسب",
                    description: "أفضل أوقات الحفظ بعد صلاة الفجر أو قبل النوم"
                )

                TipCard(
                    icon: "repeat",
                    title: "التكرار اليومي",
                    description: "١٥ دقيقة يومياً أفضل من ساعة أسبوعياً"
                )

                TipCard(
                    icon: "gift",
                    title: "التشجيع",
                    description: "احتفل بإنجازات طفلك مهما كانت صغيرة"
                )
            }
        }
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.maeemGold)
                .frame(width: 44, height: 44)
                .background(Color.maeemGold.opacity(0.15))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MaeemTypography.body)
                    .foregroundColor(.maeemWhite)

                Text(description)
                    .font(MaeemTypography.caption)
                    .foregroundColor(.maeemSoftWhite.opacity(0.6))
            }

            Spacer()
        }
        .padding(12)
        .background(Color.maeemWhite.opacity(0.03))
        .cornerRadius(12)
    }
}

// MARK: - Add Child Sheet

struct AddChildSheet: View {
    let onComplete: () -> Void

    @EnvironmentObject var supabaseService: SupabaseService
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var age = 7
    @State private var level: DifficultyLevel = .beginner
    @State private var isLoading = false

    var isFormValid: Bool {
        !name.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.maeemBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        MaeemTextField(
                            title: "اسم الطفل",
                            placeholder: "أدخل اسم طفلك",
                            text: $name,
                            icon: "person.fill"
                        )

                        // Age picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("العمر")
                                .font(MaeemTypography.caption)
                                .foregroundColor(.maeemSoftWhite.opacity(0.7))

                            Picker("العمر", selection: $age) {
                                ForEach(4...15, id: \.self) { age in
                                    Text("\(age) سنوات").tag(age)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                        }

                        // Level selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("المستوى")
                                .font(MaeemTypography.caption)
                                .foregroundColor(.maeemSoftWhite.opacity(0.7))

                            Picker("المستوى", selection: $level) {
                                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                    Text(level.displayNameAr).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        MaeemButton("إضافة الطفل") {
                            Task { await addChild() }
                        }
                        .disabled(!isFormValid || isLoading)
                        .opacity(isFormValid ? 1 : 0.6)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("إضافة طفل")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إلغاء") { dismiss() }
                        .foregroundColor(.maeemGold)
                }
            }
        }
    }

    private func addChild() async {
        guard let parentId = supabaseService.currentUser?.id else { return }

        isLoading = true
        do {
            let child = ChildInsert(
                parentId: parentId,
                name: name,
                age: age,
                level: level.rawValue
            )
            try await supabaseService.addChild(child)
            onComplete()
        } catch {
            print("Error adding child: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    ParentDashboardView()
        .environmentObject(AppState.shared)
        .environmentObject(SupabaseService.shared)
}
