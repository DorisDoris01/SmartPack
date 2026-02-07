//
//  WeatherForecast.swift
//  SmartPack
//
//  天气预报数据模型
//  SPEC: Weather Integration v1.0
//

import Foundation

/// 天气预报
struct WeatherForecast: Codable, Identifiable {
    let id: UUID
    let date: Date
    let highTemp: Double      // 最高温度（摄氏度）
    let lowTemp: Double       // 最低温度（摄氏度）
    let condition: String     // 天气状况（如 "clear", "rain", "cloudy"）
    let conditionDescription: String  // 天气描述（如 "晴天", "小雨"）
    let precipitationChance: Double   // 降水概率（0-1）
    let icon: String          // 天气图标名称（OpenWeatherMap icon code）
    
    init(
        id: UUID = UUID(),
        date: Date,
        highTemp: Double,
        lowTemp: Double,
        condition: String,
        conditionDescription: String,
        precipitationChance: Double,
        icon: String
    ) {
        self.id = id
        self.date = date
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.condition = condition
        self.conditionDescription = conditionDescription
        self.precipitationChance = precipitationChance
        self.icon = icon
    }
    
    /// 根据天气状况返回本地化描述
    func displayCondition(language: AppLanguage) -> String {
        switch language {
        case .chinese:
            return conditionDescription
        case .english:
            return conditionDescription
        }
    }
    
    /// 根据天气状况返回 SF Symbol 名称
    var weatherIcon: String {
        switch condition.lowercased() {
        case "clear", "sunny":
            return "sun.max.fill"
        case "rain", "drizzle", "shower":
            return "cloud.rain.fill"
        case "snow":
            return "cloud.snow.fill"
        case "clouds", "cloudy", "overcast":
            return "cloud.fill"
        case "thunderstorm":
            return "cloud.bolt.fill"
        case "mist", "fog", "haze":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
    
    /// 是否有降水
    var hasPrecipitation: Bool {
        precipitationChance > 0.3
    }
    
    /// 是否需要保暖
    var needsWarmClothing: Bool {
        lowTemp < 10
    }
    
    /// 是否需要防晒
    var needsSunProtection: Bool {
        highTemp > 25 && condition.lowercased().contains("clear")
    }
}
