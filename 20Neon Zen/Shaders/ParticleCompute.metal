//
//  ParticleCompute.metal
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

#include <metal_stdlib>
using namespace metal;

struct Particle {
    float2 position;
    float2 velocity;
    float3 color;
    float size;
    float lifeTime;
    float sourceIndex;
};

struct ParticleSource {
    float2 position;
    float3 color;
    float strength;
    float radius;
    int behaviorType; // 0: gravity, 1: repulsion, 2: attraction, 3: turbulence
    float time;
};

struct ParticleParams {
    float2 canvasSize;
    float gravity;
    float friction;
    float deltaTime;
    int sourceCount;
};

// Вычисление силы гравитации
float2 computeGravity(float2 particlePos, float2 sourcePos, float strength) {
    float2 direction = sourcePos - particlePos;
    float distance = length(direction);
    if (distance < 0.01) return float2(0.0);
    
    float force = strength / (distance * distance + 1.0);
    return normalize(direction) * force;
}

// Вычисление силы отталкивания
float2 computeRepulsion(float2 particlePos, float2 sourcePos, float strength, float radius) {
    float2 direction = particlePos - sourcePos;
    float distance = length(direction);
    
    if (distance > radius) return float2(0.0);
    
    float force = strength * (1.0 - distance / radius);
    return normalize(direction) * force;
}

// Вычисление силы притяжения
float2 computeAttraction(float2 particlePos, float2 sourcePos, float strength, float radius) {
    float2 direction = sourcePos - particlePos;
    float distance = length(direction);
    
    if (distance > radius) return float2(0.0);
    
    float force = strength * (1.0 - distance / radius);
    return normalize(direction) * force;
}

// Вычисление турбулентности
float2 computeTurbulence(float2 particlePos, float time, float strength) {
    float2 turbulence = float2(
        sin(particlePos.x * 0.1 + time) * cos(particlePos.y * 0.1 + time),
        cos(particlePos.x * 0.1 + time) * sin(particlePos.y * 0.1 + time)
    );
    return turbulence * strength;
}

// Основной compute shader для обновления частиц
kernel void updateParticles(
    device Particle* particles [[buffer(0)]],
    constant ParticleSource* sources [[buffer(1)]],
    constant ParticleParams& params [[buffer(2)]],
    uint id [[thread_position_in_grid]]
) {
    if (id >= 1024) return; // Максимальное количество частиц
    
    device Particle& particle = particles[id];
    
    if (particle.lifeTime <= 0.0) return;
    
    // Применяем силы от всех источников
    float2 totalForce = float2(0.0);
    
    for (int i = 0; i < params.sourceCount && i < 10; i++) {
        ParticleSource source = sources[i];
        float2 force = float2(0.0);
        
        switch (source.behaviorType) {
            case 0: // Gravity
                force = computeGravity(particle.position, source.position, source.strength);
                break;
            case 1: // Repulsion
                force = computeRepulsion(particle.position, source.position, source.strength, source.radius);
                break;
            case 2: // Attraction
                force = computeAttraction(particle.position, source.position, source.strength, source.radius);
                break;
            case 3: // Turbulence
                force = computeTurbulence(particle.position, source.time, source.strength);
                break;
        }
        
        totalForce += force;
    }
    
    // Общая гравитация вниз
    totalForce.y += params.gravity;
    
    // Обновляем скорость
    particle.velocity += totalForce * params.deltaTime;
    particle.velocity *= params.friction;
    
    // Ограничиваем максимальную скорость
    float maxSpeed = 50.0;
    float speed = length(particle.velocity);
    if (speed > maxSpeed) {
        particle.velocity = normalize(particle.velocity) * maxSpeed;
    }
    
    // Обновляем позицию
    particle.position += particle.velocity * params.deltaTime;
    
    // Обработка границ экрана
    float halfSize = particle.size * 0.5;
    float minX = halfSize;
    float maxX = params.canvasSize.x - halfSize;
    float minY = halfSize;
    float maxY = params.canvasSize.y - halfSize;
    
    if (particle.position.x < minX) {
        particle.position.x = minX;
        particle.velocity.x *= -0.8;
    } else if (particle.position.x > maxX) {
        particle.position.x = maxX;
        particle.velocity.x *= -0.8;
    }
    
    if (particle.position.y < minY) {
        particle.position.y = minY;
        particle.velocity.y *= -0.8;
    } else if (particle.position.y > maxY) {
        particle.position.y = maxY;
        particle.velocity.y *= -0.8;
    }
    
    // Уменьшаем время жизни
    particle.lifeTime -= params.deltaTime;
}

// Shader для создания новых частиц
kernel void spawnParticles(
    device Particle* particles [[buffer(0)]],
    constant ParticleSource& source [[buffer(1)]],
    constant int& particleCount [[buffer(2)]],
    uint id [[thread_position_in_grid]]
) {
    if (id >= 1) return; // Создаем только одну частицу за раз
    
    // Находим свободный слот для частицы
    int particleIndex = particleCount % 1024;
    device Particle& particle = particles[particleIndex];
    
    // Создаем частицу в позиции источника с небольшим случайным смещением
    float randomAngle = float(particleCount) * 0.618033988749; // Золотое сечение для псевдослучайности
    float randomRadius = 2.0; // Небольшое смещение от центра
    
    particle.position = source.position + float2(cos(randomAngle), sin(randomAngle)) * randomRadius;
    
    // Небольшая случайная начальная скорость
    float speed = 3.0 + float(particleCount % 5) * 0.5;
    particle.velocity = float2(cos(randomAngle), sin(randomAngle)) * speed;
    particle.color = source.color;
    particle.size = 10.0 + float(particleCount % 5) * 2.0;
    particle.lifeTime = 30.0;
    particle.sourceIndex = float(particleCount);
}

