# SmartPack Trip 设置 Section 增强 PRD

> **文档类型**：产品需求文档 (PRD)  
> **版本**：v1.0  
> **创建日期**：2026-02-15  
> **状态**：待评审  
> **基于**：PRD-Packing-List-UI-Enhancement.md

---

## 1. 需求背景

### 1.1 当前状态

根据 PRD-Packing-List-UI-Enhancement.md，SmartPack 应用已经在打包清单页面（PackingListView）中添加了 Trip 基本设置 Section，用于显示本次 Trip 的基本设置信息（日期范围、场景标签）。

当前实现：
- Trip 设置 Section 显示在进度条和天气之间
- 显示行程日期范围和场景标签
- 标签按分组显示（旅行活动、特定场合、出行配置）

### 1.2 改动动机

用户希望增强 Trip 设置 Section 的功能和体验，以：
- **简化标签显示**：不按分组显示，直接展示所有选定的标签，更简洁直观
- **增强灵活性**：支持收起/展开功能，节省屏幕空间

---

## 2. 需求范围

### 2.1 功能需求

#### 需求 1：标签显示不分组

**描述**：Trip 设置 Section 中的场景标签不再按分组（旅行活动、特定场合、出行配置）显示，而是直接展示所有用户选定的标签。

**具体要求**：
- **移除分组标题**：不再显示"旅行活动"、"特定场合"、"出行配置"等分组标题
- **直接展示标签**：所有选定的标签直接展示，如：🏃跑步、🎉宴会、✈️国际旅行
- **标签排列**：标签按选择顺序或字母顺序排列（建议按选择顺序）
- **紧凑排版**：标签之间间距较小（建议 4pt），整体布局节省空间

**用户流程**：
1. 用户进入打包清单页面
2. 看到 Trip 设置 Section
3. 直接看到所有选定的标签（不分组），如：🏃跑步、🎉宴会、✈️国际旅行
4. 标签显示清晰，无需理解分组概念

**视觉设计**：
```
修改前（分组显示）：
┌─────────────────────────┐
│ ⚙️ 清单设置              │
│ 📅 2026/02/15 - 02/18   │
│ 旅行活动: 🏃跑步 🧗攀岩  │
│ 特定场合: 🎉宴会 💼商务   │
│ 出行配置: ✈️国际旅行     │
└─────────────────────────┘

修改后（不分组显示）：
┌─────────────────────────┐
│ ⚙️ 清单设置          ▼ │
│ 📅 2026/02/15 - 02/18   │
│ 🏃跑步 🎉宴会 ✈️国际旅行 │
└─────────────────────────┘
```

#### 需求 2：Trip 设置 Section 可收起/展开

**描述**：Trip 设置 Section 支持收起和展开功能，**以每个清单（Trip）为单位独立管理收起/展开状态**。首次进入某个 Trip 的打包清单页面时默认展开，用户收起后该 Trip 的设置 Section 保持收起状态（需要持久化），直到用户再次展开。不同 Trip 之间的收起/展开状态互不影响。

**具体要求**：
- **默认状态**：
  - **每个 Trip 独立管理**：首次进入某个 Trip 的打包清单页面时，Trip 设置 Section 默认展开显示
  - **状态独立保存**：如果用户之前已经收起过该 Trip 的设置 Section，则保持收起状态
  - **不同 Trip 互不影响**：Trip A 的设置 Section 收起状态不会影响 Trip B 的设置 Section 状态
- **交互方式**：
  - 在 Trip 设置 Section 头部添加展开/收起按钮（chevron.up / chevron.down 图标）
  - 点击按钮可以切换展开/收起状态
  - 收起时隐藏设置详情内容（日期范围、标签），只显示标题栏
- **状态持久化**：
  - **必须使用 Trip 特定设置**：使用 `UserDefaults` 保存每个 Trip 的收起/展开状态
  - **Key 格式**：`"tripSettingsSectionCollapsed_\(trip.id.uuidString)"`，确保每个 Trip 有独立的 Key
  - **重要**：每个 Trip 的设置 Section 收起状态独立保存，互不影响
- **动画效果**：
  - 展开/收起时使用平滑的动画过渡（`.animation(.spring())`）
  - 动画时长约 0.3 秒

**用户流程**：
1. 用户首次进入 Trip A 的打包清单页面
2. Trip A 的设置 Section 默认展开显示设置信息
3. 用户点击收起按钮
4. Trip A 的设置 Section 收起，只显示标题栏
5. 用户离开页面后再次进入 Trip A，设置 Section 保持收起状态
6. 用户点击展开按钮，Trip A 的设置 Section 重新展开
7. **关键**：用户切换到 Trip B 时，Trip B 的设置 Section 状态独立管理（如果之前未收起过，则默认展开）

**视觉设计**：
```
展开状态：
┌─────────────────────────┐
│ ⚙️ 清单设置          ▼ │
│ 📅 2026/02/15 - 02/18   │
│ 🏃跑步 🎉宴会 ✈️国际旅行 │
└─────────────────────────┘

收起状态：
┌─────────────────────────┐
│ ⚙️ 清单设置          ▲ │
└─────────────────────────┘
```

---

## 3. 功能详细设计

### 3.1 标签显示不分组设计

#### 3.1.1 UI/UX 设计

**修改前**：
- 按分组显示标签，每组有标题
- 布局：分组标题 + 标签列表

**修改后**：
- 直接展示所有选定的标签，无分组标题
- 布局：标签列表（FlowLayout）
- 标签按选择顺序排列

#### 3.1.2 技术实现要点

**文件**：`SmartPack/SmartPack/Components/PackingList/TripSettingsCard.swift`

**需要修改**：
- 移除分组逻辑：不再使用 `TagGroup.allCases` 遍历分组
- 直接获取所有选定的标签：从 `trip.selectedTags` 获取所有标签对象
- 使用 `FlowLayout` 直接展示所有标签

**关键代码逻辑**：
```swift
// 获取所有选定的标签（不分组）
private var allSelectedTags: [Tag] {
    trip.selectedTags.compactMap { tagId in
        PresetData.shared.allTags[tagId]
    }
}

// 在视图中直接展示所有标签
if !trip.selectedTags.isEmpty {
    FlowLayout(spacing: 4) { // 紧凑：减小标签间距
        ForEach(allSelectedTags) { tag in
            TagChip(tag: tag)
        }
    }
}
```

### 3.2 Trip 设置 Section 可收起/展开设计

#### 3.2.1 UI/UX 设计

**展开状态**：
- 显示完整的设置内容（日期范围、标签）
- 头部右侧显示向下箭头（chevron.down）表示可收起

**收起状态**：
- 只显示头部（标题、收起/展开按钮）
- 头部右侧显示向上箭头（chevron.up）表示可展开
- 设置详情内容隐藏

#### 3.2.2 技术实现要点

**文件**：
- `SmartPack/SmartPack/Components/PackingList/TripSettingsCard.swift` - 添加收起/展开功能

**实现方案**：
```swift
struct TripSettingsCard: View {
    @Bindable var trip: Trip
    @EnvironmentObject var localization: LocalizationManager
    @State private var isCollapsed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 头部（始终显示）
            HStack {
                Image(systemName: "gearshape.fill")
                Text(localization.currentLanguage == .chinese ? "清单设置" : "List Settings")
                
                Spacer()
                
                // 收起/展开按钮
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isCollapsed.toggle()
                        // 保存状态
                        let key = "tripSettingsSectionCollapsed_\(trip.id.uuidString)"
                        UserDefaults.standard.set(isCollapsed, forKey: key)
                    }
                } label: {
                    Image(systemName: isCollapsed ? "chevron.up" : "chevron.down")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            // 设置详情（根据 isCollapsed 显示/隐藏）
            if !isCollapsed {
                VStack(alignment: .leading, spacing: 6) {
                    // 日期范围
                    if let startDate = trip.startDate, let endDate = trip.endDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                            Text(formatDateRange(start: startDate, end: endDate))
                        }
                    }
                    
                    // 标签（不分组）
                    if !trip.selectedTags.isEmpty {
                        FlowLayout(spacing: 4) {
                            ForEach(allSelectedTags) { tag in
                                TagChip(tag: tag)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
        .background(...)
        .onAppear {
            // 读取该 Trip 的收起状态
            let key = "tripSettingsSectionCollapsed_\(trip.id.uuidString)"
            isCollapsed = UserDefaults.standard.bool(forKey: key)
        }
    }
    
    // 获取所有选定的标签（不分组）
    private var allSelectedTags: [Tag] {
        trip.selectedTags.compactMap { tagId in
            PresetData.shared.allTags[tagId]
        }
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .chinese ? "yyyy/MM/dd" : "MMM d, yyyy"
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        return "\(startStr) - \(endStr)"
    }
}
```

---

## 4. 改动影响范围

### 4.1 涉及文件

- **`SmartPack/SmartPack/Components/PackingList/TripSettingsCard.swift`**
  - 修改标签显示逻辑：移除分组显示，直接展示所有标签
  - 添加收起/展开功能
  - 添加状态管理

### 4.2 数据模型

- **`Trip` 模型**：无需修改，已有 `startDate`、`endDate`、`selectedTags`、`items` 字段
- **`Tag` 模型**：无需修改，已有 `group`、`icon`、`displayName` 方法
- **`PresetData`**：无需修改，已有 `allTags` 字典和 `generatePackingList()` 方法

### 4.3 用户体验影响

- **正面影响**：
  - 标签显示更简洁直观，无需理解分组概念
  - 设置 Section 可以收起，节省屏幕空间

- **注意事项**：
  - **Trip 设置 Section 收起状态需要以每个 Trip 为单位独立持久化**，避免用户每次进入都需要重新收起，同时确保不同 Trip 之间的状态互不影响

---

## 5. 验收标准

### 5.1 功能验收

- ✅ **标签显示不分组**：
  - 标签直接展示，不显示分组标题
  - 所有选定的标签正确显示
  - 标签图标和名称正确显示
  - 标签排列清晰，排版紧凑

- ✅ **Trip 设置 Section 可收起/展开**：
  - **每个 Trip 独立管理**：首次进入某个 Trip 的页面时默认展开
  - 点击收起按钮后，设置详情隐藏
  - 点击展开按钮后，设置详情显示
  - **状态独立持久化**：每个 Trip 的收起状态正确持久化（刷新页面后保持）
  - **状态互不影响**：Trip A 的收起状态不影响 Trip B 的状态
  - 展开/收起动画流畅


### 5.2 用户体验验收

- ✅ 标签显示简洁直观，不分组显示
- ✅ Trip 设置 Section 收起/展开操作流畅，状态持久化正常
- ✅ 所有操作都有适当的视觉反馈

### 5.3 边界情况验收

- ✅ 没有选择任何标签时，Trip 设置 Section 只显示日期范围
- ✅ 选择了大量标签时，标签正确换行显示，不溢出
- ✅ Trip 设置 Section 收起后，页面布局正常，无空白区域
- ✅ **关键测试：不同 Trip 的设置 Section 状态独立**
  - 测试场景 1：收起 Trip A 的设置 Section，切换到 Trip B，Trip B 的设置 Section 状态不受影响
  - 测试场景 2：收起 Trip A 的设置 Section，退出应用后重新进入 Trip A，设置 Section 保持收起状态
  - 测试场景 3：Trip A 收起，Trip B 展开，两个状态互不影响

---

## 6. 技术实现建议

### 6.1 代码组织

- 保持现有代码风格和命名规范
- 修改 `TripSettingsCard` 组件，移除分组显示逻辑
- **必须使用 Trip 特定设置**：
  - Trip 设置 Section 收起状态：使用 `UserDefaults` 管理，Key：`"tripSettingsSectionCollapsed_\(trip.id.uuidString)"`
  - 确保每个 Trip 的状态独立保存，互不影响
- 添加适当的注释说明新功能，强调每个 Trip 的状态独立管理

### 6.2 布局建议

- 使用 `FlowLayout` 实现标签的多行布局（不分组）
- **紧凑排版**：
  - 减小 VStack/HStack 的 spacing 值（建议 4-6pt）
  - 标签 Chip 使用较小的 padding（水平 8pt，垂直 4pt）
  - 标签之间间距较小（建议 4pt）
  - 字体和图标尺寸适当减小，保持可读性的同时节省空间
- 保持与现有 Section 的视觉风格一致（圆角、内边距、背景色）
- 考虑使用 `DisclosureGroup` 实现 Trip 设置 Section 的收起/展开（如果 SwiftUI 版本支持）

### 6.3 性能考虑

- Trip 设置 Section 收起状态使用轻量级存储（`UserDefaults`）
- Trip 设置 Section 只在需要时渲染（`if trip.totalCount > 0`）
- 标签渲染使用 `ForEach`，支持大量标签的场景（不分组显示）

---

## 7. 后续优化建议（可选）

### 7.1 用户体验优化

- 考虑在 Weather Section 收起时显示简要天气信息（如最高温/最低温）

### 7.2 功能扩展

- 考虑添加设置项的复制功能（复制为新的 Trip）
- 考虑添加设置模板功能（保存常用设置组合）
- 考虑添加批量编辑功能（同时编辑多个 Trip）

---

## 8. 附录

### 8.1 相关文档

- `PRD-Packing-List-UI-Enhancement.md` - Trip 设置 Section 初始实现 PRD
- `PRD-SmartPack-v1.0.md` - 主 PRD 文档
- `TripSettingsCard.swift` - Trip 设置展示组件
- `Trip.swift` - Trip 模型定义
- `Tag.swift` - 标签模型定义

### 8.2 参考资源

- SwiftUI DisclosureGroup 文档
- SwiftUI UserDefaults 文档
- iOS Human Interface Guidelines

---

**文档状态**：待评审  
**下一步**：评审通过后，按照本 PRD 进行技术实现。
