//
//  HabitListView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    
    private var completedTodayCount: Int {
        habits.filter { $0.isCompleted(for: Date()) }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppTheme.Colors.backgroundSecondary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Header Stats Card
                        headerCard
                        
                        // Habits Section
                        if habits.isEmpty {
                            emptyStateView
                        } else {
                            habitsSection
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
            .navigationTitle("PeakStreak")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: createTestHabit) {
                        Text("Test Habit")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.Colors.teal)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.Colors.coral)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .navigationDestination(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
            }
            .onChange(of: habits.count) {
                refreshWidget()
            }
            .onAppear {
                refreshWidget()
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text(Date().formatted(.dateTime.weekday(.wide)))
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Text(Date().formatted(.dateTime.month(.wide).day()))
                        .font(AppTheme.Typography.title2)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.backgroundTertiary, lineWidth: 6)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: habits.isEmpty ? 0 : CGFloat(completedTodayCount) / CGFloat(habits.count))
                        .stroke(
                            AppTheme.Colors.coral,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(AppTheme.Animation.smooth, value: completedTodayCount)
                    
                    VStack(spacing: 0) {
                        Text("\(completedTodayCount)")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("/\(habits.count)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            
            // Motivational message
            if habits.isEmpty {
                Text("Start your journey by adding your first habit")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            } else if completedTodayCount == habits.count && habits.count > 0 {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("All habits completed today!")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.teal)
                }
            } else {
                Text("\(habits.count - completedTodayCount) habit\(habits.count - completedTodayCount == 1 ? "" : "s") remaining today")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
                .frame(height: 60)
            
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.coral.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppTheme.Colors.coral)
            }
            
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("No habits yet")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Add your first habit to start\nbuilding your streak")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingAddHabit = true }) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Habit")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 200)
            .padding(.top, AppTheme.Spacing.md)
            
            Spacer()
        }
        .padding(AppTheme.Spacing.xl)
    }
    
    // MARK: - Habits Section
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Your Habits")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.leading, AppTheme.Spacing.xxs)
            
            LazyVStack(spacing: AppTheme.Spacing.sm) {
                ForEach(habits) { habit in
                    HabitRowView(habit: habit)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedHabit = habit
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteHabit(habit)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Actions
    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            modelContext.delete(habit)
        }
    }
    
    private func createTestHabit() {
        // Random habit names and icons
        let testHabits: [(name: String, icon: String)] = [
            ("Morning Run", "figure.run"),
            ("Meditation", "brain.head.profile"),
            ("Read Books", "book.fill"),
            ("Drink Water", "drop.fill"),
            ("Exercise", "dumbbell.fill"),
            ("Yoga", "figure.yoga"),
            ("Journal", "book.closed.fill"),
            ("Sleep Early", "moon.fill"),
            ("Eat Healthy", "fork.knife"),
            ("Learn Coding", "keyboard.fill"),
            ("Practice Piano", "music.note"),
            ("No Sugar", "cup.and.saucer.fill"),
            ("Cold Shower", "drop.fill"),
            ("Gratitude", "heart.fill"),
            ("Walk 10k Steps", "figure.walk")
        ]
        
        let colors = AppTheme.Colors.habitColors
        
        // Pick random habit and color
        let randomHabit = testHabits.randomElement()!
        let randomColor = colors.randomElement()!
        
        // Create the habit
        let habit = Habit(
            name: randomHabit.name,
            icon: randomHabit.icon,
            colorHex: randomColor.hex
        )
        
        // Set creation date to 4 months ago
        let calendar = Calendar.current
        habit.createdAt = calendar.date(byAdding: .month, value: -4, to: Date()) ?? Date()
        
        modelContext.insert(habit)
        
        // Generate random completion data for last 4 months (~120 days)
        let today = Date()
        let daysToGenerate = 120
        
        // Random completion rate between 40% and 80%
        let completionRate = Double.random(in: 0.4...0.8)
        
        for dayOffset in 0..<daysToGenerate {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Random chance based on completion rate
            // Make recent days more likely to be completed (for streak)
            let adjustedRate: Double
            if dayOffset < 7 {
                adjustedRate = 0.85 // High chance for last week (builds streak)
            } else if dayOffset < 30 {
                adjustedRate = completionRate + 0.1
            } else {
                adjustedRate = completionRate
            }
            
            if Double.random(in: 0...1) < adjustedRate {
                let entry = HabitEntry(date: calendar.startOfDay(for: date), completed: true)
                entry.habit = habit
                habit.entries.append(entry)
            }
        }
        
        // Trigger widget refresh
        refreshWidget()
    }
    
    private func refreshWidget() {
        // Save habit data for widget
        WidgetDataManager.shared.saveHabitsForWidget(habits)
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}

