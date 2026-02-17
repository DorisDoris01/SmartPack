//
//  CategorySection.swift
//  SmartPack
//
//  打包清单组件 - 分类区域
//  Refactor v2.1: 移除 Trip 依赖，接收轻量级 existingItemIds
//

import SwiftUI

/// 分类区域
///
/// 视图隔离原则：
/// - 不持有 Trip 引用（Trip.checkedItemCount 变化不会触发本组件重绘）
/// - existingItemIds 由 ViewModel 增量维护并传入
/// - checkedCount 依赖 @Model observation 精确追踪（只在本分类 item 的 isChecked 变化时重算）
struct CategorySection: View {
    let category: String
    let items: [TripItem]
    let isExpanded: Bool
    let language: AppLanguage
    let existingItemIds: Set<String>
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
                if items.isEmpty {
                    Text(language == .chinese ? "该分类暂无物品" : "No items in this category")
                        .font(Typography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(items) { item in
                        ItemRow(
                            item: item,
                            language: language,
                            onToggle: { onToggleItem(item.id) },
                            onDelete: { onDeleteItem(item.id) }
                        )
                    }
                }

                AddItemRow(
                    category: category,
                    categoryEnum: categoryEnum,
                    existingItemIds: existingItemIds,
                    onAddItem: { itemName in onAddItem(itemName) }
                )
            }
        } header: {
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
