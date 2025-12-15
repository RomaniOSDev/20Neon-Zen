//
//  OnboardingView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.neonPink : Color.textSecondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 20)
                
                // Pages
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        title: "Welcome to Neon Zen",
                        description: "Your digital sandbox for relaxation and mindfulness",
                        icon: "sparkles",
                        color: Color.neonPink,
                        pageIndex: 0
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        title: "Interactive Particles",
                        description: "Create beautiful particle effects with multiple touch points. Each finger creates unique colorful particles",
                        icon: "circle.grid.3x3.fill",
                        color: Color.neonPurple,
                        pageIndex: 1
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        title: "Mandala & Breathing",
                        description: "Generate mesmerizing mandalas and follow guided breathing exercises for ultimate relaxation",
                        icon: "wind",
                        color: Color.neonGreen,
                        pageIndex: 2
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.textPrimary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.neonPink.opacity(0.5), lineWidth: 2)
                                    )
                            )
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < 2 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.neonPink)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.neonPink, lineWidth: 2)
                                    )
                            )
                        }
                        .neonGlow(color: Color.neonPink, intensity: 0.8)
                    } else {
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            withAnimation {
                                isPresented = false
                            }
                        }) {
                            HStack {
                                Text("Get Started")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.neonGreen)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.neonGreen, lineWidth: 2)
                                    )
                            )
                        }
                        .neonGlow(color: Color.neonGreen, intensity: 1.0)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let pageIndex: Int
    
    @State private var animationScale: CGFloat = 0.8
    @State private var animationOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                
                Image(systemName: icon)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(color)
                    .scaleEffect(animationScale)
                    .opacity(animationOpacity)
            }
            .neonGlow(color: color, intensity: 1.2)
            
            // Title
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(animationOpacity)
                .neonGlow(color: color, intensity: 0.5)
            
            // Description
            Text(description)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
                .opacity(animationOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animationScale = 1.0
                animationOpacity = 1.0
            }
        }
    }
}



