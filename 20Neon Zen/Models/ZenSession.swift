//
//  ZenSession.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import Foundation

struct ZenSession: Identifiable, Codable {
    let id: UUID
    var startTime: Date
    var endTime: Date?
    var mode: SessionMode
    var duration: TimeInterval
    var calmnessScore: Int? // 1-10
    
    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        mode: SessionMode,
        duration: TimeInterval = 0,
        calmnessScore: Int? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.mode = mode
        self.duration = duration
        self.calmnessScore = calmnessScore
    }
}

enum SessionMode: String, CaseIterable, Codable, Identifiable {
    case particles = "Particles"
    case mandala = "Mandala"
    case breathing = "Breathing"
    case asmr = "ASMR"
    
    var id: String { rawValue }
}

