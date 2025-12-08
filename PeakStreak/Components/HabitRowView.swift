//
//  HabitRowView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI
import SwiftData

struct HabitRowView: View {
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    
    private var isCompletedToday: Bool {
        habit.isCompleted(for: Date())
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.15))
                    .frame(width: 52, height: 52)
                
                Image(systemName: habit.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(habit.color)
            }
            
            // Habit Info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Text(habit.name)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(habit.currentStreak > 0 ? .orange : AppTheme.Colors.textTertiary)
                    
                    Text("\(habit.currentStreak) day streak")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Completion Checkbox
            Button(action: {
                withAnimation(AppTheme.Animation.bouncy) {
                    habit.toggleCompletion(for: Date(), context: modelContext)
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(isCompletedToday ? habit.color : AppTheme.Colors.border, lineWidth: 2)
                        .frame(width: 32, height: 32)
                    
                    if isCompletedToday {
                        Circle()
                            .fill(habit.color)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

// MARK: - Mini Contribution Preview
struct MiniContributionPreview: View {
    let habit: Habit
    let weekCount: Int = 4
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Date.lastWeeks(weekCount), id: \.first) { week in
                VStack(spacing: 2) {
                    ForEach(week, id: \.self) { date in
                        let isCompleted = habit.isCompleted(for: date)
                        let isFuture = date.isFuture
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                isFuture ? Color.clear :
                                    isCompleted ? habit.color : AppTheme.Colors.backgroundTertiary
                            )
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#FF5A5F")
    container.mainContext.insert(habit)
    
    return HabitRowView(habit: habit)
        .modelContainer(container)
        .padding()
}

