//
//  StatisticsView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(SubscriptionManager.self) private var manager
    
    @State private var selectedPeriod: StatisticsPeriod = .monthly
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- 1. Total Expenses Header ---
                    VStack(alignment: .leading, spacing: 5) {
                        Text(LocalizedStringKey("total_expenses_label"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(totalExpense, format: .currency(code: "EUR"))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // --- 2. Period Toggle (Monthly/Yearly) ---
                    HStack(spacing: 0) {
                        PeriodToggleButton(
                            title: LocalizedStringKey("monthly_label"),
                            isSelected: selectedPeriod == .monthly
                        ) {
                            selectedPeriod = .monthly
                        }
                        
                        PeriodToggleButton(
                            title: LocalizedStringKey("yearly_label"),
                            isSelected: selectedPeriod == .yearly
                        ) {
                            selectedPeriod = .yearly
                        }
                    }
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    // --- 3. Pie Chart ---
                    if !manager.subscriptions.isEmpty {
                        VStack {
                            ZStack {
                                PieChartView(data: categoryData)
                                    .frame(height: 200)
                                
                                VStack(spacing: 2) {
                                    if let topCategory = categoryData.first {
                                        Text("\(Int(topCategory.percentage))%")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text(LocalizedStringKey("of_total_expenses"))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        ContentUnavailableView(
                            label: {
                                Label(LocalizedStringKey("no_statistics_title"), systemImage: "chart.pie")
                            },
                            description: {
                                Text(LocalizedStringKey("no_statistics_description"))
                            }
                        )
                        .frame(height: 200)
                    }
                    
                    // --- 4. By Category Title ---
                    Text(LocalizedStringKey("by_category_label"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // --- 5. Category List ---
                    VStack(spacing: 12) {
                        ForEach(categoryData) { stat in
                            CategoryRowView(stat: stat)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle(LocalizedStringKey("statistics_title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var totalExpense: Double {
        if selectedPeriod == .monthly {
            return manager.getTotalMonthlyExpense()
        } else {
            return manager.getTotalMonthlyExpense() * 12
        }
    }
    
    var categoryData: [SubscriptionManager.CategoryStat] {
        let stats = manager.getCategoryStatistics()
        if selectedPeriod == .yearly {
            return stats.map { stat in
                SubscriptionManager.CategoryStat(
                    category: stat.category,
                    totalCost: stat.totalCost * 12,
                    transactionCount: stat.transactionCount,
                    percentage: stat.percentage
                )
            }
        }
        return stats
    }
}

// MARK: - Period Toggle
enum StatisticsPeriod {
    case monthly, yearly
}

struct PeriodToggleButton: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(8)
        }
    }
}

// MARK: - Category Row View
struct CategoryRowView: View {
    let stat: SubscriptionManager.CategoryStat
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(stat.category.color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: stat.category.iconName)
                    .font(.title2)
                    .foregroundColor(stat.category.color)
            }
            
            // Category info
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(stat.category.rawValue))
                    .font(.headline)
                
                Text(String(format: NSLocalizedString("transactions_count_format", comment: ""), stat.transactionCount))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Cost
            Text("-\(stat.totalCost, format: .currency(code: "EUR"))")
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Pie Chart View
struct PieChartView: View {
    let data: [SubscriptionManager.CategoryStat]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(data.enumerated()), id: \.offset) { index, stat in
                    PieSlice(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index),
                        color: stat.category.color
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let sum = data.prefix(index).reduce(0.0) { $0 + $1.percentage }
        return Angle(degrees: sum * 3.6 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let sum = data.prefix(index + 1).reduce(0.0) { $0 + $1.percentage }
        return Angle(degrees: sum * 3.6 - 90)
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let innerRadius = radius * 0.5
            
            Path { path in
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.addLine(to: CGPoint(
                    x: center.x + innerRadius * cos(endAngle.radians),
                    y: center.y + innerRadius * sin(endAngle.radians)
                ))
                path.addArc(
                    center: center,
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true
                )
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

#Preview {
    let manager = SubscriptionManager()
    manager.isLoggedIn = true
    
    return StatisticsView()
        .environment(manager)
}

