//
//  ParticleViewModel.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import Combine

class ParticleViewModel: ObservableObject {
    @Published var particles: [Particle] = []
    @Published var selectedColor: Color = .neonPink
    @Published var particleSize: CGFloat = 15
    @Published var selectedMode: ParticleMode = .water {
        didSet {
            // Обновляем существующие частицы при смене режима
            updateParticlesForModeChange()
        }
    }
    
    private var timer: Timer?
    private let gravity: CGFloat = 0.1
    private let friction: CGFloat = 0.98
    
    enum ParticleMode: String, CaseIterable {
        case water = "Water"
        case fire = "Fire"
        case stars = "Stars"
        case bubbles = "Bubbles"
    }
    
    init() {
        startAnimation()
    }
    
    func addParticle(at position: CGPoint) {
        let velocity = getVelocityForMode(at: position)
        let color = getColorForMode()
        let size = getSizeForMode()
        
        let particle = Particle(
            position: position,
            velocity: velocity,
            color: color,
            size: size,
            lifeTime: 30.0 // Увеличиваем время жизни до 30 секунд
        )
        
        particles.append(particle)
    }
    
    func updateParticlesForModeChange() {
        // Обновляем цвет и размер существующих частиц при смене режима
        for index in particles.indices {
            particles[index].color = getColorForMode()
            particles[index].size = getSizeForMode()
        }
    }
    
    func addMultipleParticles(at positions: [CGPoint]) {
        for position in positions {
            addParticle(at: position)
        }
    }
    
    func removeParticle(_ particle: Particle) {
        particles.removeAll { $0.id == particle.id }
    }
    
    func clearParticles() {
        particles.removeAll()
    }
    
    private func getVelocityForMode(at position: CGPoint) -> CGVector {
        switch selectedMode {
        case .water:
            return CGVector(dx: Double.random(in: -2 ... 2), dy: Double.random(in: -2 ... 2))
        case .fire:
            return CGVector(dx: Double.random(in: -1 ... 1), dy: Double.random(in: -3 ... -1))
        case .stars:
            return CGVector(dx: Double.random(in: -0.5 ... 0.5), dy: Double.random(in: -0.5 ... 0.5))
        case .bubbles:
            return CGVector(dx: Double.random(in: -1 ... 1), dy: Double.random(in: -2 ... -0.5))
        }
    }
    
    private func getColorForMode() -> Color {
        switch selectedMode {
        case .water:
            return Color.neonGreen
        case .fire:
            return Color.neonPink
        case .stars:
            return Color.neonPurple
        case .bubbles:
            return Color.blue.opacity(0.7)
        }
    }
    
    private func getSizeForMode() -> CGFloat {
        switch selectedMode {
        case .water:
            return particleSize
        case .fire:
            return particleSize * 0.8
        case .stars:
            return particleSize * 1.2
        case .bubbles:
            return particleSize * 1.5
        }
    }
    
    func updateParticles(in size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        
        var idsToRemove: [UUID] = []
        let halfSize = particleSize / 2
        
        for index in particles.indices {
            var particle = particles[index]
            
            // Применение физики в зависимости от режима
            switch selectedMode {
            case .water:
                // Вода: легкая гравитация вниз, сильное трение
                particle.velocity.dy += gravity * 0.2
                particle.velocity.dx *= friction
                particle.velocity.dy *= friction
            case .fire:
                // Огонь: поднимается вверх
                particle.velocity.dy -= gravity * 0.4
                particle.velocity.dx *= 0.995
            case .stars:
                // Звезды: медленное движение, почти без гравитации
                particle.velocity.dx *= 0.998
                particle.velocity.dy *= 0.998
            case .bubbles:
                // Пузыри: поднимаются вверх медленно
                particle.velocity.dy -= gravity * 0.15
                particle.velocity.dx *= 0.995
            }
            
            // Обновление позиции
            particle.position.x += particle.velocity.dx
            particle.position.y += particle.velocity.dy
            
            // Проверка и коррекция границ экрана с учетом размера частицы
            let minX = halfSize
            let maxX = size.width - halfSize
            let minY = halfSize
            let maxY = size.height - halfSize
            
            if particle.position.x < minX {
                particle.position.x = minX
                particle.velocity.dx *= -0.8
            } else if particle.position.x > maxX {
                particle.position.x = maxX
                particle.velocity.dx *= -0.8
            }
            
            if particle.position.y < minY {
                particle.position.y = minY
                particle.velocity.dy *= -0.8
            } else if particle.position.y > maxY {
                particle.position.y = maxY
                particle.velocity.dy *= -0.8
            }
            
            // Ограничение скорости для предотвращения вылета за границы
            let maxVelocity: CGFloat = 10.0
            particle.velocity.dx = max(-maxVelocity, min(maxVelocity, particle.velocity.dx))
            particle.velocity.dy = max(-maxVelocity, min(maxVelocity, particle.velocity.dy))
            
            // Уменьшение времени жизни (только если частица слишком долго существует)
            particle.lifeTime -= 0.016
            
            // Удаляем только если время жизни истекло (увеличено до 30 секунд)
            if particle.lifeTime <= 0 {
                idsToRemove.append(particle.id)
            } else {
                particles[index] = particle
            }
        }
        
        // Удаляем частицы с истекшим временем жизни по ID
        particles.removeAll { idsToRemove.contains($0.id) }
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            // Анимация будет обновляться из View
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

