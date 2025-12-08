//
//  ColorPickerView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI

struct HabitColorPickerView: View {
    @Binding var selectedColorHex: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Color")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(AppTheme.Colors.habitColors, id: \.hex) { item in
                    ColorButton(
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
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
}

struct ColorButton: View {
    let color: Color
    let hex: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    Circle()
                        .stroke(color, lineWidth: 3)
                        .frame(width: 40, height: 40)
                }
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HabitColorPickerView(selectedColorHex: .constant("#FF5A5F"))
        .padding()
}

