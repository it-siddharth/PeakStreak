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
        weekCount: Int = 10,
        showLabels: Bool = false,
        cellSize: CGFloat = AppTheme.Grid.cellSize,
        cellSpacing: CGFloat = AppTheme.Grid.cellSpacing
    ) {
        self.habit = habit
        self.weekCount = weekCount
        self.showLabels = showLabels
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
    }
    
    var body: some View {
        HStack(spacing: cellSpacing) {
            ForEach(Date.lastWeeks(weekCount).indices, id: \.self) { weekIndex in
                let week = Date.lastWeeks(weekCount)[weekIndex]
                VStack(spacing: cellSpacing) {
                    ForEach(week, id: \.self) { date in
                        ContributionCell(
                            date: date,
                            isCompleted: habit.isCompleted(for: date),
                            isFuture: date.isFuture,
                            size: cellSize
                        ) {
                            toggleCompletion(for: date)
                        }
                    }
                }
            }
        }
    }
    
    private func toggleCompletion(for date: Date) {
        guard !date.isFuture else { return }
        withAnimation(AppTheme.Animation.quick) {
            habit.toggleCompletion(for: date, context: modelContext)
        }
    }
}

// MARK: - Contribution Cell (Grayscale)
struct ContributionCell: View {
    let date: Date
    let isCompleted: Bool
    let isFuture: Bool
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: AppTheme.Grid.cellCornerRadius)
                .fill(cellColor)
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
    
    private var cellColor: Color {
        if isFuture {
            return AppTheme.Colors.gridNotCompleted.opacity(0.3)
        } else if isCompleted {
            return AppTheme.Colors.gridCompleted // White
        } else {
            // Vary the gray slightly for visual interest
            return AppTheme.Colors.gridNotCompleted
        }
    }
}

// MARK: - Compact Widget Version (uses habit colors)
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
            return habit.color // Use habit color for widget
        } else {
            return AppTheme.Colors.backgroundTertiary
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#737373")
    container.mainContext.insert(habit)
    
    return VStack(spacing: 40) {
        ContributionGridView(habit: habit, weekCount: 10)
            .padding()
        
        CompactContributionGrid(habit: habit, weekCount: 7)
            .padding()
    }
    .padding()
    .background(AppTheme.Colors.background)
    .modelContainer(container)
}
