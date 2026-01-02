//
//  ImagePickerView.swift
//  PeakStreak
//
//  Created by PeakStreak on 02/01/26.
//

import SwiftUI
import PhotosUI

// MARK: - Photo Picker (iOS 16+)
struct PhotoPickerView: View {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.lg) {
                // Navigation Bar
                navigationBar
                
                // Photo Picker
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 5,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Text("Select Photos")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.text)
                        
                        Text("Choose up to 5 photos")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    )
                    .padding(.horizontal, AppTheme.Spacing.xl)
                }
                .onChange(of: selectedItems) { _, newItems in
                    loadImages(from: newItems)
                }
                
                // Selected Images Preview
                if !selectedImages.isEmpty {
                    selectedImagesSection
                }
                
                Spacer()
                
                // Done Button
                if !selectedImages.isEmpty {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                    .buttonStyle(PillButtonStyle(isFilled: true))
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
            
            if isLoading {
                loadingOverlay
            }
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.Colors.text)
            }
            
            Spacer()
            
            Text("Add Photos")
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
    
    private var selectedImagesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("\(selectedImages.count) photo\(selectedImages.count == 1 ? "" : "s") selected")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.xl)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(selectedImages.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                            
                            Button(action: {
                                withAnimation {
                                    selectedImages.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                            .offset(x: 6, y: -6)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
            }
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.text))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.text)
            }
            .padding(AppTheme.Spacing.xl)
            .background(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        isLoading = true
        selectedImages = []
        
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedImages.append(uiImage)
                    }
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Camera View
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Image Source Picker
struct ImageSourcePicker: View {
    @Binding var showPhotoPicker: Bool
    @Binding var showCamera: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppTheme.Spacing.lg) {
                // Handle
                Capsule()
                    .fill(AppTheme.Colors.textSecondary)
                    .frame(width: 40, height: 4)
                    .padding(.top, AppTheme.Spacing.md)
                
                Text("Add Photo")
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.text)
                    .padding(.top, AppTheme.Spacing.md)
                
                VStack(spacing: AppTheme.Spacing.md) {
                    // Camera Option
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showCamera = true
                        }
                    }) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                            Text("Take Photo")
                                .font(AppTheme.Typography.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(AppTheme.Colors.text)
                        .padding(AppTheme.Spacing.lg)
                        .background(AppTheme.Colors.backgroundPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                    }
                    
                    // Photo Library Option
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showPhotoPicker = true
                        }
                    }) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                            Text("Choose from Library")
                                .font(AppTheme.Typography.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(AppTheme.Colors.text)
                        .padding(AppTheme.Spacing.lg)
                        .background(AppTheme.Colors.backgroundPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                
                Spacer()
            }
        }
        .presentationDetents([.height(280)])
    }
}

// MARK: - Image Helper
enum ImageHelper {
    static func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        var compression: CGFloat = 1.0
        let maxBytes = maxSizeKB * 1024
        
        guard var imageData = image.jpegData(compressionQuality: compression) else {
            return nil
        }
        
        while imageData.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            if let newData = image.jpegData(compressionQuality: compression) {
                imageData = newData
            }
        }
        
        return imageData
    }
    
    static func resizeImage(_ image: UIImage, maxDimension: CGFloat = 1200) -> UIImage {
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        
        if ratio >= 1.0 {
            return image
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}

#Preview {
    PhotoPickerView(selectedImages: .constant([]))
}
