//
//  MandalaGeneratorView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct MandalaGeneratorView: View {
    @StateObject private var viewModel = MandalaViewModel()
    @ObservedObject var sessionViewModel: SessionViewModel
    @State private var selectedComplexity: Int = 3
    @State private var selectedSymmetry: SymmetryType = .radial
    @State private var selectedAnimation: AnimationType = .rotation
    @State private var selectedColors: [Color] = [Color.neonPink, Color.neonPurple, Color.neonGreen]
    @State private var mandalaSize: CGSize = .zero
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
                    
                    Text("Mandala")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 30, height: 30)
                }
                .padding()
                
                // Центральная мандала
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height) * 0.7
                    
                    MandalaShape(
                        complexity: viewModel.currentPattern.complexity,
                        symmetry: viewModel.currentPattern.symmetryType,
                        colors: selectedColors,
                        rotation: viewModel.rotationAngle,
                        scale: viewModel.scale,
                        function: viewModel.selectedFunction
                    )
                    .frame(width: size, height: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                mandalaSize = geo.size
                            }
                            .onChange(of: geo.size) { newSize in
                                mandalaSize = newSize
                            }
                    }
                )
                
                // Контролы
                ScrollView {
                    VStack(spacing: 20) {
                        // Сложность
                        ControlSection(title: "Complexity") {
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { level in
                                    Button(action: {
                                        selectedComplexity = level
                                        updatePattern()
                                    }) {
                                        Text("\(level)")
                                            .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(selectedComplexity == level ? .black : Color.textPrimary)
                                            .frame(width: 50, height: 50)
                                            .background(
                                                Circle()
                                                    .fill(selectedComplexity == level ? Color.neonPink : Color.black.opacity(0.4))
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.neonPink.opacity(0.5), lineWidth: 2)
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Симметрия
                        ControlSection(title: "Symmetry") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(SymmetryType.allCases, id: \.self) { symmetry in
                                        Button(action: {
                                            selectedSymmetry = symmetry
                                            updatePattern()
                                        }) {
                                            Text(symmetry.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedSymmetry == symmetry ? .black : Color.textPrimary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(selectedSymmetry == symmetry ? Color.neonPurple : Color.black.opacity(0.4))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(Color.neonPurple.opacity(0.5), lineWidth: 2)
                                                        )
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Анимация
                        ControlSection(title: "Animation") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(AnimationType.allCases, id: \.self) { animation in
                                        Button(action: {
                                            selectedAnimation = animation
                                            updatePattern()
                                        }) {
                                            Text(animation.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedAnimation == animation ? .black : Color.textPrimary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(selectedAnimation == animation ? Color.neonGreen : Color.black.opacity(0.4))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(Color.neonGreen.opacity(0.5), lineWidth: 2)
                                                        )
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Математическая функция
                        ControlSection(title: "Function") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(MandalaFunction.allCases, id: \.self) { funcType in
                                        Button(action: {
                                            viewModel.selectedFunction = funcType
                                        }) {
                                            Text(funcType.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(viewModel.selectedFunction == funcType ? .black : Color.textPrimary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(viewModel.selectedFunction == funcType ? Color.neonPink : Color.black.opacity(0.4))
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
                        
                        // Цвета
                        ControlSection(title: "Colors") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach([Color.neonPink, .neonPurple, .neonGreen, .blue, .yellow], id: \.self) { color in
                                        Button(action: {
                                            if let index = selectedColors.firstIndex(of: color) {
                                                selectedColors.remove(at: index)
                                            } else {
                                                selectedColors.append(color)
                                            }
                                            updatePattern()
                                        }) {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Circle()
                                                        .stroke(.white.opacity(0.5), lineWidth: selectedColors.contains(color) ? 3 : 0)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            sessionViewModel.startSession(mode: .mandala)
        }
        .onDisappear {
            sessionViewModel.endSession()
        }
    }
    
    private func updatePattern() {
        let colorStrings = selectedColors.map { $0.toHex() }
        viewModel.generatePattern(
            complexity: selectedComplexity,
            symmetry: selectedSymmetry,
            colors: colorStrings,
            animation: selectedAnimation
        )
    }
}

struct ControlSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.neonPink.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct MandalaShape: View {
    let complexity: Int
    let symmetry: SymmetryType
    let colors: [Color]
    let rotation: Double
    let scale: CGFloat
    let function: MandalaFunction
    
    private var symmetryOrder: Int {
        symmetry.symmetryOrder
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let maxRadius = min(geometry.size.width, geometry.size.height) / 2
            let layersCount = complexity * 3
            
            ZStack {
                ForEach(0..<layersCount, id: \.self) { layer in
                    MandalaMathematicalLayer(
                        layer: layer,
                        layersCount: layersCount,
                        symmetryOrder: symmetryOrder,
                        center: center,
                        maxRadius: maxRadius,
                        rotation: rotation,
                        scale: scale,
                        colors: colors,
                        function: function
                    )
                }
            }
            .scaleEffect(scale)
        }
    }
}

struct MandalaMathematicalLayer: View {
    let layer: Int
    let layersCount: Int
    let symmetryOrder: Int
    let center: CGPoint
    let maxRadius: CGFloat
    let rotation: Double
    let scale: CGFloat
    let colors: [Color]
    let function: MandalaFunction
    
    private var layerProgress: Double {
        Double(layer) / Double(layersCount)
    }
    
    private var layerRadius: CGFloat {
        maxRadius * CGFloat(layerProgress * 0.9 + 0.1)
    }
    
    var body: some View {
        ForEach(0..<symmetryOrder, id: \.self) { segment in
            MandalaMathematicalSegment(
                segment: segment,
                symmetryOrder: symmetryOrder,
                layer: layer,
                layerProgress: layerProgress,
                center: center,
                baseRadius: layerRadius,
                rotation: rotation,
                color: colors[(layer + segment) % colors.count],
                function: function
            )
        }
    }
}

struct MandalaMathematicalSegment: View {
    let segment: Int
    let symmetryOrder: Int
    let layer: Int
    let layerProgress: Double
    let center: CGPoint
    let baseRadius: CGFloat
    let rotation: Double
    let color: Color
    let function: MandalaFunction
    
    private var baseAngle: Double {
        Double(segment) * 2 * .pi / Double(symmetryOrder) + rotation * .pi / 180
    }
    
    private func calculateRadius(angle: Double) -> CGFloat {
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 2 * .pi)
        let n = Double(symmetryOrder)
        
        switch function {
        case .rose:
            // Роза: r = a * cos(k * θ)
            let k = n / 2.0
            let radius = baseRadius * (0.5 + 0.5 * cos(k * normalizedAngle))
            return max(baseRadius * 0.2, radius)
            
        case .spiral:
            // Спираль: r = a * θ
            let spiralRadius = baseRadius * (0.3 + 0.7 * (normalizedAngle / (2 * .pi)))
            return spiralRadius
            
        case .flower:
            // Цветок: r = a * (1 + cos(n * θ))
            let flowerRadius = baseRadius * (0.4 + 0.6 * (1 + cos(n * normalizedAngle)) / 2)
            return flowerRadius
            
        case .geometric:
            // Геометрическая: многоугольники с закругленными углами
            let geometricRadius = baseRadius * (0.6 + 0.4 * cos(n * normalizedAngle))
            return geometricRadius
            
        case .wave:
            // Волна: r = a * (1 + sin(n * θ))
            let waveRadius = baseRadius * (0.5 + 0.5 * sin(n * normalizedAngle))
            return waveRadius
            
        case .fractal:
            // Фрактальная структура
            let fractalRadius = baseRadius * (0.3 + 0.7 * sin(n * normalizedAngle) * cos(n * normalizedAngle * 2))
            return abs(fractalRadius)
        }
    }
    
    var body: some View {
        Path { path in
            let points = generatePoints()
            guard !points.isEmpty else { return }
            
            path.move(to: center)
            
            for i in 0..<points.count {
                if i == 0 {
                    path.move(to: points[i])
                } else {
                    path.addLine(to: points[i])
                }
            }
            
            path.closeSubpath()
        }
        .fill(color.opacity(0.6))
        .overlay(
            Path { path in
                let points = generatePoints()
                guard !points.isEmpty else { return }
                
                path.move(to: center)
                for i in 0..<points.count {
                    if i == 0 {
                        path.move(to: points[i])
                    } else {
                        path.addLine(to: points[i])
                    }
                }
                path.closeSubpath()
            }
            .stroke(color, lineWidth: 2)
        )
    }
    
    private func generatePoints() -> [CGPoint] {
        let segmentAngle = 2 * .pi / Double(symmetryOrder)
        let startAngle = baseAngle
        let endAngle = startAngle + segmentAngle
        let pointCount = 20
        
        var points: [CGPoint] = []
        
        for i in 0...pointCount {
            let t = Double(i) / Double(pointCount)
            let angle = startAngle + t * (endAngle - startAngle)
            let radius = calculateRadius(angle: angle)
            
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
}

