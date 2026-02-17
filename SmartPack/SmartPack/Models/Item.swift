//
//  Item.swift
//  SmartPack
//
//  物品数据模型
//

import Foundation
import Combine

/// 物品对象（预设数据）
struct Item: Identifiable, Hashable {
    let id: String
    let name: String        // 中文名称
    let nameEn: String      // 英文名称
    let category: ItemCategory
    let genderSpecific: Gender?  // nil = 通用, .male = 仅男性, .female = 仅女性
    
    /// 根据当前语言获取显示名称
    func displayName(language: AppLanguage) -> String {
        switch language {
        case .chinese: return name
        case .english: return nameEn
        }
    }
    
    /// 转换为 TripItem（用于清单存储）
    func toTripItem() -> TripItem {
        TripItem(
            id: id,
            name: name,
            nameEn: nameEn,
            category: category.nameCN,
            categoryEn: category.nameEN,
            isChecked: false,
            sortOrder: category.sortOrder
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

/// 物品分类
enum ItemCategory: String, CaseIterable, Identifiable {
    case documents = "documents"      // 证件/钱财
    case clothing = "clothing"        // 衣物
    case toiletries = "toiletries"    // 洗漱
    case electronics = "electronics"  // 电子产品
    case sports = "sports"            // 运动装备
    case other = "other"              // 其他
    
    var id: String { rawValue }
    
    /// 中文名称
    var nameCN: String {
        switch self {
        case .documents: return "证件/钱财"
        case .clothing: return "衣物"
        case .toiletries: return "洗漱用品"
        case .electronics: return "电子产品"
        case .sports: return "运动装备"
        case .other: return "其他"
        }
    }
    
    /// 英文名称
    var nameEN: String {
        switch self {
        case .documents: return "Documents & Money"
        case .clothing: return "Clothing"
        case .toiletries: return "Toiletries"
        case .electronics: return "Electronics"
        case .sports: return "Sports Gear"
        case .other: return "Other"
        }
    }
    
    /// 根据语言获取显示名称
    func displayName(language: AppLanguage) -> String {
        switch language {
        case .chinese: return nameCN
        case .english: return nameEN
        }
    }
    
    /// 分类图标
    var icon: String {
        switch self {
        case .documents: return "wallet.pass"
        case .clothing: return "tshirt"
        case .toiletries: return "drop"
        case .electronics: return "laptopcomputer.and.iphone"
        case .sports: return "figure.run"
        case .other: return "ellipsis.circle"
        }
    }
    
    /// 分类排序优先级
    var sortOrder: Int {
        switch self {
        case .documents: return 0
        case .clothing: return 1
        case .toiletries: return 2
        case .electronics: return 3
        case .sports: return 4
        case .other: return 5
        }
    }
}
