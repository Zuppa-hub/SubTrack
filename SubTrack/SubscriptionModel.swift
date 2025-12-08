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
}
