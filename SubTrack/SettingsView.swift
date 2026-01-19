//
//  SettingsView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(SubscriptionManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                // --- Account Section ---
                Section(header: Text(LocalizedStringKey("settings_account"))) {
                    HStack {
                        Text(LocalizedStringKey("settings_email"))
                        Spacer()
                        Text("user@example.com")
                            .foregroundColor(.secondary)
                    }
                }
                
                // --- Preferences Section ---
                Section(header: Text(LocalizedStringKey("settings_preferences"))) {
                    NavigationLink(destination: CurrencySettingsView()) {
                        Text(LocalizedStringKey("settings_default_currency"))
                    }
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        Text(LocalizedStringKey("settings_notifications"))
                    }
                }
                
                // --- Data Section ---
                Section(header: Text(LocalizedStringKey("settings_data"))) {
                    Button(action: { showDeleteConfirmation = true }) {
                        HStack {
                            Text(LocalizedStringKey("settings_delete_all_data"))
                            Spacer()
                            Image(systemName: "trash")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                // --- About Section ---
                Section(header: Text(LocalizedStringKey("settings_about"))) {
                    HStack {
                        Text(LocalizedStringKey("settings_version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {}) {
                        Text(LocalizedStringKey("settings_privacy_policy"))
                    }
                    
                    Button(action: {}) {
                        Text(LocalizedStringKey("settings_terms_of_service"))
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .alert(LocalizedStringKey("confirm_delete_title"), isPresented: $showDeleteConfirmation) {
                Button(LocalizedStringKey("cancel_button"), role: .cancel) { }
                Button(LocalizedStringKey("delete_button"), role: .destructive) {
                    manager.subscriptions = []
                    dismiss()
                }
            } message: {
                Text(LocalizedStringKey("confirm_delete_message"))
            }
        }
    }
}

struct CurrencySettingsView: View {
    @State private var selectedCurrency = "EUR"
    
    var body: some View {
        Form {
            Picker(LocalizedStringKey("settings_default_currency"), selection: $selectedCurrency) {
                Text("EUR (€)").tag("EUR")
                Text("USD ($)").tag("USD")
                Text("GBP (£)").tag("GBP")
            }
        }
        .navigationTitle(LocalizedStringKey("settings_default_currency"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsView: View {
    @State private var renewalReminders = true
    @State private var weeklyReport = false
    
    var body: some View {
        Form {
            Section {
                Toggle(LocalizedStringKey("settings_renewal_reminders"), isOn: $renewalReminders)
                Toggle(LocalizedStringKey("settings_weekly_report"), isOn: $weeklyReport)
            }
        }
        .navigationTitle(LocalizedStringKey("settings_notifications"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environment(SubscriptionManager())
}
