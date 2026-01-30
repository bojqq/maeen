import SwiftUI

/// Legacy ContentView - App now uses RootView from maeemApp.swift
/// This file can be removed or used for testing individual components

struct ContentView: View {
    var body: some View {
        RootView()
            .environmentObject(AppState.shared)
            .environmentObject(Router())
            .environmentObject(SupabaseService.shared)
    }
}

#Preview {
    ContentView()
}
