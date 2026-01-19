//
//  AITextBoxView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct AITextBoxView: View {
    @Environment(SubscriptionManager.self) private var manager
    @State private var userMessage = ""
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // Messages list
                if messages.isEmpty {
                    VStack(alignment: .center, spacing: 20) {
                        Image(systemName: "sparkles.square.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(LocalizedStringKey("ai_welcome_title"))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(LocalizedStringKey("ai_welcome_description"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                        .padding()
                    }
                }
                
                // Input area
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        TextField(LocalizedStringKey("ai_message_placeholder"), text: $userMessage)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .disabled(userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    Text(LocalizedStringKey("ai_disclaimer"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle(LocalizedStringKey("ai_title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // Add user message
        messages.append(ChatMessage(id: UUID(), text: trimmedMessage, isUser: true))
        
        // Generate AI response based on keywords
        let response = generateAIResponse(for: trimmedMessage)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages.append(ChatMessage(id: UUID(), text: response, isUser: false))
        }
        
        userMessage = ""
    }
    
    private func generateAIResponse(for userText: String) -> String {
        let lowercased = userText.lowercased()
        let totalExpense = manager.getTotalMonthlyExpense()
        let subscriptionCount = manager.subscriptions.count
        
        if lowercased.contains("cost") || lowercased.contains("expense") || lowercased.contains("spesa") {
            return "Le tue spese mensili totali sono: €\(String(format: "%.2f", totalExpense)). Hai \(subscriptionCount) abbonamenti attivi."
        }
        
        if lowercased.contains("reduce") || lowercased.contains("save") || lowercased.contains("riduci") {
            if let mostExpensive = manager.subscriptions.max(by: { $0.cost < $1.cost }) {
                return "Il tuo abbonamento più costoso è \(mostExpensive.name) a €\(String(format: "%.2f", mostExpensive.cost)). Considera di annullarlo se non lo usi regolarmente."
            }
            return "Potresti rivedere i tuoi abbonamenti meno utilizzati e considerare di cancellarli per risparmiare."
        }
        
        if lowercased.contains("category") || lowercased.contains("categor") {
            let stats = manager.getCategoryStatistics()
            if let topCategory = stats.first {
                return "La categoria con più spese è \(topCategory.category.rawValue) con €\(String(format: "%.2f", topCategory.totalCost)) al mese."
            }
        }
        
        if lowercased.contains("how many") || lowercased.contains("quanti") {
            return "Hai \(subscriptionCount) abbonamenti attivi."
        }
        
        return "Ciao! Sono l'assistente AI di SubTrack. Puoi chiedermi informazioni sulle tue spese, sui tuoi abbonamenti o su come risparmiare. Cosa posso fare per te?"
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                
                Text(message.text)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "sparkles.square.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(message.text)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    let manager = SubscriptionManager()
    manager.isLoggedIn = true
    
    return AITextBoxView()
        .environment(manager)
}
