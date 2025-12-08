//
//  IconPickerView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    let accentColor: Color
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppTheme.Spacing.sm), count: 6)
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Icon")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.sm) {
                ForEach(AppTheme.habitIcons, id: \.self) { icon in
                    IconButton(
                        icon: icon,
                        isSelected: selectedIcon == icon,
                        accentColor: accentColor
                    ) {
                        withAnimation(AppTheme.Animation.quick) {
                            selectedIcon = icon
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

struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .fill(isSelected ? accentColor.opacity(0.15) : Color.clear)
                    .frame(width: 44, height: 44)
                
                if isSelected {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(accentColor, lineWidth: 2)
                        .frame(width: 44, height: 44)
                }
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? accentColor : AppTheme.Colors.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    IconPickerView(selectedIcon: .constant("star.fill"), accentColor: AppTheme.Colors.coral)
        .padding()
}

