//
//  ContributionGridView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI
import SwiftData

struct ContributionGridView: View {
    let habit: Habit
    let weekCount: Int
    let showLabels: Bool
    let cellSize: CGFloat
    let cellSpacing: CGFloat
    
    @Environment(\.modelContext) private var modelContext
    
    init(
        habit: Habit,
        weekCount: Int = 16,
        showLabels: Bool = true,
        cellSize: CGFloat = 12,
        cellSpacing: CGFloat = 3
    ) {
        self.habit = habit
        self.weekCount = weekCount
        self.showLabels = showLabels
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
    }
    
    private let weekdayLabels = ["", "M", "", "W", "", "F", ""]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Month labels
            if showLabels {
                monthLabels
            }
            
            HStack(alignment: .top, spacing: cellSpacing) {
                // Weekday labels
                if showLabels {
                    weekdayLabelsView
                }
                
                // Grid
                contributionGrid
            }
        }
    }
    
    // MARK: - Month Labels
    private var monthLabels: some View {
        let weeks = Date.lastWeeks(weekCount)
        let monthPositions = calculateMonthPositions(weeks: weeks)
        
        return HStack(spacing: 0) {
            if showLabels {
                // Spacer for weekday labels column
                Color.clear.frame(width: 20)
            }
            
            GeometryReader { geometry in
                let gridWidth = CGFloat(weekCount) * (cellSize + cellSpacing) - cellSpacing
                let scale = geometry.size.width / gridWidth
                
                ZStack(alignment: .leading) {
                    ForEach(monthPositions, id: \.month) { position in
                        Text(position.month)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .offset(x: position.offset * scale)
                    }
                }
            }
            .frame(height: 16)
        }
    }
    
    // MARK: - Weekday Labels
    private var weekdayLabelsView: some View {
        VStack(spacing: cellSpacing) {
            ForEach(0..<7, id: \.self) { index in
                Text(weekdayLabels[index])
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .frame(width: 16, height: cellSize)
            }
        }
    }
    
    // MARK: - Contribution Grid
    private var contributionGrid: some View {
        let weeks = Date.lastWeeks(weekCount)
        
        return HStack(spacing: cellSpacing) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(weeks[weekIndex], id: \.self) { date in
                        ContributionCell(
                            date: date,
                            isCompleted: habit.isCompleted(for: date),
                            isFuture: date.isFuture,
                            accentColor: habit.color,
                            size: cellSize
                        ) {
                            toggleCompletion(for: date)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func calculateMonthPositions(weeks: [[Date]]) -> [(month: String, offset: CGFloat)] {
        var positions: [(month: String, offset: CGFloat)] = []
        var currentMonth = ""
        
        for (index, week) in weeks.enumerated() {
            if let firstDay = week.first {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                let month = formatter.string(from: firstDay)
                
                // Only add if it's a new month and we're at the start of the month
                let dayOfMonth = Calendar.current.component(.day, from: firstDay)
                if month != currentMonth && dayOfMonth <= 7 {
                    currentMonth = month
                    let offset = CGFloat(index) * (cellSize + cellSpacing)
                    positions.append((month, offset))
                } else if month != currentMonth && index == 0 {
                    currentMonth = month
                    positions.append((month, 0))
                }
            }
        }
        
        return positions
    }
    
    private func toggleCompletion(for date: Date) {
        guard !date.isFuture else { return }
        withAnimation(AppTheme.Animation.quick) {
            habit.toggleCompletion(for: date, context: modelContext)
        }
    }
}

// MARK: - Contribution Cell
struct ContributionCell: View {
    let date: Date
    let isCompleted: Bool
    let isFuture: Bool
    let accentColor: Color
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 2)
                .fill(cellColor)
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
    
    private var cellColor: Color {
        if isFuture {
            return AppTheme.Colors.backgroundTertiary.opacity(0.3)
        } else if isCompleted {
            return accentColor
        } else {
            return AppTheme.Colors.backgroundTertiary
        }
    }
}

// MARK: - Compact Widget Version
struct CompactContributionGrid: View {
    let habit: Habit
    let weekCount: Int
    let cellSize: CGFloat
    let cellSpacing: CGFloat
    
    init(
        habit: Habit,
        weekCount: Int = 7,
        cellSize: CGFloat = 10,
        cellSpacing: CGFloat = 2
    ) {
        self.habit = habit
        self.weekCount = weekCount
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
    }
    
    var body: some View {
        let weeks = Date.lastWeeks(weekCount)
        
        HStack(spacing: cellSpacing) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(weeks[weekIndex], id: \.self) { date in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(cellColor(for: date))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
    
    private func cellColor(for date: Date) -> Color {
        if date.isFuture {
            return AppTheme.Colors.backgroundTertiary.opacity(0.3)
        } else if habit.isCompleted(for: date) {
            return habit.color
        } else {
            return AppTheme.Colors.backgroundTertiary
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#00A699")
    container.mainContext.insert(habit)
    
    return VStack(spacing: 40) {
        ContributionGridView(habit: habit, weekCount: 16)
            .padding()
            .background(AppTheme.Colors.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
        CompactContributionGrid(habit: habit, weekCount: 7)
            .padding()
            .background(AppTheme.Colors.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
    .background(AppTheme.Colors.backgroundSecondary)
    .modelContainer(container)
}

