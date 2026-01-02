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
    
    // Image upload states
    @State private var showImagePrompt = false
    @State private var showImageSourcePicker = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedImages: [UIImage] = []
    @State private var cameraImage: UIImage?
    
    // Handwriting animation state
    @State private var displayedQuote: String = ""
    @State private var quoteAnimationComplete = false
    private let fullQuote = "Great things come from hard work\nand perseverance. No excuses."
    
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
        .sheet(isPresented: $showImagePrompt) {
            AddPhotoPromptView(
                onAddPhoto: {
                    showImagePrompt = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showImageSourcePicker = true
                    }
                },
                onSkip: {
                    showImagePrompt = false
                }
            )
        }
        .sheet(isPresented: $showImageSourcePicker) {
            ImageSourcePicker(
                showPhotoPicker: $showPhotoPicker,
                showCamera: $showCamera
            )
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(selectedImages: $selectedImages)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(image: $cameraImage)
        }
        .onChange(of: selectedImages) { _, newImages in
            if !newImages.isEmpty, let habit = currentHabit {
                saveImages(newImages, for: habit)
                selectedImages = []
            }
        }
        .onChange(of: cameraImage) { _, newImage in
            if let image = newImage, let habit = currentHabit {
                saveImages([image], for: habit)
                cameraImage = nil
            }
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
                .opacity(displayedQuote.isEmpty ? 0 : 1)
            
            Text(displayedQuote)
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
        .onAppear {
            startHandwritingAnimation()
        }
    }
    
    // MARK: - Handwriting Animation
    private func startHandwritingAnimation() {
        guard displayedQuote.isEmpty else { return }
        
        var charIndex = 0
        let characters = Array(fullQuote)
        
        Timer.scheduledTimer(withTimeInterval: 0.045, repeats: true) { timer in
            if charIndex < characters.count {
                displayedQuote.append(characters[charIndex])
                charIndex += 1
            } else {
                timer.invalidate()
                withAnimation(.easeIn(duration: 0.3)) {
                    quoteAnimationComplete = true
                }
            }
        }
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
            
            if !isCurrentHabitCompletedToday {
                // Mark as completed and show photo prompt
                withAnimation(AppTheme.Animation.bouncy) {
                    habit.toggleCompletion(for: Date(), context: modelContext)
                }
                refreshWidget()
                
                // Show photo prompt after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showImagePrompt = true
                }
            } else {
                // Already completed, just toggle off
                withAnimation(AppTheme.Animation.bouncy) {
                    habit.toggleCompletion(for: Date(), context: modelContext)
                }
                refreshWidget()
            }
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
    
    private func saveImages(_ uiImages: [UIImage], for habit: Habit) {
        let entry = habit.getOrCreateEntry(for: Date(), context: modelContext)
        
        for uiImage in uiImages {
            let resizedImage = ImageHelper.resizeImage(uiImage)
            if let imageData = ImageHelper.compressImage(resizedImage) {
                let dayImage = DayImage(imageData: imageData)
                dayImage.entry = entry
                entry.images.append(dayImage)
            }
        }
    }
}

// MARK: - Add Photo Prompt View
struct AddPhotoPromptView: View {
    let onAddPhoto: () -> Void
    let onSkip: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.xl) {
                // Handle
                Capsule()
                    .fill(AppTheme.Colors.textSecondary)
                    .frame(width: 40, height: 4)
                    .padding(.top, AppTheme.Spacing.md)
                
                Spacer()
                
                // Icon
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.Colors.text)
                
                // Title
                Text("Capture the moment?")
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.text)
                
                // Subtitle
                Text("Add a photo to remember this day")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Spacer()
                
                // Buttons
                VStack(spacing: AppTheme.Spacing.md) {
                    Button(action: onAddPhoto) {
                        Text("Add Photo")
                    }
                    .buttonStyle(PillButtonStyle(isFilled: true))
                    
                    Button(action: onSkip) {
                        Text("Skip")
                    }
                    .buttonStyle(PillButtonStyle())
                }
                .padding(.horizontal, AppTheme.Spacing.xxl)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Habit Card View
struct HabitCardView: View {
    let habit: Habit
    let onTap: () -> Void
    
    private var totalCompletedDays: Int {
        habit.entries.filter { $0.completed }.count
    }
    
    private var totalPhotos: Int {
        habit.entries.reduce(0) { $0 + $1.images.count }
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
            VStack(spacing: AppTheme.Spacing.xxs) {
                Text("\(totalCompletedDays) days of \(habit.name).")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.text)
                
                if totalPhotos > 0 {
                    HStack(spacing: AppTheme.Spacing.xxs) {
                        Image(systemName: "photo")
                            .font(.system(size: 12))
                        Text("\(totalPhotos)")
                            .font(AppTheme.Typography.caption)
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
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

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, HabitEntry.self, DayImage.self], inMemory: true)
}
