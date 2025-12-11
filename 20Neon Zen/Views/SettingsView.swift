//
//  SettingsView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingPolicy = false
    @State private var showingTerms = false
    @State private var showingMetalDemo = false
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
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
                        
                        Text("Settings")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.textPrimary)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 30, height: 30)
                    }
                    .padding()
                    
                    // Основные настройки
                    VStack(spacing: 16) {
                        SettingsSection(title: "About") {
                            VStack(spacing: 12) {
                                SettingsRow(
                                    icon: "info.circle.fill",
                                    title: "Version",
                                    value: getAppVersion(),
                                    color: Color.neonGreen
                                )
                                
                                SettingsRow(
                                    icon: "star.fill",
                                    title: "Rate App",
                                    color: Color.neonPink,
                                    action: {
                                        rateApp()
                                    }
                                )
                            }
                        }
                        
                        // Обязательные кнопки
                        SettingsSection(title: "Legal") {
                            VStack(spacing: 12) {
                                SettingsRow(
                                    icon: "doc.text.fill",
                                    title: "Privacy Policy",
                                    color: Color.neonPurple,
                                    action: {
                                        if let url = URL(string: "https://www.termsfeed.com/live/15a51003-f257-40cb-acf0-51670fbf0c1f") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "doc.text.magnifyingglass",
                                    title: "Terms of Use",
                                    color: Color.neonGreen,
                                    action: {
                                        if let url = URL(string: "https://www.termsfeed.com/live/68341dfa-ecb4-427e-b782-36c5bee1c209") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                            }
                        }
                        
                        // Дополнительные настройки
                        SettingsSection(title: "Additional") {
                            VStack(spacing: 12) {
                                SettingsRow(
                                    icon: "sparkles",
                                    title: "Metal Effects",
                                    color: Color.neonGreen,
                                    action: {
                                        showingMetalDemo = true
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "trash.fill",
                                    title: "Clear Data",
                                    color: Color.neonPink,
                                    action: {
                                        clearAllData()
                                    }
                                )
                                
                                SettingsRow(
                                    icon: "arrow.clockwise",
                                    title: "Reset Statistics",
                                    color: Color.neonPurple,
                                    action: {
                                        resetStatistics()
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showingMetalDemo) {
            MetalEffectsDemoView()
        }
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func clearAllData() {
        // Очистка данных приложения
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    private func resetStatistics() {
        // Сброс статистики сессий
        UserDefaults.standard.removeObject(forKey: "zen_sessions")
        UserDefaults.standard.synchronize()
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.textPrimary)
                .padding(.horizontal, 4)
            
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.neonPink.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 30)
                    .neonGlow(color: color, intensity: 0.6)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.textSecondary)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.textSecondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Экран политики конфиденциальности
struct PolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Privacy Policy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.textPrimary)
                            .padding(.bottom, 10)
                        
                        Text("Last updated: \(formatDate(Date()))")
                            .font(.system(size: 14))
                            .foregroundColor(Color.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            PolicySection(
                                title: "1. Information Collection",
                                content: "Neon Zen app collects minimal information necessary for operation. We do not collect personal user data without explicit consent."
                            )
                            
                            PolicySection(
                                title: "2. Data Usage",
                                content: "Collected data is used solely to improve app functionality and provide relaxation session statistics."
                            )
                            
                            PolicySection(
                                title: "3. Data Storage",
                                content: "All data is stored locally on your device. We do not share data with third parties."
                            )
                            
                            PolicySection(
                                title: "4. Your Rights",
                                content: "You have the right to delete the app and all associated data at any time."
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color.neonPink)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.neonPink)
            
            Text(content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.textPrimary)
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
        )
    }
}

// Экран условий использования
struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Terms of Use")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.textPrimary)
                            .padding(.bottom, 10)
                        
                        Text("Last updated: \(formatDate(Date()))")
                            .font(.system(size: 14))
                            .foregroundColor(Color.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            PolicySection(
                                title: "1. Acceptance of Terms",
                                content: "By using Neon Zen app, you agree to these terms of use. If you do not agree with the terms, please do not use the app."
                            )
                            
                            PolicySection(
                                title: "2. App Usage",
                                content: "The app is intended for personal use for relaxation and meditation purposes. Commercial use without permission is prohibited."
                            )
                            
                            PolicySection(
                                title: "3. Intellectual Property",
                                content: "All app materials, including design, code, and content, are protected by copyright and belong to the developers."
                            )
                            
                            PolicySection(
                                title: "4. Limitation of Liability",
                                content: "Developers are not responsible for any consequences of app usage. The app is provided \"as is\" without any warranties."
                            )
                            
                            PolicySection(
                                title: "5. Changes to Terms",
                                content: "We reserve the right to change these terms at any time. Continued use of the app after changes means you agree to the new terms."
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color.neonPink)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

