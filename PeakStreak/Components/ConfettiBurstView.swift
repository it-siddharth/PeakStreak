//
//  ConfettiBurstView.swift
//  PeakStreak
//
//  Created by Cursor on 01/02/26.
//

import SwiftUI
import UIKit

/// A lightweight, one-shot confetti burst.
///
/// Usage:
/// - Keep an `@State var confettiTrigger = 0`
/// - Increment `confettiTrigger += 1` whenever you want a burst.
struct ConfettiBurstView: UIViewRepresentable {
    var trigger: Int
    var colors: [UIColor] = [
        .systemPink,
        .systemPurple,
        .systemBlue,
        .systemTeal,
        .systemGreen,
        .systemYellow,
        .systemOrange,
        .systemRed
    ]
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ConfettiEmitterUIView {
        let view = ConfettiEmitterUIView()
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: ConfettiEmitterUIView, context: Context) {
        guard context.coordinator.lastTrigger != trigger else { return }
        context.coordinator.lastTrigger = trigger
        uiView.burst(colors: colors)
    }
    
    final class Coordinator {
        var lastTrigger: Int = 0
    }
}

final class ConfettiEmitterUIView: UIView {
    private let emitterLayer = CAEmitterLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(emitterLayer)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.addSublayer(emitterLayer)
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.frame = bounds
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: -12)
        emitterLayer.emitterSize = CGSize(width: bounds.width, height: 1)
    }
    
    func burst(colors: [UIColor]) {
        configureIfNeeded(colors: colors)
        
        // Short burst; particles continue to fall via lifetime.
        emitterLayer.beginTime = CACurrentMediaTime()
        emitterLayer.birthRate = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            self?.emitterLayer.birthRate = 0
        }
    }
    
    private func configureIfNeeded(colors: [UIColor]) {
        // Reconfigure each time in case bounds or palette changes.
        emitterLayer.emitterShape = .line
        emitterLayer.emitterMode = .outline
        emitterLayer.renderMode = .unordered
        emitterLayer.birthRate = 0
        emitterLayer.emitterCells = makeCells(colors: colors)
    }
    
    private func makeCells(colors: [UIColor]) -> [CAEmitterCell] {
        var cells: [CAEmitterCell] = []
        
        for color in colors {
            if let square = makeConfettiImage(color: color, shape: .square),
               let circle = makeConfettiImage(color: color, shape: .circle) {
                cells.append(makeCell(contents: square))
                cells.append(makeCell(contents: circle))
            } else if let fallback = makeConfettiImage(color: color, shape: .square) {
                cells.append(makeCell(contents: fallback))
            }
        }
        
        // If image rendering fails for some reason, still avoid crashing.
        if cells.isEmpty {
            let cell = CAEmitterCell()
            cell.birthRate = 0
            return [cell]
        }
        
        return cells
    }
    
    private func makeCell(contents: CGImage) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.contents = contents
        cell.birthRate = 10
        cell.lifetime = 4.2
        cell.lifetimeRange = 1.0
        
        cell.velocity = 210
        cell.velocityRange = 140
        cell.yAcceleration = 420
        cell.xAcceleration = 0
        
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 3
        
        cell.spin = 3.2
        cell.spinRange = 4.0
        
        cell.scale = 0.28
        cell.scaleRange = 0.18
        cell.scaleSpeed = -0.02
        
        cell.alphaRange = 0.15
        cell.alphaSpeed = -0.18
        
        return cell
    }
    
    private enum ConfettiShape {
        case square
        case circle
    }
    
    private func makeConfettiImage(color: UIColor, shape: ConfettiShape) -> CGImage? {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            
            switch shape {
            case .square:
                color.setFill()
                ctx.fill(rect)
                
            case .circle:
                color.setFill()
                ctx.cgContext.fillEllipse(in: rect)
            }
        }
        
        return image.cgImage
    }
}

