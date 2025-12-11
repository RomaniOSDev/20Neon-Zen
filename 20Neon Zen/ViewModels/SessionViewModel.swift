//
//  SessionViewModel.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import Foundation
import Combine

class SessionViewModel: ObservableObject {
    @Published var currentSession: ZenSession?
    @Published var sessions: [ZenSession] = []
    @Published var totalSessionTime: TimeInterval = 0
    @Published var lastSessionDate: Date?
    
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "zen_sessions"
    
    init() {
        loadSessions()
        updateStatistics()
    }
    
    func startSession(mode: SessionMode) {
        currentSession = ZenSession(mode: mode)
    }
    
    func endSession(calmnessScore: Int? = nil) {
        guard var session = currentSession else { return }
        
        session.endTime = Date()
        session.duration = session.endTime!.timeIntervalSince(session.startTime)
        session.calmnessScore = calmnessScore
        
        sessions.append(session)
        saveSessions()
        updateStatistics()
        
        currentSession = nil
    }
    
    func getSessions(for mode: SessionMode) -> [ZenSession] {
        return sessions.filter { $0.mode == mode }
    }
    
    func getTotalTime(for mode: SessionMode) -> TimeInterval {
        return getSessions(for: mode).reduce(0) { $0 + $1.duration }
    }
    
    private func updateStatistics() {
        totalSessionTime = sessions.reduce(0) { $0 + $1.duration }
        lastSessionDate = sessions.sorted(by: { $0.startTime > $1.startTime }).first?.startTime
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
    
    private func loadSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([ZenSession].self, from: data) {
            sessions = decoded
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

