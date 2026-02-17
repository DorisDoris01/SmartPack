//
//  MainTabView.swift
//  SmartPack
//
//  [DEPRECATED] v1.2 已弃用，保留以兼容旧引用
//  新主入口为 HomeView
//

import SwiftUI
import SwiftData

/// [DEPRECATED] 请使用 HomeView
/// 此文件保留以兼容可能的旧引用
struct MainTabView: View {
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        // PRD v1.2: 重定向到 HomeView
        HomeView()
    }
}

#Preview {
    MainTabView()
        .environmentObject(LocalizationManager.shared)
        .modelContainer(for: [Trip.self, TripItem.self], inMemory: true)
}
