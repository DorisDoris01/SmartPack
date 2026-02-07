# SmartPack Trip 编辑功能需求规格说明 (Spec)

> **文档版本**：v1.6  
> **基于版本**：PRD v1.4 + SPEC v1.5  
> **创建日期**：2026-02-07  
> **状态**：待实现

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.6 | 2026-02-07 | Trip 编辑功能：删除 Item、添加 Item |

---

## 1. 需求概述

v1.6 版本聚焦于**Trip 编辑功能**，允许用户在已创建的 Trip 中进行灵活的清单管理：

- **Item 删除**：支持删除 Trip 中的任意 Item（已有基础实现，需完善）
- **Item 添加**：支持在 Trip 中直接添加新的 Item

---

## 2. 功能需求详情

### 2.1 Item 删除功能

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-1.1** | **Item 横滑删除** | **P0** | 在 `PackingListView` 中，用户可以通过**向左横滑**任意 Item 行，显示删除按钮，点击后删除该 Item。**删除功能适用于所有 Item**，包括预设 Item 和用户自定义添加的 Item。 |
| **F-1.2** | **删除确认对话框** | **P1** | 删除 Item 前弹出确认对话框，防止误操作。对话框显示 Item 名称，提供「取消」和「删除」选项。对用户自定义添加的 Item，建议显示更明确的提示（如「确定要删除自定义物品 [Item 名称] 吗？」）。 |
| **F-1.3** | **删除后更新** | **P0** | 删除 Item 后，立即更新进度圆环、完成状态和 Live Activity（如果启用）。无论删除的是预设 Item 还是自定义 Item，更新逻辑一致。 |
| **F-1.4** | **数据持久化** | **P0** | 删除操作需立即保存到 SwiftData，确保数据一致性。删除用户自定义添加的 Item 后，该 Item 将从 Trip 中永久移除。 |
| **F-1.5** | **空分类处理** | **P1** | 当某个分类下的所有 Item 被删除后，该分类应自动从列表中隐藏或显示为空状态提示。 |
| **F-1.6** | **统一删除体验** | **P0** | 预设 Item 和用户自定义添加的 Item 使用相同的删除交互方式（横滑删除），确保用户体验一致。 |

**技术实现**：
- 使用 SwiftUI 原生 `.swipeActions()` modifier（已有基础实现）
- 删除操作通过 `trip.items` 数组的 `removeAll` 方法实现
- 使用 `@Bindable` 确保 SwiftData 自动同步
- **删除逻辑统一**：预设 Item 和用户自定义添加的 Item 使用相同的删除方法，基于 Item ID 进行删除，不区分 Item 来源

**UI 示例**：
```
[Item 名称]                    [删除]
  ← 横滑显示删除按钮
```

**当前状态**：
- ✅ 基础删除功能已实现（`PackingListView.swift` line 278-284）
- ✅ 删除功能已支持所有 Item（包括用户自定义添加的 Item）
- ⚠️ 缺少删除确认对话框（F-1.2）
- ⚠️ 空分类处理逻辑需完善（F-1.5）

---

### 2.2 Item 添加功能

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-2.1** | **分类下添加按钮** | **P0** | 在每个分类区域（`CategorySection`）的底部或头部添加「添加物品」按钮，点击后弹出该分类下的添加界面。 |
| **F-2.2** | **预设 Item 选择** | **P0** | 在添加界面中，显示该分类下的所有预设 Item，用户可多选添加。 |
| **F-2.3** | **自定义 Item 输入** | **P1** | 支持用户手动输入 Item 名称（中英文），直接添加到当前分类。 |
| **F-2.4** | **去重处理** | **P0** | 添加 Item 时，自动检测 Trip 中是否已存在相同 Item（基于 ID 或名称），避免重复添加。 |
| **F-2.5** | **添加后更新** | **P0** | 添加 Item 后，立即更新该分类的列表显示、进度统计和 Live Activity（如果启用）。 |
| **F-2.6** | **数据持久化** | **P0** | 添加操作需立即保存到 SwiftData。 |

**技术实现**：
- 在每个 `CategorySection` 中添加「添加物品」按钮
- 创建 `AddItemSheet` 视图组件，接收分类参数
- 使用 `PresetData.shared.allItems` 过滤出该分类下的预设 Item
- 支持从预设 Item 选择或创建自定义 `TripItem`（自动归属到当前分类）
- 自定义 Item 需生成唯一 ID（UUID 或时间戳）

**UI 流程**（与 Item 管理保持一致）：
```
PackingListView
  → 用户展开某个分类（CategorySection，使用 DisclosureGroup）
  → 在展开内容的底部显示「添加物品」按钮（plus.circle.fill 图标，蓝色文字）
  → 点击「添加物品」按钮
  → 弹出 AddItemSheet（使用 sheet(item:) 方式，已绑定当前分类）
    → TabView（两个 Tab）
      → Tab 1: 预设 Item 选择器（显示该分类下的预设 Item，多选）
      → Tab 2: 自定义输入（Form + TextField，与 Item 管理一致）
  → 点击「添加」按钮（toolbar 右侧，名称为空时禁用）
  → Item 添加到当前分类下
  → Sheet 自动关闭
  → 更新 Trip.items 和分类显示
```

**数据结构**：
```swift
// 自定义 Item 创建
let customItem = TripItem(
    id: UUID().uuidString,
    name: "用户输入的中文名",
    nameEn: "User Input English Name",
    category: selectedCategory.nameCN,
    categoryEn: selectedCategory.nameEN,
    isChecked: false
)
```

---

---

## 3. 用户交互流程

### 3.1 删除 Item 流程

**适用于所有 Item**（预设 Item 和用户自定义添加的 Item）：

```
1. 用户在 PackingListView 中查看 Trip
2. 向左横滑某个 Item 行（可以是预设 Item 或用户自定义添加的 Item）
3. 显示「删除」按钮
4. 点击删除按钮
5. 弹出确认对话框：「确定要删除 [Item 名称] 吗？」
6. 用户确认删除
7. Item 从列表中移除（无论 Item 来源）
8. 进度统计和 Live Activity 更新
9. 数据保存到 SwiftData
```

**注意**：删除用户自定义添加的 Item 后，该 Item 将永久从 Trip 中移除，无法恢复。删除预设 Item 后，用户可以通过添加功能重新添加。

### 3.2 添加 Item 流程

**与 Item 管理功能保持一致的用户交互**：

```
1. 用户在 PackingListView 中查看 Trip
2. 展开某个分类（使用 DisclosureGroup，如「证件/钱财」）
3. 在展开内容的底部看到「添加物品」按钮（plus.circle.fill 图标，蓝色文字）
4. 点击「添加物品」按钮
5. 弹出 AddItemSheet（使用 sheet(item:) 方式，已绑定当前分类）
6. 用户选择添加方式：
   a. Tab 1 - 从预设选择：浏览该分类下的预设 Item，多选后点击「添加」
   b. Tab 2 - 自定义输入：在 Form 中输入 Item 名称（TextField），自动归属到当前分类
7. 「添加」按钮在 toolbar 右侧，名称为空时自动禁用
8. 点击「添加」按钮
9. 系统检测重复（基于 Item ID 或名称）
10. 添加成功，Sheet 自动关闭
11. 新 Item 显示在当前分类下
12. 进度统计和 Live Activity 更新
13. 数据保存到 SwiftData
```

**与 Item 管理的一致性**：
- ✅ 使用相同的 DisclosureGroup 展开方式
- ✅ 添加按钮位置和样式一致（底部，plus.circle.fill，蓝色）
- ✅ 使用相同的 sheet(item:) 方式弹出
- ✅ 自定义输入使用 Form + TextField 样式
- ✅ Toolbar 按钮布局一致（取消/添加）
- ✅ 添加按钮禁用逻辑一致（名称为空时禁用）

---

## 4. 数据模型变更

### 4.1 Item 添加逻辑

添加 Item 时，分类自动确定（由用户点击的「添加物品」按钮所在分类决定）：

**预设 Item 添加**：
```swift
// 从预设 Item 选择添加
let presetItem = PresetData.shared.allItems
    .filter { $0.category == targetCategory }  // 过滤出目标分类的预设 Item
    .first { $0.id == selectedId }

let tripItem = presetItem.toTripItem()  // 转换为 TripItem，分类已自动设置
```

**自定义 Item 创建**：
```swift
// 自定义 Item 创建示例
let customItem = TripItem(
    id: UUID().uuidString,
    name: "用户输入的中文名",
    nameEn: "User Input English Name",
    category: targetCategory.nameCN,  // 自动使用当前分类
    categoryEn: targetCategory.nameEN,
    isChecked: false
)
```

**注意**：
- 无需扩展 `Trip` 模型，所有 Item 统一使用 `TripItem` 结构
- 分类由用户操作上下文决定，无需用户再次选择
- 添加的 Item 直接归属到触发添加操作的分类下

---

## 5. UI 组件设计

### 5.1 CategorySection 扩展

**功能**：在每个分类区域添加「添加物品」按钮（与 Item 管理保持一致）

**结构**：
- 将 `CategorySection` 改为使用 `DisclosureGroup`（与 ItemManagementView 的 tagRow 一致）
- 在 `DisclosureGroup` 的展开内容底部添加按钮
- 按钮样式：使用 `plus.circle.fill` 图标，蓝色文字，与 Item 管理一致
- 使用 `sheet(item:)` 方式弹出（避免竞态条件）

**实现示例**：
```swift
struct CategorySection: View {
    let category: String
    let items: [TripItem]
    let isExpanded: Bool
    let language: AppLanguage
    let onToggleExpand: () -> Void
    let onToggleItem: (String) -> Void
    let onDeleteItem: (String) -> Void
    
    /// 使用 item 驱动 sheet，避免 isPresented + 可选内容 的竞态导致空白
    @State private var selectedCategoryForAdd: ItemCategory?
    
    var body: some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { isExpanded },
                set: { _ in onToggleExpand() }
            )
        ) {
            // Item 列表
            ForEach(items) { item in
                ItemRow(
                    item: item,
                    language: language,
                    onToggle: { onToggleItem(item.id) },
                    onDelete: { onDeleteItem(item.id) }
                )
            }
            
            // 添加物品按钮（与 Item 管理一致）
            Button {
                selectedCategoryForAdd = categoryEnum
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text(language == .chinese ? "添加物品" : "Add Item")
                        .foregroundColor(.blue)
                }
            }
            .padding(.leading, 36)  // 与 Item 列表对齐
        } label: {
            // 分类头部
            HStack {
                Image(systemName: categoryIcon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(category)
                Spacer()
                Text("\(checkedCount)/\(items.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(item: $selectedCategoryForAdd) { categoryEnum in
            AddItemSheet(category: category, categoryEnum: categoryEnum)
        }
    }
}
```

### 5.2 AddItemSheet

**功能**：在指定分类下添加 Item 的界面（与 Item 管理的 AddCustomItemSheet 保持一致）

**参数**：
- `category: String`：当前分类名称（中文）
- `categoryEnum: ItemCategory`：当前分类枚举值

**结构**（与 Item 管理一致）：
- 使用 `sheet(item:)` 方式弹出（避免竞态条件）
- NavigationStack + Form 布局
- TabView（两个 Tab）
  - Tab 1: 预设 Item 选择器（仅显示当前分类下的预设 Item）
  - Tab 2: 自定义 Item 输入（Form + TextField，与 AddCustomItemSheet 一致）
- Toolbar：取消（左侧）、添加（右侧，名称为空时禁用）

**预设 Item 选择器**：
- 显示当前分类下的所有预设 Item（通过 `PresetData.shared.allItems` 过滤）
- 每个 Item 行显示复选框（多选）
- 显示已添加的 Item 为已选状态（避免重复）
- 支持搜索过滤

**自定义 Item 输入**（与 AddCustomItemSheet 一致）：
- Form 布局
- Section(header: "物品名称")
- TextField（输入物品名称，placeholder: "输入物品名称"）
- Section 底部显示提示文字：「新增的物品会添加到「[分类名称]」分类下。」
- 使用 `.font(.caption)` 和 `.foregroundColor(.secondary)` 样式

**实现示例**（与 AddCustomItemSheet 保持一致）：
```swift
struct AddItemSheet: View {
    let category: String
    let categoryEnum: ItemCategory
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var selectedPresetItems: Set<String> = []
    @State private var customItemName = ""
    @State private var selectedTab = 0
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Tab 1: 预设选择
                PresetItemSelectorView(
                    category: categoryEnum,
                    selectedItems: $selectedPresetItems
                )
                .tabItem { 
                    Label(
                        localization.currentLanguage == .chinese ? "预设" : "Preset",
                        systemImage: "list.bullet"
                    )
                }
                .tag(0)
                
                // Tab 2: 自定义输入（与 AddCustomItemSheet 一致）
                Form {
                    Section(header: Text(
                        localization.currentLanguage == .chinese ? "物品名称" : "Item Name"
                    )) {
                        TextField(
                            localization.currentLanguage == .chinese ? "输入物品名称" : "Enter item name",
                            text: $customItemName
                        )
                    }
                    
                    Section {
                        Text(
                            localization.currentLanguage == .chinese
                                ? "新增的物品会添加到「\(category)」分类下。"
                                : "The new item will be added to the \"\(categoryEnum.nameEN)\" category."
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .tabItem { 
                    Label(
                        localization.currentLanguage == .chinese ? "自定义" : "Custom",
                        systemImage: "pencil"
                    )
                }
                .tag(1)
            }
            .navigationTitle(localization.currentLanguage == .chinese ? "添加物品" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.currentLanguage == .chinese ? "取消" : "Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.currentLanguage == .chinese ? "添加" : "Add") {
                        addItems()
                    }
                    .disabled(!canAddItems)
                }
            }
            .alert(
                localization.currentLanguage == .chinese ? "错误" : "Error",
                isPresented: $showingError
            ) {
                Button(localization.currentLanguage == .chinese ? "确定" : "OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var canAddItems: Bool {
        if selectedTab == 0 {
            return !selectedPresetItems.isEmpty
        } else {
            return !customItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    private func addItems() {
        var itemsToAdd: [TripItem] = []
        
        if selectedTab == 0 {
            // 添加预设 Item
            let presetItems = PresetData.shared.allItems
                .filter { $0.category == categoryEnum }
                .filter { selectedPresetItems.contains($0.id) }
            itemsToAdd.append(contentsOf: presetItems.map { $0.toTripItem() })
        } else {
            // 添加自定义 Item
            let trimmedName = customItemName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedName.isEmpty {
                errorMessage = localization.currentLanguage == .chinese
                    ? "物品名称不能为空"
                    : "Item name cannot be empty"
                showingError = true
                return
            }
            
            // 检查重复
            // TODO: 实现重复检测逻辑
            
            let customItem = TripItem(
                id: UUID().uuidString,
                name: trimmedName,
                nameEn: trimmedName,  // 简化：使用相同名称
                category: category,
                categoryEn: categoryEnum.nameEN,
                isChecked: false
            )
            itemsToAdd.append(customItem)
        }
        
        if itemsToAdd.isEmpty {
            errorMessage = localization.currentLanguage == .chinese
                ? "请至少选择一个物品"
                : "Please select at least one item"
            showingError = true
            return
        }
        
        // 调用回调添加 Item
        // TODO: 实现添加逻辑
        
        dismiss()
    }
}
```

---

## 6. 实现建议

### 6.1 开发顺序

1. **Phase 1：完善删除功能**
   - 添加删除确认对话框（F-1.2）
   - 完善空分类处理（F-1.5）

2. **Phase 2：实现添加功能**
   - 将 `CategorySection` 改为使用 `DisclosureGroup`（与 ItemManagementView 一致）
   - 在 `DisclosureGroup` 底部添加「添加物品」按钮（样式与 Item 管理一致，F-2.1）
   - 创建 `AddItemSheet` 组件（使用 `sheet(item:)` 方式，与 AddCustomItemSheet 一致）
   - 实现预设 Item 选择器（按分类过滤，F-2.2）
   - 实现自定义 Item 输入（Form + TextField，与 AddCustomItemSheet 一致，F-2.3）
   - 实现去重处理（F-2.4）
   - 确保 Toolbar 按钮布局和禁用逻辑与 Item 管理一致

### 6.2 技术要点

1. **数据持久化**：所有变更需立即保存到 SwiftData
2. **去重逻辑**：基于 Item ID 进行去重检测，预设 Item 选择器中已添加的 Item 显示为已选状态
3. **分类绑定**：添加的 Item 自动归属到触发添加操作的分类，无需用户再次选择
4. **国际化**：所有新增 UI 文本需支持中英文切换
5. **Live Activity**：Item 增删时需更新 Live Activity 进度

### 6.3 测试要点

1. **删除功能**：
   - 删除预设 Item（验证删除确认对话框）
   - 删除用户自定义添加的 Item（验证删除确认对话框和永久删除）
   - 删除分类下最后一个 Item（空分类处理）
   - 删除后进度更新正确性
   - 验证预设 Item 和自定义 Item 使用相同的删除交互方式

2. **添加功能**：
   - 在每个分类下点击「添加物品」按钮
   - 从预设添加多个 Item（仅显示当前分类下的预设 Item）
   - 添加自定义 Item（自动归属到当前分类）
   - 重复添加检测（已添加的 Item 在预设选择器中显示为已选）
   - 添加后 Item 显示在正确的分类下
   - 添加后进度更新正确性

---

## 7. 与现有功能的集成

### 7.1 与 Live Activity 集成

- Item 增删时，调用 `activityManager.updateActivity()` 更新进度
- 确保进度计算准确：`checkedCount/totalCount`

### 7.2 与归档功能集成

- 已归档的 Trip 应禁用编辑功能（只读模式）
- 或允许编辑，但编辑后自动取消归档状态

### 7.3 与 Item 管理功能集成

- 自定义 Item 不添加到全局 Item 库（仅属于当前 Trip）
- 预设 Item 的修改不影响已创建的 Trip（除非用户手动更新）
- **删除功能统一**：预设 Item 和用户自定义添加的 Item 都支持删除，使用相同的删除交互方式（横滑删除）
- 删除用户自定义添加的 Item 后，该 Item 永久从 Trip 中移除
- 删除预设 Item 后，用户可以通过添加功能重新添加该预设 Item

---

## 8. 边界情况处理

### 8.1 空分类处理

- 当分类下所有 Item 被删除后，分类仍保留在列表中
- 显示空状态提示：「该分类暂无物品」
- 或自动隐藏空分类（需配置选项）

### 8.2 删除自定义 Item 的恢复

- 用户自定义添加的 Item 删除后无法恢复（与预设 Item 不同）
- 删除确认对话框应明确提示用户删除自定义 Item 的不可逆性
- 考虑在删除确认对话框中区分预设 Item 和自定义 Item 的提示文案

### 8.3 大量 Item 性能

- 使用 `LazyVStack` 确保列表性能
- Item 搜索使用本地过滤，避免频繁数据库查询
- 删除操作应高效，不影响列表滚动性能

---

## 9. 后续扩展建议

1. **批量操作**：支持批量删除、批量添加 Item
2. **Item 排序**：支持手动调整 Item 顺序
3. **分类折叠记忆**：记住用户的分类展开/折叠状态
4. **导入/导出**：支持从其他 Trip 导入 Item
5. **自定义分类**：未来版本可考虑支持用户创建自定义分类

---

*文档维护：实现时请同步更新本 Spec 与主 PRD，并标注完成状态。*
