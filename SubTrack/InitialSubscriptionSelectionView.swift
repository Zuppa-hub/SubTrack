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
    @State private var isConfiguring: Bool = false
    
    // Grid configuration: 3 adaptive columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                // --- Header and Title ---
                HStack {
                    Text(LocalizedStringKey("select_active_subscriptions"))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(LocalizedStringKey("skip")) {
                        manager.isLoggedIn = true
                    }
                }
                .padding(.horizontal)
                
                // --- Search Bar (Placeholder) ---
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField(LocalizedStringKey("search_services_placeholder"), text: .constant("")) // Placeholder
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding([.horizontal, .bottom])
                
                // --- Selection Grid ---
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
                
                // --- Next Button ---
                if !selectedServiceIDs.isEmpty {
                    // Uses NSLocalizedString for string formatting (e.g., "Next (3 Selected)")
                    Button(String(format: NSLocalizedString("next_selected_format", comment: ""), selectedServiceIDs.count)) {
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
            
            .navigationDestination(isPresented: .constant(currentServiceIndex != nil)) {
                if let index = currentServiceIndex, index < servicesToConfigure.count {
                    let service = servicesToConfigure[index]
                    ConfigureSubscriptionView(
                        serviceToConfigure: service,
                        onCompletion: { newSub in
                            handleConfigurationCompletion(subscription: newSub)
                        }
                    )
                    .id(service.id) // Force recreation of the view for each service
                } else {
                    Text(LocalizedStringKey("internal_configuration_error"))
                        .frame(height: 0)
                }
            }
        }
    }
    
    private func startConfiguration() {
        // 1. Filter selected services
        servicesToConfigure = PredefinedService.popularServices.filter {
            selectedServiceIDs.contains($0.id)
        }
        // 2. Reset the configured subscriptions array
        configuredSubscriptions = []
        // 3. Start the first step
        currentServiceIndex = 0
    }
    
    private func handleConfigurationCompletion(subscription: Subscription) {
        // 1. Add the configured subscription to the temporary array
        configuredSubscriptions.append(subscription)
        
        // 2. Check if there are other subscriptions to configure
        if let current = currentServiceIndex, current + 1 < servicesToConfigure.count {
            // Move to the next subscription
            currentServiceIndex = current + 1
        } else {
            // 3. CONFIGURATION END:
            // Add all subscriptions to the Manager
            for sub in configuredSubscriptions {
                manager.addSubscription(sub)
            }
            
            // Set the app state to logged in and switch to the Tab Bar
            manager.isLoggedIn = true
            
            // Reset the index to close the NavigationStack
            currentServiceIndex = nil
        }
    }
    
    // Function to handle multiple selection
    private func toggleSelection(_ service: PredefinedService) {
        if selectedServiceIDs.contains(service.id) {
            selectedServiceIDs.remove(service.id)
        } else {
            selectedServiceIDs.insert(service.id)
        }
    }
}

// --- View for the Grid Item ---
struct ServiceGridItem: View {
    let service: PredefinedService
    let isSelected: Bool
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                // Service Icon
                Image(systemName: service.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(service.isCustom ? .blue : .primary)
                    .padding()
                    .background(service.isCustom ? Color(.systemGray5) : Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 3)
                
                // ⭐️ Checkmark on the bottom right
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .background(Circle().fill(.white))
                        .offset(x: 5, y: 5)
                }
            }
            
            // Service Name
            Text(service.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .opacity(isSelected ? 1.0 : 0.7) // Make selected items more prominent
    }
}

#Preview {
    InitialSubscriptionSelectionView()
        .environment(SubscriptionManager())
}
