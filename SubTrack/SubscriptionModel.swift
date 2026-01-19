import Foundation
import SwiftUI // Included for @Observable (often implicitly available)

// MARK: - Category Enumeration
enum Category: String, Codable, CaseIterable {
    case entertainment = "Entertainment"
    case music = "Music"
    case productivity = "Productivity"
    case news = "News"
    case gaming = "Gaming"
    case fitness = "Fitness"
    case other = "Other"
    
    var iconName: String {
        switch self {
        case .entertainment: return "film.fill"
        case .music: return "music.note"
        case .productivity: return "briefcase.fill"
        case .news: return "newspaper.fill"
        case .gaming: return "gamecontroller.fill"
        case .fitness: return "figure.run"
        case .other: return "tag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .entertainment: return .red
        case .music: return .purple
        case .productivity: return .blue
        case .news: return .orange
        case .gaming: return .green
        case .fitness: return .pink
        case .other: return .gray
        }
    }
}

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
    var category: Category // Category of the subscription
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
    var subscriptions: [Subscription] = [] {
        didSet {
            saveSubscriptions()
        }
    }
    var isLoggedIn: Bool = false {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        }
    }
    
    private let subscriptionsKey = "savedSubscriptions"

    // Initializer: executed when the Manager is created
    init() {
        loadSubscriptions()
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    // Example function to add a subscription
    func addSubscription(_ sub: Subscription) {
        subscriptions.append(sub)
    }
    
    // MARK: - Persistence Methods
    private func saveSubscriptions() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: subscriptionsKey)
        }
    }
    
    private func loadSubscriptions() {
        if let savedData = UserDefaults.standard.data(forKey: subscriptionsKey),
           let decoded = try? JSONDecoder().decode([Subscription].self, from: savedData) {
            subscriptions = decoded
        }
    }
    
    func deleteSubscription(_ subscription: Subscription) {
        subscriptions.removeAll { $0.id == subscription.id }
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
            Subscription(id: UUID(), name: "Netflix Premium", cost: 17.99, currency: "EUR", renewalDate: netflixDate, paymentCycle: .monthly, category: .entertainment),
            Subscription(id: UUID(), name: "Spotify Family", cost: 15.99, currency: "EUR", renewalDate: spotifyDate, paymentCycle: .monthly, category: .music),
            Subscription(id: UUID(), name: "Adobe Creative Cloud", cost: 60.99, currency: "EUR", renewalDate: calendar.date(byAdding: .month, value: 3, to: today)!, paymentCycle: .quarterly, category: .productivity),
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
    
    // MARK: - Statistics Methods
    struct CategoryStat: Identifiable {
        let id = UUID()
        let category: Category
        let totalCost: Double
        let transactionCount: Int
        let percentage: Double
    }
    
    func getCategoryStatistics() -> [CategoryStat] {
        guard !subscriptions.isEmpty else { return [] }
        
        // Group subscriptions by category
        let grouped = Dictionary(grouping: subscriptions, by: { $0.category })
        
        // Calculate total monthly cost for percentage
        let totalMonthlyCost = subscriptions.reduce(0.0) { result, sub in
            let monthlyEquivalent: Double
            switch sub.paymentCycle {
            case .monthly: monthlyEquivalent = sub.cost
            case .quarterly: monthlyEquivalent = sub.cost / 3.0
            case .annually: monthlyEquivalent = sub.cost / 12.0
            case .weekly: monthlyEquivalent = sub.cost * (30.0 / 7.0)
            }
            return result + monthlyEquivalent
        }
        
        // Create statistics for each category
        let stats = grouped.map { (category, subs) -> CategoryStat in
            let categoryCost = subs.reduce(0.0) { result, sub in
                let monthlyEquivalent: Double
                switch sub.paymentCycle {
                case .monthly: monthlyEquivalent = sub.cost
                case .quarterly: monthlyEquivalent = sub.cost / 3.0
                case .annually: monthlyEquivalent = sub.cost / 12.0
                case .weekly: monthlyEquivalent = sub.cost * (30.0 / 7.0)
                }
                return result + monthlyEquivalent
            }
            
            let percentage = totalMonthlyCost > 0 ? (categoryCost / totalMonthlyCost) * 100 : 0
            
            return CategoryStat(
                category: category,
                totalCost: categoryCost,
                transactionCount: subs.count,
                percentage: percentage
            )
        }
        
        return stats.sorted { $0.totalCost > $1.totalCost }
    }
    
    func getTotalMonthlyExpense() -> Double {
        return subscriptions.reduce(0.0) { result, sub in
            let monthlyEquivalent: Double
            switch sub.paymentCycle {
            case .monthly: monthlyEquivalent = sub.cost
            case .quarterly: monthlyEquivalent = sub.cost / 3.0
            case .annually: monthlyEquivalent = sub.cost / 12.0
            case .weekly: monthlyEquivalent = sub.cost * (30.0 / 7.0)
            }
            return result + monthlyEquivalent
        }
    }
}
