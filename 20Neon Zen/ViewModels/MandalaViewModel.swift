//
//  MandalaViewModel.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import Combine

class MandalaViewModel: ObservableObject {
    @Published var currentPattern: MandalaPattern
    @Published var rotationAngle: Double = 0
    @Published var scale: CGFloat = 1.0
    @Published var pulsePhase: Double = 0
    @Published var selectedFunction: MandalaFunction = .rose
    
    private var timer: Timer?
    
    init() {
        self.currentPattern = MandalaPattern(
            name: "Basic Mandala",
            complexity: 3,
            symmetryType: .radial,
            baseColors: ["#F00144", "#FF21FF", "#00FF9D"],
            animationType: .rotation
        )
        startAnimation()
    }
    
    func generatePattern(complexity: Int, symmetry: SymmetryType, colors: [String], animation: AnimationType) {
        currentPattern = MandalaPattern(
            name: "Mandala \(complexity)",
            complexity: complexity,
            symmetryType: symmetry,
            baseColors: colors,
            animationType: animation
        )
    }
    
    func updateAnimation() {
        switch currentPattern.animationType {
        case .rotation:
            rotationAngle += 0.5
            if rotationAngle >= 360 {
                rotationAngle = 0
            }
        case .pulse:
            pulsePhase += 0.05
            scale = 1.0 + sin(pulsePhase) * 0.1
        case .flow:
            rotationAngle += 0.3
            pulsePhase += 0.03
            scale = 1.0 + sin(pulsePhase) * 0.05
        case .static:
            break
        }
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.updateAnimation()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
