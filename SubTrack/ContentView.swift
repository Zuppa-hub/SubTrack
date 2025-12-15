//
//  ContentView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 07/12/25.
//

// File: ContentView.swift

import SwiftUI

struct ContentView: View {

    @Environment(SubscriptionManager.self) private var manager
    
    var body: some View {
        if manager.isLoggedIn {
            // Show the Tab Bar (Home, Statistics, etc.)
            TabView {
                SubscriptionsListView()
                    .tabItem { Label(LocalizedStringKey("tab_subscriptions"), systemImage: "list.bullet.rectangle.fill") }
                
                StatisticsView()
                    .tabItem { Label(LocalizedStringKey("tab_statistics"), systemImage: "chart.bar.fill") }

                AITextBoxView()
                    .tabItem { Label(LocalizedStringKey("tab_ai"), systemImage: "sparkles.square.fill") }
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

