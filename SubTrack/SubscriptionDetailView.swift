//
//  SubscriptionDetailView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct SubscriptionDetailView: View {
    @Environment(SubscriptionManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    let subscription: Subscription
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                // --- 1. Header with Icon ---
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(subscription.category.color.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: subscription.category.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(subscription.category.color)
                    }
                    
                    Text(subscription.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(subscription.cost, format: .currency(code: subscription.currency))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // --- 2. Details Section ---
                VStack(alignment: .leading, spacing: 0) {
                    DetailRow(icon: "calendar", title: LocalizedStringKey("next_renewal"), value: subscription.renewalDate.formatted(date: .long, time: .omitted))
                    Divider()
                    DetailRow(icon: "arrow.triangle.2.circlepath", title: LocalizedStringKey("payment_cycle_title"), value: LocalizedStringKey(subscription.paymentCycle.rawValue))
                    Divider()
                    DetailRow(icon: "tag.fill", title: LocalizedStringKey("category_title"), value: LocalizedStringKey(subscription.category.rawValue))
                }
                .background(Color.gray.opacity(0.1)) // 使用 generic color replacement strategy
                .cornerRadius(12)
                .padding(.horizontal)
                
                // --- 3. Delete Button ---
                Button(role: .destructive) {
                    deleteSubscription()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text(LocalizedStringKey("delete_subscription"))
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .navigationTitle(LocalizedStringKey("details_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteSubscription() {
        manager.deleteSubscription(subscription)
        dismiss()
    }
}

struct DetailRow: View {
    let icon: String
    let title: LocalizedStringKey
    let value: LocalizedStringKey
    
    // Helper init for String value to avoid ambiguity
    init(icon: String, title: LocalizedStringKey, value: String) {
        self.icon = icon
        self.title = title
        self.value = LocalizedStringKey(value)
    }

    init(icon: String, title: LocalizedStringKey, value: LocalizedStringKey) {
        self.icon = icon
        self.title = title
        self.value = value
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.blue)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding()
    }
}

#Preview {
    SubscriptionDetailView(subscription: SubscriptionManager.createMockSubscriptions()[0])
        .environment(SubscriptionManager())
}
