//
//  BreathingViewModel.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import Combine

class BreathingViewModel: ObservableObject {
    @Published var currentExercise: BreathingExercise
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var phaseProgress: Double = 0.0
    @Published var currentCycle: Int = 0
    @Published var isRunning: Bool = false
    @Published var circleScale: CGFloat = 0.5
    
    private var timer: Timer?
    private var phaseStartTime: Date = Date()
    private var totalDuration: TimeInterval = 0
    
    let defaultExercises: [BreathingExercise] = [
        BreathingExercise(
            name: "4-7-8 for Sleep",
            inhaleTime: 4,
            holdTime: 7,
            exhaleTime: 8,
            cycles: 4,
            description: "Calming technique before sleep"
        ),
        BreathingExercise(
            name: "Energizing Breath",
            inhaleTime: 2,
            holdTime: 1,
            exhaleTime: 2,
            cycles: 10,
            description: "Energizing morning pattern"
        ),
        BreathingExercise(
            name: "Equal Breathing",
            inhaleTime: 5,
            holdTime: 0,
            exhaleTime: 5,
            cycles: 8,
            description: "Balancing technique"
        )
    ]
    
    init() {
        self.currentExercise = defaultExercises[0]
    }
    
    func startExercise() {
        isRunning = true
        currentCycle = 0
        currentPhase = .inhale
        phaseStartTime = Date()
        phaseProgress = 0.0
        startTimer()
    }
    
    func pauseExercise() {
        isRunning = false
        timer?.invalidate()
    }
    
    func stopExercise() {
        isRunning = false
        timer?.invalidate()
        currentCycle = 0
        currentPhase = .inhale
        phaseProgress = 0.0
        circleScale = 0.5
    }
    
    func selectExercise(_ exercise: BreathingExercise) {
        stopExercise()
        currentExercise = exercise
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePhase()
        }
    }
    
    private func updatePhase() {
        guard isRunning else { return }
        
        let elapsed = Date().timeIntervalSince(phaseStartTime)
        let phaseDuration = getPhaseDuration()
        
        phaseProgress = min(elapsed / phaseDuration, 1.0)
        
        // Обновление масштаба круга
        switch currentPhase {
        case .inhale:
            circleScale = 0.5 + (phaseProgress * 0.5)
        case .hold:
            circleScale = 1.0
        case .exhale:
            circleScale = 1.0 - (phaseProgress * 0.5)
        case .rest:
            circleScale = 0.5
        }
        
        if phaseProgress >= 1.0 {
            moveToNextPhase()
        }
    }
    
    private func moveToNextPhase() {
        switch currentPhase {
        case .inhale:
            if currentExercise.holdTime > 0 {
                currentPhase = .hold
            } else {
                currentPhase = .exhale
            }
        case .hold:
            currentPhase = .exhale
        case .exhale:
            currentCycle += 1
            if currentCycle >= currentExercise.cycles {
                currentPhase = .rest
                stopExercise()
            } else {
                currentPhase = .inhale
            }
        case .rest:
            currentPhase = .inhale
        }
        
        phaseStartTime = Date()
        phaseProgress = 0.0
    }
    
    private func getPhaseDuration() -> TimeInterval {
        switch currentPhase {
        case .inhale:
            return currentExercise.inhaleTime
        case .hold:
            return currentExercise.holdTime
        case .exhale:
            return currentExercise.exhaleTime
        case .rest:
            return 1.0
        }
    }
    
    var phaseText: String {
        switch currentPhase {
        case .inhale:
            return "Inhale"
        case .hold:
            return "Hold"
        case .exhale:
            return "Exhale"
        case .rest:
            return "Rest"
        }
    }
    
    var remainingTime: TimeInterval {
        let phaseDuration = getPhaseDuration()
        return max(0, phaseDuration - (Date().timeIntervalSince(phaseStartTime)))
    }
    
    deinit {
        timer?.invalidate()
    }
}

