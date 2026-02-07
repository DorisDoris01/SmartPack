//
//  SmartPackApp.swift
//  SmartPack
//
//  智能打包清单 - 基于场景的行李打包助手
//  PRD v1.2: 首次欢迎页 + 清单列表为首页
//

import SwiftUI
import SwiftData

@main
struct SmartPackApp: App {
    @StateObject private var localization = LocalizationManager.shared
    @State private var showWelcome = false
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(localization)
                .onAppear {
                    // 首次启动时显示欢迎页
                    if !localization.hasCompletedOnboarding {
                        showWelcome = true
                    }
                }
                .fullScreenCover(isPresented: $showWelcome) {
                    WelcomeView(isPresented: $showWelcome)
                        .environmentObject(localization)
                        .background(Color.clear)
                        .interactiveDismissDisabled(true)
                }
        }
        .modelContainer(for: Trip.self)
    }
}
