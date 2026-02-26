//
//  CategorySection.swift
//  SmartPack
//
//  打包清单组件 - 原生 List Section（iOS Reminders 风格）
//

import SwiftUI

/// 分类 Section（用于 List(.insetGrouped)）— Reminders 风格
struct CategorySection: View {
    let category: String
    let items: [TripItem]
    let isExpanded: Bool
    let language: AppLanguage
    let existingItemIds: Set<String>
    let accentColor: Color
    let onToggleExpand: () -> Void
    let onToggleItem: (String) -> Void
    let onDeleteItem: (String) -> Void
    let onAddItem: (String) -> Bool

    /// 分隔线对齐偏移：leading inset (20) + circleSize (22) + spacing (12)
    private let separatorLeadingInset: CGFloat = 54

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
                        .font(Typography.footnote)
                        .foregroundColor(Color(.systemGray))
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(items) { item in
                        ItemRow(
                            item: item,
                            language: language,
                            accentColor: accentColor,
                            onToggle: { onToggleItem(item.id) },
                            onDelete: { onDeleteItem(item.id) }
                        )
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            separatorLeadingInset
                        }
                    }
                }

                AddItemRow(
                    category: category,
                    categoryEnum: categoryEnum,
                    existingItemIds: existingItemIds,
                    accentColor: accentColor,
                    onAddItem: { itemName in return onAddItem(itemName) }
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
                accentColor: accentColor,
                onToggle: onToggleExpand
            )
        }
        .animation(PremiumAnimation.standard, value: isExpanded)
    }
}
