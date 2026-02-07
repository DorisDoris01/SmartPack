//
//  CategorySection.swift
//  SmartPack
//
//  打包清单组件 - 分类区域（SPEC v1.7: 使用 List Section）
//

import SwiftUI

/// 分类区域
struct CategorySection: View {
    let category: String
    let items: [TripItem]
    let isExpanded: Bool
    let language: AppLanguage
    let trip: Trip
    let onToggleExpand: () -> Void
    let onToggleItem: (String) -> Void
    let onDeleteItem: (String) -> Void
    let onAddItem: (String) -> Void

    private var checkedCount: Int {
        items.filter { $0.isChecked }.count
    }

    private var categoryIcon: String {
        switch category {
        case "证件/钱财", "Documents & Money": return "wallet.pass"
        case "衣物", "Clothing": return "tshirt"
        case "洗漱用品", "Toiletries": return "drop"
        case "电子产品", "Electronics": return "laptopcomputer.and.iphone"
        case "运动装备", "Sports Gear": return "figure.run"
        default: return "ellipsis.circle"
        }
    }

    private var categoryEnum: ItemCategory {
        ItemCategory.allCases.first { cat in
            cat.nameCN == category || cat.nameEN == category
        } ?? .other
    }

    var body: some View {
        Section {
            if isExpanded {
                // Item 列表
                if items.isEmpty {
                    // 空状态处理
                    Text(language == .chinese ? "该分类暂无物品" : "No items in this category")
                        .font(Typography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(items) { item in
                        ItemRow(
                            item: item,
                            language: language,
                            onToggle: {
                                onToggleItem(item.id)
                            },
                            onDelete: {
                                onDeleteItem(item.id)
                            }
                        )
                    }
                }

                // SPEC v1.7 F-2.1: 添加输入框（参照 Reminders）
                AddItemRow(
                    category: category,
                    categoryEnum: categoryEnum,
                    existingItemIds: Set(trip.items.map { $0.id }),
                    onAddItem: { itemName in
                        onAddItem(itemName)
                    }
                )
            }
        } header: {
            // Section Header（分类名称 + 统计）
            CategoryHeader(
                category: category,
                checkedCount: checkedCount,
                totalCount: items.count,
                icon: categoryIcon,
                isExpanded: isExpanded,
                language: language,
                onToggle: onToggleExpand
            )
        }
    }
}
