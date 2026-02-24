//
//  AddItemRow.swift
//  SmartPack
//
//  打包清单组件 - 添加物品输入框（iOS Reminders 风格）
//

import SwiftUI

/// 添加物品输入框 — 模仿 iOS Reminders "新提醒事项" 行
struct AddItemRow: View {
    let category: String
    let categoryEnum: ItemCategory
    let existingItemIds: Set<String>
    let accentColor: Color
    let onAddItem: (String) -> Void

    @EnvironmentObject var localization: LocalizationManager
    @FocusState private var isFocused: Bool
    @State private var isEditing = false
    @State private var itemName = ""
    @State private var showPresetSuggestions = false

    private let circleSize: CGFloat = 22

    // 获取当前分类下的预设 Item（用于自动补全）
    private var presetItemsForCategory: [Item] {
        PresetData.shared.allItems.values
            .filter { $0.category == categoryEnum }
            .filter { !existingItemIds.contains($0.id) }
            .sorted { $0.displayName(language: localization.currentLanguage) < $1.displayName(language: localization.currentLanguage) }
    }

    // 过滤后的预设 Item（基于输入）
    private var filteredPresetItems: [Item] {
        if itemName.isEmpty {
            return []
        }
        return presetItemsForCategory.filter { item in
            item.displayName(language: localization.currentLanguage)
                .localizedCaseInsensitiveContains(itemName)
        }
        .prefix(5)
        .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.sm) {
                // 空心圆图标 — 与 ItemRow 的未选中状态一致
                Circle()
                    .stroke(Color(.systemGray3), lineWidth: 1.5)
                    .frame(width: circleSize, height: circleSize)

                if isEditing || !itemName.isEmpty {
                    // 激活态：TextField
                    TextField(
                        localization.currentLanguage == .chinese ? "添加物品..." : "Add item...",
                        text: $itemName
                    )
                    .font(Typography.body)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .onSubmit {
                        addItem()
                    }
                    .onChange(of: itemName) { oldValue, newValue in
                        showPresetSuggestions = !newValue.isEmpty && !filteredPresetItems.isEmpty
                    }

                    if !itemName.isEmpty {
                        Button {
                            addItem()
                        } label: {
                            Text(localization.currentLanguage == .chinese ? "添加" : "Add")
                                .font(Typography.subheadline)
                                .foregroundColor(accentColor)
                        }
                    }
                } else {
                    // 未激活态：点击区域 — 类似 Reminders "新提醒事项"
                    Button {
                        isEditing = true
                    } label: {
                        Text(localization.currentLanguage == .chinese ? "添加物品" : "Add Item")
                            .font(Typography.body)
                            .foregroundColor(Color(.systemGray2))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }

            // 预设 Item 建议
            if showPresetSuggestions && !filteredPresetItems.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(filteredPresetItems) { item in
                            Button {
                                itemName = item.displayName(language: localization.currentLanguage)
                                addItem()
                            } label: {
                                Text(item.displayName(language: localization.currentLanguage))
                                    .font(Typography.caption)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, 6)
                                    .background(accentColor.opacity(0.12))
                                    .cornerRadius(CornerRadius.lg)
                            }
                        }
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowSeparator(.hidden)
    }

    private func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        onAddItem(trimmedName)
        itemName = ""
        isFocused = false
        isEditing = false
        showPresetSuggestions = false
    }
}
