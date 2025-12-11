//
//  MainDashboardView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct MainDashboardView: View {
    @StateObject private var sessionViewModel = SessionViewModel()
    @State private var selectedMode: SessionMode?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Заголовок и кнопка настроек
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 8) {
                                Text("Neon Zen")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.textPrimary)
                                    .neonGlow(color: Color.neonPink, intensity: 1.5)
                                
                                Text("Digital Sandbox for Relaxation")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.textSecondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.textPrimary)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.4))
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.neonPink.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.top, 20)
                        
                        // Статистика
                        if let lastSession = sessionViewModel.lastSessionDate {
                            HStack(spacing: 30) {
                                StatCard(
                                    title: "Total Time",
                                    value: sessionViewModel.formatDuration(sessionViewModel.totalSessionTime),
                                    color: Color.neonGreen
                                )
                                
                                StatCard(
                                    title: "Last Session",
                                    value: formatDate(lastSession),
                                    color: Color.neonPurple
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Карточки режимов
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 15),
                            GridItem(.flexible(), spacing: 15)
                        ], spacing: 15) {
                            ModeCard(
                                mode: .particles,
                                title: "Particles",
                                icon: "sparkles",
                                color: Color.neonPink,
                                preview: AnyView(ParticlePreview())
                            )
                            .onTapGesture {
                                selectedMode = .particles
                            }
                            
                            ModeCard(
                                mode: .mandala,
                                title: "Mandala",
                                icon: "circle.grid.3x3.fill",
                                color: Color.neonPurple,
                                preview: AnyView(MandalaPreview())
                            )
                            .onTapGesture {
                                selectedMode = .mandala
                            }
                            
                            ModeCard(
                                mode: .breathing,
                                title: "Breathing",
                                icon: "wind",
                                color: Color.neonGreen,
                                preview: AnyView(BreathingPreview())
                            )
                            .onTapGesture {
                                selectedMode = .breathing
                            }
                            
                            ModeCard(
                                mode: .asmr,
                                title: "ASMR",
                                icon: "waveform.path",
                                color: Color.neonPink,
                                preview: AnyView(ASMRPreview())
                            )
                            .onTapGesture {
                                selectedMode = .asmr
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedMode) { mode in
                destinationView(for: mode)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for mode: SessionMode) -> some View {
        switch mode {
        case .particles:
            AdvancedParticleSandboxView(sessionViewModel: sessionViewModel)
        case .mandala:
            MandalaGeneratorView(sessionViewModel: sessionViewModel)
        case .breathing:
            BreathingGuideView(sessionViewModel: sessionViewModel)
        case .asmr:
            ASMRVisualizerView(sessionViewModel: sessionViewModel)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
                .neonGlow(color: color, intensity: 0.8)
            
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ModeCard: View {
    let mode: SessionMode
    let title: String
    let icon: String
    let color: Color
    let preview: AnyView
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.4))
                    .frame(height: 120)
                
                preview
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .neonGlow(color: color, intensity: 0.6)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(color.opacity(0.4), lineWidth: 2)
                )
        )
        .neonGlow(color: color, intensity: 0.3)
    }
}

// Превью для карточек
struct ParticlePreview: View {
    var body: some View {
        ZStack {
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.neonPink.opacity(0.6))
                    .frame(width: 20, height: 20)
                    .offset(
                        x: cos(Double(index) * 2 * .pi / 5) * 30,
                        y: sin(Double(index) * 2 * .pi / 5) * 30
                    )
            }
        }
    }
}

struct MandalaPreview: View {
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.neonPurple.opacity(0.5))
                    .frame(width: 4, height: 40)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
    }
}

struct BreathingPreview: View {
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        Circle()
            .stroke(Color.neonGreen.opacity(0.6), lineWidth: 3)
            .frame(width: 60, height: 60)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    scale = 1.2
                }
            }
    }
}

struct ASMRPreview: View {
    var body: some View {
        ZStack {
            ForEach(0..<3) { row in
                ForEach(0..<3) { col in
                    Circle()
                        .fill(Color.neonPink.opacity(0.4))
                        .frame(width: 15, height: 15)
                        .offset(x: CGFloat(col - 1) * 25, y: CGFloat(row - 1) * 25)
                }
            }
        }
    }
}

