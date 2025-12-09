//
//  HabitDetailView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteAlert = false
    
    private var totalCompletedDays: Int {
        habit.entries.filter { $0.completed }.count
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                Spacer()
                
                // Full Screen Grid
                gridSection
                
                // Habit Info
                habitInfoSection
                    .padding(.top, AppTheme.Spacing.xl)
                
                Spacer()
                
                // Squiggle at bottom
                SquiggleView()
                    .frame(width: 80, height: 24)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
            }
        }
        .alert("Delete Journey", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteHabit()
            }
        } message: {
            Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
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
            
            // Delete button (optional menu)
            Menu {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Journey", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.Colors.text)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
    }
    
    // MARK: - Grid Section
    private var gridSection: some View {
        ContributionGridView(
            habit: habit,
            weekCount: 10,
            showLabels: false,
            cellSize: AppTheme.Grid.cellSize,
            cellSpacing: AppTheme.Grid.cellSpacing
        )
        .padding(.horizontal, AppTheme.Spacing.xl)
    }
    
    // MARK: - Habit Info
    private var habitInfoSection: some View {
        Text("\(totalCompletedDays) days of \(habit.name).")
            .font(AppTheme.Typography.body)
            .foregroundColor(AppTheme.Colors.text)
    }
    
    // MARK: - Actions
    private func deleteHabit() {
        modelContext.delete(habit)
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#737373")
    container.mainContext.insert(habit)
    
    return HabitDetailView(habit: habit)
        .modelContainer(container)
}
