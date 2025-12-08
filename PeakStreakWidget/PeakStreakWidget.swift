//
//  PeakStreakWidget.swift
//  PeakStreakWidget
//
//  Created by Siddharth on 08/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    static let coral = Color(hex: "#FF5A5F")!
    static let teal = Color(hex: "#00A699")!
}

// MARK: - Shared Data Structure (must match main app)
struct WidgetHabitData: Codable {
    let id: String
    let name: String
    let icon: String
    let colorHex: String
    let currentStreak: Int
    let completedDates: [Date]
    
    var color: Color {
        Color(hex: colorHex) ?? .coral
    }
    
    func isCompleted(for date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        return completedDates.contains { calendar.startOfDay(for: $0) == targetDay }
    }
}

// MARK: - Widget Data Loader
struct WidgetDataLoader {
    static let appGroupID = "group.com.itsiddharth.PeakStreak"
    static let habitsKey = "widgetHabits"
    
    static func loadHabits() -> [WidgetHabitData] {
        guard let userDefaults = UserDefaults(suiteName: appGroupID),
              let data = userDefaults.data(forKey: habitsKey),
              let habits = try? JSONDecoder().decode([WidgetHabitData].self, from: data) else {
            return []
        }
        return habits
    }
}

// MARK: - Widget Entry
struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let habit: WidgetHabitData?
}

// MARK: - Timeline Provider
struct HabitProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            habit: WidgetHabitData(
                id: UUID().uuidString,
                name: "Exercise",
                icon: "figure.run",
                colorHex: "#FF5A5F",
                currentStreak: 7,
                completedDates: []
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        let habits = WidgetDataLoader.loadHabits()
        let entry = HabitWidgetEntry(
            date: Date(),
            habit: habits.first ?? placeholder(in: context).habit
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let habits = WidgetDataLoader.loadHabits()
        let entry = HabitWidgetEntry(
            date: Date(),
            habit: habits.first
        )
        
        // Update every hour or at midnight
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget View
struct StreakWidgetEntryView: View {
    var entry: HabitWidgetEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let habit = entry.habit {
            switch family {
            case .systemSmall:
                SmallWidgetView(habit: habit)
            case .systemMedium:
                MediumWidgetView(habit: habit)
            default:
                SmallWidgetView(habit: habit)
            }
        } else {
            emptyStateView
        }
    }
    
    private var emptyStateView: some View {
        Text("Open app to add habits")
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let habit: WidgetHabitData
    
    private let weekCount = 11
    private let cellSize: CGFloat = 10
    private let cellSpacing: CGFloat = 2
    
    var body: some View {
        HStack(spacing: cellSpacing) {
            ForEach(getWeeks().indices, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(getWeeks()[weekIndex], id: \.self) { date in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(cellColor(for: date))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }
    
    private func getWeeks() -> [[Date]] {
        var weeks: [[Date]] = []
        let calendar = Calendar.current
        let today = Date()
        
        let todayWeekday = calendar.component(.weekday, from: today) - 1
        guard let startOfThisWeek = calendar.date(byAdding: .day, value: -todayWeekday, to: calendar.startOfDay(for: today)) else {
            return weeks
        }
        
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -(weekCount - 1), to: startOfThisWeek) else {
            return weeks
        }
        
        var currentDate = startDate
        
        for _ in 0..<weekCount {
            var week: [Date] = []
            for _ in 0..<7 {
                week.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            weeks.append(week)
        }
        
        return weeks
    }
    
    private func cellColor(for date: Date) -> Color {
        if date > Date() {
            return Color(.systemGray5)
        } else if habit.isCompleted(for: date) {
            // Variable intensity based on nearby completions for richer look
            let intensity = calculateIntensity(for: date)
            return habit.color.opacity(intensity)
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func calculateIntensity(for date: Date) -> Double {
        let calendar = Calendar.current
        var nearbyCount = 0
        
        // Check 3 days before and after for density
        for offset in -3...3 {
            if let checkDate = calendar.date(byAdding: .day, value: offset, to: date),
               habit.isCompleted(for: checkDate) {
                nearbyCount += 1
            }
        }
        
        // Map to intensity levels like GitHub
        switch nearbyCount {
        case 0...1: return 0.4
        case 2...3: return 0.6
        case 4...5: return 0.8
        default: return 1.0
        }
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let habit: WidgetHabitData
    
    private let weekCount = 26
    private let cellSize: CGFloat = 10
    private let cellSpacing: CGFloat = 2
    
    var body: some View {
        HStack(spacing: cellSpacing) {
            ForEach(getWeeks().indices, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(getWeeks()[weekIndex], id: \.self) { date in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(cellColor(for: date))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }
    
    private func getWeeks() -> [[Date]] {
        var weeks: [[Date]] = []
        let calendar = Calendar.current
        let today = Date()
        
        let todayWeekday = calendar.component(.weekday, from: today) - 1
        guard let startOfThisWeek = calendar.date(byAdding: .day, value: -todayWeekday, to: calendar.startOfDay(for: today)) else {
            return weeks
        }
        
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -(weekCount - 1), to: startOfThisWeek) else {
            return weeks
        }
        
        var currentDate = startDate
        
        for _ in 0..<weekCount {
            var week: [Date] = []
            for _ in 0..<7 {
                week.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            weeks.append(week)
        }
        
        return weeks
    }
    
    private func cellColor(for date: Date) -> Color {
        if date > Date() {
            return Color(.systemGray5)
        } else if habit.isCompleted(for: date) {
            let intensity = calculateIntensity(for: date)
            return habit.color.opacity(intensity)
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func calculateIntensity(for date: Date) -> Double {
        let calendar = Calendar.current
        var nearbyCount = 0
        
        for offset in -3...3 {
            if let checkDate = calendar.date(byAdding: .day, value: offset, to: date),
               habit.isCompleted(for: checkDate) {
                nearbyCount += 1
            }
        }
        
        switch nearbyCount {
        case 0...1: return 0.4
        case 2...3: return 0.6
        case 4...5: return 0.8
        default: return 1.0
        }
    }
}

// MARK: - Widget Definition
struct PeakStreakWidget: Widget {
    let kind: String = "PeakStreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Habit Streak")
        .description("Track your habit streaks with a GitHub-style contribution grid.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry Point
@main
struct PeakStreakWidgetBundle: WidgetBundle {
    var body: some Widget {
        PeakStreakWidget()
    }
}

// MARK: - Previews
#Preview(as: .systemSmall) {
    PeakStreakWidget()
} timeline: {
    HabitWidgetEntry(
        date: Date(),
        habit: WidgetHabitData(
            id: UUID().uuidString,
            name: "Exercise",
            icon: "figure.run",
            colorHex: "#FF5A5F",
            currentStreak: 12,
            completedDates: []
        )
    )
}

#Preview(as: .systemMedium) {
    PeakStreakWidget()
} timeline: {
    HabitWidgetEntry(
        date: Date(),
        habit: WidgetHabitData(
            id: UUID().uuidString,
            name: "Meditation",
            icon: "brain.head.profile",
            colorHex: "#00A699",
            currentStreak: 24,
            completedDates: []
        )
    )
}
