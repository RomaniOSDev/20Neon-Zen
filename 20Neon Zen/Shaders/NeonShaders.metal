//
//  NeonShaders.metal
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// Вершинный шейдер
vertex VertexOut vertex_main(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    out.texCoord = in.texCoord;
    return out;
}

// Неоновое свечение (без текстуры)
fragment float4 neon_glow(VertexOut in [[stage_in]],
                          constant float &time [[buffer(0)]],
                          constant float3 &glowColor [[buffer(1)]],
                          constant float &intensity [[buffer(2)]]) {
    // Вычисляем расстояние от центра
    float2 center = float2(0.5, 0.5);
    float dist = distance(in.texCoord, center);
    
    // Создаем эффект свечения
    float glow = 1.0 - smoothstep(0.0, 0.5, dist);
    glow = pow(glow, 2.0);
    
    // Добавляем пульсацию
    float pulse = sin(time * 2.0) * 0.3 + 0.7;
    
    // Применяем цвет свечения
    float3 glowEffect = glowColor * glow * intensity * pulse;
    
    // Фоновый цвет
    float3 backgroundColor = float3(0.05, 0.05, 0.05);
    
    // Смешиваем с фоном
    float3 finalColor = backgroundColor + glowEffect;
    
    return float4(finalColor, 1.0);
}

// Цветовые переходы (без текстуры)
fragment float4 color_transition(VertexOut in [[stage_in]],
                                constant float &time [[buffer(0)]],
                                constant float3 &color1 [[buffer(1)]],
                                constant float3 &color2 [[buffer(2)]],
                                constant float3 &color3 [[buffer(3)]]) {
    // Создаем градиент на основе времени
    float t = sin(time * 0.5) * 0.5 + 0.5;
    
    // Интерполируем между цветами
    float3 colorA = mix(color1, color2, t);
    float3 colorB = mix(color2, color3, t);
    float3 gradientColor = mix(colorA, colorB, in.texCoord.y);
    
    // Добавляем радиальный градиент
    float2 center = float2(0.5, 0.5);
    float dist = distance(in.texCoord, center);
    float radial = 1.0 - smoothstep(0.0, 0.7, dist);
    
    float3 finalColor = mix(gradientColor * 0.3, gradientColor, radial);
    
    return float4(finalColor, 1.0);
}

// Волновые искажения (без текстуры)
fragment float4 wave_distortion(VertexOut in [[stage_in]],
                               constant float &time [[buffer(0)]],
                               constant float &waveAmplitude [[buffer(1)]],
                               constant float &waveFrequency [[buffer(2)]]) {
    // Создаем волновое искажение координат
    float2 wave = float2(
        sin(in.texCoord.y * waveFrequency + time) * waveAmplitude,
        cos(in.texCoord.x * waveFrequency + time) * waveAmplitude
    );
    
    float2 distortedCoord = in.texCoord + wave;
    
    // Создаем эффект волн
    float wavePattern = sin(distortedCoord.x * waveFrequency + time) * 
                       cos(distortedCoord.y * waveFrequency + time);
    
    // Преобразуем в цвет
    float3 color = float3(0.2, 0.1, 0.3) + float3(wavePattern * 0.5) * float3(1.0, 0.27, 0.44);
    
    return float4(color, 1.0);
}

// Частичная система (particle system) - простой вариант
fragment float4 particle_system(VertexOut in [[stage_in]],
                                constant float &time [[buffer(0)]],
                                constant float2 &particlePosition [[buffer(1)]],
                                constant float &particleSize [[buffer(2)]],
                                constant float3 &particleColor [[buffer(3)]],
                                constant int &particleCount [[buffer(4)]]) {
    float4 color = float4(0.0);
    
    // Простой эффект частиц через математические функции
    float2 center = float2(0.5, 0.5);
    float dist = distance(in.texCoord, center);
    
    // Создаем эффект частиц
    float particle = 0.0;
    for (int i = 0; i < min(particleCount, 10); i++) {
        float angle = float(i) * 2.0 * 3.14159 / float(particleCount) + time;
        float2 pos = center + float2(cos(angle), sin(angle)) * 0.3;
        float pDist = distance(in.texCoord, pos);
        particle += exp(-pDist * 10.0) * (sin(time * 2.0 + float(i)) * 0.5 + 0.5);
    }
    
    color.rgb = particleColor * particle;
    color.a = particle;
    
    return color;
}

// Комбинированный эффект: неоновое свечение + волны (без текстуры)
fragment float4 neon_wave(VertexOut in [[stage_in]],
                         constant float &time [[buffer(0)]],
                         constant float3 &glowColor [[buffer(1)]],
                         constant float &intensity [[buffer(2)]],
                         constant float &waveAmplitude [[buffer(3)]]) {
    // Волновое искажение
    float2 wave = float2(
        sin(in.texCoord.y * 10.0 + time) * waveAmplitude,
        cos(in.texCoord.x * 10.0 + time) * waveAmplitude
    );
    float2 distortedCoord = clamp(in.texCoord + wave, 0.0, 1.0);
    
    // Неоновое свечение
    float2 center = float2(0.5, 0.5);
    float dist = distance(distortedCoord, center);
    float glow = 1.0 - smoothstep(0.0, 0.5, dist);
    glow = pow(glow, 2.0);
    float pulse = sin(time * 2.0) * 0.3 + 0.7;
    float3 glowEffect = glowColor * glow * intensity * pulse;
    
    // Волновой паттерн
    float wavePattern = sin(distortedCoord.x * 10.0 + time) * 
                       cos(distortedCoord.y * 10.0 + time);
    float3 waveEffect = float3(wavePattern * 0.3);
    
    float3 backgroundColor = float3(0.05, 0.05, 0.05);
    float3 finalColor = backgroundColor + glowEffect + waveEffect;
    
    return float4(finalColor, 1.0);
}

