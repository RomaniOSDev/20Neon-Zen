//
//  ASMRTrigger.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import Foundation

struct ASMRTrigger: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: TriggerType
    var color: String
    var animation: String
    
    init(
        id: UUID = UUID(),
        name: String,
        type: TriggerType = .visual,
        color: String = "#F00144",
        animation: String = "ripple"
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.color = color
        self.animation = animation
    }
}

enum TriggerType: String, CaseIterable, Codable {
    case visual = "Visual"
    case tactile = "Tactile"
    case auditory = "Auditory"
}

