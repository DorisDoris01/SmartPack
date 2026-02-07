//
//  AddItemRow.swift
//  SmartPack
//
//  打包清单组件 - SPEC v1.7 F-2.1: 添加物品输入框（参照 Reminders）
//

import SwiftUI

/// 添加物品输入框
struct AddItemRow: View {
    let category: String
    let categoryEnum: ItemCategory
    let existingItemIds: Set<String>
    let onAddItem: (String) -> Void

    @EnvironmentObject var localization: LocalizationManager
    @FocusState private var isFocused: Bool
    @State private var itemName = ""
    @State private var showPresetSuggestions = false

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
        VStack(alignment: .leading, spacing: 8) {
            // 输入框
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)

                TextField(
                    localization.currentLanguage == .chinese ? "添加物品..." : "Add item...",
                    text: $itemName
                )
                .focused($isFocused)
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
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.vertical, 4)

            // 预设 Item 建议（可选，类似 Reminders 的自动补全）
            if showPresetSuggestions && !filteredPresetItems.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filteredPresetItems) { item in
                            Button {
                                itemName = item.displayName(language: localization.currentLanguage)
                                addItem()
                            } label: {
                                Text(item.displayName(language: localization.currentLanguage))
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .listRowBackground(Color(.systemBackground))
    }

    private func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        onAddItem(trimmedName)
        itemName = ""
        isFocused = false
        showPresetSuggestions = false
    }
}
