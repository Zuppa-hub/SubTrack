//
//  LoginView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    // Passed from OnboardingView to handle navigation/authentication
    let onLoginSuccess: () -> Void
    let onRegisterTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            
            // --- Header ---
            Text(LocalizedStringKey("welcome_back_title"))
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(LocalizedStringKey("login_subtitle"))
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 30)
            
            // --- Input Fields ---
            VStack(spacing: 15) {
                // TextField uses the localized key as a placeholder
                TextField(LocalizedStringKey("email_placeholder"), text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                SecureField(LocalizedStringKey("password_placeholder"), text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            Spacer().frame(height: 10)
            
            // --- Primary Button ---
            Button(LocalizedStringKey("log_in_button")) {
                if !email.isEmpty && !password.isEmpty {
                    onLoginSuccess()
                } else {
                    print("Please fill all fields")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // --- Separator or Secondary Option ---
            Text(LocalizedStringKey("or_continue_with"))
                .font(.caption)
                .foregroundStyle(.gray)
            
            // Apple/Google Sign-In Button (Secondary)
            Button {
                print("Apple Sign-In pressed")
                onLoginSuccess()
            } label: {
                HStack {
                    Image(systemName: "apple.logo") // Uses an SF Symbols icon
                    Text(LocalizedStringKey("continue_with_apple"))
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.black)
                .cornerRadius(10)
            }
            
            Spacer()
            
            // --- Registration Link ---
            HStack {
                Text(LocalizedStringKey("dont_have_account_prompt"))
                
                Button {
                    onRegisterTapped() // Switches the view to Registration
                } label: {
                    Text(LocalizedStringKey("register_for_free_link"))
                }
            }
        }
        .padding(30)
        .frame(maxHeight: .infinity)
    }
}
