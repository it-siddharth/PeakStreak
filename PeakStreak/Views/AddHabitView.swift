//
//  AddHabitView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var habitName: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColorHex: String = "#FF5A5F"
    
    @FocusState private var isNameFocused: Bool
    
    private var selectedColor: Color {
        Color(hex: selectedColorHex) ?? AppTheme.Colors.coral
    }
    
    private var isValid: Bool {
        !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundSecondary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Preview Card
                        previewCard
                        
                        // Name Input
                        nameInputSection
                        
                        // Icon Picker
                        IconPickerView(selectedIcon: $selectedIcon, accentColor: selectedColor)
                        
                        // Color Picker
                        HabitColorPickerView(selectedColorHex: $selectedColorHex)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(AppTheme.Spacing.md)
                }
                
                // Save Button
                VStack {
                    Spacer()
                    
                    Button(action: saveHabit) {
                        Text("Create Habit")
                    }
                    .buttonStyle(PrimaryButtonStyle(color: selectedColor))
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.lg)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }
    
    // MARK: - Preview Card
    private var previewCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: selectedIcon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(selectedColor)
            }
            
            Text(habitName.isEmpty ? "Habit Name" : habitName)
                .font(AppTheme.Typography.title3)
                .foregroundColor(habitName.isEmpty ? AppTheme.Colors.textTertiary : AppTheme.Colors.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
        .cardStyle()
    }
    
    // MARK: - Name Input
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Name")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            TextField("e.g., Morning Exercise", text: $habitName)
                .font(AppTheme.Typography.body)
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(isNameFocused ? selectedColor : AppTheme.Colors.border, lineWidth: isNameFocused ? 2 : 1)
                )
                .focused($isNameFocused)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
    
    // MARK: - Actions
    private func saveHabit() {
        let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let habit = Habit(
            name: trimmedName,
            icon: selectedIcon,
            colorHex: selectedColorHex
        )
        
        modelContext.insert(habit)
        
        dismiss()
    }
}

#Preview {
    AddHabitView()
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}

