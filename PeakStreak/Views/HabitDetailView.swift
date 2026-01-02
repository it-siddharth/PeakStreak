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
    @State private var showingGallery = false
    @State private var selectedDate: Date?
    @State private var showingDayDetail = false
    
    private var totalCompletedDays: Int {
        habit.entries.filter { $0.completed }.count
    }
    
    private var totalPhotos: Int {
        habit.entries.reduce(0) { $0 + $1.images.count }
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
                
                // Gallery Button (if has photos)
                if totalPhotos > 0 {
                    galleryButton
                        .padding(.top, AppTheme.Spacing.lg)
                }
                
                Spacer()
                
                // Tip text
                Text("Long press a day to view details")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.bottom, AppTheme.Spacing.md)
                
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
        .sheet(isPresented: $showingGallery) {
            ImageGalleryView(habit: habit)
        }
        .sheet(isPresented: $showingDayDetail) {
            if let date = selectedDate {
                DayDetailView(habit: habit, date: date)
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
            
            // Menu with options
            Menu {
                if totalPhotos > 0 {
                    Button {
                        showingGallery = true
                    } label: {
                        Label("View Gallery", systemImage: "photo.on.rectangle")
                    }
                }
                
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
            cellSpacing: AppTheme.Grid.cellSpacing,
            onDateSelected: { date in
                selectedDate = date
                showingDayDetail = true
            }
        )
        .padding(.horizontal, AppTheme.Spacing.xl)
    }
    
    // MARK: - Habit Info
    private var habitInfoSection: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text("\(totalCompletedDays) days of \(habit.name).")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
            
            if totalPhotos > 0 {
                Text("\(totalPhotos) photo\(totalPhotos == 1 ? "" : "s") captured")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }
    
    // MARK: - Gallery Button
    private var galleryButton: some View {
        Button(action: { showingGallery = true }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 16))
                Text("View Gallery")
                    .font(AppTheme.Typography.caption)
            }
            .foregroundColor(AppTheme.Colors.text)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                Capsule()
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Actions
    private func deleteHabit() {
        modelContext.delete(habit)
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, DayImage.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#737373")
    container.mainContext.insert(habit)
    
    return HabitDetailView(habit: habit)
        .modelContainer(container)
}
