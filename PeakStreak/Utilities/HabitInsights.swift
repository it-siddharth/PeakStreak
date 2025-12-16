//
//  HabitInsights.swift
//  PeakStreak
//
//  Created by PeakStreak on 16/12/25.
//

import Foundation

struct HabitDailyPoint: Identifiable {
    let id = UUID()
    let date: Date
    let completed: Bool

    var value: Int { completed ? 1 : 0 }
}

struct HabitWeeklyPoint: Identifiable {
    let id = UUID()
    let weekStart: Date
    let completedCount: Int
    let totalCount: Int

    var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}

extension Habit {
    func dailyPoints(lastDays: Int, endingOn endDate: Date = Date()) -> [HabitDailyPoint] {
        let calendar = Calendar.current
        let endDay = calendar.startOfDay(for: endDate)
        let clampedDays = max(1, lastDays)
        let startDay = calendar.date(byAdding: .day, value: -(clampedDays - 1), to: endDay) ?? endDay

        var points: [HabitDailyPoint] = []
        points.reserveCapacity(clampedDays)

        var current = startDay
        while current <= endDay {
            points.append(HabitDailyPoint(date: current, completed: isCompleted(for: current)))
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current.addingTimeInterval(24 * 60 * 60)
        }

        return points
    }

    func weeklyPoints(lastWeeks: Int, endingOn endDate: Date = Date()) -> [HabitWeeklyPoint] {
        let calendar = Calendar.current
        let endDay = calendar.startOfDay(for: endDate)
        let clampedWeeks = max(1, lastWeeks)
        let weeks = Date.lastWeeks(clampedWeeks)

        return weeks.compactMap { week in
            guard let weekStart = week.first.map({ calendar.startOfDay(for: $0) }) else { return nil }

            let validDays = week.filter { calendar.startOfDay(for: $0) <= endDay }
            let completed = validDays.filter { isCompleted(for: $0) }.count

            return HabitWeeklyPoint(
                weekStart: weekStart,
                completedCount: completed,
                totalCount: validDays.count
            )
        }
    }

    func completionRate(lastDays: Int, endingOn endDate: Date = Date()) -> Double {
        let points = dailyPoints(lastDays: lastDays, endingOn: endDate)
        guard !points.isEmpty else { return 0 }
        let completed = points.filter { $0.completed }.count
        return Double(completed) / Double(points.count)
    }
}
