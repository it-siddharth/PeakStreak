//
//  HabitDetailView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI
import SwiftData

enum CalendarViewMode: String, CaseIterable {
    case monthly = "Monthly"
    case grid = "Grid"
    
    var icon: String {
        switch self {
        case .monthly: return "calendar"
        case .grid: return "square.grid.3x3"
        }
    }
}

struct HabitDetailView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewMode: CalendarViewMode = .grid
    @State private var showingDeleteAlert = false
    
    private var isCompletedToday: Bool {
        habit.isCompleted(for: Date())
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundSecondary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Header Card
                    headerCard
                    
                    // Stats Row
                    statsRow
                    
                    // View Mode Toggle
                    viewModeToggle
                    
                    // Calendar View
                    calendarSection
                    
                    Spacer(minLength: 100)
                }
                .padding(AppTheme.Spacing.md)
            }
            
            // Complete Today Button
            VStack {
                Spacer()
                
                completeButton
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Habit", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteHabit()
            }
        } message: {
            Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: habit.icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(habit.color)
            }
            
            VStack(spacing: AppTheme.Spacing.xxs) {
                Text(habit.name)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Started \(habit.createdAt.formatted(.dateTime.month(.wide).day().year()))")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .cardStyle()
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            StatCard(
                title: "Current Streak",
                value: "\(habit.currentStreak)",
                unit: "days",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Total Completed",
                value: "\(totalCompletedDays)",
                unit: "days",
                icon: "checkmark.circle.fill",
                color: habit.color
            )
            
            StatCard(
                title: "Completion Rate",
                value: "\(completionRate)",
                unit: "%",
                icon: "chart.line.uptrend.xyaxis",
                color: AppTheme.Colors.teal
            )
        }
    }
    
    // MARK: - View Mode Toggle
    private var viewModeToggle: some View {
        HStack(spacing: 0) {
            ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(AppTheme.Animation.quick) {
                        viewMode = mode
                    }
                }) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .medium))
                        Text(mode.rawValue)
                            .font(AppTheme.Typography.subheadline)
                    }
                    .foregroundColor(viewMode == mode ? .white : AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        viewMode == mode ? habit.color : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.Spacing.xxs)
        .background(AppTheme.Colors.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
    
    // MARK: - Calendar Section
    private var calendarSection: some View {
        Group {
            switch viewMode {
            case .monthly:
                MonthlyCalendarView(habit: habit)
                    .cardStyle()
            case .grid:
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Last 16 Weeks")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.top, AppTheme.Spacing.md)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        ContributionGridView(
                            habit: habit,
                            weekCount: 16,
                            showLabels: true,
                            cellSize: 14,
                            cellSpacing: 3
                        )
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.bottom, AppTheme.Spacing.md)
                    }
                }
                .cardStyle()
            }
        }
    }
    
    // MARK: - Complete Button
    private var completeButton: some View {
        Button(action: {
            withAnimation(AppTheme.Animation.bouncy) {
                habit.toggleCompletion(for: Date(), context: modelContext)
            }
        }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                
                Text(isCompletedToday ? "Completed Today" : "Mark Complete")
            }
        }
        .buttonStyle(PrimaryButtonStyle(color: isCompletedToday ? AppTheme.Colors.teal : habit.color))
    }
    
    // MARK: - Computed Properties
    private var totalCompletedDays: Int {
        habit.entries.filter { $0.completed }.count
    }
    
    private var completionRate: Int {
        let calendar = Calendar.current
        let daysSinceCreation = calendar.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 1
        let activeDays = max(daysSinceCreation, 1)
        return min(100, Int((Double(totalCompletedDays) / Double(activeDays)) * 100))
    }
    
    // MARK: - Actions
    private func deleteHabit() {
        modelContext.delete(habit)
        dismiss()
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(unit)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.xs)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        let container = try! ModelContainer(for: Habit.self, HabitEntry.self)
        let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#FF5A5F")
        container.mainContext.insert(habit)
        
        return HabitDetailView(habit: habit)
            .modelContainer(container)
    }
}

