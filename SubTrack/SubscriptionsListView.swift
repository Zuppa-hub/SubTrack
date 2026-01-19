//
//  SubscriptionsListView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct SubscriptionsListView: View {
    // We request the instance of the SubscriptionManager that was injected
    @Environment(SubscriptionManager.self) private var manager
    
    // State to control the presentation of the modal sheet for adding a subscription
    @State private var isShowingAddSheet = false
    
    @State private var searchText = ""

    // File: SubscriptionsListView.swift (Correzione del body)

    var body: some View {
        // ⭐️ CORREZIONE: NavigationStack deve avvolgere TUTTA la logica
        NavigationStack {
            
            // Contenuto della vista (Home Screen o Empty State)
            Group {
                if manager.subscriptions.isEmpty {
                    // Stato Vuoto
                    ContentUnavailableView(
                        label: {
                            Label(LocalizedStringKey("no_subscriptions_title"), systemImage: "xmark.circle")
                        },
                        description: {
                            Text(LocalizedStringKey("no_subscriptions_description"))
                        },
                        actions: {
                            Button(LocalizedStringKey("add_button")) {
                                isShowingAddSheet = true
                            }
                        }
                    )
                } else {
                    // Stato Pieno (il tuo layout ScrollView)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            
                            // --- 1. Header con Data e Impostazioni ---
                            HStack {
                                VStack(alignment: .leading) {
                                    // ... (Data e Giorno della Settimana) ...
                                    Text(NSLocalizedString("day_of_week_placeholder", comment: ""))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(Date(), style: .date)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                                NavigationLink {
                                    SettingsView() // Naviga alla vista Impostazioni
                                } label: {
                                    Image(systemName: "gearshape")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                            
                            // --- 2. Barra di Ricerca ---
                            HStack {
                                Image(systemName: "magnifyingglass")
                                TextField(LocalizedStringKey("search_subscription_placeholder"), text: $searchText)
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                            // --- 3. Riepilogo Mensile ---
                            MonthlySummaryView()
                                .padding(.horizontal)
                            
                            // --- 4. Intestazione Lista e Pulsante Add ---
                            HStack {
                                Text(LocalizedStringKey("active_subscriptions_list_title"))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Button(LocalizedStringKey("add_button")) {
                                    isShowingAddSheet = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            .padding(.horizontal)
                            
                            // --- 5. Lista Abbonamenti ---
                            let sortedSubscriptions = manager.subscriptions
                                .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
                                .sorted { $0.renewalDate < $1.renewalDate }
                            
                            VStack(spacing: 1) {
                                ForEach(sortedSubscriptions) { subscription in
                                    NavigationLink(destination: SubscriptionDetailView(subscription: subscription)) {
                                        SubscriptionRowView(subscription: subscription)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Keeps the row looking like a custom view, not a blue link
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                }
                            }
                        } // Fine VStack ScrollView
                    } // Fine ScrollView
                    .navigationTitle(LocalizedStringKey("home_screen_title"))
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            // ⭐️ Aggiungiamo .toolbar e .sheet QUI (dopo il NavigationStack)
            .toolbar {
                 // Il pulsante Aggiungi è gestito nell'HStack interno, ma se volessi un pulsante fisso nella barra...
                 // ... lo metteresti qui se fosse necessario. Per ora lasciamo l'HStack interno come nel mockup.
            }
            .sheet(isPresented: $isShowingAddSheet) {
                // ... (Implementazione del foglio modale per l'aggiunta) ...
                NavigationStack {
                    ConfigureSubscriptionView(
                        serviceToConfigure: PredefinedService(name: NSLocalizedString("custom_sub_name", comment: ""), iconName: "tag.fill", isCustom: true),
                        onCompletion: { newSub in
                            manager.addSubscription(newSub)
                            isShowingAddSheet = false
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(LocalizedStringKey("cancel_button")) {
                                isShowingAddSheet = false
                            }
                        }
                    }
                }
            }
        } // Fine NavigationStack
    }
}

// Support view for the design of each individual row
// File: SubscriptionsListView.swift (dentro SubscriptionRowView)

struct SubscriptionRowView: View {
    let subscription: Subscription
    
    // Formatta la data di rinnovo in base al design (es. "Tomorrow" o "In two weeks")
    var renewalText: String {
        let days = subscription.daysUntilRenewal
        let dateFormatter = DateFormatter()
        
        if days == 0 {
            return NSLocalizedString("renewal_tomorrow", comment: "") // Domani
        } else if days <= 7 {
            return String(format: NSLocalizedString("renewal_in_days_format", comment: ""), days) // In X giorni
        } else if days <= 30 {
            let weeks = days / 7
            return String(format: NSLocalizedString("renewal_in_weeks_format", comment: ""), weeks) // In X settimane
        } else {
            // Mostra la data esatta per scadenze più lontane
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: subscription.renewalDate)
        }
    }
    
    var body: some View {
        HStack {
            // Icona Servizio (Placeholder)
            Image(systemName: subscription.isCustom ? "tag.fill" : "circle.fill")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(subscription.isCustom ? .purple : .red)
                .padding(.trailing, 5)
            
            // Dettagli Nome e Rinnovo
            VStack(alignment: .leading) {
                Text(subscription.name)
                    .font(.headline)
                
                Text(renewalText) // Es. "Tomorrow", "In two weeks"
                    .font(.subheadline)
                    .foregroundColor(subscription.daysUntilRenewal <= 7 ? .red : .gray) // Colore rosso se vicina
            }
            
            Spacer()
            
            // Costo e Gestisci >
            HStack(spacing: 5) {
                Text(subscription.cost, format: .currency(code: subscription.currency))
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

        }
    }
}
#Preview {
    SubscriptionsListView()
        .environment(SubscriptionManager())
}
