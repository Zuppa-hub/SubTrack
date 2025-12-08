//
//  LoginView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct LoginView: View {
    // ⭐️ @State: Variabili che contengono lo stato locale della vista (input utente)
    @State private var email = ""
    @State private var password = ""
    
    // Passato dalla OnboardingView per gestire la navigazione/autenticazione
    let onLoginSuccess: () -> Void
    let onRegisterTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            
            // --- Header ---
            Text("Welcome back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("The easiest way to manage your subscriptions and save money")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 30)
            
            // --- Campi di Input ---
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            Spacer().frame(height: 10)
            
            // --- Pulsanti Principali ---
            Button("Log in") {
                // TODO: Implementare la logica di autenticazione backend
                onLoginSuccess() // Simulazione di successo
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // --- Separatore o Opzione Secondaria ---
            Text("or continue with")
                .font(.caption)
                .foregroundStyle(.gray)
            
            // Pulsante di Accesso con Apple/Google (Secondario)
            Button {
                // TODO: Implementare l'accesso con servizi esterni
            } label: {
                HStack {
                    Image(systemName: "apple.logo") // Usa un'icona SF Symbols
                    Text("Continue with Apple")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            
            Spacer()
            
            // --- Link Registrazione ---
            HStack {
                Text("Don't have an account?")
                
                Button {
                    onRegisterTapped() // Cambia la vista per la Registrazione
                } label: {
                    Text("**Register for free**")
                }
            }
        }
        .padding(30)
        .frame(maxHeight: .infinity) // ⭐️ Assicura che il VSTACK si estenda
    }
}

// ... (Preview omettiamo per brevità, la faremo nella OnboardingView)
