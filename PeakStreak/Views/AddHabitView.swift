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
    @State private var selectedColorHex: String = "#737373"
    
    @FocusState private var isNameFocused: Bool
    
    private var isValid: Bool {
        !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                
                // Name Input
                nameInputSection
                
                // Color Picker (for widget)
                colorPickerSection
                    .padding(.top, AppTheme.Spacing.xxxl)
                
                Spacer()
                
                // Add Journey Button
                addButton
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
            }
        }
        .onAppear {
            isNameFocused = true
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
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
    }
    
    // MARK: - Name Input
    private var nameInputSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text("Name your journey")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
            
            TextField("", text: $habitName)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
                .multilineTextAlignment(.center)
                .focused($isNameFocused)
                .tint(AppTheme.Colors.text)
            
            // Underline
            Rectangle()
                .fill(AppTheme.Colors.text)
                .frame(height: 1)
                .padding(.horizontal, AppTheme.Spacing.xxxl)
        }
        .padding(.horizontal, AppTheme.Spacing.xxl)
    }
    
    // MARK: - Color Picker
    private var colorPickerSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.Spacing.md), count: 6), spacing: AppTheme.Spacing.md) {
                ForEach(AppTheme.Colors.habitColors, id: \.hex) { item in
                    ColorCircleButton(
                        color: item.color,
                        hex: item.hex,
                        isSelected: selectedColorHex == item.hex
                    ) {
                        withAnimation(AppTheme.Animation.quick) {
                            selectedColorHex = item.hex
                        }
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xxl)
    }
    
    // MARK: - Add Button
    private var addButton: some View {
        Button(action: saveHabit) {
            Text("Add journey")
        }
        .buttonStyle(PillButtonStyle())
        .disabled(!isValid)
        .opacity(isValid ? 1 : 0.5)
    }
    
    // MARK: - Actions
    private func saveHabit() {
        let trimmedName = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let habit = Habit(
            name: trimmedName,
            icon: "star.fill",
            colorHex: selectedColorHex
        )
        
        modelContext.insert(habit)
        dismiss()
    }
}

// MARK: - Color Circle Button
struct ColorCircleButton: View {
    let color: Color
    let hex: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                
                if isSelected {
                    Circle()
                        .stroke(AppTheme.Colors.text, lineWidth: 2)
                        .frame(width: 52, height: 52)
                }
            }
            .frame(width: 52, height: 52)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddHabitView()
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
