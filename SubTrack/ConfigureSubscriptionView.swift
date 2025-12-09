//
//  ConfigureSubscriptionView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct ConfigureSubscriptionView: View {
    @Environment(SubscriptionManager.self) private var manager
    
    // Il servizio che stiamo configurando (passato dalla vista precedente)
    let serviceToConfigure: PredefinedService
    
    @State private var costString: String = "" // Usiamo String per TextField del costo
    @State private var currency: String = "EUR"
    @State private var renewalDate: Date = Date()
    @State private var paymentCycle: PaymentCycle = .monthly
    
    // L'azione da eseguire al completamento (passata dalla vista madre)
    let onCompletion: (Subscription) -> Void
    
    // Dizionario delle valute semplici (per la demo)
    let availableCurrencies = ["EUR", "USD", "GBP"]
    
    var body: some View {
        Form { // Form è ideale per la raccolta di input strutturati
            
            // --- Sezione Dettagli ---
            Section(header: Text("Dettagli Abbonamento")) {
                
                // Nome del Servizio (non modificabile, viene dal PredefinedService)
                HStack {
                    Text("Servizio:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(serviceToConfigure.name)
                        .fontWeight(.semibold)
                }
            }
            
            // --- Sezione Costo e Ciclo ---
            Section(header: Text("Costo e Pagamento")) {
                
                // Input Costo
                TextField("Costo (es. 12.99)", text: $costString)
                    .keyboardType(.decimalPad) // Tastiera numerica
                
                // Scelta Valuta
                Picker("Valuta", selection: $currency) {
                    ForEach(availableCurrencies, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                
                // Scelta Ciclo di Pagamento
                Picker("Ciclo di Pagamento", selection: $paymentCycle) {
                    // Usiamo CaseIterable definito nel PaymentCycle
                    ForEach(PaymentCycle.allCases, id: \.self) { cycle in
                        Text(cycle.rawValue) // .rawValue mostra il nome leggibile ("Mensile")
                    }
                }
            }
            
            // --- Sezione Data di Rinnovo ---
            Section(header: Text("Prossimo Rinnovo")) {
                DatePicker("Data di Rinnovo", selection: $renewalDate, displayedComponents: .date)
                    // Non permettiamo date passate
                    .datePickerStyle(.graphical)
                    .tint(.blue)
            }
            
            // --- Pulsante di Salvataggio ---
            Button("Salva Abbonamento") {
                saveSubscription()
            }
            // Disabilitato se il campo costo è vuoto o non valido
            .disabled(costString.isEmpty || Double(costString) == nil)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .navigationTitle("Configura \(serviceToConfigure.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Funzione per creare e salvare l'abbonamento
    private func saveSubscription() {
        guard let cost = Double(costString) else { return } // Dovrebbe essere gestito da disabled, ma per sicurezza
        
        // Crea il nuovo oggetto Subscription
        let newSubscription = Subscription(
            id: UUID(), // Assicurati di passare l'ID per la correzione Codable
            name: serviceToConfigure.name,
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
        onCompletion: { _ in } // Placeholder vuoto per la preview
    )
    .environment(SubscriptionManager())
}
