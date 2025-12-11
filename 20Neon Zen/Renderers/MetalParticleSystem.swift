//
//  MetalParticleSystem.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import Metal
import MetalKit
import SwiftUI
import simd
import Combine

struct MetalParticle {
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
    var color: SIMD3<Float>
    var size: Float
    var lifeTime: Float
    var sourceIndex: Float
}

struct ParticleSource {
    var position: SIMD2<Float>
    var color: SIMD3<Float>
    var strength: Float
    var radius: Float
    var behaviorType: Int32
    var time: Float
}

enum ParticleBehavior: Int32, CaseIterable {
    case gravity = 0
    case repulsion = 1
    case attraction = 2
    case turbulence = 3
    
    var displayName: String {
        switch self {
        case .gravity: return "Gravity"
        case .repulsion: return "Repulsion"
        case .attraction: return "Attraction"
        case .turbulence: return "Turbulence"
        }
    }
}

class MetalParticleSystem: ObservableObject {
    var device: MTLDevice?
    private var commandQueue: MTLCommandQueue!
    private var computePipelineState: MTLComputePipelineState!
    private var spawnPipelineState: MTLComputePipelineState!
    
    private var particleBuffer: MTLBuffer!
    private var sourceBuffer: MTLBuffer!
    private var paramsBuffer: MTLBuffer!
    
    @Published var particleCount: Int = 0
    @Published var sources: [ParticleSource] = []
    
    private var lastUpdateTime: CFTimeInterval = 0
    private let maxParticles = 1024
    
    var behaviorType: ParticleBehavior = .gravity
    var gravity: Float = 0.5
    var friction: Float = 0.98
    
    init() {
        setupMetal()
    }
    
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal not supported")
            return
        }
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        setupPipelines()
        setupBuffers()
    }
    
    private func setupPipelines() {
        guard let device = device,
              let library = device.makeDefaultLibrary() else {
            print("Failed to setup Metal pipelines")
            return
        }
        
        // Pipeline для обновления частиц
        guard let updateFunction = library.makeFunction(name: "updateParticles") else {
            print("Failed to find updateParticles function")
            return
        }
        
        do {
            computePipelineState = try device.makeComputePipelineState(function: updateFunction)
        } catch {
            print("Failed to create compute pipeline: \(error)")
        }
        
        // Pipeline для создания частиц
        guard let spawnFunction = library.makeFunction(name: "spawnParticles") else {
            print("Failed to find spawnParticles function")
            return
        }
        
        do {
            spawnPipelineState = try device.makeComputePipelineState(function: spawnFunction)
        } catch {
            print("Failed to create spawn pipeline: \(error)")
        }
    }
    
    private func setupBuffers() {
        guard let device = device else { return }
        
        // Буфер для частиц
        let particleData = Array(repeating: MetalParticle(
            position: SIMD2<Float>(0, 0),
            velocity: SIMD2<Float>(0, 0),
            color: SIMD3<Float>(1, 0, 0.27),
            size: 10,
            lifeTime: 0,
            sourceIndex: 0
        ), count: maxParticles)
        
        particleBuffer = device.makeBuffer(
            bytes: particleData,
            length: MemoryLayout<MetalParticle>.stride * maxParticles,
            options: .storageModeShared
        )
        
        // Буфер для источников
        sourceBuffer = device.makeBuffer(
            length: MemoryLayout<ParticleSource>.stride * 10,
            options: .storageModeShared
        )
        
        // Буфер для параметров
        var params = ParticleParams(
            canvasSize: SIMD2<Float>(1000, 1000),
            gravity: gravity,
            friction: friction,
            deltaTime: 0.016,
            sourceCount: 0
        )
        
        paramsBuffer = device.makeBuffer(
            bytes: &params,
            length: MemoryLayout<ParticleParams>.size,
            options: .storageModeShared
        )
    }
    
    func addSource(at position: CGPoint, color: Color, behavior: ParticleBehavior) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let source = ParticleSource(
            position: SIMD2<Float>(Float(position.x), Float(position.y)),
            color: SIMD3<Float>(Float(red), Float(green), Float(blue)),
            strength: 100.0,
            radius: 200.0,
            behaviorType: behavior.rawValue,
            time: 0
        )
        
        sources.append(source)
        
        // Ограничиваем количество источников
        if sources.count > 10 {
            sources.removeFirst()
        }
        
        // Создаем частицу только если указано (по умолчанию true для обратной совместимости)
        spawnParticles(from: source)
    }
    
    func addSource(at position: CGPoint, color: Color, behavior: ParticleBehavior, spawnParticle: Bool) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let source = ParticleSource(
            position: SIMD2<Float>(Float(position.x), Float(position.y)),
            color: SIMD3<Float>(Float(red), Float(green), Float(blue)),
            strength: 100.0,
            radius: 200.0,
            behaviorType: behavior.rawValue,
            time: 0
        )
        
        sources.append(source)
        
        // Ограничиваем количество источников
        if sources.count > 10 {
            sources.removeFirst()
        }
        
        // Создаем частицу только если указано
        if spawnParticle {
            spawnParticles(from: source)
        }
    }
    
    func removeSource(at position: CGPoint, threshold: CGFloat = 50) {
        sources.removeAll { source in
            let distance = sqrt(
                pow(CGFloat(source.position.x) - position.x, 2) +
                pow(CGFloat(source.position.y) - position.y, 2)
            )
            return distance < threshold
        }
    }
    
    func updateSources(positions: [CGPoint]) {
        // Обновляем позиции существующих источников
        for (index, position) in positions.enumerated() {
            if index < sources.count {
                sources[index].position = SIMD2<Float>(Float(position.x), Float(position.y))
                sources[index].time += 0.016
            }
        }
    }
    
    func spawnParticle(from source: ParticleSource) {
        spawnParticles(from: source)
    }
    
    private func spawnParticles(from source: ParticleSource) {
        guard let device = device,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        // Обновляем буфер источника
        let sourcePointer = sourceBuffer.contents().bindMemory(
            to: ParticleSource.self,
            capacity: 1
        )
        sourcePointer.pointee = source
        
        var count = particleCount
        let countBuffer = device.makeBuffer(bytes: &count, length: MemoryLayout<Int>.stride, options: [])
        
        computeEncoder.setComputePipelineState(spawnPipelineState)
        computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(sourceBuffer, offset: 0, index: 1)
        computeEncoder.setBuffer(countBuffer, offset: 0, index: 2)
        
        // Создаем только одну частицу за раз
        let threadgroupSize = MTLSize(width: 1, height: 1, depth: 1)
        let threadgroupCount = MTLSize(width: 1, height: 1, depth: 1)
        
        computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        particleCount = min(particleCount + 1, maxParticles)
    }
    
    func update(canvasSize: CGSize) {
        guard device != nil, commandQueue != nil else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = Float(currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        // Обновляем параметры
        var params = ParticleParams(
            canvasSize: SIMD2<Float>(Float(canvasSize.width), Float(canvasSize.height)),
            gravity: gravity,
            friction: friction,
            deltaTime: deltaTime > 0 ? deltaTime : 0.016,
            sourceCount: Int32(sources.count)
        )
        
        let paramsPointer = paramsBuffer.contents().bindMemory(
            to: ParticleParams.self,
            capacity: 1
        )
        paramsPointer.pointee = params
        
        // Обновляем буфер источников
        if !sources.isEmpty {
            let sourcesPointer = sourceBuffer.contents().bindMemory(
                to: ParticleSource.self,
                capacity: sources.count
            )
            for (index, source) in sources.enumerated() {
                sourcesPointer[index] = source
            }
        }
        
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(sourceBuffer, offset: 0, index: 1)
        computeEncoder.setBuffer(paramsBuffer, offset: 0, index: 2)
        
        let threadgroupSize = MTLSize(
            width: computePipelineState.threadExecutionWidth,
            height: 1,
            depth: 1
        )
        let threadgroupCount = MTLSize(
            width: (maxParticles + threadgroupSize.width - 1) / threadgroupSize.width,
            height: 1,
            depth: 1
        )
        
        computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // Подсчитываем живые частицы
        updateParticleCount()
    }
    
    private func updateParticleCount() {
        let particles = particleBuffer.contents().bindMemory(
            to: MetalParticle.self,
            capacity: maxParticles
        )
        
        var count = 0
        for i in 0..<maxParticles {
            if particles[i].lifeTime > 0 {
                count += 1
            }
        }
        
        particleCount = count
    }
    
    func getParticles() -> [MetalParticle] {
        guard let buffer = particleBuffer else { return [] }
        
        let particles = buffer.contents().bindMemory(
            to: MetalParticle.self,
            capacity: maxParticles
        )
        
        var result: [MetalParticle] = []
        for i in 0..<maxParticles {
            if particles[i].lifeTime > 0 {
                result.append(particles[i])
            }
        }
        
        return result
    }
    
    func clearParticles() {
        particleCount = 0
        sources.removeAll()
        
        // Сбрасываем буфер частиц
        let particles = particleBuffer.contents().bindMemory(
            to: MetalParticle.self,
            capacity: maxParticles
        )
        
        for i in 0..<maxParticles {
            particles[i].lifeTime = 0
        }
    }
}

struct ParticleParams {
    var canvasSize: SIMD2<Float>
    var gravity: Float
    var friction: Float
    var deltaTime: Float
    var sourceCount: Int32
    
    static var stride: Int {
        return MemoryLayout<SIMD2<Float>>.stride +
               MemoryLayout<Float>.stride * 3 +
               MemoryLayout<Int32>.stride
    }
}

