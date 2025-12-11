//
//  Particle.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct Particle: Identifiable {
    let id: UUID
    var position: CGPoint
    var velocity: CGVector
    var color: Color
    var size: CGFloat
    var lifeTime: TimeInterval
    
    init(
        id: UUID = UUID(),
        position: CGPoint,
        velocity: CGVector = CGVector(dx: 0, dy: 0),
        color: Color = .pink,
        size: CGFloat = 10,
        lifeTime: TimeInterval = 5.0
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.color = color
        self.size = size
        self.lifeTime = lifeTime
    }
}

