//
//  InitialSubscriptionSelectionView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

// File: InitialSubscriptionSelectionView.swift

import SwiftUI

struct InitialSubscriptionSelectionView: View {
    @Environment(SubscriptionManager.self) private var manager
    
    @State private var selectedServiceIDs: Set<UUID> = []
    @State private var servicesToConfigure: [PredefinedService] = []
    @State private var configuredSubscriptions: [Subscription] = []
    @State private var currentServiceIndex: Int? = nil
    // Configurazione della griglia: 3 colonne adattive
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                // --- Header e Titolo ---
                HStack {
                    Text("Select your active subscriptions")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button("Skip") {
                        manager.isLoggedIn = true
                    }
                }
                .padding(.horizontal)
                
                // --- Barra di Ricerca (Placeholder) ---
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search services...", text: .constant("")) // Placeholder
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding([.horizontal, .bottom])
                
                // --- Griglia di Selezione ---
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(PredefinedService.popularServices) { service in
                            ServiceGridItem(service: service, isSelected: selectedServiceIDs.contains(service.id))
                                .onTapGesture {
                                    toggleSelection(service)
                                }
                        }
                    }
                    .padding()
                }
                
                // --- Pulsante Next ---
                if !selectedServiceIDs.isEmpty {
                    Button("Next (\(selectedServiceIDs.count) Selected)") {
                        startConfiguration()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $currentServiceIndex) { index in
                guard index < servicesToConfigure.count else {
                    // Se l'indice non è valido, mostra un placeholder vuoto o ritorna
                    // (Questo è solo un controllo di sicurezza)
                    return Text("Errore di configurazione interno.").frame(height: 0)
                }
                
                let service = servicesToConfigure[index]
                
                ConfigureSubscriptionView(
                    serviceToConfigure: service,
                    onCompletion: { newSub in
                        handleConfigurationCompletion(subscription: newSub)
                    }
                )
            }
    }
    private func startConfiguration() {
        // 1. Filtra i servizi selezionati
        servicesToConfigure = PredefinedService.popularServices.filter {
            selectedServiceIDs.contains($0.id)
        }
        // 2. Resetta l'array di abbonamenti configurati
        configuredSubscriptions = []
        // 3. Avvia il primo step
        currentServiceIndex = 0
    }
    private func handleConfigurationCompletion(subscription: Subscription) {
        // 1. Aggiunge l'abbonamento configurato all'array temporaneo
        configuredSubscriptions.append(subscription)
        
        // 2. Controlla se ci sono altri abbonamenti da configurare
        if let current = currentServiceIndex, current + 1 < servicesToConfigure.count {
            // Passa al prossimo abbonamento
            currentServiceIndex = current + 1
        } else {
            // 3. FINE DELLA CONFIGURAZIONE:
            // Aggiunge tutti gli abbonamenti al Manager
            for sub in configuredSubscriptions {
                manager.addSubscription(sub)
            }
            
            // Imposta lo stato dell'app su loggato e passa alla Tab Bar
            manager.isLoggedIn = true
            
            // Resetta l'indice per chiudere la NavigationStack
            currentServiceIndex = nil
        }
    }
    
    // Funzione per gestire la selezione multipla
    private func toggleSelection(_ service: PredefinedService) {
        if selectedServiceIDs.contains(service.id) {
            selectedServiceIDs.remove(service.id)
        } else {
            selectedServiceIDs.insert(service.id)
        }
    }
}

// --- Vista per l'Elemento della Griglia ---
struct ServiceGridItem: View {
    let service: PredefinedService
    let isSelected: Bool
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                // Icona del Servizio
                Image(systemName: service.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(service.isCustom ? .blue : .primary)
                    .padding()
                    .background(service.isCustom ? Color(.systemGray5) : Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 3)
                
                // ⭐️ Checkmark in basso a destra
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .background(Circle().fill(.white))
                        .offset(x: 5, y: 5)
                }
            }
            
            // Nome del Servizio
            Text(service.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .opacity(isSelected ? 1.0 : 0.7) // Rende gli elementi selezionati più evidenti
    }
}

#Preview {
    InitialSubscriptionSelectionView()
        .environment(SubscriptionManager())
}
