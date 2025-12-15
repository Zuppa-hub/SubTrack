//
//  RegistrationView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

// File: RegistrationView.swift

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // passed by onboardingView
    let onRegistrationSuccess: () -> Void
    let onLoginTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Create Your Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer().frame(height: 30)
            
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
                
                SecureField("Re-type Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            Spacer().frame(height: 10)
            
            Button("Register") {
                // TODO: Implementare la logica di registrazione backend
                if password == confirmPassword {
                    onRegistrationSuccess() //simulation
                } else {
                    // TODO:shoe an error
                    print("Passwords do not match!")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            
            Spacer()
            
            // --- Link Login ---
            HStack {
                Text("Already have an account?")
                
                Button {
                    onLoginTapped() // change view for login
                } label: {
                    Text("**Log in**")
                }
            }
        }
        .padding(30)
        .frame(maxHeight: .infinity)
    }
}
