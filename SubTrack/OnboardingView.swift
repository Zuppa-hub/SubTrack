//
//  OnboardingView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

// File: OnboardingView.swift

import SwiftUI

// ⭐️ Enumerazione per tracciare lo stato di visualizzazione
enum AuthScreen {
    case login
    case registration
}

struct OnboardingView: View {
    @Environment(SubscriptionManager.self) private var manager
    
    // Aggiungiamo un nuovo stato per tracciare la fase di Onboarding
    @State private var isAuthenticated: Bool = false
    
    @State private var currentScreen: AuthScreen = .login
    
    // Funzione chiamata al successo dell'autenticazione
    func handleAuthSuccess() {
        // Al successo dell'autenticazione, passiamo alla selezione iniziale
        isAuthenticated = true
        // ❌ Rimuovi 'manager.isLoggedIn = true' qui. Lo sposteremo dopo la selezione.
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if isAuthenticated {
                    // ⭐️ MOSTRA LA SELEZIONE INIZIALE
                    InitialSubscriptionSelectionView()
                } else {
                    // MOSTRA LOGIN/REGISTRAZIONE
                    switch currentScreen {
                        // ... (Il codice di LoginView e RegistrationView rimane invariato) ...
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
