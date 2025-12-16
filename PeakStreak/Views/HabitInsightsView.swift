//
//  HabitInsightsView.swift
//  PeakStreak
//
//  Created by PeakStreak on 16/12/25.
//

import SwiftUI
import Charts
import SwiftData

struct HabitInsightsView: View {
    let habit: Habit

    @Environment(\.dismiss) private var dismiss

    private var totalCompletedDays: Int {
        habit.entries.filter { $0.completed }.count
    }

    private var last30Rate: Double {
        habit.completionRate(lastDays: 30)
    }

    private var last14Days: [HabitDailyPoint] {
        habit.dailyPoints(lastDays: 14)
    }

    private var last10Weeks: [HabitWeeklyPoint] {
        habit.weeklyPoints(lastWeeks: 10)
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        summarySection

                        weeklyChartSection

                        dailyChartSection

                        SquiggleView()
                            .frame(width: 80, height: 24)
                            .padding(.top, AppTheme.Spacing.lg)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
        }
    }

    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.Colors.text)
            }

            Spacer()

            Text("Insights")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)

            Spacer()

            // Keep symmetry with an invisible placeholder
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .opacity(0)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
    }

    // MARK: - Summary
    private var summarySection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(habit.name)
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.text)
                .multilineTextAlignment(.center)

            Text("\(totalCompletedDays) days done · \(habit.currentStreak) day streak")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Text("Last 30 days: \(Int((last30Rate * 100).rounded()))%")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }

    // MARK: - Weekly Chart
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Weekly")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)

            Chart {
                ForEach(last10Weeks) { point in
                    BarMark(
                        x: .value("Week", point.weekStart),
                        y: .value("Completed", point.completedCount)
                    )
                    .foregroundStyle(habit.color)
                    .opacity(point.totalCount == 0 ? 0.2 : 0.85)
                    .cornerRadius(3)
                }
            }
            .chartYScale(domain: 0...7)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 140)
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }

    // MARK: - Daily Chart
    private var dailyChartSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Last 14 days")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)

            Chart {
                ForEach(last14Days) { point in
                    BarMark(
                        x: .value("Day", point.date),
                        y: .value("Done", point.value)
                    )
                    .foregroundStyle(point.completed ? habit.color : AppTheme.Colors.backgroundTertiary)
                    .opacity(point.completed ? 0.85 : 0.6)
                    .cornerRadius(2)
                }
            }
            .chartYScale(domain: 0...1)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 90)
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#FF5A5F")

    // Seed a few entries
    let calendar = Calendar.current
    for offset in [0, 1, 2, 4, 7, 9, 12, 13, 15, 20] {
        let date = calendar.date(byAdding: .day, value: -offset, to: Date())!.startOfDay
        let entry = HabitEntry(date: date, completed: true)
        entry.habit = habit
        habit.entries.append(entry)
    }

    container.mainContext.insert(habit)

    return HabitInsightsView(habit: habit)
        .modelContainer(container)
}
