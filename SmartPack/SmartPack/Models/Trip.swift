//
//  Trip.swift
//  SmartPack
//
//  行程实例 - SwiftData 持久化模型
//  PRD v1.3: 新增 isArchived 归档字段
//

import Foundation
import SwiftData

/// 行程中的物品项
struct TripItem: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let nameEn: String
    let category: String
    let categoryEn: String
    var isChecked: Bool
    
    func displayName(language: AppLanguage) -> String {
        switch language {
        case .chinese: return name
        case .english: return nameEn
        }
    }
    
    func displayCategory(language: AppLanguage) -> String {
        switch language {
        case .chinese: return category
        case .english: return categoryEn
        }
    }
}

/// 行程实例（持久化存储）
@Model
final class Trip {
    var id: UUID
    var name: String
    var gender: String  // Gender.rawValue
    var duration: String  // TripDuration.rawValue
    var selectedTags: [String]
    var itemsData: Data  // [TripItem] 序列化
    var createdAt: Date
    var isArchived: Bool  // PRD v1.3: 归档状态
    // SPEC: Weather Integration v1.0
    var destination: String = ""  // 目的地
    var startDate: Date? = nil   // 出发日期
    var endDate: Date? = nil     // 返回日期
    var weatherData: Data? = nil  // 天气数据（序列化的 [WeatherForecast]）
    
    init(
        name: String,
        gender: Gender,
        duration: TripDuration,
        selectedTags: [String],
        items: [TripItem],
        destination: String = "",
        startDate: Date? = nil,
        endDate: Date? = nil,
        weatherForecasts: [WeatherForecast] = []
    ) {
        self.id = UUID()
        self.name = name
        self.gender = gender.rawValue
        self.duration = duration.rawValue
        self.selectedTags = selectedTags
        self.itemsData = (try? JSONEncoder().encode(items)) ?? Data()
        self.createdAt = Date()
        self.isArchived = false
        // SPEC: Weather Integration v1.0
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.weatherData = (try? JSONEncoder().encode(weatherForecasts)) ?? nil
    }
    
    /// 获取物品列表
    var items: [TripItem] {
        get {
            (try? JSONDecoder().decode([TripItem].self, from: itemsData)) ?? []
        }
        set {
            itemsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    /// 已勾选数量
    var checkedCount: Int {
        items.filter { $0.isChecked }.count
    }
    
    /// 总物品数
    var totalCount: Int {
        items.count
    }
    
    /// 完成进度 (0.0 - 1.0)
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(checkedCount) / Double(totalCount)
    }
    
    /// 是否全部完成
    var isAllChecked: Bool {
        totalCount > 0 && checkedCount == totalCount
    }
    
    /// 切换物品勾选状态
    func toggleItem(_ itemId: String) {
        var currentItems = items
        if let index = currentItems.firstIndex(where: { $0.id == itemId }) {
            currentItems[index].isChecked.toggle()
            items = currentItems
        }
    }
    
    /// 重置所有勾选状态（一键清空）
    func resetAllChecks() {
        var currentItems = items
        for index in currentItems.indices {
            currentItems[index].isChecked = false
        }
        items = currentItems
    }
    
    /// 归档行程 (PRD v1.3)
    func archive() {
        isArchived = true
    }
    
    /// 取消归档
    func unarchive() {
        isArchived = false
    }
    
    /// 格式化创建日期
    func formattedDate(language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = language == .chinese ? Locale(identifier: "zh_CN") : Locale(identifier: "en_US")
        return formatter.string(from: createdAt)
    }
    
    // MARK: - SPEC: Weather Integration v1.0
    
    /// 获取天气预报
    var weatherForecasts: [WeatherForecast] {
        get {
            guard let data = weatherData else { return [] }
            return (try? JSONDecoder().decode([WeatherForecast].self, from: data)) ?? []
        }
        set {
            weatherData = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// 是否有天气数据
    var hasWeatherData: Bool {
        !weatherForecasts.isEmpty
    }
}
