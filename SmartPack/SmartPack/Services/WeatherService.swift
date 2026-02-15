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

    private let forecastURL = "https://api.open-meteo.com/v1/forecast"
    private let geocodingURL = "https://geocoding-api.open-meteo.com/v1/search"

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
        print("🌤️ 获取天气: 城市=\(city), 从 \(startDate) 到 \(endDate)")

        // 步骤 1: 地理编码 - 将城市名称转换为经纬度
        guard let (latitude, longitude) = try? await geocodeCity(city) else {
            print("⚠️ 无法找到城市: \(city)，返回不可用数据")
            return generateUnavailableForecasts(startDate: startDate, endDate: endDate)
        }

        print("🌤️ 城市坐标: \(latitude), \(longitude)")

        // 步骤 2: 获取天气预报
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        let startDateStr = dateFormatter.string(from: startDate)
        let endDateStr = dateFormatter.string(from: endDate)

        print("🌤️ 请求日期范围: \(startDateStr) 到 \(endDateStr)")

        // 构建请求 URL
        let urlString = "\(forecastURL)?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode&timezone=auto&start_date=\(startDateStr)&end_date=\(endDateStr)"

        print("🌤️ API URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }

        // 发送请求
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            // 网络错误，返回不可用数据
            print("⚠️ 网络错误: \(error.localizedDescription)，返回不可用数据")
            return generateUnavailableForecasts(startDate: startDate, endDate: endDate)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("⚠️ 无效的响应格式，返回不可用数据")
            return generateUnavailableForecasts(startDate: startDate, endDate: endDate)
        }

        guard httpResponse.statusCode == 200 else {
            print("⚠️ API 错误 (状态码: \(httpResponse.statusCode))，返回不可用数据")
            return generateUnavailableForecasts(startDate: startDate, endDate: endDate)
        }

        // 解析响应
        let decoder = JSONDecoder()
        let weatherResponse: OpenMeteoResponse
        do {
            weatherResponse = try decoder.decode(OpenMeteoResponse.self, from: data)
        } catch {
            print("⚠️ JSON 解析错误: \(error.localizedDescription)，返回不可用数据")
            return generateUnavailableForecasts(startDate: startDate, endDate: endDate)
        }

        // 转换为 WeatherForecast 数组
        return convertToForecasts(
            response: weatherResponse,
            startDate: startDate,
            endDate: endDate
        )
    }

    /// 地理编码 - 将城市名称转换为经纬度
    private func geocodeCity(_ city: String) async throws -> (Double, Double)? {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw WeatherError.invalidCityName
        }

        let urlString = "\(geocodingURL)?name=\(encodedCity)&count=1&language=en&format=json"
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let geocodingResponse = try decoder.decode(GeocodingResponse.self, from: data)

        guard let firstResult = geocodingResponse.results?.first else {
            return nil
        }

        return (firstResult.latitude, firstResult.longitude)
    }
    
    /// 将 Open-Meteo 响应转换为 WeatherForecast 数组
    private func convertToForecasts(
        response: OpenMeteoResponse,
        startDate: Date,
        endDate: Date
    ) -> [WeatherForecast] {
        let calendar = Calendar.current
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        guard let daily = response.daily else {
            print("🌤️ ⚠️ 未找到每日预报数据")
            return generateUnavailableForecasts(startDate: startDate, endDate: endDate)
        }

        print("🌤️ API 返回了 \(daily.time.count) 天的预报")
        print("🌤️ API 返回的日期: \(daily.time.joined(separator: ", "))")

        // 创建日期到预报的映射
        var forecastMap: [Date: WeatherForecast] = [:]

        // Open-Meteo 提供数组格式的每日预报
        for (index, dateStr) in daily.time.enumerated() {
            print("🌤️ 处理日期: \(dateStr)")

            guard let date = dateFormatter.date(from: dateStr) else {
                continue
            }

            let dayStart = calendar.startOfDay(for: date)

            // 获取该日的天气数据
            guard index < daily.temperatureMax.count,
                  index < daily.temperatureMin.count,
                  index < daily.precipitationProbability.count,
                  index < daily.weathercode.count else {
                continue
            }

            let highTemp = daily.temperatureMax[index]
            let lowTemp = daily.temperatureMin[index]
            let precipProb = daily.precipitationProbability[index]
            let weathercode = daily.weathercode[index]

            let (condition, conditionDesc) = weatherCodeToCondition(weathercode)

            print("🌤️ ✅ 添加日期 \(dateStr): \(lowTemp)°C - \(highTemp)°C")
            let forecast = WeatherForecast(
                date: dayStart,
                highTemp: highTemp,
                lowTemp: lowTemp,
                condition: condition,
                conditionDescription: conditionDesc,
                precipitationChance: precipProb / 100.0,
                icon: weatherCodeToIcon(weathercode)
            )
            forecastMap[dayStart] = forecast
        }

        // 现在为行程中的每一天生成预报（有数据的用真实数据，没有的标记为不可用）
        var allForecasts: [WeatherForecast] = []
        let tripStartDay = calendar.startOfDay(for: startDate)
        let tripEndDay = calendar.startOfDay(for: endDate)
        let daysBetween = calendar.dateComponents([.day], from: tripStartDay, to: tripEndDay).day ?? 0
        let totalDays = daysBetween + 1

        print("🌤️ 行程需要 \(totalDays) 天的数据 (从 \(dateFormatter.string(from: tripStartDay)) 到 \(dateFormatter.string(from: tripEndDay)))")

        for dayOffset in 0..<totalDays {
            guard let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: tripStartDay) else {
                continue
            }

            let dayStart = calendar.startOfDay(for: currentDay)

            if let forecast = forecastMap[dayStart] {
                // 有真实数据
                allForecasts.append(forecast)
            } else {
                // 数据不可用
                print("🌤️ ⚠️ 日期 \(dateFormatter.string(from: currentDay)) 无天气数据，标记为不可用")
                let unavailableForecast = WeatherForecast.unavailable(for: dayStart)
                allForecasts.append(unavailableForecast)
            }
        }

        print("🌤️ 最终返回 \(allForecasts.count) 天的预报 (\(forecastMap.count) 天有数据, \(allForecasts.count - forecastMap.count) 天不可用)")
        return allForecasts
    }

    /// 将 WMO 天气代码转换为条件和描述
    private func weatherCodeToCondition(_ code: Int) -> (String, String) {
        switch code {
        case 0:
            return ("clear", "晴天")
        case 1, 2, 3:
            return ("cloudy", "多云")
        case 45, 48:
            return ("fog", "雾")
        case 51, 53, 55:
            return ("drizzle", "毛毛雨")
        case 61, 63, 65:
            return ("rain", "雨")
        case 66, 67:
            return ("rain", "冻雨")
        case 71, 73, 75:
            return ("snow", "雪")
        case 77:
            return ("snow", "雪粒")
        case 80, 81, 82:
            return ("shower", "阵雨")
        case 85, 86:
            return ("snow", "阵雪")
        case 95:
            return ("thunderstorm", "雷暴")
        case 96, 99:
            return ("thunderstorm", "雷暴伴冰雹")
        default:
            return ("unknown", "未知")
        }
    }

    /// 将 WMO 天气代码转换为图标代码
    private func weatherCodeToIcon(_ code: Int) -> String {
        switch code {
        case 0:
            return "01d"
        case 1, 2, 3:
            return "03d"
        case 45, 48:
            return "50d"
        case 51, 53, 55, 61, 63, 65, 66, 67, 80, 81, 82:
            return "10d"
        case 71, 73, 75, 77, 85, 86:
            return "13d"
        case 95, 96, 99:
            return "11d"
        default:
            return "01d"
        }
    }
    
    /// 生成不可用天气预报（当 API 不可用或无数据时）
    private func generateUnavailableForecasts(startDate: Date, endDate: Date) -> [WeatherForecast] {
        let calendar = Calendar.current
        var forecasts: [WeatherForecast] = []
        let tripStartDay = calendar.startOfDay(for: startDate)
        let tripEndDay = calendar.startOfDay(for: endDate)
        let daysBetween = calendar.dateComponents([.day], from: tripStartDay, to: tripEndDay).day ?? 0
        let totalDays = daysBetween + 1

        for dayOffset in 0..<totalDays {
            guard let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: tripStartDay) else {
                continue
            }

            let forecast = WeatherForecast.unavailable(for: currentDay)
            forecasts.append(forecast)
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
        
        // 检查温度范围（仅使用有效数据）
        let validLowTemps = forecasts.compactMap { $0.lowTemp }
        let validHighTemps = forecasts.compactMap { $0.highTemp }

        guard !validLowTemps.isEmpty && !validHighTemps.isEmpty else {
            // 没有有效温度数据，不进行温度相关的物品调整
            return adjustedItems
        }

        let avgLowTemp = validLowTemps.reduce(0, +) / Double(validLowTemps.count)
        let avgHighTemp = validHighTemps.reduce(0, +) / Double(validHighTemps.count)

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

// MARK: - Open-Meteo API 响应模型

struct OpenMeteoResponse: Codable {
    let daily: DailyForecast?
}

struct DailyForecast: Codable {
    let time: [String]  // 日期数组，格式: "yyyy-MM-dd"
    let temperatureMax: [Double]
    let temperatureMin: [Double]
    let precipitationProbability: [Double]
    let weathercode: [Int]  // WMO 天气代码

    enum CodingKeys: String, CodingKey {
        case time
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
        case precipitationProbability = "precipitation_probability_max"
        case weathercode
    }
}

// MARK: - 地理编码响应模型

struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?
}

struct GeocodingResult: Codable {
    let latitude: Double
    let longitude: Double
    let name: String
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
