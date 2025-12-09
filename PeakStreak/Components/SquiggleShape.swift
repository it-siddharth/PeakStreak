//
//  SquiggleShape.swift
//  PeakStreak
//
//  Created by PeakStreak on 09/12/25.
//

import SwiftUI

/// A hand-drawn style squiggle/wave shape
struct SquiggleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midY = height / 2
        
        // Start from left
        path.move(to: CGPoint(x: 0, y: midY))
        
        // Create a wavy line with 3 waves
        let waveCount = 3
        let waveWidth = width / CGFloat(waveCount)
        let amplitude = height * 0.4
        
        for i in 0..<waveCount {
            let startX = CGFloat(i) * waveWidth
            let endX = startX + waveWidth
            let midX = startX + waveWidth / 2
            
            // Alternate wave direction
            let direction: CGFloat = i % 2 == 0 ? -1 : 1
            
            path.addQuadCurve(
                to: CGPoint(x: midX, y: midY + (amplitude * direction)),
                control: CGPoint(x: startX + waveWidth * 0.25, y: midY + (amplitude * direction * 1.2))
            )
            
            path.addQuadCurve(
                to: CGPoint(x: endX, y: midY),
                control: CGPoint(x: midX + waveWidth * 0.25, y: midY + (amplitude * direction * 1.2))
            )
        }
        
        return path
    }
}

/// A view that displays the squiggle, using image asset if available, otherwise falls back to shape
struct SquiggleView: View {
    var color: Color = .black
    var lineWidth: CGFloat = 3
    
    var body: some View {
        // Try to use the image asset first, fall back to shape
        if UIImage(named: "Squiggle") != nil {
            Image("Squiggle")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(color)
                .aspectRatio(contentMode: .fit)
        } else {
            SquiggleShape()
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        SquiggleView()
            .frame(width: 100, height: 30)
        
        SquiggleShape()
            .stroke(.black, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .frame(width: 100, height: 30)
    }
    .padding()
}
