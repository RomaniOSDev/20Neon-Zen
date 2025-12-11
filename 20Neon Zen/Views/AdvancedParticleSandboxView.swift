//
//  AdvancedParticleSandboxView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import Combine

struct AdvancedParticleSandboxView: View {
    @StateObject private var metalSystem = MetalParticleSystem()
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var canvasSize: CGSize = .zero
    @State private var selectedBehavior: ParticleBehavior = .gravity
    @State private var touchPoints: [CGPoint] = []
    @State private var touchColors: [Color] = []
    @State private var lastSpawnTime: [Int: Date] = [:]
    @State private var activeTouchIndices: Set<Int> = []
    @State private var supportsMetal: Bool = {
        return MTLCreateSystemDefaultDevice() != nil
    }()
    @Environment(\.dismiss) private var dismiss
    
    private let colors: [Color] = [
        .neonPink, .neonPurple, .neonGreen, .blue, .yellow, .orange, .cyan, Color(red: 1.0, green: 0.0, blue: 1.0)
    ]
    
    var body: some View {
        Group {
            if supportsMetal {
                metalParticleView
            } else {
                fallbackView
            }
        }
    }
    
    private var metalParticleView: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            // Canvas для частиц
            GeometryReader { geometry in
                ZStack {
                    // Рендерим частицы из Metal системы
                    ForEach(Array(metalSystem.getParticles().enumerated()), id: \.offset) { index, particle in
                        Circle()
                            .fill(Color(
                                red: Double(particle.color.x),
                                green: Double(particle.color.y),
                                blue: Double(particle.color.z)
                            ))
                            .frame(width: CGFloat(particle.size), height: CGFloat(particle.size))
                            .position(x: CGFloat(particle.position.x), y: CGFloat(particle.position.y))
                            .shadow(
                                color: Color(
                                    red: Double(particle.color.x),
                                    green: Double(particle.color.y),
                                    blue: Double(particle.color.z)
                                ).opacity(0.8),
                                radius: 10
                            )
                            .shadow(
                                color: Color(
                                    red: Double(particle.color.x),
                                    green: Double(particle.color.y),
                                    blue: Double(particle.color.z)
                                ).opacity(0.6),
                                radius: 20
                            )
                    }
                    
                    // Визуализация источников (для отладки)
                    ForEach(Array(metalSystem.sources.enumerated()), id: \.offset) { index, source in
                        Circle()
                            .stroke(
                                Color(
                                    red: Double(source.color.x),
                                    green: Double(source.color.y),
                                    blue: Double(source.color.z)
                                ),
                                lineWidth: 2
                            )
                            .frame(width: CGFloat(source.radius), height: CGFloat(source.radius))
                            .position(x: CGFloat(source.position.x), y: CGFloat(source.position.y))
                            .opacity(0.3)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay(
                    MultiTouchView(
                        onTouchesChanged: { locations in
                            handleMultiTouch(locations: locations, geometry: geometry)
                        },
                        onTouchesEnded: {
                            // Очищаем отслеживание касаний при отпускании
                            activeTouchIndices.removeAll()
                            lastSpawnTime.removeAll()
                        }
                    )
                )
                .onAppear {
                    canvasSize = geometry.size
                    metalSystem.update(canvasSize: geometry.size)
                }
                .onChange(of: geometry.size) { newSize in
                    canvasSize = newSize
                }
            }
            .onAppear {
                sessionViewModel.startSession(mode: .particles)
            }
            .onDisappear {
                sessionViewModel.endSession()
            }
            
            // Панель инструментов
            VStack {
                Spacer()
                
                AdvancedToolbarView(
                    metalSystem: metalSystem,
                    selectedBehavior: $selectedBehavior
                )
                .padding(.bottom, 30)
            }
            
            // Кнопка закрытия и счетчик
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.textPrimary)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Particles: \(metalSystem.particleCount)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.textSecondary)
                        
                        Text("Metal Accelerated")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(Color.neonGreen.opacity(0.7))
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.5))
                    )
                    .padding(.trailing)
                }
                
                Spacer()
            }
        }
        .onReceive(Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()) { _ in
            if canvasSize.width > 0 && canvasSize.height > 0 {
                metalSystem.update(canvasSize: canvasSize)
            }
        }
    }
    
    private var fallbackView: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Metal Not Supported")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.textPrimary)
                
                Text("This device does not support Metal acceleration. Please use the standard particle view.")
                    .font(.system(size: 16))
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Use Standard View") {
                    dismiss()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.neonPink.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neonPink, lineWidth: 2)
                        )
                )
            }
            .padding()
        }
    }
    
    private func handleMultiTouch(locations: [CGPoint], geometry: GeometryProxy) {
        let currentTime = Date()
        
        // Отслеживаем активные касания
        var currentTouchIndices: Set<Int> = []
        
        // Обновляем источники для каждого касания
        for (index, location) in locations.enumerated() {
            currentTouchIndices.insert(index)
            
            let clampedLocation = CGPoint(
                x: max(0, min(geometry.size.width, location.x)),
                y: max(0, min(geometry.size.height, location.y))
            )
            
            // Проверяем, является ли это новым касанием (не было в предыдущем списке активных)
            let isNewTouch = !activeTouchIndices.contains(index)
            
            // Проверяем, есть ли уже источник для этого индекса касания
            if index < metalSystem.sources.count {
                // Обновляем существующий источник (не создаем частицы при движении)
                metalSystem.sources[index].position = SIMD2<Float>(
                    Float(clampedLocation.x),
                    Float(clampedLocation.y)
                )
                metalSystem.sources[index].time += 0.016
            } else {
                // Это новый индекс - всегда создаем источник и частицу
                let colorIndex = index % colors.count
                let color = colors[colorIndex]
                
                metalSystem.addSource(
                    at: clampedLocation,
                    color: color,
                    behavior: selectedBehavior,
                    spawnParticle: true
                )
            }
            
            // Если это новое касание (палец был отпущен и снова коснулся), создаем частицу
            // даже если источник уже существует
            if isNewTouch && index < metalSystem.sources.count {
                let colorIndex = index % colors.count
                let color = colors[colorIndex]
                
                // Создаем частицу для нового касания, используя существующий источник
                metalSystem.addSource(
                    at: clampedLocation,
                    color: color,
                    behavior: selectedBehavior,
                    spawnParticle: true
                )
                // Удаляем дубликат источника, оставляем только обновленный
                if metalSystem.sources.count > index + 1 {
                    metalSystem.sources.removeLast()
                }
            }
        }
        
        // Обновляем множество активных касаний
        activeTouchIndices = currentTouchIndices
        
        // Удаляем источники, которые больше не активны
        if locations.count < metalSystem.sources.count {
            let indicesToRemove = metalSystem.sources.count - locations.count
            metalSystem.sources.removeLast(indicesToRemove)
            // Также очищаем отслеживание для удаленных индексов
            for i in locations.count..<metalSystem.sources.count + indicesToRemove {
                lastSpawnTime.removeValue(forKey: i)
            }
        }
    }
}

struct AdvancedToolbarView: View {
    @ObservedObject var metalSystem: MetalParticleSystem
    @Binding var selectedBehavior: ParticleBehavior
    
    var body: some View {
        VStack(spacing: 16) {
            // Выбор поведения
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ParticleBehavior.allCases, id: \.self) { behavior in
                        BehaviorButton(
                            title: behavior.displayName,
                            isSelected: selectedBehavior == behavior,
                            color: getColorForBehavior(behavior)
                        ) {
                            selectedBehavior = behavior
                            // Обновляем поведение всех источников
                            for index in metalSystem.sources.indices {
                                metalSystem.sources[index].behaviorType = behavior.rawValue
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Настройки гравитации и трения
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gravity: \(String(format: "%.2f", metalSystem.gravity))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                    
                    Slider(value: Binding(
                        get: { Double(metalSystem.gravity) },
                        set: { metalSystem.gravity = Float($0) }
                    ), in: -1.0...2.0)
                        .tint(Color.neonGreen)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Friction: \(String(format: "%.2f", metalSystem.friction))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                    
                    Slider(value: Binding(
                        get: { Double(metalSystem.friction) },
                        set: { metalSystem.friction = Float($0) }
                    ), in: 0.9...1.0)
                        .tint(Color.neonPurple)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
            )
            .padding(.horizontal)
            
            // Кнопка очистки
            Button(action: {
                metalSystem.clearParticles()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.neonPink.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neonPink, lineWidth: 2)
                        )
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.neonPink.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private func getColorForBehavior(_ behavior: ParticleBehavior) -> Color {
        switch behavior {
        case .gravity: return .neonGreen
        case .repulsion: return .neonPink
        case .attraction: return .neonPurple
        case .turbulence: return .blue
        }
    }
}

struct BehaviorButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .black : Color.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : Color.black.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(color.opacity(isSelected ? 1 : 0.5), lineWidth: 2)
                        )
                )
        }
        .neonGlow(color: color, intensity: isSelected ? 0.8 : 0.3)
    }
}

