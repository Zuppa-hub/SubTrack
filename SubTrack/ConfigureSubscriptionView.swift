//
//  ConfigureSubscriptionView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct ConfigureSubscriptionView: View {
    @Environment(SubscriptionManager.self) private var manager
    
    // Il servizio che stiamo configurando
    let serviceToConfigure: PredefinedService
    
    // Usiamo 'serviceName' universale invece di 'customServiceName'
    @State private var serviceName: String
    @State private var costString: String = ""
    @State private var currency: String = "EUR"
    @State private var renewalDate: Date = Date()
    @State private var paymentCycle: PaymentCycle = .monthly
    
    // Azione al completamento
    let onCompletion: (Subscription) -> Void
    
    let availableCurrencies = ["EUR", "USD", "GBP"]
    
    // ⭐️ INIZIALIZZATORE PERSONALIZZATO
    // Serve per pre-popolare il campo 'serviceName' con il nome del servizio scelto (es. "Netflix")
    init(serviceToConfigure: PredefinedService, onCompletion: @escaping (Subscription) -> Void) {
        self.serviceToConfigure = serviceToConfigure
        self.onCompletion = onCompletion
        
        // Inizializza lo stato del nome con il valore passato
        _serviceName = State(initialValue: serviceToConfigure.name)
    }
    
    var body: some View {
        Form {
            // --- Details Section ---
            Section(header: Text(LocalizedStringKey("subscription_details"))) {
                
                // ⭐️ CAMPO NOME: Ora funziona per TUTTI i servizi
                // Parte pre-compilato con "Netflix" (o altro) ma è modificabile
                TextField(LocalizedStringKey("service_name_placeholder"), text: $serviceName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                
                // ⭐️ CAMPO COSTO
                TextField(LocalizedStringKey("cost_placeholder"), text: $costString)
                    .keyboardType(.decimalPad)
            }
            
            // --- Cost and Payment Section ---
            Section(header: Text(LocalizedStringKey("cost_and_payment"))) {
                
                // Currency Picker
                Picker(LocalizedStringKey("currency_title"), selection: $currency) {
                    ForEach(availableCurrencies, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                
                // Payment Cycle Picker
                Picker(LocalizedStringKey("payment_cycle_title"), selection: $paymentCycle) {
                    ForEach(PaymentCycle.allCases, id: \.self) { cycle in
                        Text(LocalizedStringKey(cycle.rawValue))
                    }
                }
            }
            
            // --- Next Renewal Date Section ---
            Section(header: Text(LocalizedStringKey("next_renewal"))) {
                DatePicker(LocalizedStringKey("renewal_date_title"), selection: $renewalDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(.blue)
            }
            
            // --- Save Button ---
            Button(LocalizedStringKey("save_subscription")) {
                saveSubscription()
            }
            // Disabilitato se costo invalido o nome vuoto
            .disabled(costString.isEmpty || Double(costString) == nil || serviceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .navigationTitle("\(NSLocalizedString("configure_title_prefix", comment: "")) \(serviceToConfigure.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // ⭐️ UNICA Funzione di salvataggio
    private func saveSubscription() {
        guard let cost = Double(costString) else { return }
        
        // Pulisci e verifica il nome
        let finalServiceName = serviceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !finalServiceName.isEmpty else { return }
        
        // Crea il nuovo oggetto Subscription usando i dati modificati
        let newSubscription = Subscription(
            id: UUID(),
            name: finalServiceName, // Usa il nome editato dall'utente
            cost: cost,
            currency: currency,
            renewalDate: renewalDate,
            paymentCycle: paymentCycle,
            isCustom: serviceToConfigure.isCustom
        )
        
        // Passa l'oggetto creato alla funzione di completamento
        onCompletion(newSubscription)
    }
}

#Preview {
    ConfigureSubscriptionView(
        serviceToConfigure: PredefinedService(name: "Netflix", iconName: "netflix.icon", isCustom: false),
        onCompletion: { _ in }
    )
    .environment(SubscriptionManager())
}
