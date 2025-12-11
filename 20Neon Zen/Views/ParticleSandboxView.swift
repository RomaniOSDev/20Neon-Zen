//
//  ParticleSandboxView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import Combine

struct ParticleSandboxView: View {
    @StateObject private var viewModel = ParticleViewModel()
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var canvasSize: CGSize = .zero
    @State private var lastParticleTime: Date = Date()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            // Canvas для частиц
            GeometryReader { geometry in
                ZStack {
                    ForEach(viewModel.particles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .position(particle.position)
                            .shadow(color: particle.color.opacity(0.8), radius: 10)
                            .shadow(color: particle.color.opacity(0.6), radius: 20)
                            .shadow(color: particle.color.opacity(0.4), radius: 30)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let location = value.location
                            // Проверяем, что касание в пределах экрана
                            let halfSize = viewModel.particleSize / 2
                            let minX = halfSize
                            let maxX = max(minX, geometry.size.width - halfSize)
                            let minY = halfSize
                            let maxY = max(minY, geometry.size.height - halfSize)
                            
                            let clampedX = max(minX, min(maxX, location.x))
                            let clampedY = max(minY, min(maxY, location.y))
                            let clampedLocation = CGPoint(x: clampedX, y: clampedY)
                            
                            // Ограничиваем частоту добавления частиц (не чаще чем раз в 0.03 секунды)
                            let now = Date()
                            if now.timeIntervalSince(lastParticleTime) > 0.03 {
                                viewModel.addParticle(at: clampedLocation)
                                lastParticleTime = now
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            // Также добавляем частицу при простом тапе
                            let centerX = geometry.size.width / 2
                            let centerY = geometry.size.height / 2
                            let halfSize = viewModel.particleSize / 2
                            let location = CGPoint(
                                x: max(halfSize, min(geometry.size.width - halfSize, centerX)),
                                y: max(halfSize, min(geometry.size.height - halfSize, centerY))
                            )
                            viewModel.addParticle(at: location)
                        }
                )
                .onAppear {
                    canvasSize = geometry.size
                    // Добавляем несколько тестовых частиц для демонстрации
                    if viewModel.particles.isEmpty && geometry.size.width > 0 && geometry.size.height > 0 {
                        let centerX = geometry.size.width / 2
                        let centerY = geometry.size.height / 2
                        let halfSize = viewModel.particleSize / 2
                        let maxRadius = min(centerX, centerY) - halfSize - 20
                        
                        for i in 0..<5 {
                            let angle = Double(i) * 2 * .pi / 5
                            let x = centerX + cos(angle) * maxRadius
                            let y = centerY + sin(angle) * maxRadius
                            let clampedX = max(halfSize, min(geometry.size.width - halfSize, x))
                            let clampedY = max(halfSize, min(geometry.size.height - halfSize, y))
                            viewModel.addParticle(at: CGPoint(x: clampedX, y: clampedY))
                        }
                    }
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
                
                ToolbarView(viewModel: viewModel)
                    .padding(.bottom, 30)
            }
            
            // Кнопка закрытия и счетчик частиц
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
                    
                    // Счетчик частиц для отладки
                    Text("Particles: \(viewModel.particles.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.textSecondary)
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
                viewModel.updateParticles(in: canvasSize)
            }
        }
    }
}

struct ToolbarView: View {
    @ObservedObject var viewModel: ParticleViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Режимы
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ParticleViewModel.ParticleMode.allCases, id: \.self) { mode in
                        ModeButton(
                            title: mode.rawValue,
                            isSelected: viewModel.selectedMode == mode,
                            color: getColorForMode(mode)
                        ) {
                            viewModel.selectedMode = mode
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Размер частиц
            VStack(alignment: .leading, spacing: 8) {
                Text("Size: \(Int(viewModel.particleSize))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.textSecondary)
                
                Slider(value: $viewModel.particleSize, in: 5...30)
                    .tint(Color.neonPink)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
            )
            .padding(.horizontal)
            
            // Кнопка очистки
            Button(action: {
                viewModel.clearParticles()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
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
    
    private func getColorForMode(_ mode: ParticleViewModel.ParticleMode) -> Color {
        switch mode {
        case .water: return Color.neonGreen
        case .fire: return Color.neonPink
        case .stars: return Color.neonPurple
        case .bubbles: return .blue
        }
    }
}

struct ModeButton: View {
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

