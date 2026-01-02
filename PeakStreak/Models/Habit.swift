//
//  Habit.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \HabitEntry.habit)
    var entries: [HabitEntry] = []
    
    init(name: String, icon: String = "star.fill", colorHex: String = "#FF5A5F") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = Date()
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .coral
    }
    
    // Calculate current streak
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today
        
        // Sort entries by date descending
        let sortedEntries = entries
            .filter { $0.completed }
            .sorted { $0.date > $1.date }
        
        let completedDates = Set(sortedEntries.map { calendar.startOfDay(for: $0.date) })
        
        // Check if today or yesterday is completed (allow for checking at start of day)
        if !completedDates.contains(today) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            if !completedDates.contains(checkDate) {
                return 0
            }
        }
        
        // Count consecutive days
        while completedDates.contains(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        return streak
    }
    
    // Check if habit is completed for a specific date
    func isCompleted(for date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        return entries.contains { entry in
            calendar.startOfDay(for: entry.date) == targetDay && entry.completed
        }
    }
    
    // Toggle completion for a specific date
    func toggleCompletion(for date: Date, context: ModelContext) {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        
        if let existingEntry = entries.first(where: { calendar.startOfDay(for: $0.date) == targetDay }) {
            existingEntry.completed.toggle()
            if !existingEntry.completed {
                context.delete(existingEntry)
            }
        } else {
            let newEntry = HabitEntry(date: targetDay, completed: true)
            newEntry.habit = self
            entries.append(newEntry)
        }
    }
    
    // Get entry for a specific date
    func entry(for date: Date) -> HabitEntry? {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        return entries.first { calendar.startOfDay(for: $0.date) == targetDay }
    }
    
    // Get or create entry for a specific date
    func getOrCreateEntry(for date: Date, context: ModelContext) -> HabitEntry {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: date)
        
        if let existingEntry = entries.first(where: { calendar.startOfDay(for: $0.date) == targetDay }) {
            return existingEntry
        } else {
            let newEntry = HabitEntry(date: targetDay, completed: true)
            newEntry.habit = self
            entries.append(newEntry)
            return newEntry
        }
    }
    
    // Check if entry has images for a specific date
    func hasImages(for date: Date) -> Bool {
        entry(for: date)?.hasImages ?? false
    }
    
    // Get all entries with images sorted by date
    var entriesWithImages: [HabitEntry] {
        entries.filter { $0.hasImages }.sorted { $0.date > $1.date }
    }
}

@Model
final class HabitEntry {
    var id: UUID
    var date: Date
    var completed: Bool
    var habit: Habit?
    var note: String?
    
    @Relationship(deleteRule: .cascade, inverse: \DayImage.entry)
    var images: [DayImage] = []
    
    init(date: Date, completed: Bool = false, note: String? = nil) {
        self.id = UUID()
        self.date = date
        self.completed = completed
        self.note = note
    }
    
    var hasImages: Bool {
        !images.isEmpty
    }
}

@Model
final class DayImage {
    var id: UUID
    var imageData: Data
    var createdAt: Date
    var entry: HabitEntry?
    
    init(imageData: Data) {
        self.id = UUID()
        self.imageData = imageData
        self.createdAt = Date()
    }
}

// MARK: - Color Extension for Hex Support
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
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#FF5A5F"
        }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Preset Colors
extension Color {
    static let coral = Color(hex: "#FF5A5F")!
    static let emerald = Color(hex: "#00A699")!
    static let sunflower = Color(hex: "#FFB400")!
    static let lavender = Color(hex: "#914669")!
    static let ocean = Color(hex: "#007AFF")!
    static let mint = Color(hex: "#34C759")!
    static let peach = Color(hex: "#FF9500")!
    static let berry = Color(hex: "#AF52DE")!
}

