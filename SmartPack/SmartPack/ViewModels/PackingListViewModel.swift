//
//  PackingListViewModel.swift
//  SmartPack
//
//  Refactor v2.1: MVVM 架构 — 业务逻辑与副作用集中管理
//  职责：物品增删改查、分组缓存、Live Activity、完成检测与归档
//

import Foundation
import SwiftData
import Observation

/// 打包清单 ViewModel
///
/// 设计原则：
/// - toggle 操作不重建分组（依赖 @Model 的 @Observable 精确追踪 isChecked）
/// - 只在结构性变化（增、删、重置、语言切换）时才 rebuild 分组
/// - existingItemIds 增量维护，不在渲染周期中临时计算
@Observable
final class PackingListViewModel {

    // MARK: - 被观察的状态（驱动 UI）

    /// 按分类分组的物品列表（结构性变化时重建）
    private(set) var groupedItems: [(category: String, items: [TripItem])] = []

    /// 已存在的物品 ID 缓存（用于 AddItemRow 去重，增量维护）
    private(set) var existingItemIds: Set<String> = []

    /// 展开的分类集合
    var expandedCategories: Set<String> = []

    /// 是否显示庆祝动画
    var showCelebration = false

    // MARK: - 依赖

    private let trip: Trip
    private let activityManager = PackingActivityManagerCompat.shared

    // MARK: - 初始化

    init(trip: Trip, language: AppLanguage) {
        self.trip = trip
        rebuildGroups(language: language)
        existingItemIds = Set(trip.items.map { $0.id })
        expandedCategories = Set(groupedItems.map { $0.category })
    }

    // MARK: - 物品操作

    /// 切换勾选状态
    ///
    /// 执行策略：三阶段分离
    /// 1. 同步：只做最小数据变更（isChecked + 计数器），让 SwiftUI 立即渲染勾选动画
    /// 2. 延迟：Live Activity 跨进程通信推到下一个 RunLoop
    /// 3. 延迟：完成检测 + archive 数据库写入推到下一个 RunLoop
    ///
    /// 不调用 rebuildGroups。TripItem 是 @Model（遵循 @Observable），
    /// isChecked 变化会被 SwiftUI 精确追踪，只有对应的 ItemRow 会局部刷新。
    func toggleItem(_ itemId: String) {
        // Phase 1（同步）：最小数据变更，释放主线程给渲染
        let wasAllChecked = trip.isAllChecked
        trip.toggleItem(itemId)

        // Phase 2 & 3（延迟）：副作用推到下一个 RunLoop，不阻塞当前帧
        let checkedCount = trip.checkedCount
        let totalCount = trip.totalCount
        let isNowAllChecked = trip.isAllChecked
        let isArchived = trip.isArchived

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            // Phase 2：Live Activity 跨进程通信
            if !isArchived {
                self.activityManager.updateActivity(
                    checkedCount: checkedCount,
                    totalCount: totalCount
                )
            }

            // Phase 3：完成检测 → 归档 + 庆祝
            if !wasAllChecked && isNowAllChecked && !isArchived {
                HapticFeedback.success()
                self.activityManager.endActivity()
                self.trip.archive()
                self.showCelebration = true
            }
        }
    }

    /// 删除物品（结构性变化 → 重建分组）
    func deleteItem(_ itemId: String, language: AppLanguage) {
        existingItemIds.remove(itemId)
        trip.removeItem(itemId)
        rebuildGroups(language: language)
        syncLiveActivity()
    }

    /// 添加物品到指定分类（含去重逻辑）
    ///
    /// - Returns: 是否添加成功（用于 UI 反馈，如清空输入框）
    @discardableResult
    func addItem(to category: String, name: String, language: AppLanguage) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }

        // 去重：基于名称
        let existingNames = Set(trip.items.map { $0.name.lowercased() })
        guard !existingNames.contains(trimmedName.lowercased()) else { return false }

        // 解析分类枚举
        let categoryEnum = ItemCategory.allCases.first { cat in
            cat.nameCN == category || cat.nameEN == category
        } ?? .other

        // 优先匹配预设 Item
        let presetItem = PresetData.shared.allItems.values.first { item in
            (item.name == trimmedName || item.nameEn == trimmedName) &&
            item.category == categoryEnum &&
            !existingItemIds.contains(item.id)
        }

        let newItem: TripItem
        if let preset = presetItem {
            newItem = preset.toTripItem()
        } else {
            newItem = TripItem(
                id: UUID().uuidString,
                name: trimmedName,
                nameEn: trimmedName,
                category: category,
                categoryEn: categoryEnum.nameEN,
                sortOrder: categoryEnum.sortOrder
            )
        }

        // 增量更新缓存 + 模型
        existingItemIds.insert(newItem.id)
        trip.addItem(newItem)
        rebuildGroups(language: language)
        syncLiveActivity()
        return true
    }

    /// 重置所有勾选（结构性变化 → 重建分组，因为所有 isChecked 批量变化）
    func resetAll(language: AppLanguage) {
        trip.resetAllChecks()
        rebuildGroups(language: language)
        syncLiveActivity()
    }

    // MARK: - 归档操作

    /// 手动归档（菜单触发）
    func archiveTrip() {
        trip.archive()
        activityManager.endActivity()
    }

    /// 取消归档
    func unarchiveTrip() {
        trip.unarchive()
    }

    // MARK: - Live Activity 生命周期

    /// 页面出现时启动 Live Activity
    func startLiveActivityIfNeeded() {
        guard !trip.isArchived && !trip.isAllChecked else { return }
        activityManager.startActivity(
            tripName: trip.name,
            checkedCount: trip.checkedCount,
            totalCount: trip.totalCount
        )
    }

    /// 页面消失时结束 Live Activity
    func stopLiveActivity() {
        activityManager.endActivity()
    }

    // MARK: - 分组管理

    /// 重建分组缓存（仅在结构性变化时调用）
    func rebuildGroups(language: AppLanguage) {
        groupedItems = PresetData.shared.groupByCategory(trip.items, language: language)
    }

    // MARK: - Private

    /// 同步 Live Activity 进度（如果行程未归档）
    private func syncLiveActivity() {
        guard !trip.isArchived else { return }
        activityManager.updateActivity(
            checkedCount: trip.checkedCount,
            totalCount: trip.totalCount
        )
    }
}
