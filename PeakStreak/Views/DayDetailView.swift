//
//  DayDetailView.swift
//  PeakStreak
//
//  Created by PeakStreak on 02/01/26.
//

import SwiftUI
import SwiftData

struct DayDetailView: View {
    @Bindable var habit: Habit
    let date: Date
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showImageSourcePicker = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedImages: [UIImage] = []
    @State private var cameraImage: UIImage?
    @State private var selectedImageIndex: Int?
    @State private var showFullScreenImage = false
    
    private var entry: HabitEntry? {
        habit.entry(for: date)
    }
    
    private var images: [DayImage] {
        entry?.images.sorted { $0.createdAt > $1.createdAt } ?? []
    }
    
    private var isCompleted: Bool {
        habit.isCompleted(for: date)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // Date Header
                        dateHeader
                        
                        // Status Section
                        statusSection
                        
                        // Photos Section
                        photosSection
                        
                        // Add Photo Button
                        if isCompleted {
                            addPhotoButton
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
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
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let index = selectedImageIndex, index < images.count {
                FullScreenImageView(
                    images: images,
                    selectedIndex: index,
                    onDelete: { imageToDelete in
                        deleteImage(imageToDelete)
                    }
                )
            }
        }
        .onChange(of: selectedImages) { _, newImages in
            if !newImages.isEmpty {
                saveImages(newImages)
                selectedImages = []
            }
        }
        .onChange(of: cameraImage) { _, newImage in
            if let image = newImage {
                saveImages([image])
                cameraImage = nil
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
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.md)
    }
    
    // MARK: - Date Header
    private var dateHeader: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(formattedDate)
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.Colors.text)
            
            Text(habit.name)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(.top, AppTheme.Spacing.lg)
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(isCompleted ? AppTheme.Colors.gridCompleted : AppTheme.Colors.gridNotCompleted)
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Text(isCompleted ? "Completed" : "Not completed")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.text)
            
            Spacer()
            
            // Toggle button
            Button(action: {
                withAnimation(AppTheme.Animation.bouncy) {
                    habit.toggleCompletion(for: date, context: modelContext)
                }
            }) {
                Text(isCompleted ? "Undo" : "Mark Done")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.text)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(
                        Capsule()
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
    
    // MARK: - Photos Section
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Photos")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.text)
                
                Spacer()
                
                if !images.isEmpty {
                    Text("\(images.count)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            if images.isEmpty {
                // Empty state
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Text(isCompleted ? "No photos yet" : "Mark as done to add photos")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.xxl)
            } else {
                // Photo Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.sm),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.sm)
                ], spacing: AppTheme.Spacing.sm) {
                    ForEach(Array(images.enumerated()), id: \.element.id) { index, dayImage in
                        if let uiImage = UIImage(data: dayImage.imageData) {
                            Button(action: {
                                selectedImageIndex = index
                                showFullScreenImage = true
                            }) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                            }
                        }
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
    
    // MARK: - Add Photo Button
    private var addPhotoButton: some View {
        Button(action: {
            showImageSourcePicker = true
        }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                Text("Add Photo")
                    .font(AppTheme.Typography.headline)
            }
            .foregroundColor(AppTheme.Colors.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            )
        }
    }
    
    // MARK: - Actions
    private func saveImages(_ uiImages: [UIImage]) {
        let entry = habit.getOrCreateEntry(for: date, context: modelContext)
        
        for uiImage in uiImages {
            let resizedImage = ImageHelper.resizeImage(uiImage)
            if let imageData = ImageHelper.compressImage(resizedImage) {
                let dayImage = DayImage(imageData: imageData)
                dayImage.entry = entry
                entry.images.append(dayImage)
            }
        }
    }
    
    private func deleteImage(_ dayImage: DayImage) {
        modelContext.delete(dayImage)
    }
}

// MARK: - Full Screen Image View
struct FullScreenImageView: View {
    let images: [DayImage]
    @State var selectedIndex: Int
    let onDelete: (DayImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Image Viewer
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, dayImage in
                    if let uiImage = UIImage(data: dayImage.imageData) {
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
                    
                    Text("\(selectedIndex + 1) / \(images.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
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
                let imageToDelete = images[selectedIndex]
                if selectedIndex > 0 {
                    selectedIndex -= 1
                }
                onDelete(imageToDelete)
                if images.count <= 1 {
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this photo?")
        }
    }
}

// MARK: - Zoomable Image View
struct ZoomableImageView: View {
    let image: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 1), 4)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            if scale < 1 {
                                withAnimation {
                                    scale = 1
                                    offset = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if scale > 1 {
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        if scale > 1 {
                            scale = 1
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Habit.self, HabitEntry.self, DayImage.self)
    let habit = Habit(name: "Exercise", icon: "figure.run", colorHex: "#737373")
    container.mainContext.insert(habit)
    
    return DayDetailView(habit: habit, date: Date())
        .modelContainer(container)
}
