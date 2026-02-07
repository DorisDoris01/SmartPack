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
        // 首先尝试从 Info.plist 读取
        if let key = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String,
           !key.isEmpty,
           key != "YOUR_OPENWEATHERMAP_API_KEY" {
            return key
        }
        
        // 如果 Info.plist 中没有，尝试从环境变量读取（用于开发）
        if let key = ProcessInfo.processInfo.environment["WEATHER_API_KEY"],
           !key.isEmpty {
            return key
        }
        
        // 如果都没有，返回空字符串（WeatherService 会处理这种情况）
        print("⚠️ 警告: WEATHER_API_KEY 未配置，天气功能将使用模拟数据")
        return ""
    }
}
