import Foundation
import SwiftUI // Included for @Observable (often implicitly available)

// MARK: - 1. The Data Structure
struct Subscription: Identifiable, Codable {
    // Unique identifier, required for using ForEach in SwiftUI Lists
    let id : UUID
    
    var name: String // E.g.: "Netflix", "Spotify"
    var cost: Double // E.g.: 12.99
    var currency: String // E.g.: "EUR", "USD"
    
    // The date when the subscription renews next
    var renewalDate: Date
    
    var paymentCycle: PaymentCycle // Monthly, Annually, etc.
    var isCustom: Bool = false
    
    // Computed Property: useful for sorting and display
    var daysUntilRenewal: Int {
        // Calculates the difference in days between now and the renewal date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: renewalDate)
        // Returns the number of days, or 0 if calculation fails
        return components.day ?? 0
    }
}
struct MonthlyCost: Identifiable {
    let id = UUID()
    let month: String
    let totalCost: Double
}
// for the onboarding
struct PredefinedService: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let isCustom: Bool
    
    // static list of predefined services
    static let popularServices: [PredefinedService] = [
        PredefinedService(name: "Custom", iconName: "plus.circle.fill", isCustom: true),
        PredefinedService(name: "Netflix", iconName: "netflix.icon", isCustom: false),
        PredefinedService(name: "Spotify", iconName: "spotify.icon" , isCustom: false),
        PredefinedService(name: "Disney+", iconName: "film.fill", isCustom: false),
        PredefinedService(name: "Amazon Prime", iconName: "bag.fill", isCustom: false),
        PredefinedService(name: "YouTube Premium", iconName: "play.tv.fill", isCustom: false),
        PredefinedService(name: "Apple Music", iconName: "music.note.list", isCustom: false),
        PredefinedService(name: "Xbox Game Pass", iconName: "gamecontroller.fill", isCustom: false),
        PredefinedService(name: "Dropbox", iconName: "folder.fill.badge.person.crop", isCustom: false),
    ]
}

// MARK: - 2. Enumeration for Payment Cycle
// CaseIterable allows us to easily iterate over all possible cases (e.g., in a Picker)
enum PaymentCycle: String, Codable, CaseIterable {
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annually = "Annually"
    case weekly = "Weekly"
}

// MARK: - 3. The Data Manager (Shared State)
// @Observable ensures that all Views using this class are automatically notified and refreshed
// whenever the 'subscriptions' array changes.
@Observable
class SubscriptionManager {
    // The list that will hold all the user's subscriptions
    var subscriptions: [Subscription] = []
    var isLoggedIn: Bool = false

    // Initializer: executed when the Manager is created
    init() {
        /* Create mock data for initial testing
        if subscriptions.isEmpty {
            subscriptions = Self.createMockSubscriptions()
        }
         */
    }
    
    // Example function to add a subscription
    func addSubscription(_ sub: Subscription) {
        subscriptions.append(sub)
        // TODO: Add logic here to save data permanently (Persistence)
    }
    
    // Helper function to create sample data
    static func createMockSubscriptions() -> [Subscription] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let today = Date()
        
        // Renewal in 3 days
        let netflixDate = calendar.date(byAdding: .day, value: 3, to: today)!
        // Renewal in 15 days
        let spotifyDate = calendar.date(byAdding: .day, value: 15, to: today)!

        return [
            Subscription(id: UUID(), name: "Netflix Premium", cost: 17.99, currency: "EUR", renewalDate: netflixDate, paymentCycle: .monthly),
            Subscription(id: UUID(), name: "Spotify Family", cost: 15.99, currency: "EUR", renewalDate: spotifyDate, paymentCycle: .monthly),
            Subscription(id: UUID(), name: "Adobe Creative Cloud", cost: 60.99, currency: "EUR", renewalDate: calendar.date(byAdding: .month, value: 3, to: today)!, paymentCycle: .quarterly),
        ]
    }
    func calculateEstimatedMonthlyCost() -> [MonthlyCost] {
        if subscriptions.isEmpty {
            return []
        }
        
        // 1. Calcola il costo totale equivalente mensile per OGNI abbonamento
        let monthlyTotal = subscriptions.reduce(0.0) { result, sub in
            let monthlyEquivalent: Double
            
            switch sub.paymentCycle {
            case .monthly:
                monthlyEquivalent = sub.cost
            case .quarterly:
                monthlyEquivalent = sub.cost / 3.0
            case .annually:
                monthlyEquivalent = sub.cost / 12.0
            case .weekly:
                monthlyEquivalent = sub.cost * (30.0 / 7.0) // Approssimazione
            }
            
            // Accumula il totale
            return result + monthlyEquivalent
        }
        
        // 2. Creiamo dei dati fittizi per visualizzare una tendenza storica
        // NB: La logica del mese è fittizia per mostrare una tendenza nel grafico.
        let costs = [
            ("Ottobre 2025", monthlyTotal * 0.95),
            ("Novembre 2025", monthlyTotal),
            ("Dicembre 2025", monthlyTotal * 1.05), // Aumento fittizio nel mese corrente
            ("Gennaio 2026", monthlyTotal * 1.02),
        ]
        
        return costs.map { MonthlyCost(month: $0.0, totalCost: $0.1) }
    }
}
