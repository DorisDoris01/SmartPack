//
//  ItemManagementView.swift
//  SmartPack
//
//  PRD v1.4: Item 管理页
//  - 按「标签组 → 标签 → Item」层级展示
//  - 用户可在标签下新增/删除自定义 Item
//  - 预设 Item 不可删除
//

import SwiftUI

struct ItemManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager
    @State private var customItemManager = CustomItemManager.shared
    
    @State private var expandedTags: Set<String> = []
    /// 使用 item 驱动 sheet，避免 isPresented + 可选内容 的竞态导致空白
    @State private var selectedTagForAdd: Tag?
    
    var body: some View {
        List {
            ForEach(TagGroup.allCases) { group in
                Section(header: Text(group.displayName(language: localization.currentLanguage))) {
                    ForEach(PresetData.shared.tags(for: group)) { tag in
                        tagRow(tag: tag)
                    }
                }
            }
        }
        .navigationTitle(localization.currentLanguage == .chinese ? "Item 管理" : "Item Management")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text(localization.currentLanguage == .chinese ? "完成" : "Done")
                        .font(Typography.body)
                        .fontWeight(.medium)
                }
            }
        }
        .sheet(item: $selectedTagForAdd) { tag in
            AddCustomItemSheet(tag: tag)
                .environmentObject(localization)
        }
    }
    
    // MARK: - 标签行（可展开）
    
    private func tagRow(tag: Tag) -> some View {
        let isExpanded = expandedTags.contains(tag.id)
        let presetItems = PresetData.shared.getPresetItems(for: tag.id)
        let customItems = customItemManager.getCustomItems(for: tag.id)
        // SPEC v1.5: 获取所有预设 Item（包括已删除的，用于计算总数）
        let allPresetItems = PresetData.shared.allTags[tag.id]?.itemIds.compactMap { PresetData.shared.allItems[$0] } ?? []
        
        return DisclosureGroup(
            isExpanded: Binding(
                get: { isExpanded },
                set: { newValue in
                    if newValue {
                        expandedTags.insert(tag.id)
                    } else {
                        expandedTags.remove(tag.id)
                    }
                }
            )
        ) {
            // SPEC v1.5: 预设 Item（可删除）
            ForEach(allPresetItems) { item in
                presetItemRow(item: item, tagId: tag.id, allPresetCount: allPresetItems.count, customCount: customItems.count)
            }
            
            // 自定义 Item（可删除）
            ForEach(customItems, id: \.self) { itemName in
                customItemRow(itemName: itemName, tagId: tag.id, presetCount: allPresetItems.count, customCount: customItems.count)
            }
            
            // 新增按钮
            Button {
                selectedTagForAdd = tag
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.primary)
                    Text(localization.currentLanguage == .chinese ? "添加物品" : "Add Item")
                        .font(Typography.body)
                        .foregroundColor(AppColors.primary)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: tag.icon)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)

                Text(tag.displayName(language: localization.currentLanguage))
                    .font(Typography.body)
                
                Spacer()
                
                // SPEC v1.5: 显示活跃 Item 数量（不包括已删除的预设 Item）
                Text("\(presetItems.count + customItems.count)")
                    .font(Typography.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - SPEC v1.5: 预设 Item 行（可删除）
    
    private func presetItemRow(item: Item, tagId: String, allPresetCount: Int, customCount: Int) -> some View {
        let isDeleted = customItemManager.isPresetItemDeleted(item.id)
        
        return HStack {
            Text(item.displayName(language: localization.currentLanguage))
                .font(Typography.body)
                .foregroundColor(isDeleted ? .secondary : .primary)
                .strikethrough(isDeleted, color: .orange)
            
            Spacer()
            
            Text(localization.currentLanguage == .chinese ? "预设" : "Preset")
                .font(Typography.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.systemGray5))
                .cornerRadius(4)
        }
        .padding(.leading, 36)
        // SPEC v1.5 F-2.1: 预设 Item 横滑删除
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if isDeleted {
                // 恢复按钮
                Button {
                    customItemManager.restorePresetItem(item.id)
                } label: {
                    Label(localization.currentLanguage == .chinese ? "恢复" : "Restore", systemImage: "arrow.uturn.backward")
                }
                .tint(AppColors.primary)
            } else {
                // 删除按钮
                Button {
                    deletePresetItem(itemId: item.id, tagId: tagId, allPresetCount: allPresetCount, customCount: customCount)
                } label: {
                    Label(localization.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
    }
    
    // MARK: - 自定义 Item 行（可删除）
    
    private func customItemRow(itemName: String, tagId: String, presetCount: Int, customCount: Int) -> some View {
        HStack {
            Text(itemName)
                .font(Typography.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // 删除按钮
            Button {
                deleteCustomItem(itemName: itemName, tagId: tagId, presetCount: presetCount, customCount: customCount)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 36)
    }
    
    // MARK: - 删除自定义 Item
    
    private func deleteCustomItem(itemName: String, tagId: String, presetCount: Int, customCount: Int) {
        // SPEC v1.5: 获取所有预设 Item ID（用于检查约束）
        let allPresetItemIds = PresetData.shared.allTags[tagId]?.itemIds ?? []
        if !customItemManager.canDeleteItem(tagId: tagId, presetItemIds: allPresetItemIds, customItemCount: customCount) {
            // 提示用户不能删除最后一个
            return
        }
        
        customItemManager.removeCustomItem(itemName, from: tagId)
    }
    
    // MARK: - SPEC v1.5: 删除预设 Item
    
    private func deletePresetItem(itemId: String, tagId: String, allPresetCount: Int, customCount: Int) {
        // SPEC v1.5 F-2.2: 检查是否至少保留 1 个 Item
        let allPresetItemIds = PresetData.shared.allTags[tagId]?.itemIds ?? []
        if !customItemManager.canDeleteItem(tagId: tagId, presetItemIds: allPresetItemIds, customItemCount: customCount) {
            // 提示用户不能删除最后一个
            return
        }
        
        customItemManager.deletePresetItem(itemId)
    }
}

// MARK: - 添加自定义 Item Sheet

struct AddCustomItemSheet: View {
    let tag: Tag
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager
    @State private var customItemManager = CustomItemManager.shared
    
    @State private var itemName = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(localization.currentLanguage == .chinese ? "物品名称" : "Item Name")) {
                    TextField(
                        localization.currentLanguage == .chinese ? "输入物品名称" : "Enter item name",
                        text: $itemName
                    )
                }
                
                Section {
                    Text(localization.currentLanguage == .chinese
                         ? "新增的物品会在选择「\(tag.name)」标签时自动加入行程清单。"
                         : "The new item will be automatically added to the packing list when \"\(tag.nameEn)\" tag is selected.")
                        .font(Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(localization.currentLanguage == .chinese ? "添加物品" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(localization.currentLanguage == .chinese ? "取消" : "Cancel")
                            .font(Typography.body)
                            .fontWeight(.medium)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addItem()
                    } label: {
                        Text(localization.currentLanguage == .chinese ? "添加" : "Add")
                            .font(Typography.body)
                            .fontWeight(.medium)
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert(localization.currentLanguage == .chinese ? "错误" : "Error", isPresented: $showingError) {
                Button(localization.currentLanguage == .chinese ? "确定" : "OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addItem() {
        let success = customItemManager.addCustomItem(itemName, to: tag.id)
        if success {
            dismiss()
        } else {
            errorMessage = localization.currentLanguage == .chinese
                ? "物品名称已存在或为空"
                : "Item name already exists or is empty"
            showingError = true
        }
    }
}

#Preview {
    NavigationStack {
        ItemManagementView()
            .environmentObject(LocalizationManager.shared)
    }
}
