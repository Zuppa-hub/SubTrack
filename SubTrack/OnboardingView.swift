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
    
    // ⭐️ Lo stato che decide quale schermata mostrare (Login o Registrazione)
    @State private var currentScreen: AuthScreen = .login
    
    // Funzione chiamata al successo dell'autenticazione
    func handleAuthSuccess() {
        // Al successo, impostiamo lo stato di login a true nel Manager
        manager.isLoggedIn = true
        // ⚠️ Nota: Aggiungeremo qui la logica per la selezione iniziale degli abbonamenti più avanti
    }
    
    var body: some View {
        // Usa una NavigationStack per permettere il pulsante "back"
        NavigationStack {
            VStack {
                
                // --- Visualizzazione Condizionale ---
                switch currentScreen {
                case .login:
                    LoginView(
                        onLoginSuccess: handleAuthSuccess,
                        onRegisterTapped: {
                            // Cambia la schermata quando l'utente clicca "Register for free"
                            currentScreen = .registration
                        }
                    )
                case .registration:
                    RegistrationView(
                        onRegistrationSuccess: handleAuthSuccess,
                        onLoginTapped: {
                            // Cambia la schermata quando l'utente clicca "Log in"
                            currentScreen = .login
                        }
                    )
                }
            }
            .animation(.easeInOut, value: currentScreen) // Animazione fluida tra le schermate
            // Nasconde la barra di navigazione di default, lasciando l'interfaccia pulita
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(SubscriptionManager())
}
