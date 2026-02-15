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
    let highTemp: Double?     // 最高温度（摄氏度），nil 表示数据不可用
    let lowTemp: Double?      // 最低温度（摄氏度），nil 表示数据不可用
    let condition: String     // 天气状况（如 "clear", "rain", "cloudy", "unavailable"）
    let conditionDescription: String  // 天气描述（如 "晴天", "小雨", "数据不可用"）
    let precipitationChance: Double?  // 降水概率（0-1），nil 表示数据不可用
    let icon: String          // 天气图标名称

    init(
        id: UUID = UUID(),
        date: Date,
        highTemp: Double?,
        lowTemp: Double?,
        condition: String,
        conditionDescription: String,
        precipitationChance: Double?,
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

    /// 天气数据是否可用
    var isAvailable: Bool {
        return highTemp != nil && lowTemp != nil
    }

    /// 创建一个"数据不可用"的天气预报
    static func unavailable(for date: Date, language: AppLanguage = .chinese) -> WeatherForecast {
        let description = language == .chinese ? "数据不可用" : "Not Available"
        return WeatherForecast(
            date: date,
            highTemp: nil,
            lowTemp: nil,
            condition: "unavailable",
            conditionDescription: description,
            precipitationChance: nil,
            icon: "questionmark.circle"
        )
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
        case "unavailable":
            return "questionmark.circle"
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
        guard let chance = precipitationChance else { return false }
        return chance > 0.3
    }

    /// 是否需要保暖
    var needsWarmClothing: Bool {
        guard let temp = lowTemp else { return false }
        return temp < 10
    }

    /// 是否需要防晒
    var needsSunProtection: Bool {
        guard let temp = highTemp else { return false }
        return temp > 25 && condition.lowercased().contains("clear")
    }
}
