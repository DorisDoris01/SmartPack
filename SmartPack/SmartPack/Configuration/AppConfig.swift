//
//  AppConfig.swift
//  SmartPack
//
//  应用配置 - 集中管理敏感配置信息
//

import Foundation

/// 应用配置
struct AppConfig {
    /// 天气 API Key（从 Info.plist 读取）
    static var weatherAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String else {
            fatalError("WEATHER_API_KEY not found in Info.plist")
        }
        return key
    }
}
