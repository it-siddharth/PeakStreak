//
//  MeshGradientBackground.swift
//  PeakStreak
//
//  Created by PeakStreak on 01/01/26.
//

import SwiftUI

struct MeshGradientBackground: View {
    let accentColor: Color

    var body: some View {
        ZStack {
            AppTheme.Colors.background

            if #available(iOS 17.0, *) {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        SIMD2<Float>(0.0, 0.0), SIMD2<Float>(0.5, 0.0), SIMD2<Float>(1.0, 0.0),
                        SIMD2<Float>(0.0, 0.5), SIMD2<Float>(0.5, 0.5), SIMD2<Float>(1.0, 0.5),
                        SIMD2<Float>(0.0, 1.0), SIMD2<Float>(0.5, 1.0), SIMD2<Float>(1.0, 1.0)
                    ],
                    colors: [
                        accentColor.opacity(0.25), AppTheme.Colors.background.opacity(0.9), accentColor.opacity(0.12),
                        AppTheme.Colors.background.opacity(0.85), accentColor.opacity(0.18), AppTheme.Colors.background.opacity(0.9),
                        accentColor.opacity(0.10), AppTheme.Colors.background.opacity(0.95), accentColor.opacity(0.20)
                    ]
                )
                .blur(radius: 42)
                .opacity(0.9)
                .ignoresSafeArea()
            } else {
                // Fallback: soft layered gradients (keeps a similar look on older iOS).
                ZStack {
                    RadialGradient(
                        colors: [accentColor.opacity(0.22), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 420
                    )
                    RadialGradient(
                        colors: [accentColor.opacity(0.16), Color.clear],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 520
                    )
                }
                .blur(radius: 36)
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MeshGradientBackground(accentColor: .coral)
}

