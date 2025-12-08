//
//  SubscriptionsListView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct SubscriptionsListView: View {
    // Richiediamo l'istanza del SubscriptionManager che è stata iniettata
    @Environment(SubscriptionManager.self) private var manager
    
    var body: some View {
        // La NavigationStack gestisce la navigazione all'interno della singola tab
        if manager.subscriptions.isEmpty {
            ContentUnavailableView(
                label: {
                    Label("No subscription", systemImage: "xmark.circle")
                },
                description: {
                    Text("Add your first one")
                },
                actions: {
                    Button("Add") {
                        // TODO: Implementare la logica per aprire la schermata di aggiunta
                    }
                }
            )
        }
        else{
            NavigationStack {
                
                // Ordina gli abbonamenti per data di rinnovo (il più vicino prima)
                let sortedSubscriptions = manager.subscriptions.sorted {
                    $0.renewalDate < $1.renewalDate
                }
                
                List {
                    // Iteriamo sulla lista degli abbonamenti ordinati
                    ForEach(sortedSubscriptions) { subscription in
                        // Creiamo una cella (riga) per ogni abbonamento
                        SubscriptionRowView(subscription: subscription)
                    }
                }
                .navigationTitle("Abbonamenti Attivi") // Titolo nella barra superiore
            }
        }
    }
}

// Vista di supporto per il design di ogni singola riga
struct SubscriptionRowView: View {
    let subscription: Subscription
    
    var body: some View {
        HStack {
            // Nome e costo
            VStack(alignment: .leading) {
                Text(subscription.name)
                    .font(.headline)
                
                Text("Rinnovo in \(subscription.daysUntilRenewal) giorni")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            
            Spacer() // Spinge il testo del costo a destra
            
            // Dettaglio Costo
            Text(String(format: "%.2f %@", subscription.cost, subscription.currency))
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    // Per l'Anteprima, dobbiamo iniettare un'istanza mock del manager
    SubscriptionsListView()
        .environment(SubscriptionManager())
}
