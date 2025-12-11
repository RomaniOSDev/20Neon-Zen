//
//  BreathingExercise.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import Foundation

struct BreathingExercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var inhaleTime: TimeInterval
    var holdTime: TimeInterval
    var exhaleTime: TimeInterval
    var cycles: Int
    var description: String
    
    init(
        id: UUID = UUID(),
        name: String,
        inhaleTime: TimeInterval,
        holdTime: TimeInterval = 0,
        exhaleTime: TimeInterval,
        cycles: Int = 4,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.inhaleTime = inhaleTime
        self.holdTime = holdTime
        self.exhaleTime = exhaleTime
        self.cycles = cycles
        self.description = description
    }
}

enum BreathingPhase {
    case inhale
    case hold
    case exhale
    case rest
}


