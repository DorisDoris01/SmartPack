//
//  Trip.swift
//  SmartPack
//
//  行程实例 - SwiftData 持久化模型
//  Refactor v2.0: TripItem 升级为独立 @Model，移除 JSON 序列化
//

import Foundation
import SwiftData

// MARK: - TripItem（独立 SwiftData 模型）

/// 行程中的物品项（SwiftData 持久化）
@Model
final class TripItem {
    var id: String
    var name: String
    var nameEn: String
    var category: String
    var categoryEn: String
    var isChecked: Bool
    var sortOrder: Int

    /// 反向关系：所属行程
    var trip: Trip?

    init(
        id: String,
        name: String,
        nameEn: String,
        category: String,
        categoryEn: String,
        isChecked: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.category = category
        self.categoryEn = categoryEn
        self.isChecked = isChecked
        self.sortOrder = sortOrder
    }

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

// MARK: - Trip（行程主模型）

/// 行程实例（持久化存储）
@Model
final class Trip {
    var id: UUID
    var name: String
    var gender: String
    var duration: String
    var selectedTags: [String]
    var createdAt: Date
    var isArchived: Bool

    // SPEC: Weather Integration v1.0
    var destination: String = ""
    var startDate: Date? = nil
    var endDate: Date? = nil
    var weatherData: Data? = nil

    // 一对多关系：行程包含的物品
    @Relationship(deleteRule: .cascade, inverse: \TripItem.trip)
    var items: [TripItem] = []

    // 持久化的统计计数器（避免每次遍历）
    var checkedItemCount: Int = 0
    var totalItemCount: Int = 0

    // Performance: 缓存已解码的天气数据
    @Transient private var cachedWeather: [WeatherForecast]? = nil

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
        self.createdAt = Date()
        self.isArchived = false
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.weatherData = weatherForecasts.isEmpty ? nil : (try? JSONEncoder().encode(weatherForecasts))

        // 建立关系并初始化计数器
        self.items = items
        self.totalItemCount = items.count
        self.checkedItemCount = items.filter { $0.isChecked }.count
    }

    // MARK: - 统计属性（O(1) 读取，不再遍历）

    /// 已勾选数量
    var checkedCount: Int {
        checkedItemCount
    }

    /// 总物品数
    var totalCount: Int {
        totalItemCount
    }

    /// 完成进度 (0.0 - 1.0)
    var progress: Double {
        guard totalItemCount > 0 else { return 0 }
        return Double(checkedItemCount) / Double(totalItemCount)
    }

    /// 是否全部完成
    var isAllChecked: Bool {
        totalItemCount > 0 && checkedItemCount == totalItemCount
    }

    // MARK: - 物品操作（精确增量更新）

    /// 切换物品勾选状态（增量更新计数器）
    func toggleItem(_ itemId: String) {
        guard let item = items.first(where: { $0.id == itemId }) else { return }
        item.isChecked.toggle()
        checkedItemCount += item.isChecked ? 1 : -1
    }

    /// 重置所有勾选状态
    func resetAllChecks() {
        for item in items {
            item.isChecked = false
        }
        checkedItemCount = 0
    }

    /// 添加物品
    func addItem(_ item: TripItem) {
        items.append(item)
        totalItemCount += 1
        if item.isChecked {
            checkedItemCount += 1
        }
    }

    /// 删除物品
    func removeItem(_ itemId: String) {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        let item = items[index]
        if item.isChecked {
            checkedItemCount -= 1
        }
        items.remove(at: index)
        totalItemCount -= 1
    }

    /// 重新同步计数器（用于数据修复或迁移后校验）
    func recalculateCounts() {
        totalItemCount = items.count
        checkedItemCount = items.filter { $0.isChecked }.count
    }

    // MARK: - 归档操作

    /// 归档行程 (PRD v1.3)
    func archive() {
        isArchived = true
    }

    /// 取消归档
    func unarchive() {
        isArchived = false
    }

    // MARK: - 格式化

    /// 格式化创建日期
    func formattedDate(language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = language == .chinese ? Locale(identifier: "zh_CN") : Locale(identifier: "en_US")
        return formatter.string(from: createdAt)
    }

    // MARK: - Weather Integration

    /// 获取天气预报（带缓存优化）
    var weatherForecasts: [WeatherForecast] {
        get {
            if let cached = cachedWeather {
                return cached
            }
            guard let data = weatherData else { return [] }
            let decoded = (try? JSONDecoder().decode([WeatherForecast].self, from: data)) ?? []
            cachedWeather = decoded
            return decoded
        }
        set {
            weatherData = try? JSONEncoder().encode(newValue)
            cachedWeather = newValue
        }
    }

    /// 是否有天气数据
    var hasWeatherData: Bool {
        !weatherForecasts.isEmpty
    }
}
