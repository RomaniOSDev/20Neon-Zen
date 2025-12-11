//
//  MetalEffectsDemoView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import MetalKit

struct MetalEffectsDemoView: View {
    @State private var selectedEffect: MetalRenderer.EffectType = .neonGlow
    @State private var glowIntensity: CGFloat = 1.0
    @State private var waveAmplitude: CGFloat = 0.02
    @State private var selectedColor: Color = .neonPink
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Заголовок
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.textPrimary)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Metal Effects")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.textPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 30, height: 30)
                }
                .padding()
                
                // Демонстрация эффекта
                GeometryReader { geometry in
                    OptimizedEffectView(
                        effectType: selectedEffect,
                        glowColor: selectedColor,
                        intensity: glowIntensity,
                        waveAmplitude: waveAmplitude
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectedColor.opacity(0.3), lineWidth: 2)
                    )
                }
                .padding(.horizontal)
                .frame(height: 300)
                
                // Контролы
                ScrollView {
                    VStack(spacing: 20) {
                        // Выбор эффекта
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Effect")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.textPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach([MetalRenderer.EffectType.neonGlow,
                                            .colorTransition,
                                            .waveDistortion,
                                            .particleSystem,
                                            .neonWave], id: \.self) { effect in
                                        Button(action: {
                                            selectedEffect = effect
                                        }) {
                                            Text(effect.displayName)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedEffect == effect ? .black : Color.textPrimary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(selectedEffect == effect ? Color.neonPink : Color.black.opacity(0.4))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(Color.neonPink.opacity(0.5), lineWidth: 2)
                                                        )
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.3))
                        )
                        .padding(.horizontal)
                        
                        // Интенсивность свечения
                        if selectedEffect == .neonGlow || selectedEffect == .neonWave {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Intensity: \(Int(glowIntensity * 100))%")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.textSecondary)
                                
                                Slider(value: $glowIntensity, in: 0.1...2.0)
                                    .tint(Color.neonPink)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.3))
                            )
                            .padding(.horizontal)
                        }
                        
                        // Амплитуда волн
                        if selectedEffect == .waveDistortion || selectedEffect == .neonWave {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Wave Amplitude: \(Int(waveAmplitude * 1000))")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.textSecondary)
                                
                                Slider(value: $waveAmplitude, in: 0.01...0.1)
                                    .tint(Color.neonPurple)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.3))
                            )
                            .padding(.horizontal)
                        }
                        
                        // Выбор цвета
                        if selectedEffect == .neonGlow || selectedEffect == .neonWave {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Color")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.textPrimary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach([Color.neonPink, Color.neonPurple, Color.neonGreen, Color.blue, Color.yellow], id: \.self) { color in
                                            Button(action: {
                                                selectedColor = color
                                            }) {
                                                Circle()
                                                    .fill(color)
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(.white.opacity(0.5), lineWidth: selectedColor == color ? 3 : 0)
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.3))
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

extension MetalRenderer.EffectType {
    var displayName: String {
        switch self {
        case .neonGlow:
            return "Neon Glow"
        case .colorTransition:
            return "Color Transition"
        case .waveDistortion:
            return "Wave Distortion"
        case .particleSystem:
            return "Particles"
        case .neonWave:
            return "Neon + Waves"
        }
    }
}

