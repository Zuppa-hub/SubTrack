//
//  SubTrackApp.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 07/12/25.
//

import SwiftUI

@main
struct SubTrackApp: App {
    //Create instance
    @State private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
        }
    }
}
