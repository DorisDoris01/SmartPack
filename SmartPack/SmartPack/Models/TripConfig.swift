//
//  TripConfig.swift
//  SmartPack
//
//  行程配置数据模型
//

import Foundation

/// 性别
enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "male"
    case female = "female"
    
    var id: String { rawValue }
    
    var nameCN: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        }
    }
    
    var nameEN: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
    
    func displayName(language: AppLanguage) -> String {
        switch language {
        case .chinese: return nameCN
        case .english: return nameEN
        }
    }
    
    var icon: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        }
    }
}

/// 出行时长（保留用于 Trip 模型兼容性）
enum TripDuration: String, CaseIterable, Identifiable, Codable {
    case short = "short"        // 3天以内
    case medium = "medium"      // 3-7天
    case long = "long"          // 7-14天
    case extraLong = "extraLong" // 14天以上
    
    var id: String { rawValue }
    
    var nameCN: String {
        switch self {
        case .short: return "短途（3天以内）"
        case .medium: return "中途（3-7天）"
        case .long: return "长途（7-14天）"
        case .extraLong: return "极长途（14天以上）"
        }
    }
    
    var nameEN: String {
        switch self {
        case .short: return "Short (≤3 days)"
        case .medium: return "Medium (3-7 days)"
        case .long: return "Long (7-14 days)"
        case .extraLong: return "Extra Long (14+ days)"
        }
    }
    
    func displayName(language: AppLanguage) -> String {
        switch language {
        case .chinese: return nameCN
        case .english: return nameEN
        }
    }
    
    var icon: String {
        switch self {
        case .short: return "hare"
        case .medium: return "figure.walk"
        case .long: return "airplane"
        case .extraLong: return "globe.asia.australia"
        }
    }
}

/// 出行时间（日期范围，用于计算行程天数）
struct TripDateRange: Codable {
    var startDate: Date
    var endDate: Date
    
    /// 计算行程天数
    var dayCount: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(1, (components.day ?? 0) + 1) // 至少1天
    }
    
    /// 转换为 TripDuration（用于兼容旧模型）
    func toTripDuration() -> TripDuration {
        let days = dayCount
        if days <= 3 {
            return .short
        } else if days <= 7 {
            return .medium
        } else if days <= 14 {
            return .long
        } else {
            return .extraLong
        }
    }
}

/// 行程配置（用于新建清单时的临时状态）
struct TripConfig {
    var gender: Gender = .male
    var dateRange: TripDateRange? = nil  // SPEC: 出行时间（日期选择器）
    var destination: String = ""          // SPEC: 目的地（城市）
    var selectedActivityTags: Set<String> = []   // SPEC: 旅行活动
    var selectedOccasionTags: Set<String> = []    // SPEC: 特定场合
    var selectedConfigTags: Set<String> = []      // SPEC: 出行配置
    
    /// 所有选中的标签（合并三组）
    var allSelectedTags: Set<String> {
        selectedActivityTags.union(selectedOccasionTags).union(selectedConfigTags)
    }
    
    /// 是否有选择任何标签
    var hasSelectedTags: Bool {
        !selectedActivityTags.isEmpty || !selectedOccasionTags.isEmpty || !selectedConfigTags.isEmpty
    }
    
    /// 生成清单名称
    func generateListName(language: AppLanguage) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let dateStr = dateFormatter.string(from: dateRange?.startDate ?? Date())
        
        var parts: [String] = []
        
        // 添加目的地（如果有）
        if !destination.isEmpty {
            parts.append(destination)
        }
        
        // 添加标签名称
        var tagNames: [String] = []
        for tagId in allSelectedTags {
            if let tag = PresetData.shared.allTags[tagId] {
                tagNames.append(tag.displayName(language: language))
            }
        }
        
        if !tagNames.isEmpty {
            parts.append(tagNames.prefix(2).joined(separator: language == .chinese ? "、" : ", "))
        }
        
        if parts.isEmpty {
            parts.append(language == .chinese ? "日常出行" : "Daily Travel")
        }
        
        return "\(parts.joined(separator: " - ")) - \(dateStr)"
    }
}
