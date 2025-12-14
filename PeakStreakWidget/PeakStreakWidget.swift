//
//  PeakStreakWidget.swift
//  PeakStreakWidget
//
//  Created by Siddharth on 08/12/25.
//

import WidgetKit
import SwiftUI
import AppIntents

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
    
    static func loadHabit(withId id: String) -> WidgetHabitData? {
        return loadHabits().first { $0.id == id }
    }
}

// MARK: - Habit App Entity
struct HabitEntity: AppEntity {
    var id: String
    var name: String
    var colorHex: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
    static var defaultQuery = HabitEntityQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

// MARK: - Habit Entity Query
struct HabitEntityQuery: EntityQuery {
    func entities(for identifiers: [HabitEntity.ID]) async throws -> [HabitEntity] {
        let habits = WidgetDataLoader.loadHabits()
        return habits
            .filter { identifiers.contains($0.id) }
            .map { HabitEntity(id: $0.id, name: $0.name, colorHex: $0.colorHex) }
    }
    
    func suggestedEntities() async throws -> [HabitEntity] {
        let habits = WidgetDataLoader.loadHabits()
        return habits.map { HabitEntity(id: $0.id, name: $0.name, colorHex: $0.colorHex) }
    }
    
    func defaultResult() async -> HabitEntity? {
        let habits = WidgetDataLoader.loadHabits()
        guard let first = habits.first else { return nil }
        return HabitEntity(id: first.id, name: first.name, colorHex: first.colorHex)
    }
}

// MARK: - Widget Configuration Intent
struct SelectHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    static var description = IntentDescription("Choose which habit to display in the widget.")
    
    @Parameter(title: "Habit")
    var habit: HabitEntity?
}

// MARK: - Widget Entry
struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let habit: WidgetHabitData?
}

// MARK: - Timeline Provider
struct HabitProvider: AppIntentTimelineProvider {
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
    
    func snapshot(for configuration: SelectHabitIntent, in context: Context) async -> HabitWidgetEntry {
        let habit: WidgetHabitData?
        if let selectedHabit = configuration.habit {
            habit = WidgetDataLoader.loadHabit(withId: selectedHabit.id)
        } else {
            habit = WidgetDataLoader.loadHabits().first
        }
        
        return HabitWidgetEntry(date: Date(), habit: habit ?? placeholder(in: context).habit)
    }
    
    func timeline(for configuration: SelectHabitIntent, in context: Context) async -> Timeline<HabitWidgetEntry> {
        let habit: WidgetHabitData?
        if let selectedHabit = configuration.habit {
            habit = WidgetDataLoader.loadHabit(withId: selectedHabit.id)
        } else {
            habit = WidgetDataLoader.loadHabits().first
        }
        
        let entry = HabitWidgetEntry(date: Date(), habit: habit)
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
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
    
    private let weekCount = 7
    private let cellSize: CGFloat = 17
    private let cellSpacing: CGFloat = 4
    private let outerCornerRadius: CGFloat = 16
    private let innerCornerRadius: CGFloat = 2
    
    var body: some View {
        let weeks = getWeeks()
        
        HStack(spacing: cellSpacing) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(Array(weeks[weekIndex].enumerated()), id: \.element) { dayIndex, date in
                        let corners = cornerRadius(weekIndex: weekIndex, dayIndex: dayIndex, totalWeeks: weeks.count)
                        
                        UnevenRoundedRectangle(
                            topLeadingRadius: corners.topLeading,
                            bottomLeadingRadius: corners.bottomLeading,
                            bottomTrailingRadius: corners.bottomTrailing,
                            topTrailingRadius: corners.topTrailing
                        )
                        .fill(cellColor(for: date))
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
    }
    
    private func cornerRadius(weekIndex: Int, dayIndex: Int, totalWeeks: Int) -> (topLeading: CGFloat, bottomLeading: CGFloat, bottomTrailing: CGFloat, topTrailing: CGFloat) {
        let isFirstWeek = weekIndex == 0
        let isLastWeek = weekIndex == totalWeeks - 1
        let isFirstDay = dayIndex == 0
        let isLastDay = dayIndex == 6
        
        var topLeading: CGFloat = innerCornerRadius
        var bottomLeading: CGFloat = innerCornerRadius
        var bottomTrailing: CGFloat = innerCornerRadius
        var topTrailing: CGFloat = innerCornerRadius
        
        // Top-left corner of grid
        if isFirstWeek && isFirstDay {
            topLeading = outerCornerRadius
        }
        // Bottom-left corner of grid
        if isFirstWeek && isLastDay {
            bottomLeading = outerCornerRadius
        }
        // Top-right corner of grid
        if isLastWeek && isFirstDay {
            topTrailing = outerCornerRadius
        }
        // Bottom-right corner of grid
        if isLastWeek && isLastDay {
            bottomTrailing = outerCornerRadius
        }
        
        return (topLeading, bottomLeading, bottomTrailing, topTrailing)
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
    
    private let uncheckedColor = Color(hex: "#EBEBEB")! // Very light gray
    
    private func cellColor(for date: Date) -> Color {
        if date > Date() {
            return uncheckedColor // Future days
        } else if habit.isCompleted(for: date) {
            return habit.color // Checked: selected color
        } else {
            return uncheckedColor // Unchecked: light gray
        }
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let habit: WidgetHabitData
    
    private let weekCount = 15
    private let cellSize: CGFloat = 17
    private let cellSpacing: CGFloat = 4
    private let outerCornerRadius: CGFloat = 16
    private let innerCornerRadius: CGFloat = 2
    
    var body: some View {
        let weeks = getWeeks()
        
        HStack(spacing: cellSpacing) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                VStack(spacing: cellSpacing) {
                    ForEach(Array(weeks[weekIndex].enumerated()), id: \.element) { dayIndex, date in
                        let corners = cornerRadius(weekIndex: weekIndex, dayIndex: dayIndex, totalWeeks: weeks.count)
                        
                        UnevenRoundedRectangle(
                            topLeadingRadius: corners.topLeading,
                            bottomLeadingRadius: corners.bottomLeading,
                            bottomTrailingRadius: corners.bottomTrailing,
                            topTrailingRadius: corners.topTrailing
                        )
                        .fill(cellColor(for: date))
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
    }
    
    private func cornerRadius(weekIndex: Int, dayIndex: Int, totalWeeks: Int) -> (topLeading: CGFloat, bottomLeading: CGFloat, bottomTrailing: CGFloat, topTrailing: CGFloat) {
        let isFirstWeek = weekIndex == 0
        let isLastWeek = weekIndex == totalWeeks - 1
        let isFirstDay = dayIndex == 0
        let isLastDay = dayIndex == 6
        
        var topLeading: CGFloat = innerCornerRadius
        var bottomLeading: CGFloat = innerCornerRadius
        var bottomTrailing: CGFloat = innerCornerRadius
        var topTrailing: CGFloat = innerCornerRadius
        
        if isFirstWeek && isFirstDay {
            topLeading = outerCornerRadius
        }
        if isFirstWeek && isLastDay {
            bottomLeading = outerCornerRadius
        }
        if isLastWeek && isFirstDay {
            topTrailing = outerCornerRadius
        }
        if isLastWeek && isLastDay {
            bottomTrailing = outerCornerRadius
        }
        
        return (topLeading, bottomLeading, bottomTrailing, topTrailing)
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
    
    private let uncheckedColor = Color(hex: "#EBEBEB")! // Very light gray
    
    private func cellColor(for date: Date) -> Color {
        if date > Date() {
            return uncheckedColor // Future days
        } else if habit.isCompleted(for: date) {
            return habit.color // Checked: selected color
        } else {
            return uncheckedColor // Unchecked: light gray
        }
    }
}

// MARK: - Widget Definition
struct PeakStreakWidget: Widget {
    let kind: String = "PeakStreakWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: HabitProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
                .containerBackground(Color.white, for: .widget)
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
