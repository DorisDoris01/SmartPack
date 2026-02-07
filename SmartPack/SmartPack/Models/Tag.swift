//
//  Tag.swift
//  SmartPack
//
//  标签/场景数据模型
//

import Foundation

/// 标签分组（SPEC: 旅行活动、特定场合、出行配置）
enum TagGroup: String, CaseIterable, Identifiable {
    case activity = "activity"    // 旅行活动：跑步、攀岩、潜水、露营、越野、摄影、摩旅、骑行
    case occasion = "occasion"    // 特定场合：宴会、商务会议、自驾
    case config = "config"        // 出行配置：国际旅行、带娃、带宠物
    
    var id: String { rawValue }
    
    var nameCN: String {
        switch self {
        case .activity: return "旅行活动"
        case .occasion: return "特定场合"
        case .config: return "出行配置"
        }
    }
    
    var nameEN: String {
        switch self {
        case .activity: return "Travel Activities"
        case .occasion: return "Occasions"
        case .config: return "Travel Config"
        }
    }
    
    func displayName(language: AppLanguage) -> String {
        switch language {
        case .chinese: return nameCN
        case .english: return nameEN
        }
    }
}

/// 标签/场景对象
struct Tag: Identifiable, Hashable {
    let id: String
    let name: String        // 中文名称
    let nameEn: String      // 英文名称
    let group: TagGroup
    let icon: String        // SF Symbol 名称
    let itemIds: [String]   // 关联的物品 ID 列表
    
    /// 根据当前语言获取显示名称
    func displayName(language: AppLanguage) -> String {
        switch language {
        case .chinese: return name
        case .english: return nameEn
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
}
