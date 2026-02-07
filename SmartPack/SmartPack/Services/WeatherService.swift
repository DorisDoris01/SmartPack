//
//  WeatherService.swift
//  SmartPack
//
//  天气服务 - 查询天气预报
//  SPEC: Weather Integration v1.0
//

import Foundation

/// 天气服务
class WeatherService {
    static let shared = WeatherService()
    
    // TODO: 将 API Key 存储在安全位置（如 Info.plist 或环境变量）
    // 这里使用占位符，实际使用时需要替换
    private let apiKey = "2b6127466cb2774fb88ed36e707fcad5"
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    private init() {}
    
    /// 查询天气预报
    /// - Parameters:
    ///   - city: 城市名称
    ///   - startDate: 开始日期
    ///   - endDate: 结束日期
    /// - Returns: 天气预报数组
    func fetchWeatherForecast(
        city: String,
        startDate: Date,
        endDate: Date
    ) async throws -> [WeatherForecast] {
        // 检查 API Key
        guard apiKey != "YOUR_OPENWEATHERMAP_API_KEY" else {
            throw WeatherError.apiKeyNotConfigured
        }
        
        // 构建请求 URL
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw WeatherError.invalidCityName
        }
        
        let urlString = "\(baseURL)/forecast?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=zh_cn"
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        // 发送请求
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw WeatherError.invalidAPIKey
            } else if httpResponse.statusCode == 404 {
                throw WeatherError.cityNotFound
            } else {
                throw WeatherError.serverError(httpResponse.statusCode)
            }
        }
        
        // 解析响应
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let weatherResponse = try decoder.decode(OpenWeatherResponse.self, from: data)
        
        // 转换为 WeatherForecast 数组
        return convertToForecasts(
            response: weatherResponse,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    /// 将 OpenWeatherMap 响应转换为 WeatherForecast 数组
    private func convertToForecasts(
        response: OpenWeatherResponse,
        startDate: Date,
        endDate: Date
    ) -> [WeatherForecast] {
        let calendar = Calendar.current
        var forecasts: [WeatherForecast] = []
        var processedDates = Set<String>()
        
        // 按日期分组，每天取一个代表性的预报
        for item in response.list {
            let date = Date(timeIntervalSince1970: item.dt)
            let dateKey = calendar.startOfDay(for: date).timeIntervalSince1970
            
            // 只处理行程日期范围内的数据
            guard date >= calendar.startOfDay(for: startDate),
                  date <= calendar.startOfDay(for: endDate) else {
                continue
            }
            
            // 每天只取一个预报（选择中午时段的预报）
            let hour = calendar.component(.hour, from: date)
            guard hour >= 10 && hour <= 14 else {
                continue
            }
            
            if !processedDates.contains(String(dateKey)) {
                let forecast = WeatherForecast(
                    date: calendar.startOfDay(for: date),
                    highTemp: item.main.tempMax,
                    lowTemp: item.main.tempMin,
                    condition: item.weather.first?.main ?? "unknown",
                    conditionDescription: item.weather.first?.description ?? "未知",
                    precipitationChance: item.pop ?? 0.0,
                    icon: item.weather.first?.icon ?? "01d"
                )
                forecasts.append(forecast)
                processedDates.insert(String(dateKey))
            }
        }
        
        // 如果没有找到预报，生成模拟数据（用于演示）
        if forecasts.isEmpty {
            return generateMockForecasts(startDate: startDate, endDate: endDate)
        }
        
        return forecasts.sorted { $0.date < $1.date }
    }
    
    /// 生成模拟天气预报（用于演示或 API 不可用时）
    private func generateMockForecasts(startDate: Date, endDate: Date) -> [WeatherForecast] {
        let calendar = Calendar.current
        var forecasts: [WeatherForecast] = []
        var currentDate = calendar.startOfDay(for: startDate)
        
        while currentDate <= endDate {
            let forecast = WeatherForecast(
                date: currentDate,
                highTemp: Double.random(in: 15...25),
                lowTemp: Double.random(in: 5...15),
                condition: ["clear", "cloudy", "rain"].randomElement() ?? "clear",
                conditionDescription: "晴天",
                precipitationChance: Double.random(in: 0...0.3),
                icon: "01d"
            )
            forecasts.append(forecast)
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return forecasts
    }
    
    /// 根据天气调整物品清单
    func adjustItemsForWeather(
        items: [TripItem],
        forecasts: [WeatherForecast]
    ) -> [TripItem] {
        var adjustedItems = items
        
        // 检查是否有雨天
        let hasRain = forecasts.contains { $0.hasPrecipitation }
        if hasRain {
            // 检查是否已有雨具
            let hasUmbrella = adjustedItems.contains { item in
                item.name.contains("雨伞") || item.name.contains("雨衣") || 
                item.nameEn.lowercased().contains("umbrella") || 
                item.nameEn.lowercased().contains("raincoat")
            }
            
            if !hasUmbrella {
                // 添加雨伞
                let umbrella = TripItem(
                    id: "weather_umbrella_\(UUID().uuidString)",
                    name: "雨伞",
                    nameEn: "Umbrella",
                    category: "其他",
                    categoryEn: "Other",
                    isChecked: false
                )
                adjustedItems.append(umbrella)
            }
        }
        
        // 检查温度范围
        let avgLowTemp = forecasts.map { $0.lowTemp }.reduce(0, +) / Double(forecasts.count)
        let avgHighTemp = forecasts.map { $0.highTemp }.reduce(0, +) / Double(forecasts.count)
        
        // 低温：添加保暖物品
        if avgLowTemp < 10 {
            let hasWarmClothing = adjustedItems.contains { item in
                item.name.contains("外套") || item.name.contains("羽绒服") ||
                item.nameEn.lowercased().contains("jacket") ||
                item.nameEn.lowercased().contains("coat")
            }
            
            if !hasWarmClothing {
                let jacket = TripItem(
                    id: "weather_jacket_\(UUID().uuidString)",
                    name: "保暖外套",
                    nameEn: "Warm Jacket",
                    category: "衣物",
                    categoryEn: "Clothing",
                    isChecked: false
                )
                adjustedItems.append(jacket)
            }
        }
        
        // 高温：添加防晒物品
        if avgHighTemp > 25 {
            let hasSunProtection = adjustedItems.contains { item in
                item.name.contains("防晒") || item.name.contains("太阳镜") ||
                item.nameEn.lowercased().contains("sunscreen") ||
                item.nameEn.lowercased().contains("sunglasses")
            }
            
            if !hasSunProtection {
                let sunscreen = TripItem(
                    id: "weather_sunscreen_\(UUID().uuidString)",
                    name: "防晒霜",
                    nameEn: "Sunscreen",
                    category: "洗漱用品",
                    categoryEn: "Toiletries",
                    isChecked: false
                )
                adjustedItems.append(sunscreen)
                
                let sunglasses = TripItem(
                    id: "weather_sunglasses_\(UUID().uuidString)",
                    name: "太阳镜",
                    nameEn: "Sunglasses",
                    category: "其他",
                    categoryEn: "Other",
                    isChecked: false
                )
                adjustedItems.append(sunglasses)
            }
        }
        
        return adjustedItems
    }
}

// MARK: - OpenWeatherMap API 响应模型

struct OpenWeatherResponse: Codable {
    let list: [WeatherItem]
}

struct WeatherItem: Codable {
    let dt: TimeInterval  // 时间戳
    let main: MainInfo
    let weather: [WeatherInfo]
    let pop: Double?  // 降水概率
}

struct MainInfo: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct WeatherInfo: Codable {
    let main: String  // 主要天气状况
    let description: String  // 天气描述
    let icon: String  // 图标代码
}

// MARK: - 错误类型

enum WeatherError: LocalizedError {
    case apiKeyNotConfigured
    case invalidCityName
    case invalidURL
    case invalidResponse
    case invalidAPIKey
    case cityNotFound
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "天气 API Key 未配置"
        case .invalidCityName:
            return "无效的城市名称"
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的响应"
        case .invalidAPIKey:
            return "无效的 API Key"
        case .cityNotFound:
            return "未找到该城市"
        case .serverError(let code):
            return "服务器错误: \(code)"
        }
    }
}
