//
//  WidgetDataManager.swift
//  PeakStreak
//
//  Created by Siddharth on 08/12/25.
//

import Foundation
import WidgetKit

// Shared data structure for widget
struct WidgetHabitData: Codable {
    let id: String
    let name: String
    let icon: String
    let colorHex: String
    let currentStreak: Int
    let completedDates: [Date]
}

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let appGroupID = "group.com.itsiddharth.PeakStreak"
    private let habitsKey = "widgetHabits"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    // Save habits data for widget
    func saveHabitsForWidget(_ habits: [Habit]) {
        let widgetData = habits.map { habit in
            WidgetHabitData(
                id: habit.id.uuidString,
                name: habit.name,
                icon: habit.icon,
                colorHex: habit.colorHex,
                currentStreak: habit.currentStreak,
                completedDates: habit.entries.filter { $0.completed }.map { $0.date }
            )
        }
        
        if let encoded = try? JSONEncoder().encode(widgetData) {
            userDefaults?.set(encoded, forKey: habitsKey)
            
            // Reload widget timelines
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // Load habits data (used by widget)
    func loadHabitsForWidget() -> [WidgetHabitData] {
        guard let data = userDefaults?.data(forKey: habitsKey),
              let habits = try? JSONDecoder().decode([WidgetHabitData].self, from: data) else {
            return []
        }
        return habits
    }
}

