//
//  MandalaPattern.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct MandalaPattern: Identifiable, Codable {
    let id: UUID
    var name: String
    var complexity: Int // 1-5
    var symmetryType: SymmetryType
    var baseColors: [String] // hex colors
    var animationType: AnimationType
    
    init(
        id: UUID = UUID(),
        name: String,
        complexity: Int = 3,
        symmetryType: SymmetryType = .radial,
        baseColors: [String] = ["#F00144"],
        animationType: AnimationType = .rotation
    ) {
        self.id = id
        self.name = name
        self.complexity = max(1, min(5, complexity))
        self.symmetryType = symmetryType
        self.baseColors = baseColors
        self.animationType = animationType
    }
}

enum SymmetryType: String, CaseIterable, Codable {
    case radial = "Radial"
    case bilateral = "Bilateral"
    case rotational = "Rotational"
    case none = "Asymmetric"
    
    var symmetryOrder: Int {
        switch self {
        case .radial: return 8
        case .rotational: return 6
        case .bilateral: return 4
        case .none: return 1
        }
    }
}

enum AnimationType: String, CaseIterable, Codable {
    case pulse = "Pulse"
    case rotation = "Rotation"
    case flow = "Flow"
    case `static` = "Static"
}

enum MandalaFunction: String, CaseIterable {
    case rose = "Rose"
    case spiral = "Spiral"
    case flower = "Flower"
    case geometric = "Geometric"
    case wave = "Wave"
    case fractal = "Fractal"
}
