# SmartPack Trip 编辑功能需求规格说明 (Spec)

> **文档版本**：v1.7  
> **基于版本**：PRD v1.4 + SPEC v1.5  
> **创建日期**：2026-02-07  
> **状态**：待实现  
> **UI 参考**：Apple Reminders App

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.6 | 2026-02-07 | Trip 编辑功能：删除 Item、添加 Item（TabView 方式） |
| v1.7 | 2026-02-07 | **UI 重构**：参照 Reminders 设计，使用 List + 底部输入框方式 |

---

## 1. 需求概述

v1.7 版本聚焦于**UI 重构**，参照 Apple Reminders App 的设计理念，提供更符合 iOS 原生体验的清单管理界面：

- **Item 删除**：支持删除 Trip 中的任意 Item（已有基础实现，需完善 UI）
- **Item 添加**：参照 Reminders 的简洁设计，在分类列表底部直接添加 Item
- **UI 统一**：使用 List 原生样式，确保与 iOS 系统风格一致

---

## 2. UI 设计原则（参照 Reminders）

### 2.1 Reminders 核心设计理念

1. **简洁性**：直接在列表底部添加新项目，无需弹窗
2. **原生体验**：使用 List 原生样式，符合 iOS 设计规范
3. **快速操作**：最小化操作步骤，提升效率
4. **视觉一致性**：与系统应用保持一致的视觉风格

### 2.2 当前 UI 问题分析

**问题 1：未使用 List 原生样式**
- ❌ 当前使用 `VStack` + `Button` 组合
- ❌ `ItemRow` 使用自定义 Button，而非 List 行
- ✅ 应使用 `List` + `ForEach`，让系统自动处理样式

**问题 2：添加方式过于复杂**
- ❌ 当前使用 TabView + Sheet 弹窗方式
- ❌ 需要多步操作（点击按钮 → 选择 Tab → 输入 → 确认）
- ✅ 应参照 Reminders，在列表底部直接添加

**问题 3：样式不一致**
- ❌ `CategorySection` 使用自定义 VStack，样式与系统不一致
- ❌ 背景色、圆角、间距等与 iOS 原生 List 不匹配
- ✅ 应使用 `List` + `Section` 原生组件

**问题 4：交互体验不佳**
- ❌ DisclosureGroup 在 VStack 中，展开动画不流畅
- ❌ Item 行点击区域和视觉反馈不明确
- ✅ 应使用 List 的原生展开/折叠和点击反馈

---

## 3. 功能需求详情

### 3.1 Item 删除功能

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-1.1** | **Item 横滑删除** | **P0** | 在 `PackingListView` 的 List 中，用户可以通过**向左横滑**任意 Item 行，显示删除按钮，点击后删除该 Item。**删除功能适用于所有 Item**，包括预设 Item 和用户自定义添加的 Item。 |
| **F-1.2** | **删除确认对话框** | **P1** | 删除 Item 前弹出确认对话框，防止误操作。对话框显示 Item 名称，提供「取消」和「删除」选项。 |
| **F-1.3** | **删除后更新** | **P0** | 删除 Item 后，立即更新进度圆环、完成状态和 Live Activity（如果启用）。 |
| **F-1.4** | **数据持久化** | **P0** | 删除操作需立即保存到 SwiftData，确保数据一致性。 |
| **F-1.5** | **空分类处理** | **P1** | 当某个分类下的所有 Item 被删除后，该分类仍显示，但显示空状态提示。 |

**技术实现**：
- 使用 SwiftUI `List` + `ForEach` 原生样式
- 使用 `.swipeActions()` modifier 实现横滑删除
- 删除操作通过 `trip.items` 数组的 `removeAll` 方法实现
- 使用 `@Bindable` 确保 SwiftData 自动同步

---

### 3.2 Item 添加功能（参照 Reminders 设计）

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-2.1** | **列表底部添加输入框** | **P0** | 在每个分类的 List Section 底部，显示一个输入框（类似 Reminders 的 "+ New Reminder"），用户可以直接输入 Item 名称并添加。 |
| **F-2.2** | **快速添加预设 Item** | **P0** | 输入框支持自动补全，显示当前分类下的预设 Item 建议。用户点击建议项即可快速添加。 |
| **F-2.3** | **自定义 Item 输入** | **P0** | 用户可以直接输入任意 Item 名称（中英文），按回车或点击添加按钮后添加到当前分类。 |
| **F-2.4** | **去重处理** | **P0** | 添加 Item 时，自动检测 Trip 中是否已存在相同 Item（基于 ID 或名称），避免重复添加。 |
| **F-2.5** | **添加后更新** | **P0** | 添加 Item 后，立即更新该分类的列表显示、进度统计和 Live Activity（如果启用）。 |
| **F-2.6** | **数据持久化** | **P0** | 添加操作需立即保存到 SwiftData。 |

**UI 设计（参照 Reminders）**：

```
┌─────────────────────────────────┐
│  📁 证件/钱财         2/5      │ ← Section Header
├─────────────────────────────────┤
│  ☐ 身份证/护照                  │
│  ☑ 少量现金                     │
│  ☐ 银行卡                       │
│  ☐ 信用卡                       │
│  ☐ 旅行支票                     │
│  ┌───────────────────────────┐ │
│  │ + 添加物品...              │ │ ← 输入框（类似 Reminders）
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

**技术实现**：
- 使用 `List` + `Section` 原生组件
- 在每个 Section 底部添加 `TextField`（类似 Reminders 的输入框）
- 支持自动补全预设 Item（使用 `.searchable()` 或自定义补全列表）
- 输入框聚焦时自动展开，失焦时收起（可选）

---

## 4. UI 组件设计（参照 Reminders）

### 4.1 PackingListView 整体结构

**使用 List 替代 ScrollView + LazyVStack**：

```swift
List {
    ForEach(groupedItems, id: \.category) { group in
        CategorySection(
            category: group.category,
            items: group.items,
            isExpanded: expandedCategories.contains(group.category),
            language: localization.currentLanguage,
            trip: trip,
            onToggleExpand: { toggleCategory(group.category) },
            onToggleItem: { itemId in toggleItemAndCheckCompletion(itemId) },
            onDeleteItem: { itemId in requestDeleteItem(itemId) },
            onAddItem: { itemName in addItemToCategory(group.category, itemName: itemName) }
        )
    }
}
.listStyle(.insetGrouped)  // 使用 iOS 原生分组列表样式
```

### 4.2 CategorySection 重构

**使用 List Section 替代自定义 VStack**：

```swift
Section {
    // Item 列表（使用 List 原生行样式）
    ForEach(items) { item in
        ItemRow(
            item: item,
            language: language,
            onToggle: { onToggleItem(item.id) },
            onDelete: { onDeleteItem(item.id) }
        )
    }
    
    // 空状态处理
    if items.isEmpty {
        Text(language == .chinese ? "该分类暂无物品" : "No items in this category")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .listRowBackground(Color.clear)
    }
    
    // 添加输入框（参照 Reminders）
    AddItemRow(
        category: category,
        categoryEnum: categoryEnum,
        existingItemIds: existingItemIds,
        onAddItem: { itemName in
            onAddItem(itemName)
        }
    )
} header: {
    // Section Header（分类名称 + 统计）
    CategoryHeader(
        category: category,
        checkedCount: checkedCount,
        totalCount: items.count,
        icon: categoryIcon
    )
}
```

### 4.3 ItemRow 重构

**使用 List 原生行样式**：

```swift
HStack(spacing: 12) {
    // 复选框（左侧）
    Button {
        onToggle()
    } label: {
        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundColor(item.isChecked ? .green : .gray)
    }
    .buttonStyle(.plain)
    
    // Item 名称
    Text(item.displayName(language: language))
        .font(.body)
        .foregroundColor(item.isChecked ? .secondary : .primary)
        .strikethrough(item.isChecked, color: .secondary)
    
    Spacer()
}
.padding(.vertical, 4)
.contentShape(Rectangle())
.swipeActions(edge: .trailing, allowsFullSwipe: false) {
    Button(role: .destructive) {
        onDelete()
    } label: {
        Label(localization.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
    }
}
```

### 4.4 AddItemRow（参照 Reminders）

**在列表底部添加输入框**：

```swift
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 输入框
            HStack {
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
            .padding(.vertical, 8)
            
            // 预设 Item 建议（可选，类似 Reminders 的自动补全）
            if showPresetSuggestions && !presetItemsForCategory.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(presetItemsForCategory.prefix(5)) { item in
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
                    .padding(.horizontal)
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
    }
}
```

---

## 5. 用户交互流程（参照 Reminders）

### 5.1 添加 Item 流程（简化版）

```
1. 用户在 PackingListView 中查看 Trip
2. 滚动到某个分类（如「证件/钱财」）
3. 在分类列表底部看到输入框「+ 添加物品...」
4. 点击输入框，键盘弹出
5. 用户输入 Item 名称（或点击预设建议）
6. 按回车或点击「添加」按钮
7. Item 立即添加到当前分类下
8. 输入框清空，键盘收起
9. 进度统计和 Live Activity 更新
10. 数据保存到 SwiftData
```

**对比 v1.6 的改进**：
- ❌ v1.6: 点击按钮 → 弹出 Sheet → 选择 Tab → 输入 → 点击添加 → 关闭 Sheet（6 步）
- ✅ v1.7: 点击输入框 → 输入 → 按回车（3 步）

### 5.2 删除 Item 流程（保持不变）

```
1. 用户在 PackingListView 中查看 Trip
2. 向左横滑某个 Item 行
3. 显示「删除」按钮
4. 点击删除按钮
5. 弹出确认对话框：「确定要删除 [Item 名称] 吗？」
6. 用户确认删除
7. Item 从列表中移除
8. 进度统计和 Live Activity 更新
9. 数据保存到 SwiftData
```

---

## 6. UI 修复清单

### 6.1 必须修复的问题

1. **✅ 使用 List 替代 VStack**
   - 将 `ScrollView` + `LazyVStack` 改为 `List`
   - 使用 `.listStyle(.insetGrouped)` 获得原生分组样式

2. **✅ 使用 Section 替代自定义分类卡片**
   - 将 `CategorySection` 的 `VStack` + `DisclosureGroup` 改为 `Section`
   - 使用 `Section` 的 `header` 参数显示分类信息

3. **✅ ItemRow 使用 List 原生行样式**
   - 移除自定义 `Button` + `HStack` 包装
   - 直接使用 `HStack`，让 List 自动处理行样式

4. **✅ 添加输入框在列表底部**
   - 移除 `AddItemSheet` 弹窗
   - 在每个 Section 底部添加 `AddItemRow` 输入框

5. **✅ 统一背景色和间距**
   - 使用系统默认的 `Color(.systemGroupedBackground)`
   - 移除自定义的 `cornerRadius` 和 `clipped()`

6. **✅ 修复展开/折叠动画**
   - 使用 `DisclosureGroup` 在 List 中的原生展开动画
   - 确保动画流畅自然

### 6.2 可选优化

1. **预设 Item 自动补全**（类似 Reminders）
   - 输入时显示预设 Item 建议
   - 点击建议快速添加

2. **输入框聚焦动画**
   - 聚焦时自动滚动到输入框位置
   - 失焦时自动收起建议列表

3. **空状态优化**
   - 空分类时显示更友好的提示
   - 添加引导性文字

---

## 7. 实现建议

### 7.1 开发顺序

1. **Phase 1：UI 基础重构**
   - 将 `ScrollView` + `LazyVStack` 改为 `List`
   - 将 `CategorySection` 改为 `Section`
   - 修复 `ItemRow` 样式

2. **Phase 2：添加功能重构**
   - 移除 `AddItemSheet` 弹窗
   - 实现 `AddItemRow` 输入框组件
   - 实现添加逻辑

3. **Phase 3：优化和测试**
   - 添加预设 Item 自动补全（可选）
   - 测试所有交互流程
   - 修复 UI 细节问题

### 7.2 技术要点

1. **使用 List 原生组件**
   - `List` + `Section` + `ForEach` 组合
   - `.listStyle(.insetGrouped)` 获得分组样式
   - `.swipeActions()` 实现横滑删除

2. **输入框实现**
   - 使用 `TextField` + `@FocusState`
   - `.onSubmit()` 处理回车提交
   - 支持预设 Item 建议（可选）

3. **数据持久化**
   - 所有变更通过 `@Bindable` 自动同步
   - 添加/删除后立即更新 Live Activity

---

## 8. 与现有功能的集成

### 8.1 与 Live Activity 集成

- Item 增删时，调用 `activityManager.updateActivity()` 更新进度
- 确保进度计算准确：`checkedCount/totalCount`

### 8.2 与归档功能集成

- 已归档的 Trip 应禁用编辑功能（输入框禁用或隐藏）
- 或允许编辑，但编辑后自动取消归档状态

### 8.3 与 Item 管理功能集成

- 自定义 Item 不添加到全局 Item 库（仅属于当前 Trip）
- 预设 Item 的修改不影响已创建的 Trip（除非用户手动更新）

---

## 9. 测试要点

1. **UI 样式测试**：
   - 验证 List 样式与 iOS 原生一致
   - 验证展开/折叠动画流畅
   - 验证横滑删除交互正常

2. **添加功能测试**：
   - 在每个分类下添加 Item
   - 验证输入框聚焦和失焦
   - 验证预设 Item 建议（如果实现）
   - 验证去重处理

3. **删除功能测试**：
   - 删除预设 Item 和自定义 Item
   - 验证删除确认对话框
   - 验证空分类处理

4. **数据一致性测试**：
   - 验证添加/删除后数据正确保存
   - 验证进度统计更新正确
   - 验证 Live Activity 更新正确

---

## 10. 后续扩展建议

1. **批量操作**：支持批量删除、批量添加 Item
2. **Item 排序**：支持手动调整 Item 顺序（拖拽）
3. **分类折叠记忆**：记住用户的分类展开/折叠状态
4. **导入/导出**：支持从其他 Trip 导入 Item
5. **自定义分类**：未来版本可考虑支持用户创建自定义分类

---

*文档维护：实现时请同步更新本 Spec 与主 PRD，并标注完成状态。*
