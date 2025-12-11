//
//  BreathingGuideView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct BreathingGuideView: View {
    @StateObject private var viewModel = BreathingViewModel()
    @ObservedObject var sessionViewModel: SessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
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
                    
                    Text("Breathing Exercises")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 30, height: 30)
                }
                .padding()
                
                // Центральный круг
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height) * 0.6
                    
                    ZStack {
                        // Внешний круг с пульсацией
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.neonGreen.opacity(0.6), Color.neonGreen.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 8
                            )
                            .frame(width: size, height: size)
                            .scaleEffect(viewModel.circleScale)
                            .blur(radius: 10)
                        
                        // Основной круг
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.neonGreen.opacity(0.3),
                                        Color.neonGreen.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: size / 2
                                )
                            )
                            .frame(width: size, height: size)
                            .scaleEffect(viewModel.circleScale)
                        
                        // Внутренний круг
                        Circle()
                            .stroke(Color.neonGreen, lineWidth: 4)
                            .frame(width: size * 0.7, height: size * 0.7)
                            .scaleEffect(viewModel.circleScale)
                            .neonGlow(color: Color.neonGreen, intensity: viewModel.isRunning ? 1.0 : 0.5)
                        
                        // Текст фазы
                        VStack(spacing: 12) {
                            Text(viewModel.phaseText)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Color.neonGreen)
                                .neonGlow(color: Color.neonGreen, intensity: 1.2)
                            
                            Text("\(Int(viewModel.remainingTime)) sec")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color.textSecondary)
                            
                            Text("Cycle \(viewModel.currentCycle + 1) / \(viewModel.currentExercise.cycles)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                
                // Контролы
                VStack(spacing: 20) {
                    // Выбор упражнения
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.defaultExercises) { exercise in
                                ExerciseButton(
                                    exercise: exercise,
                                    isSelected: viewModel.currentExercise.id == exercise.id
                                ) {
                                    viewModel.selectExercise(exercise)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Кнопки управления
                    HStack(spacing: 20) {
                        if !viewModel.isRunning {
                            Button(action: {
                                viewModel.startExercise()
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Start")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.neonGreen)
                                )
                            }
                            .neonGlow(color: Color.neonGreen, intensity: 1.0)
                        } else {
                            Button(action: {
                                viewModel.pauseExercise()
                            }) {
                                HStack {
                                    Image(systemName: "pause.fill")
                                    Text("Pause")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.neonPink.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.neonPink, lineWidth: 2)
                                        )
                                )
                            }
                            
                            Button(action: {
                                viewModel.stopExercise()
                            }) {
                                HStack {
                                    Image(systemName: "stop.fill")
                                    Text("Stop")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.black.opacity(0.4))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.textSecondary, lineWidth: 2)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Описание упражнения
                    if !viewModel.currentExercise.description.isEmpty {
                        Text(viewModel.currentExercise.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            sessionViewModel.startSession(mode: .breathing)
        }
        .onDisappear {
            sessionViewModel.endSession()
        }
    }
}

struct ExerciseButton: View {
    let exercise: BreathingExercise
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .black : Color.textPrimary)
                
                Text("\(Int(exercise.inhaleTime))-\(Int(exercise.holdTime))-\(Int(exercise.exhaleTime))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .black.opacity(0.7) : Color.textSecondary)
            }
            .frame(width: 140)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.neonGreen : Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.neonGreen.opacity(isSelected ? 1 : 0.5), lineWidth: 2)
                    )
            )
        }
        .neonGlow(color: Color.neonGreen, intensity: isSelected ? 0.8 : 0.3)
    }
}

