import SwiftUI

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isAuthenticated = false
    @Published var currentUserRole: UserRole?
    @Published var currentChild: Child?
    @Published var selectedSurah: Surah?
    @Published var currentSession: LearningSession?

    // Navigation
    @Published var currentRoute: AppRoute = .splash

    private init() {}

    // MARK: - Session Management

    func startSession(surah: Surah, chunks: [AyahChunk]) {
        currentSession = LearningSession(
            surahId: surah.id,
            surahName: surah.nameAr,
            chunks: chunks
        )
    }

    func completeChunk(_ chunkId: UUID) {
        currentSession?.completedChunks.insert(chunkId)
        if let index = currentSession?.currentChunkIndex,
           let count = currentSession?.chunks.count,
           index < count - 1 {
            currentSession?.currentChunkIndex = index + 1
        }
    }

    func resetSession() {
        currentSession = nil
    }

    // MARK: - Auth State

    func setAuthenticated(role: UserRole) {
        isAuthenticated = true
        currentUserRole = role
        currentRoute = role == .parent ? .parentDashboard : .home
    }

    func logout() {
        isAuthenticated = false
        currentUserRole = nil
        currentChild = nil
        selectedSurah = nil
        currentSession = nil
        currentRoute = .onboarding
    }
}

// MARK: - App Routes

enum AppRoute: Hashable {
    case splash
    case onboarding
    case roleSelection
    case parentSignUp
    case childSetup
    case surahSelection
    case levelCheck
    case home
    case learn(surahId: Int)
    case practice(surahId: Int)
    case orderGame(surahId: Int)
    case missingSegmentGame(surahId: Int)
    case recite(surahId: Int)
    case results
    case parentDashboard
    case childProgress(childId: UUID)
}

// MARK: - Router

@MainActor
class Router: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func replace(with route: AppRoute) {
        path = NavigationPath()
        path.append(route)
    }
}
