//
//  MonthlyCalendarView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI
import SwiftData

struct MonthlyCalendarView: View {
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentMonth: Date = Date()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Month Navigation
            monthNavigator
            
            // Weekday Headers
            weekdayHeaders
            
            // Calendar Grid
            calendarGrid
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
    
    // MARK: - Month Navigator
    private var monthNavigator: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.backgroundSecondary)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(currentMonth.monthYearString)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(canGoForward ? AppTheme.Colors.textSecondary : AppTheme.Colors.textTertiary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.Colors.backgroundSecondary)
                    .clipShape(Circle())
            }
            .disabled(!canGoForward)
        }
    }
    
    // MARK: - Weekday Headers
    private var weekdayHeaders: some View {
        HStack(spacing: 4) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(AppTheme.Typography.captionBold)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        let dates = currentMonth.calendarGridDates()
        
        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    DayCell(
                        date: date,
                        isCompleted: habit.isCompleted(for: date),
                        isToday: date.isToday,
                        isFuture: date.isFuture,
                        accentColor: habit.color
                    ) {
                        toggleCompletion(for: date)
                    }
                } else {
                    Color.clear
                        .frame(height: 40)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var canGoForward: Bool {
        let calendar = Calendar.current
        let currentMonthStart = currentMonth.startOfMonth
        let thisMonthStart = Date().startOfMonth
        return currentMonthStart < thisMonthStart
    }
    
    // MARK: - Actions
    private func previousMonth() {
        withAnimation(AppTheme.Animation.quick) {
            currentMonth = currentMonth.adding(months: -1)
        }
    }
    
    private func nextMonth() {
        guard canGoForward else { return }
        withAnimation(AppTheme.Animation.quick) {
            currentMonth = currentMonth.adding(months: 1)
        }
    }
    
    private func toggleCompletion(for date: Date) {
        guard !date.isFuture else { return }
        withAnimation(AppTheme.Animation.bouncy) {
            habit.toggleCompletion(for: date, context: modelContext)
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let isFuture: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                if isCompleted {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .fill(accentColor)
                } else if isToday {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(accentColor, lineWidth: 2)
                }
                
                // Day Number
                Text(date.dayString)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundColor(
                        isCompleted ? .white :
                        isFuture ? AppTheme.Colors.textTertiary :
                        isToday ? accentColor :
                        AppTheme.Colors.textPrimary
                    )
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#FF5A5F")
    container.mainContext.insert(habit)
    
    return MonthlyCalendarView(habit: habit)
        .modelContainer(container)
        .padding()
}

