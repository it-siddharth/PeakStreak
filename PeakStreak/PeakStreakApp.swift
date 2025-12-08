//
//  PeakStreakApp.swift
//  PeakStreak
//
//  Created by Siddharth on 08/12/25.
//

import SwiftUI
import SwiftData

@main
struct PeakStreakApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure for App Group to share with widget
            let schema = Schema([Habit.self, HabitEntry.self])
            
            // Try to use App Group container for widget sharing
            let appGroupID = "group.com.itsiddharth.PeakStreak"
            
            var modelConfiguration: ModelConfiguration
            
            if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
                let storeURL = appGroupURL.appendingPathComponent("PeakStreak.store")
                modelConfiguration = ModelConfiguration(
                    schema: schema,
                    url: storeURL,
                    allowsSave: true
                )
            } else {
                // Fallback to default location if App Group not available
                modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    allowsSave: true
                )
            }
            
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HabitListView()
        }
        .modelContainer(modelContainer)
    }
}
