//
//  OnboardingView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

// File: OnboardingView.swift

import SwiftUI

enum AuthScreen {
    case login
    case registration
}

struct OnboardingView: View {
    @Environment(SubscriptionManager.self) private var manager
    
    @State private var isAuthenticated: Bool = false
    
    @State private var currentScreen: AuthScreen = .login
        func handleAuthSuccess() {
        isAuthenticated = true
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if isAuthenticated {
                    InitialSubscriptionSelectionView()
                } else {
                    switch currentScreen {
                    case .login:
                        LoginView(
                            onLoginSuccess: handleAuthSuccess,
                            onRegisterTapped: { currentScreen = .registration }
                        )
                    case .registration:
                        RegistrationView(
                            onRegistrationSuccess: handleAuthSuccess,
                            onLoginTapped: { currentScreen = .login }
                        )
                    }
                }
            }
            .animation(.easeInOut, value: isAuthenticated)
            .animation(.easeInOut, value: currentScreen)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(SubscriptionManager())
}
