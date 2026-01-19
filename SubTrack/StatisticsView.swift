//
//  StatisticsView.swift
//  SubTrack
//
//  Created by Andrea Cazzato on 08/12/25.
//

import SwiftUI

// MARK: - Main View
struct StatisticsView: View {
    @Environment(SubscriptionManager.self) private var manager
    @State private var selectedPeriod: StatisticsPeriod = .monthly
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    StatsHeaderView(totalExpense: totalExpense)
                    
                    StatsPeriodSelector(selectedPeriod: $selectedPeriod)
                    
                    // Pass pre-calculated data to the chart
                    StatsChartView(
                        isEmpty: manager.subscriptions.isEmpty,
                        pieData: pieChartData,
                        topCategoryPercentage: topCategoryPercentage
                    )
                    
                    StatsCategoryListView(categoryData: categoryData)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle(LocalizedStringKey("statistics_title"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalExpense: Double {
        if selectedPeriod == .monthly {
            return manager.getTotalMonthlyExpense()
        } else {
            return manager.getTotalMonthlyExpense() * 12
        }
    }
    
    private var categoryData: [CategoryStat] {
        let stats = manager.getCategoryStatistics()
        if selectedPeriod == .yearly {
            return stats.map { stat in
                CategoryStat(
                    category: stat.category,
                    totalCost: stat.totalCost * 12,
                    transactionCount: stat.transactionCount,
                    percentage: stat.percentage
                )
            }
        }
        return stats
    }
    
    // Pre-calculate chart data to relieve compiler pressure
    private var pieChartData: [PieSliceData] {
        var slices: [PieSliceData] = []
        var currentAngle: Double = -90 // Start at top
        
        for stat in categoryData {
            let angleAmount = stat.percentage * 3.6 // 3.6 degrees per percent
            let endAngle = currentAngle + angleAmount
            
            slices.append(PieSliceData(
                startAngle: Angle(degrees: currentAngle),
                endAngle: Angle(degrees: endAngle),
                color: stat.category.color
            ))
            
            currentAngle = endAngle
        }
        return slices
    }
    
    private var topCategoryPercentage: Int? {
        guard let first = categoryData.first else { return nil }
        return Int(first.percentage)
    }
}

// MARK: - Enums & Models
enum StatisticsPeriod {
    case monthly, yearly
}

struct PieSliceData: Identifiable {
    let id = UUID()
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
}

// MARK: - Subviews

struct StatsHeaderView: View {
    let totalExpense: Double
    
    var body: some View {
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
    }
}

struct StatsPeriodSelector: View {
    @Binding var selectedPeriod: StatisticsPeriod
    
    var body: some View {
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
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct StatsChartView: View {
    let isEmpty: Bool
    let pieData: [PieSliceData]
    let topCategoryPercentage: Int?
    
    var body: some View {
        Group {
            if !isEmpty {
                VStack {
                    ZStack {
                        // Simplified Chart
                        GeometryReader { geometry in
                            ZStack {
                                ForEach(pieData) { slice in
                                    PieSliceShape(
                                        startAngle: slice.startAngle,
                                        endAngle: slice.endAngle
                                    )
                                    .fill(slice.color)
                                }
                            }
                        }
                        .frame(height: 200)
                        
                        // Center Text
                        VStack(spacing: 2) {
                            if let percentage = topCategoryPercentage {
                                Text("\(percentage)%")
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
        }
    }
}

struct StatsCategoryListView: View {
    let categoryData: [CategoryStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("by_category_label"))
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(categoryData) { stat in
                    CategoryRowView(stat: stat)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Components

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

struct CategoryRowView: View {
    let stat: CategoryStat
    
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
            Text("-" + stat.totalCost.formatted(.currency(code: "EUR")))
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}

// Converted to Shape for better performance
struct PieSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * 0.5
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.addLine(to: CGPoint(
            x: center.x + innerRadius * CGFloat(cos(endAngle.radians)),
            y: center.y + innerRadius * CGFloat(sin(endAngle.radians))
        ))
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    let manager = SubscriptionManager()
    manager.isLoggedIn = true
    
    return StatisticsView()
        .environment(manager)
}
