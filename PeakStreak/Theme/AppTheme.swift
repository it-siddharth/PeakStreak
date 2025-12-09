//
//  AppTheme.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI

// MARK: - Minimalist Design System
enum AppTheme {
    
    // MARK: - Custom Font Name
    static let customFontName = "LovedbytheKing"
    
    // MARK: - Colors
    enum Colors {
        // Main Background - Beige
        static let background = Color(hex: "#DAD9D1")!
        
        // Text - Black
        static let text = Color.black
        
        // Grid Colors (Grayscale for in-app)
        static let gridCompleted = Color(hex: "#404040")! // Dark gray for checked
        static let gridNotCompleted = Color.white // White for unchecked
        static let gridEmpty = Color(hex: "#D4D4D4")! // Light gray for future/empty
        
        // Button Colors
        static let buttonBorder = Color.black
        static let buttonFilled = Color.black
        static let buttonText = Color.black
        static let buttonTextFilled = Color.white
        
        // Legacy colors kept for backward compatibility and widget use
        static let coral = Color(hex: "#FF5A5F")!
        static let teal = Color(hex: "#00A699")!
        
        // Neutrals (kept for compatibility)
        static let backgroundPrimary = Color.white
        static let backgroundSecondary = background
        static let backgroundTertiary = Color(hex: "#D4D4D4")!
        
        static let textPrimary = text
        static let textSecondary = Color(hex: "#525252")!
        static let textTertiary = Color(hex: "#737373")!
        
        static let border = Color.black
        static let borderLight = Color(hex: "#D4D4D4")!
        
        // Accent Colors for Widget Only
        static let habitColors: [(name: String, color: Color, hex: String)] = [
            ("Gray", Color(hex: "#737373")!, "#737373"),
            ("Silver", Color(hex: "#A3A3A3")!, "#A3A3A3"),
            ("White", Color.white, "#FFFFFF"),
            ("Coral", Color(hex: "#FF5A5F")!, "#FF5A5F"),
            ("Orange", Color(hex: "#FF9500")!, "#FF9500"),
            ("Red", Color(hex: "#FF2D55")!, "#FF2D55"),
            ("Pink", Color(hex: "#FF2D92")!, "#FF2D92"),
            ("Teal", Color(hex: "#00A699")!, "#00A699"),
            ("Yellow", Color(hex: "#FFCC00")!, "#FFCC00"),
            ("Green", Color(hex: "#34C759")!, "#34C759"),
            ("Purple", Color(hex: "#AF52DE")!, "#AF52DE"),
            ("Blue", Color(hex: "#007AFF")!, "#007AFF")
        ]
    }
    
    // MARK: - Typography (Custom Font)
    enum Typography {
        // Helper to get custom font with fallback
        static func customFont(size: CGFloat) -> Font {
            Font.custom(AppTheme.customFontName, size: size)
        }
        
        // Large Title - Main quote text
        static let largeTitle = customFont(size: 32)
        
        // Title 1 - Screen titles
        static let title1 = customFont(size: 28)
        
        // Title 2 - Section headers
        static let title2 = customFont(size: 24)
        
        // Title 3 - Card titles
        static let title3 = customFont(size: 20)
        
        // Headline - Emphasized text
        static let headline = customFont(size: 18)
        
        // Body - Regular text
        static let body = customFont(size: 32)
        
        // Callout - Secondary information
        static let callout = customFont(size: 28)
        
        // Subheadline - Smaller secondary text
        static let subheadline = customFont(size: 24)
        
        // Footnote - Tertiary information
        static let footnote = customFont(size: 20)
        
        // Caption - Smallest text
        static let caption = customFont(size: 16)
        
        // Caption Bold
        static let captionBold = customFont(size: 16)
        
        // Button text
        static let button = customFont(size: 32)
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
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let pill: CGFloat = 110
        static let circular: CGFloat = 9999
    }
    
    // MARK: - Grid
    enum Grid {
        static let cellSize: CGFloat = 22
        static let cellSpacing: CGFloat = 6
        static let cellCornerRadius: CGFloat = 4
        static let columns: Int = 10
        static let rows: Int = 7
    }
    
    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
    
    // MARK: - Icons (SF Symbols for habits - minimal set)
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
        "leaf.fill"
    ]
}

// MARK: - Pill Button Style (Outlined)
struct PillButtonStyle: ButtonStyle {
    var isFilled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.button)
            .foregroundColor(isFilled ? AppTheme.Colors.buttonTextFilled : AppTheme.Colors.buttonText)
            .padding(.horizontal, AppTheme.Spacing.xxl)
            .padding(.vertical, AppTheme.Spacing.lg)
            .background(isFilled ? AppTheme.Colors.buttonFilled : Color.clear)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.Colors.buttonBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Legacy Button Styles (for compatibility)
struct PrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    init(color: Color = AppTheme.Colors.buttonFilled) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .background(color)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.button)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .background(Color.clear)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Card Style (simplified)
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Note: Color extension with hex support is defined in Habit.swift
