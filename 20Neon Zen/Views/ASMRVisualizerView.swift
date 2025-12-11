//
//  ASMRVisualizerView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import Combine

struct ASMRVisualizerView: View {
    @StateObject private var viewModel = ASMRViewModel()
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var sessionStartTime: Date?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Заголовок и кнопка закрытия
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.textPrimary)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("ASMR Visualizer")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    if let startTime = sessionStartTime {
                        Text(formatDuration(Date().timeIntervalSince(startTime)))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.neonPink)
                            .neonGlow(color: Color.neonPink, intensity: 0.6)
                    }
                }
                .padding()
                
                // Сетка триггеров
                GeometryReader { geometry in
                    let columns = 4
                    let rows = 5
                    let spacing: CGFloat = 15
                    let itemWidth = (geometry.size.width - spacing * CGFloat(columns + 1)) / CGFloat(columns)
                    let itemHeight = (geometry.size.height - spacing * CGFloat(rows + 1)) / CGFloat(rows)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                        ForEach(0..<(columns * rows), id: \.self) { index in
                            ASMRTriggerCell(
                                index: index,
                                viewModel: viewModel,
                                size: CGSize(width: itemWidth, height: itemHeight)
                            )
                        }
                    }
                    .padding(spacing)
                }
                
                // Контролы
                VStack(spacing: 16) {
                    // Интенсивность
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Intensity: \(Int(viewModel.intensity * 100))%")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.textSecondary)
                        
                        Slider(value: $viewModel.intensity, in: 0.1...1.0)
                            .tint(Color.neonPink)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.4))
                    )
                    .padding(.horizontal)
                    
                    // Кнопка сброса
                    Button(action: {
                        viewModel.resetAllTriggers()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset All")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.neonPurple.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.neonPurple, lineWidth: 2)
                                        )
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            sessionStartTime = Date()
            sessionViewModel.startSession(mode: .asmr)
        }
        .onDisappear {
            sessionViewModel.endSession()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

class ASMRViewModel: ObservableObject {
    @Published var activeTriggers: Set<Int> = []
    @Published var rippleStates: [Int: Double] = [:]
    @Published var intensity: CGFloat = 0.5
    
    func trigger(index: Int) {
        activeTriggers.insert(index)
        rippleStates[index] = 0.0
        
        // Автоматическое отключение через время
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.activeTriggers.remove(index)
            self.rippleStates.removeValue(forKey: index)
        }
        
        // Обновление ripple анимации
        withAnimation(.easeOut(duration: 2.0)) {
            rippleStates[index] = 1.0
        }
    }
    
    func resetAllTriggers() {
        activeTriggers.removeAll()
        rippleStates.removeAll()
    }
    
    func updateRipples() {
        for index in rippleStates.keys {
            if let currentValue = rippleStates[index], currentValue < 1.0 {
                rippleStates[index] = min(currentValue + 0.05, 1.0)
            }
        }
    }
}

struct ASMRTriggerCell: View {
    let index: Int
    @ObservedObject var viewModel: ASMRViewModel
    let size: CGSize
    
    @State private var localRipple: Double = 0
    
    private var colors: [Color] {
        [Color.neonPink, Color.neonPurple, Color.neonGreen, Color.blue, Color.yellow]
    }
    
    private var color: Color {
        colors[index % colors.count]
    }
    
    private var isActive: Bool {
        viewModel.activeTriggers.contains(index)
    }
    
    var body: some View {
        ZStack {
            // Фон
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(isActive ? 1 : 0.3), lineWidth: 2)
                )
            
            // Ripple эффект
            if isActive {
                ForEach(0..<3) { ring in
                    Circle()
                        .stroke(color.opacity(0.6 - Double(ring) * 0.2), lineWidth: 2)
                        .frame(width: size.width * 0.8, height: size.height * 0.8)
                        .scaleEffect(1.0 + (localRipple + Double(ring) * 0.3))
                        .opacity(1.0 - localRipple - Double(ring) * 0.2)
                }
            }
            
            // Центральный элемент
            Circle()
                .fill(color.opacity(isActive ? 0.6 : 0.2))
                .frame(width: size.width * 0.4, height: size.height * 0.4)
                .scaleEffect(isActive ? 1.2 : 1.0)
                .neonGlow(color: color, intensity: isActive ? viewModel.intensity : 0.3)
        }
        .frame(width: size.width, height: size.height)
        .onTapGesture {
            viewModel.trigger(index: index)
            withAnimation(.easeOut(duration: 2.0)) {
                localRipple = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                localRipple = 0
            }
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            if localRipple > 0 {
                localRipple = max(0, localRipple - 0.02)
            }
        }
    }
}

