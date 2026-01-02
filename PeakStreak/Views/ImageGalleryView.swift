//
//  ImageGalleryView.swift
//  PeakStreak
//
//  Created by PeakStreak on 02/01/26.
//

import SwiftUI
import SwiftData

struct ImageGalleryView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedEntry: HabitEntry?
    @State private var selectedImageIndex: Int?
    @State private var showFullScreenImage = false
    
    private var entriesWithImages: [HabitEntry] {
        habit.entriesWithImages
    }
    
    private var allImages: [(entry: HabitEntry, image: DayImage)] {
        entriesWithImages.flatMap { entry in
            entry.images.map { (entry: entry, image: $0) }
        }.sorted { $0.image.createdAt > $1.image.createdAt }
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                if entriesWithImages.isEmpty {
                    emptyState
                } else {
                    galleryContent
                }
            }
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let index = selectedImageIndex {
                GalleryFullScreenView(
                    images: allImages,
                    selectedIndex: index,
                    onDelete: { image in
                        deleteImage(image)
                    }
                )
            }
        }
    }
    
    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.Colors.text)
            }
            
            Spacer()
            
            Text("Gallery")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)
            
            Spacer()
            
            // Placeholder for balance
            Color.clear
                .frame(width: 20, height: 20)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("No photos yet")
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.text)
            
            Text("Photos you add to your daily entries\nwill appear here")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            SquiggleView()
                .frame(width: 80, height: 24)
                .padding(.bottom, AppTheme.Spacing.xxxl)
        }
    }
    
    // MARK: - Gallery Content
    private var galleryContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                // Stats
                statsSection
                
                // All Photos Grid
                allPhotosSection
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            StatCard(
                title: "Total Photos",
                value: "\(allImages.count)",
                icon: "photo"
            )
            
            StatCard(
                title: "Days with Photos",
                value: "\(entriesWithImages.count)",
                icon: "calendar"
            )
        }
        .padding(.top, AppTheme.Spacing.lg)
    }
    
    // MARK: - All Photos Section
    private var allPhotosSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("All Photos")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs),
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs),
                GridItem(.flexible(), spacing: AppTheme.Spacing.xs)
            ], spacing: AppTheme.Spacing.xs) {
                ForEach(Array(allImages.enumerated()), id: \.element.image.id) { index, item in
                    if let uiImage = UIImage(data: item.image.imageData) {
                        Button(action: {
                            selectedImageIndex = index
                            showFullScreenImage = true
                        }) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    private func deleteImage(_ image: DayImage) {
        modelContext.delete(image)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Text(value)
                .font(AppTheme.Typography.title2)
                .foregroundColor(AppTheme.Colors.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
}

// MARK: - Gallery Full Screen View
struct GalleryFullScreenView: View {
    let images: [(entry: HabitEntry, image: DayImage)]
    @State var selectedIndex: Int
    let onDelete: (DayImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    private var currentImage: (entry: HabitEntry, image: DayImage)? {
        guard selectedIndex < images.count else { return nil }
        return images[selectedIndex]
    }
    
    private var formattedDate: String {
        guard let entry = currentImage?.entry else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Image Viewer
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.element.image.id) { index, item in
                    if let uiImage = UIImage(data: item.image.imageData) {
                        ZoomableImageView(image: uiImage)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            
            // Overlay Controls
            VStack {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(AppTheme.Spacing.sm)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("\(selectedIndex + 1) / \(images.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text(formattedDate)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(AppTheme.Spacing.sm)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)
                
                Spacer()
            }
        }
        .alert("Delete Photo", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                guard let image = currentImage?.image else { return }
                if selectedIndex > 0 {
                    selectedIndex -= 1
                }
                onDelete(image)
                if images.count <= 1 {
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this photo?")
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, DayImage.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#737373")
    container.mainContext.insert(habit)
    
    return ImageGalleryView(habit: habit)
        .modelContainer(container)
}
