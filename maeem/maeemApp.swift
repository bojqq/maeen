import SwiftUI
import Supabase

@main
struct maeemApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var router = Router()
    @StateObject private var supabaseService = SupabaseService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(router)
                .environmentObject(supabaseService)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root View

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var supabaseService: SupabaseService

    var body: some View {
        Group {
            switch appState.currentRoute {
            case .splash:
                SplashView()
            case .onboarding, .roleSelection:
                OnboardingFlow()
            case .parentDashboard:
                ParentDashboardView()
            case .home:
                HomeView()
            default:
                OnboardingFlow()
            }
        }
        .animation(.easeInOut, value: appState.currentRoute)
    }
}
