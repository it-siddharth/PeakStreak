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
    var onDateSelected: ((Date) -> Void)?
    
    @Environment(\.modelContext) private var modelContext
    
    init(
        habit: Habit,
        weekCount: Int = 10,
        showLabels: Bool = false,
        cellSize: CGFloat = AppTheme.Grid.cellSize,
        cellSpacing: CGFloat = AppTheme.Grid.cellSpacing,
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self.habit = habit
        self.weekCount = weekCount
        self.showLabels = showLabels
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
        self.onDateSelected = onDateSelected
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
                            hasImage: habit.hasImages(for: date),
                            isFuture: date.isFuture,
                            size: cellSize,
                            onTap: {
                                toggleCompletion(for: date)
                            },
                            onLongPress: {
                                onDateSelected?(date)
                            }
                        )
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
    let hasImage: Bool
    let isFuture: Bool
    let size: CGFloat
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    init(
        date: Date,
        isCompleted: Bool,
        hasImage: Bool = false,
        isFuture: Bool,
        size: CGFloat,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void = {}
    ) {
        self.date = date
        self.isCompleted = isCompleted
        self.hasImage = hasImage
        self.isFuture = isFuture
        self.size = size
        self.onTap = onTap
        self.onLongPress = onLongPress
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.Grid.cellCornerRadius)
                .fill(cellColor)
                .frame(width: size, height: size)
            
            // Image indicator (small dot in corner)
            if hasImage && !isFuture {
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .offset(x: size/2 - 5, y: -size/2 + 5)
            }
        }
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            if !isFuture {
                onLongPress()
            }
        }
        .disabled(isFuture)
    }
    
    private var cellColor: Color {
        if isFuture {
            return AppTheme.Colors.gridNotCompleted.opacity(0.3)
        } else if isCompleted {
            return AppTheme.Colors.gridCompleted // Dark gray
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
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, DayImage.self)
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
