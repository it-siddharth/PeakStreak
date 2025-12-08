//
//  DateHelpers.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var endOfMonth: Date {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return self
        }
        return Calendar.current.date(byAdding: .day, value: -1, to: nextMonth) ?? self
    }
    
    var daysInMonth: Int {
        let range = Calendar.current.range(of: .day, in: .month, for: self)
        return range?.count ?? 30
    }
    
    var weekdayIndex: Int {
        // Returns 0 for Sunday, 1 for Monday, etc.
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday - 1
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
    
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    var shortWeekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isFuture: Bool {
        self > Date()
    }
    
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    // Get all dates in the current month
    func datesInMonth() -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return dates
        }
        
        for day in range {
            if let date = calendar.date(bySetting: .day, value: day, of: startOfMonth) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    // Get dates for calendar grid (including padding days from previous/next month)
    func calendarGridDates() -> [Date?] {
        var dates: [Date?] = []
        let calendar = Calendar.current
        
        let firstDayOfMonth = startOfMonth
        let firstWeekday = firstDayOfMonth.weekdayIndex
        
        // Add nil placeholders for days before the start of month
        for _ in 0..<firstWeekday {
            dates.append(nil)
        }
        
        // Add all days in month
        dates.append(contentsOf: datesInMonth().map { Optional($0) })
        
        return dates
    }
    
    // Get the last N weeks of dates (for contribution grid)
    static func lastWeeks(_ count: Int) -> [[Date]] {
        var weeks: [[Date]] = []
        let calendar = Calendar.current
        let today = Date()
        
        // Find the start of this week (Sunday)
        let todayWeekday = today.weekdayIndex
        guard let startOfThisWeek = calendar.date(byAdding: .day, value: -todayWeekday, to: today.startOfDay) else {
            return weeks
        }
        
        // Go back to the start of the first week we want
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -(count - 1), to: startOfThisWeek) else {
            return weeks
        }
        
        var currentDate = startDate
        
        for _ in 0..<count {
            var week: [Date] = []
            for _ in 0..<7 {
                week.append(currentDate)
                currentDate = currentDate.adding(days: 1)
            }
            weeks.append(week)
        }
        
        return weeks
    }
}

