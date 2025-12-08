//
//  SubTrackApp.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 07/12/25.
//

import SwiftUI

@main
struct SubTrackApp: App {
    // Crea un'unica istanza del SubscriptionManager all'avvio dell'app.
    @State private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            // Rende il manager accessibile a tutte le viste all'interno di ContentView
            ContentView()
                .environment(subscriptionManager)
        }
    }
}
