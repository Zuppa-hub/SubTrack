//
//  ContentView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 07/12/25.
//

// ContentView.swift aggiornato

// File: ContentView.swift

import SwiftUI

struct ContentView: View {

    @Environment(SubscriptionManager.self) private var manager
    
    var body: some View {
        if manager.isLoggedIn {
            // MOSTRA LA TAB BAR (Schermate Home, Statistiche, ecc.)
            TabView {
                SubscriptionsListView()
                    .tabItem { Label("Abbonamenti", systemImage: "list.bullet.rectangle.fill") }
                
                StatisticsView()
                    .tabItem { Label("Statistiche", systemImage: "chart.bar.fill") }

                AITextBoxView()
                    .tabItem { Label("AI", systemImage: "sparkles.square.fill") }
            }
        } else {
            OnboardingView()
        }
    }
}

#Preview {

    let manager = SubscriptionManager()
    manager.isLoggedIn = false
    
    return ContentView()
        .environment(manager)
}
