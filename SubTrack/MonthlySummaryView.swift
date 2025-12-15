//
//  MonthlySummaryView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 15/12/25.
//

// File: MonthlySummaryView.swift

import SwiftUI

struct MonthlySummaryView: View {
    @Environment(SubscriptionManager.self) private var manager
    
    // montly estimated price
    var totalCost: Double {
        manager.calculateEstimatedMonthlyCost().first(where: { $0.month.contains("Dicembre") || $0.month.contains("Novembre") })?.totalCost ?? 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(LocalizedStringKey("total_for_this_month_title")) // "Total for this month"
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 15) {
                // Icona Moneta
                Image(systemName: "dollarsign.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(totalCost, format: .currency(code: "EUR")) // Es. 60.00€
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(String(format: NSLocalizedString("active_subscriptions_count_format", comment: ""), manager.subscriptions.count)) // Es. 3 active subscriptions
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}
