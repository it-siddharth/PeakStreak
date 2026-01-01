//
//  HabitListView.swift
//  PeakStreak
//
//  Created by PeakStreak on 08/12/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    
    @State private var showingAddHabit = false
    @State private var selectedHabitIndex: Int = 0
    @State private var selectedHabit: Habit?
    
    @State private var quoteAnimationComplete = false
    private let fullQuote = "Great things come from hard work\nand perseverance. No excuses."
    private let emptyStateTypingText = "Start your journey.\nOne day at a time."
    
    private var currentHabit: Habit? {
        guard !habits.isEmpty, selectedHabitIndex < habits.count else { return nil }
        return habits[selectedHabitIndex]
    }
    
    private var isCurrentHabitCompletedToday: Bool {
        currentHabit?.isCompleted(for: Date()) ?? false
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            // Soft noise layer
            NoiseView()
                .ignoresSafeArea()
            
            // Soft color gradient at bottom
            if let habit = currentHabit {
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [
                            habit.color.opacity(0),
                            habit.color.opacity(0.15),
                            habit.color.opacity(0.25)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 300)
                }
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: selectedHabitIndex)
            }
            
            if habits.isEmpty {
                // Empty State - Begin Journey
                emptyStateView
            } else {
                // Main Content
                mainContentView
            }
            
            // Add Button (top right)
            VStack {
                HStack {
                    Spacer()
                    addButton
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
        .fullScreenCover(item: $selectedHabit) { habit in
            HabitDetailView(habit: habit)
        }
        .onChange(of: habits.count) {
            refreshWidget()
            // Reset index if out of bounds
            if selectedHabitIndex >= habits.count {
                selectedHabitIndex = max(0, habits.count - 1)
            }
        }
        .onAppear {
            refreshWidget()
        }
    }
    
    // MARK: - Add Button
    private var addButton: some View {
        Button(action: { showingAddHabit = true }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
        }
    }
    
    // MARK: - Empty State (Begin Journey)
    private var emptyStateView: some View {
        VStack {
            Spacer()
            
            TypingText(text: emptyStateTypingText, interval: 0.04, showCursor: true)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, AppTheme.Spacing.xxl)
                .frame(minHeight: 70)
                .padding(.bottom, AppTheme.Spacing.lg)
            
            Button(action: { showingAddHabit = true }) {
                Text("Begin Journey")
            }
            .buttonStyle(PillButtonStyle())
            
            SquiggleView()
                .frame(width: 80, height: 24)
                .padding(.top, AppTheme.Spacing.lg)
            
            Spacer()
                .frame(height: 100)
        }
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Quote Section
            quoteSection
                .padding(.top, 60)
            
            // Squiggle
            SquiggleView()
                .frame(width: 80, height: 24)
                .padding(.top, AppTheme.Spacing.sm)
            
            // Horizontal Swipeable Habit Cards
            habitCardsSection
            
            Spacer()
            
            // Mark for Today Button
            markButton
                .padding(.horizontal, AppTheme.Spacing.xxl)
                .padding(.bottom, AppTheme.Spacing.xxxl)
        }
    }
    
    // MARK: - Quote Section
    private var quoteSection: some View {
        VStack(spacing: 4) {
            Text("\"")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
            
            TypingText(
                text: fullQuote,
                interval: 0.045,
                showCursor: true,
                onStarted: {
                    quoteAnimationComplete = false
                },
                onCompleted: {
                    withAnimation(.easeIn(duration: 0.3)) {
                        quoteAnimationComplete = true
                    }
                }
            )
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(minHeight: 60)
            
            Text("\"")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
                .opacity(quoteAnimationComplete ? 1 : 0)
            
            Text("— Kobe Bryant")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.top, 4)
                .opacity(quoteAnimationComplete ? 1 : 0)
                .animation(.easeIn(duration: 0.3), value: quoteAnimationComplete)
        }
        .padding(.horizontal, AppTheme.Spacing.xxl)
    }
    
    // MARK: - Habit Cards Section
    private var habitCardsSection: some View {
        TabView(selection: $selectedHabitIndex) {
            ForEach(Array(habits.enumerated()), id: \.element.id) { index, habit in
                HabitCardView(habit: habit) {
                    selectedHabit = habit
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 320)
        .padding(.top, AppTheme.Spacing.xl)
    }
    
    // MARK: - Mark Button
    private var markButton: some View {
        Button(action: {
            guard let habit = currentHabit else { return }
            withAnimation(AppTheme.Animation.bouncy) {
                habit.toggleCompletion(for: Date(), context: modelContext)
            }
            refreshWidget()
        }) {
            Text(isCurrentHabitCompletedToday ? "Done for today" : "Mark for today")
        }
        .buttonStyle(PillButtonStyle(isFilled: isCurrentHabitCompletedToday))
        .disabled(currentHabit == nil)
    }
    
    // MARK: - Actions
    private func refreshWidget() {
        WidgetDataManager.shared.saveHabitsForWidget(habits)
    }
}

// MARK: - Habit Card View
struct HabitCardView: View {
    let habit: Habit
    let onTap: () -> Void
    
    private var totalCompletedDays: Int {
        habit.entries.filter { $0.completed }.count
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Contribution Grid
            ContributionGridView(
                habit: habit,
                weekCount: 10,
                showLabels: false,
                cellSize: AppTheme.Grid.cellSize,
                cellSpacing: AppTheme.Grid.cellSpacing
            )
            .onTapGesture {
                onTap()
            }
            
            // Habit Info
            Text("\(totalCompletedDays) days of \(habit.name).")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.text)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }
}

// MARK: - Noise View
struct NoiseView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<Int(size.width * size.height * 0.03) {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let opacity = Double.random(in: 0.02...0.06)
                
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(Color.black.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Typing Text
private struct TypingText: View {
    let text: String
    var interval: TimeInterval = 0.045
    var showCursor: Bool = false
    var cursor: String = "▍"
    var cursorBlinkInterval: TimeInterval = 0.5
    var onStarted: (() -> Void)? = nil
    var onCompleted: (() -> Void)? = nil
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var displayedText: String = ""
    @State private var isComplete: Bool = false
    @State private var cursorVisible: Bool = true
    @State private var didFireCompletion: Bool = false
    
    var body: some View {
        Text(displayedText + cursorSuffix)
            .task(id: text) {
                await startTyping()
            }
            .task(id: isComplete) {
                await blinkCursorIfNeeded()
            }
    }
    
    private var cursorSuffix: String {
        guard showCursor, !reduceMotion, !isComplete, cursorVisible else { return "" }
        return cursor
    }
    
    private func startTyping() async {
        await MainActor.run {
            displayedText = ""
            isComplete = false
            cursorVisible = true
            didFireCompletion = false
            onStarted?()
        }
        
        if reduceMotion || text.isEmpty {
            await MainActor.run {
                displayedText = text
                isComplete = true
            }
            fireCompletionIfNeeded()
            return
        }
        
        let characters = Array(text)
        let nsPerChar = max(0, Int64(interval * 1_000_000_000))
        
        for char in characters {
            if Task.isCancelled { return }
            if nsPerChar > 0 {
                try? await Task.sleep(nanoseconds: UInt64(nsPerChar))
            }
            if Task.isCancelled { return }
            await MainActor.run {
                displayedText.append(char)
            }
        }
        
        await MainActor.run { isComplete = true }
        fireCompletionIfNeeded()
    }
    
    private func blinkCursorIfNeeded() async {
        guard showCursor, !reduceMotion else { return }
        guard !isComplete else { return }
        
        let ns = max(1, Int64(cursorBlinkInterval * 1_000_000_000))
        while !Task.isCancelled {
            if await MainActor.run({ isComplete }) { return }
            try? await Task.sleep(nanoseconds: UInt64(ns))
            if Task.isCancelled { return }
            await MainActor.run {
                cursorVisible.toggle()
            }
        }
    }
    
    private func fireCompletionIfNeeded() {
        guard !didFireCompletion else { return }
        Task { @MainActor in
            guard !didFireCompletion else { return }
            didFireCompletion = true
            onCompleted?()
        }
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
