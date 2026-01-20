# SubTrack

A modern iOS app to manage and track your subscriptions easily and efficiently.

## 📋 Description

SubTrack is a SwiftUI application for managing recurring subscriptions. It allows users to track the total cost of their subscriptions, view detailed statistics, and receive assistance from a personalized AI assistant.

## ✨ Features

### 🏠 Home
- **Active subscriptions list**: view all your subscriptions sorted by next renewal date
- **Monthly total cost**: monitor your total spending for the current month
- **Quick search**: easily find your subscriptions
- **Add subscription**: add new custom subscriptions or select from predefined services

### 📊 Statistics
- **Monthly analysis**: view total monthly expenses
- **Yearly analysis**: track annual spending
- **Category breakdown**: see how much you spend on each category (Entertainment, Music, Productivity, etc.)
- **Interactive charts**: visual representations of your spending

### 🤖 AI Assistant
- **Personalized advice**: receive suggestions on how to save money
- **Spending analysis**: ask questions about your subscriptions and spending
- **Intelligent assistance**: responses generated based on your spending data

### ⚙️ Settings
- **Account profile**: manage your account data
- **Default currency**: choose your preferred currency
- **Notifications**: configure alerts for renewals

### 🔐 Authentication
- **Login**: access with email and password
- **Registration**: create a new account
- **Single Sign-On**: continue with Apple ID

## 🛠️ Technologies Used

- **SwiftUI**: modern framework for building user interfaces
- **Swift Observation**: reactive state management
- **Codable**: data serialization and deserialization
- **Localization**: multi-language support (Italian, English)

## 📦 Project Structure

```
SubTrack/
├── SubTrackApp.swift              # Application entry point
├── ContentView.swift              # Main view with TabBar
├── SubscriptionModel.swift        # Data models and Manager
├── LoginView.swift                # Login screen
├── RegistrationView.swift         # User registration
├── OnboardingView.swift           # Initial onboarding
├── SubscriptionsListView.swift    # Subscriptions list (Home)
├── StatisticsView.swift           # Statistics view
├── AITextBoxView.swift            # AI Assistant
├── SettingsView.swift             # Settings
├── SubscriptionDetailView.swift   # Subscription details
├── ConfigureSubscriptionView.swift # Subscription configuration
├── InitialSubscriptionSelectionView.swift # Service selection
├── MonthlySummaryView.swift       # Monthly summary
├── en.lproj/                      # Localized strings (English)
└── it.lproj/                      # Localized strings (Italian)
```

## 🗂️ Main Data Models

### Subscription
Represents a single subscription with the following properties:
- `id`: unique identifier (UUID)
- `name`: service name
- `cost`: subscription cost
- `currency`: currency used
- `renewalDate`: next renewal date
- `paymentCycle`: payment frequency (Monthly, Quarterly, Annually, Weekly)
- `category`: service category
- `daysUntilRenewal`: days remaining until renewal (computed)

### Category
Available categories:
- Entertainment
- Music
- Productivity
- News
- Gaming
- Fitness
- Other

### PaymentCycle
Supported payment cycles:
- Monthly
- Quarterly
- Annually
- Weekly

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/username/SubTrack.git
   cd SubTrack
   ```

2. **Open the project in Xcode**
   ```bash
   open SubTrack.xcodeproj
   ```

3. **Build and run**
   - Select a simulator or connected device
   - Press Cmd + R to build and launch

## 📱 Requirements

- iOS 14 or later
- Xcode 15+
- Swift 5.9+

## 🌍 Localization

The app supports:
- 🇮🇹 Italian
- 🇬🇧 English

Localized strings are managed through `.strings` files in `en.lproj` and `it.lproj`.

## 🎯 Predefined Services

The app includes a list of popular preconfigured services:
- Netflix
- Spotify
- Disney+
- Amazon Prime
- YouTube Premium
- Apple Music
- Xbox Game Pass
- Dropbox
- Custom (for personalized services)

## 📊 State Management

The app uses the `SubscriptionManager` class (marked with `@Observable`) to manage:
- Subscriptions list
- User login state
- Persistent data

## 🔒 Security

- Secure credential management
- Single Sign-On with Apple
- Data safely stored on device

## 📝 Development Notes

- Renewal dates are used to sort subscriptions
- Costs are automatically calculated for the current period
- Statistics update in real-time with app data

## 👨‍💻 Author

Andrea Cazzato - University Project (Mobile Systems)

---

**Last updated**: January 2026
