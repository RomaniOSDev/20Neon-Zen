//
//  NeonGlow.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct NeonGlow: ViewModifier {
    var color: Color
    var intensity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: intensity * 10)
            .shadow(color: color.opacity(0.6), radius: intensity * 20)
            .shadow(color: color.opacity(0.4), radius: intensity * 30)
    }
}

extension View {
    func neonGlow(color: Color, intensity: CGFloat = 1.0) -> some View {
        modifier(NeonGlow(color: color, intensity: intensity))
    }
}

let backgroundGradient = LinearGradient(
    colors: [
        Color(hex: "0A0A0A"),
        Color(hex: "1B1B1B"),
        Color(hex: "252525")
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)



