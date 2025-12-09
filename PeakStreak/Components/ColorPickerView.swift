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
        VStack(spacing: AppTheme.Spacing.md) {
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
    }
}

#Preview {
    HabitColorPickerView(selectedColorHex: .constant("#737373"))
        .padding()
        .background(AppTheme.Colors.background)
}
