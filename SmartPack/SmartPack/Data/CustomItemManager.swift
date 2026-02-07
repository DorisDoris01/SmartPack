//
//  CustomItemManager.swift
//  SmartPack
//
//  PRD v1.4: 管理用户自定义 Item
//  SPEC v1.5: 扩展支持预设 Item 删除
//  - 存储用户在各标签下新增的自定义 Item
//  - 存储用户删除的预设 Item ID
//  - 自定义 Item 仅需纯文本名称（无双语、无 icon）
//

import Foundation
import Combine

/// 自定义 Item 管理器
class CustomItemManager: ObservableObject {
    static let shared = CustomItemManager()
    
    /// 自定义 Item 存储
    /// Key: 标签 ID (如 "tag_formal")
    /// Value: 用户新增的 Item 名称数组
    @Published private(set) var customItems: [String: [String]] = [:]
    
    /// SPEC v1.5: 已删除的预设 Item ID 集合
    @Published private(set) var deletedPresetItemIds: Set<String> = []
    
    private let userDefaultsKey = "customItems"
    private let deletedPresetItemsKey = "deletedPresetItemIds"
    
    private init() {
        loadCustomItems()
        loadDeletedPresetItems()
    }
    
    // MARK: - 公开方法
    
    /// 获取某个标签下的自定义 Item 列表
    func getCustomItems(for tagId: String) -> [String] {
        return customItems[tagId] ?? []
    }
    
    /// 在某个标签下新增自定义 Item
    /// - Parameters:
    ///   - itemName: Item 名称（纯文本）
    ///   - tagId: 标签 ID
    /// - Returns: 是否成功（名称为空或已存在则失败）
    @discardableResult
    func addCustomItem(_ itemName: String, to tagId: String) -> Bool {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        
        var items = customItems[tagId] ?? []
        
        // 检查是否已存在（不区分大小写）
        if items.contains(where: { $0.lowercased() == trimmedName.lowercased() }) {
            return false
        }
        
        items.append(trimmedName)
        customItems[tagId] = items
        saveCustomItems()
        return true
    }
    
    /// 从某个标签下删除自定义 Item
    /// - Parameters:
    ///   - itemName: Item 名称
    ///   - tagId: 标签 ID
    func removeCustomItem(_ itemName: String, from tagId: String) {
        guard var items = customItems[tagId] else { return }
        items.removeAll { $0 == itemName }
        
        if items.isEmpty {
            customItems.removeValue(forKey: tagId)
        } else {
            customItems[tagId] = items
        }
        saveCustomItems()
    }
    
    /// SPEC v1.5: 检查某个标签下是否可以删除 Item（至少保留 1 个）
    /// - Parameters:
    ///   - tagId: 标签 ID
    ///   - presetItemIds: 该标签的所有预设 Item ID
    ///   - customItemCount: 当前自定义 Item 数量
    /// - Returns: 是否可以删除
    func canDeleteItem(tagId: String, presetItemIds: [String], customItemCount: Int) -> Bool {
        // 计算未删除的预设 Item 数量
        let activePresetCount = presetItemIds.filter { !deletedPresetItemIds.contains($0) }.count
        let totalCount = activePresetCount + customItemCount
        return totalCount > 1
    }
    
    /// SPEC v1.5: 删除预设 Item
    /// - Parameter itemId: 预设 Item ID
    func deletePresetItem(_ itemId: String) {
        deletedPresetItemIds.insert(itemId)
        saveDeletedPresetItems()
    }
    
    /// SPEC v1.5: 恢复预设 Item（撤销删除）
    /// - Parameter itemId: 预设 Item ID
    func restorePresetItem(_ itemId: String) {
        deletedPresetItemIds.remove(itemId)
        saveDeletedPresetItems()
    }
    
    /// SPEC v1.5: 检查预设 Item 是否已被删除
    /// - Parameter itemId: 预设 Item ID
    /// - Returns: 是否已删除
    func isPresetItemDeleted(_ itemId: String) -> Bool {
        return deletedPresetItemIds.contains(itemId)
    }
    
    // MARK: - 持久化
    
    private func loadCustomItems() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            customItems = [:]
            return
        }
        customItems = decoded
    }
    
    private func saveCustomItems() {
        guard let data = try? JSONEncoder().encode(customItems) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    // SPEC v1.5: 加载已删除的预设 Item
    private func loadDeletedPresetItems() {
        if let data = UserDefaults.standard.data(forKey: deletedPresetItemsKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            deletedPresetItemIds = decoded
        } else {
            deletedPresetItemIds = []
        }
    }
    
    // SPEC v1.5: 保存已删除的预设 Item
    private func saveDeletedPresetItems() {
        if let data = try? JSONEncoder().encode(deletedPresetItemIds) {
            UserDefaults.standard.set(data, forKey: deletedPresetItemsKey)
        }
    }
}
