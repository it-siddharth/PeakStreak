//
//  AppTheme.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI

// MARK: - Airbnb-Inspired Design System
enum AppTheme {
    
    // MARK: - Colors
    enum Colors {
        // Primary
        static let coral = Color(hex: "#FF5A5F")!
        static let coralDark = Color(hex: "#E04E53")!
        
        // Secondary
        static let teal = Color(hex: "#00A699")!
        static let tealDark = Color(hex: "#008F82")!
        
        // Neutrals
        static let backgroundPrimary = Color(hex: "#FFFFFF")!
        static let backgroundSecondary = Color(hex: "#F7F7F7")!
        static let backgroundTertiary = Color(hex: "#EBEBEB")!
        
        static let textPrimary = Color(hex: "#222222")!
        static let textSecondary = Color(hex: "#717171")!
        static let textTertiary = Color(hex: "#B0B0B0")!
        
        static let border = Color(hex: "#DDDDDD")!
        static let borderLight = Color(hex: "#EBEBEB")!
        
        // Accent Colors for Habits
        static let habitColors: [(name: String, color: Color, hex: String)] = [
            ("Coral", coral, "#FF5A5F"),
            ("Teal", teal, "#00A699"),
            ("Sunflower", Color(hex: "#FFB400")!, "#FFB400"),
            ("Ocean", Color(hex: "#007AFF")!, "#007AFF"),
            ("Mint", Color(hex: "#34C759")!, "#34C759"),
            ("Peach", Color(hex: "#FF9500")!, "#FF9500"),
            ("Berry", Color(hex: "#AF52DE")!, "#AF52DE"),
            ("Lavender", Color(hex: "#914669")!, "#914669"),
            ("Slate", Color(hex: "#5856D6")!, "#5856D6"),
            ("Rose", Color(hex: "#FF2D55")!, "#FF2D55")
        ]
        
        // Contribution Grid Colors (based on habit color)
        static func contributionColor(for baseColor: Color, intensity: Double) -> Color {
            if intensity == 0 {
                return backgroundTertiary
            }
            return baseColor.opacity(0.2 + (intensity * 0.8))
        }
    }
    
    // MARK: - Typography
    enum Typography {
        // Large Title - Used for main headers
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        
        // Title 1 - Screen titles
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        
        // Title 2 - Section headers
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        
        // Title 3 - Card titles
        static let title3 = Font.system(size: 18, weight: .semibold, design: .rounded)
        
        // Headline - Emphasized text
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        
        // Body - Regular text
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        
        // Callout - Secondary information
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        
        // Subheadline - Smaller secondary text
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        
        // Footnote - Tertiary information
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        
        // Caption - Smallest text
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        
        // Caption Bold
        static let captionBold = Font.system(size: 12, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Spacing
    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let circular: CGFloat = 9999
    }
    
    // MARK: - Shadows
    enum Shadows {
        static func card() -> some View {
            Color.black.opacity(0.08)
        }
        
        static let cardShadowRadius: CGFloat = 8
        static let cardShadowY: CGFloat = 2
        
        static let buttonShadowRadius: CGFloat = 4
        static let buttonShadowY: CGFloat = 2
    }
    
    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
    
    // MARK: - Icons (SF Symbols for habits)
    static let habitIcons: [String] = [
        "star.fill",
        "flame.fill",
        "bolt.fill",
        "heart.fill",
        "book.fill",
        "figure.run",
        "figure.yoga",
        "dumbbell.fill",
        "drop.fill",
        "moon.fill",
        "sun.max.fill",
        "leaf.fill",
        "brain.head.profile",
        "paintbrush.fill",
        "music.note",
        "keyboard.fill",
        "cup.and.saucer.fill",
        "fork.knife",
        "pill.fill",
        "cross.fill",
        "checkmark.seal.fill",
        "target",
        "chart.line.uptrend.xyaxis",
        "graduationcap.fill"
    ]
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
            .shadow(
                color: Color.black.opacity(0.06),
                radius: AppTheme.Shadows.cardShadowRadius,
                x: 0,
                y: AppTheme.Shadows.cardShadowY
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = AppTheme.Colors.coral) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.Colors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

