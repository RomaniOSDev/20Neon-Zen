//
//  MetalRenderer.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import Metal
import MetalKit
import SwiftUI
import UIKit

class MetalRenderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var computePipelineState: MTLComputePipelineState?
    
    var vertexBuffer: MTLBuffer!
    var time: Float = 0
    
    // Параметры эффектов
    var glowColor: SIMD3<Float> = SIMD3<Float>(1.0, 0.0, 0.27) // neonPink
    var glowIntensity: Float = 1.0
    var waveAmplitude: Float = 0.02
    var waveFrequency: Float = 10.0
    
    var effectType: EffectType = .neonGlow {
        didSet {
            if oldValue != effectType {
                setupPipeline()
            }
        }
    }
    
    enum EffectType {
        case neonGlow
        case colorTransition
        case waveDistortion
        case particleSystem
        case neonWave
    }
    
    override init() {
        super.init()
        setupMetal()
    }
    
    func setupMetal() {
        // Проверяем доступность Metal
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("❌ Metal не поддерживается на этом устройстве")
            return
        }
        
        print("✅ Metal устройство найдено: \(device.name)")
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        setupPipeline()
        setupVertexBuffer()
    }
    
    func setupPipeline() {
        guard let device = device else { return }
        
        // Загружаем библиотеку шейдеров
        guard let library = device.makeDefaultLibrary() else {
            print("❌ Не удалось загрузить библиотеку шейдеров")
            return
        }
        
        print("✅ Библиотека шейдеров загружена")
        
        // Создаем pipeline для рендеринга
        guard let vertexFunction = library.makeFunction(name: "vertex_main") else {
            print("❌ Не удалось найти vertex_main")
            return
        }
        
        let functionName = effectType.functionName
        guard let fragmentFunction = library.makeFunction(name: functionName) else {
            print("❌ Не удалось найти функцию \(functionName)")
            return
        }
        
        print("✅ Функции шейдеров найдены: vertex_main, \(functionName)")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Настраиваем vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Position attribute
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // TexCoord attribute
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 2
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        // Buffer layout
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 4
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            print("✅ Pipeline создан успешно для эффекта: \(effectType.functionName)")
        } catch {
            print("❌ Ошибка создания pipeline: \(error)")
        }
    }
    
    func setupVertexBuffer() {
        guard let device = device else { return }
        
        // Создаем полноэкранный квад с правильной структурой
        // position (x, y), texCoord (u, v)
        let vertices: [Float] = [
            // Треугольник 1
            -1.0, -1.0,  0.0, 1.0,  // нижний левый
             1.0, -1.0,  1.0, 1.0,  // нижний правый
            -1.0,  1.0,  0.0, 0.0,  // верхний левый
            // Треугольник 2
             1.0, -1.0,  1.0, 1.0,  // нижний правый
             1.0,  1.0,  1.0, 0.0,  // верхний правый
            -1.0,  1.0,  0.0, 0.0   // верхний левый
        ]
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Обработка изменения размера
    }
    
    func draw(in view: MTKView) {
        guard let device = device,
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderPipelineState = renderPipelineState else {
            // Если pipeline не готов, просто очищаем экран
            return
        }
        
        time += 0.016 // ~60 FPS
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Передаем параметры в шейдер
        var timeValue = time
        renderEncoder.setFragmentBytes(&timeValue, length: MemoryLayout<Float>.size, index: 0)
        
        // Передаем параметры в зависимости от типа эффекта
        switch effectType {
        case .neonGlow, .neonWave:
            var glowColorValue = glowColor
            renderEncoder.setFragmentBytes(&glowColorValue, length: MemoryLayout<SIMD3<Float>>.size, index: 1)
            
            var intensityValue = glowIntensity
            renderEncoder.setFragmentBytes(&intensityValue, length: MemoryLayout<Float>.size, index: 2)
            
            if effectType == .neonWave {
                var waveAmplitudeValue = waveAmplitude
                renderEncoder.setFragmentBytes(&waveAmplitudeValue, length: MemoryLayout<Float>.size, index: 3)
            }
            
        case .colorTransition:
            let color1 = SIMD3<Float>(1.0, 0.0, 0.27) // neonPink
            let color2 = SIMD3<Float>(1.0, 0.13, 1.0) // neonPurple
            let color3 = SIMD3<Float>(0.0, 1.0, 0.62) // neonGreen
            
            var color1Value = color1
            var color2Value = color2
            var color3Value = color3
            
            renderEncoder.setFragmentBytes(&color1Value, length: MemoryLayout<SIMD3<Float>>.size, index: 1)
            renderEncoder.setFragmentBytes(&color2Value, length: MemoryLayout<SIMD3<Float>>.size, index: 2)
            renderEncoder.setFragmentBytes(&color3Value, length: MemoryLayout<SIMD3<Float>>.size, index: 3)
            
        case .waveDistortion:
            var waveAmplitudeValue = waveAmplitude
            var waveFrequencyValue = waveFrequency
            renderEncoder.setFragmentBytes(&waveAmplitudeValue, length: MemoryLayout<Float>.size, index: 1)
            renderEncoder.setFragmentBytes(&waveFrequencyValue, length: MemoryLayout<Float>.size, index: 2)
            
        case .particleSystem:
            let particlePos = SIMD2<Float>(0.5, 0.5)
            let particleSizeValue: Float = 0.1
            var particleColorValue = glowColor
            
            var particlePosValue = particlePos
            var particleSize = particleSizeValue
            var particleCount: Int32 = 10
            
            renderEncoder.setFragmentBytes(&particlePosValue, length: MemoryLayout<SIMD2<Float>>.size, index: 1)
            renderEncoder.setFragmentBytes(&particleSize, length: MemoryLayout<Float>.size, index: 2)
            renderEncoder.setFragmentBytes(&particleColorValue, length: MemoryLayout<SIMD3<Float>>.size, index: 3)
            renderEncoder.setFragmentBytes(&particleCount, length: MemoryLayout<Int32>.size, index: 4)
        }
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension MetalRenderer.EffectType {
    var functionName: String {
        switch self {
        case .neonGlow:
            return "neon_glow"
        case .colorTransition:
            return "color_transition"
        case .waveDistortion:
            return "wave_distortion"
        case .particleSystem:
            return "particle_system"
        case .neonWave:
            return "neon_wave"
        }
    }
}

// SwiftUI wrapper для Metal view
struct MetalEffectView: UIViewRepresentable {
    var effectType: MetalRenderer.EffectType
    var glowColor: Color
    var intensity: CGFloat
    var waveAmplitude: CGFloat
    
    func makeUIView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            let fallbackView = MTKView()
            fallbackView.backgroundColor = .black
            return fallbackView
        }
        
        let mtkView = MTKView()
        mtkView.device = device
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
        mtkView.colorPixelFormat = .bgra8Unorm
        
        let renderer = MetalRenderer()
        renderer.effectType = effectType
        
        // Конвертируем цвет
        let uiColor = UIColor(glowColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        renderer.glowColor = SIMD3<Float>(Float(red), Float(green), Float(blue))
        renderer.glowIntensity = Float(intensity)
        renderer.waveAmplitude = Float(waveAmplitude)
        
        mtkView.delegate = renderer
        context.coordinator.renderer = renderer
        context.coordinator.mtkView = mtkView
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else { return }
        
        renderer.effectType = effectType
        let uiColor = UIColor(glowColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        renderer.glowColor = SIMD3<Float>(Float(red), Float(green), Float(blue))
        renderer.glowIntensity = Float(intensity)
        renderer.waveAmplitude = Float(waveAmplitude)
        
        // Убеждаемся, что view не приостановлен
        uiView.isPaused = false
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var renderer: MetalRenderer?
        var mtkView: MTKView?
    }
}

// Fallback для старых устройств без Metal
struct FallbackEffectView: View {
    var effectType: MetalRenderer.EffectType
    var glowColor: Color
    var intensity: CGFloat
    
    @State private var animationPhase: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // CPU-based fallback эффекты
                switch effectType {
                case .neonGlow:
                    NeonGlowFallback(color: glowColor, intensity: intensity, phase: animationPhase)
                case .colorTransition:
                    ColorTransitionFallback(phase: animationPhase)
                case .waveDistortion:
                    WaveDistortionFallback(phase: animationPhase)
                case .particleSystem:
                    ParticleSystemFallback(phase: animationPhase)
                case .neonWave:
                    NeonWaveFallback(color: glowColor, intensity: intensity, phase: animationPhase)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
    }
}

// CPU fallback эффекты
struct NeonGlowFallback: View {
    let color: Color
    let intensity: CGFloat
    let phase: Double
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.8 * intensity),
                        color.opacity(0.4 * intensity),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
            .scaleEffect(1.0 + sin(phase * 2 * .pi) * 0.1)
            .blur(radius: 20)
    }
}

struct ColorTransitionFallback: View {
    let phase: Double
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.neonPink.opacity(0.6),
                Color.neonPurple.opacity(0.6),
                Color.neonGreen.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .hueRotation(.radians(phase * 2 * .pi))
    }
}

struct WaveDistortionFallback: View {
    let phase: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<5) { i in
                Circle()
                    .stroke(Color.neonPink.opacity(0.3), lineWidth: 2)
                    .frame(width: CGFloat(100 + i * 30), height: CGFloat(100 + i * 30))
                    .offset(x: sin(phase * 2 * .pi + Double(i)) * 10,
                           y: cos(phase * 2 * .pi + Double(i)) * 10)
            }
        }
    }
}

struct ParticleSystemFallback: View {
    let phase: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { i in
                ParticleView(index: i, phase: phase)
            }
        }
    }
}

struct ParticleView: View {
    let index: Int
    let phase: Double
    
    private var angle: Double {
        phase * 2 * .pi + Double(index) * 2 * .pi / 10
    }
    
    private var xOffset: CGFloat {
        cos(angle) * 100
    }
    
    private var yOffset: CGFloat {
        sin(angle) * 100
    }
    
    var body: some View {
        Circle()
            .fill(Color.neonPink.opacity(0.6))
            .frame(width: 10, height: 10)
            .offset(x: xOffset, y: yOffset)
    }
}

struct NeonWaveFallback: View {
    let color: Color
    let intensity: CGFloat
    let phase: Double
    
    var body: some View {
        ZStack {
            NeonGlowFallback(color: color, intensity: intensity, phase: phase)
            WaveDistortionFallback(phase: phase)
        }
    }
}

// Умный выбор между Metal и CPU рендерингом
struct OptimizedEffectView: View {
    var effectType: MetalRenderer.EffectType
    var glowColor: Color
    var intensity: CGFloat
    var waveAmplitude: CGFloat
    
    @State private var supportsMetal: Bool = {
        let device = MTLCreateSystemDefaultDevice()
        let supports = device != nil
        print("🔍 Проверка Metal поддержки: \(supports ? "✅ Поддерживается" : "❌ Не поддерживается")")
        return supports
    }()
    
    var body: some View {
        ZStack {
            if supportsMetal {
                MetalEffectView(
                    effectType: effectType,
                    glowColor: glowColor,
                    intensity: intensity,
                    waveAmplitude: waveAmplitude
                )
            } else {
                VStack(spacing: 16) {
                    FallbackEffectView(
                        effectType: effectType,
                        glowColor: glowColor,
                        intensity: intensity
                    )
                    
                    Text("Using CPU Rendering")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                        .padding(.top, 8)
                }
            }
        }
    }
}

