# SmartPack v1.5 需求规格说明 (Spec)

> **文档版本**：v1.5  
> **基于版本**：PRD v1.4 + SPEC Input-Output Mapping  
> **创建日期**：2026-02-02  
> **状态**：待实现

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.5 | 2026-02-02 | 交互优化 + Live Activity 支持 |
| v1.4 | 2026-02-02 | 修正标签与 Item 关系 + Item 管理 |
| v1.3 | - | UI/UX 优化 + 自定义标签 + 行程归档 |
| v1.2 | - | 首次欢迎页 + 性别设置 |
| v1.1 | - | MVP 初始版本 |

---

## 1. 需求概述

v1.5 版本聚焦于**交互体验优化**和**iOS 原生功能集成**，主要包括：

- **横滑删除操作**：Trip 列表和 Item 列表支持原生横滑删除
- **导航优化**：归档后自动返回列表页
- **Live Activity**：锁屏显示打包进度（iOS 16.1+）

---

## 2. 功能需求详情

### 2.1 Trip Item 横滑删除

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-1.1** | **Item 横滑删除** | **P0** | 在 `PackingListView` 中，用户可以通过**向左横滑**任意 Item 行，显示删除按钮，点击后删除该 Item。 |
| **F-1.2** | **删除确认** | **P1** | 删除 Item 前弹出确认对话框（可选，或直接删除）。 |
| **F-1.3** | **删除后更新** | **P0** | 删除 Item 后，立即更新进度圆环和完成状态。 |
| **F-1.4** | **数据持久化** | **P0** | 删除操作需立即保存到 SwiftData，确保数据一致性。 |

**技术实现**：
- 使用 SwiftUI 原生 `.swipeActions()` modifier
- 删除操作直接修改 `trip.items` 数组并保存

**UI 示例**：
```
[Item 名称]                    [删除]
  ← 横滑显示删除按钮
```

---

### 2.2 Item 管理中预设 Item 横滑删除

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-2.1** | **预设 Item 可删除** | **P0** | 在 `ItemManagementView` 中，**预设 Item 也支持横滑删除**（与自定义 Item 一致）。 |
| **F-2.2** | **删除约束** | **P0** | 每个标签下**至少保留 1 个 Item**（预设 + 自定义合计），不足时禁止删除并提示。 |
| **F-2.3** | **删除后同步** | **P0** | 删除预设 Item 后，需从 `PresetData` 的映射中移除（或标记为已删除），确保后续生成的 Trip 不包含已删除的预设 Item。 |

**技术实现**：
- 使用 `CustomItemManager` 扩展，新增 `deletedPresetItemIds: Set<String>` 存储已删除的预设 Item ID
- 在 `PresetData.generatePackingList()` 中过滤已删除的预设 Item

**数据存储**：
```swift
// UserDefaults 中存储
"deletedPresetItemIds": ["act_run_001", "occ_biz_002", ...]
```

**UI 示例**：
```
预设 Item: 跑鞋                    [删除]
  ← 横滑显示删除按钮（与自定义 Item 一致）
```

---

### 2.3 归档后返回列表页

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-3.1** | **归档后导航** | **P0** | 当用户在 `PackingListView` 中点击「归档行程」并确认后，**自动返回首页列表**（`HomeView`）。 |
| **F-3.2** | **导航方式** | **P0** | 使用 `NavigationStack` 的 `dismiss()` 或 `navigationBarBackButtonHidden` 控制，确保返回行为一致。 |
| **F-3.3** | **状态更新** | **P0** | 返回列表页后，列表自动刷新，归档的 Trip 显示在「已归档」分组底部。 |

**技术实现**：
- 在 `PackingListView` 的归档确认回调中调用 `dismiss()`
- 确保 `isNewlyCreated = false` 时也能正确返回

**用户流程**：
```
PackingListView → 点击归档 → 确认 → 自动返回 HomeView
```

---

### 2.4 Trip 列表横滑删除

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-4.1** | **Trip 横滑删除** | **P0** | 在 `HomeView` 的 Trip 列表中，用户可以通过**向左横滑**任意 Trip 行，显示删除按钮。 |
| **F-4.2** | **删除确认** | **P1** | 删除 Trip 前弹出确认对话框，提示「删除后无法恢复」。 |
| **F-4.3** | **删除操作** | **P0** | 确认后从 SwiftData 中删除该 Trip，列表立即更新。 |
| **F-4.4** | **空状态处理** | **P0** | 删除最后一个 Trip 后，显示空状态提示。 |

**技术实现**：
- 使用 SwiftUI 原生 `.swipeActions()` modifier
- 删除操作使用 `modelContext.delete(trip)` 并保存

**UI 示例**：
```
[行程名称] [进度]                  [删除]
  ← 横滑显示删除按钮
```

---

### 2.5 iOS Live Activity（锁屏进度显示）

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-5.1** | **Live Activity 启动** | **P0** | 当用户进入 `PackingListView` 且 Trip 未完成时，自动启动 Live Activity，在锁屏显示打包进度。 |
| **F-5.2** | **进度更新** | **P0** | 每次勾选/取消 Item 时，实时更新 Live Activity 的进度（已勾选数/总数）。 |
| **F-5.3** | **显示内容** | **P0** | 锁屏显示：行程名称、进度百分比、已勾选数/总数、进度条。 |
| **F-5.4** | **自动结束** | **P0** | 当 Trip 全部完成或用户归档后，自动结束 Live Activity。 |
| **F-5.5** | **手动结束** | **P1** | 用户可在设置中手动结束 Live Activity。 |
| **F-5.6** | **系统要求** | **P0** | 仅支持 iOS 16.1+，低版本自动降级（不显示 Live Activity）。 |

**技术实现**：
- 使用 `ActivityKit` 框架（iOS 16.1+）
- 创建 `PackingActivity` 实体和 `PackingActivityAttributes`
- 在 `PackingListView` 的 `onAppear` 启动，`onDisappear` 或完成时结束

**数据结构**：
```swift
struct PackingActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var tripName: String
        var checkedCount: Int
        var totalCount: Int
        var progress: Double
    }
}
```

**锁屏显示示例**：
```
┌─────────────────────────┐
│ SmartPack               │
│ 上海商务出差             │
│ ████████░░ 80%          │
│ 8/10 items checked      │
└─────────────────────────┘
```

**实现步骤**：
1. 创建 `ActivityKit` 相关文件（Attributes、ContentState）
2. 在 `PackingListView` 中集成启动/更新/结束逻辑
3. 添加系统版本检查（iOS 16.1+）
4. 处理后台更新（使用 `BackgroundTasks` 或远程推送）

---

## 3. 非功能性需求

### 3.1 性能要求
- 横滑删除操作响应时间 < 100ms
- Live Activity 更新延迟 < 500ms

### 3.2 兼容性
- Live Activity 仅支持 iOS 16.1+
- 横滑删除支持 iOS 15+

### 3.3 数据一致性
- 删除操作需立即持久化，避免数据丢失
- Live Activity 状态需与 Trip 数据同步

---

## 4. 实现优先级

| 功能 | 优先级 | 预计工作量 | 备注 |
|------|--------|------------|------|
| Trip Item 横滑删除 | P0 | 2h | 核心交互优化 |
| Trip 列表横滑删除 | P0 | 2h | 核心交互优化 |
| 归档后返回列表页 | P0 | 1h | 导航优化 |
| Item 管理预设删除 | P0 | 3h | 需扩展数据模型 |
| Live Activity | P1 | 8h | 需 ActivityKit 集成 |

---

## 5. 技术依赖

### 5.1 框架
- **SwiftUI**：横滑操作（`.swipeActions()`）
- **ActivityKit**：Live Activity（iOS 16.1+）
- **SwiftData**：数据持久化

### 5.2 系统要求
- **最低版本**：iOS 15.0（横滑删除）
- **推荐版本**：iOS 16.1+（Live Activity）

---

## 6. 测试要点

### 6.1 功能测试
- [ ] Trip Item 横滑删除功能正常
- [ ] Item 管理中预设 Item 可删除
- [ ] 删除约束（至少保留 1 个 Item）生效
- [ ] 归档后正确返回列表页
- [ ] Trip 列表横滑删除功能正常
- [ ] Live Activity 在锁屏正确显示
- [ ] Live Activity 进度实时更新
- [ ] Live Activity 自动结束

### 6.2 边界测试
- [ ] 删除最后一个 Item 时的提示
- [ ] 删除最后一个 Trip 时的空状态
- [ ] iOS 15 设备上 Live Activity 不崩溃
- [ ] 多个 Trip 同时存在时的 Live Activity 管理

---

## 7. 后续优化建议

1. **批量删除**：支持多选 Item 批量删除
2. **撤销删除**：删除后 3 秒内可撤销
3. **Live Activity 交互**：锁屏上直接勾选 Item（需 iOS 17+）
4. **通知集成**：打包完成时发送通知

---

*文档维护：实现时请同步更新本 Spec 与主 PRD，并标注完成状态。*
