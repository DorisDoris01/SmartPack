# SmartPack Trip Archive 功能增强 PRD

> **文档类型**：产品需求文档 (PRD)  
> **版本**：v1.0  
> **创建日期**：2026-02-15  
> **状态**：待评审  
> **基于**：PRD-SmartPack-v1.0.md

---

## 1. 需求背景

### 1.1 当前状态

SmartPack 应用目前支持以下 Trip 管理功能：
- 在列表页（HomeView）可以删除 Trip（横滑删除）
- 在详情页（PackingListView）可以手动归档 Trip（通过菜单）
- 已完成和未完成的 Trip 在列表页分开显示（Active / Archived）

### 1.2 改动动机

用户希望增强 Trip 的归档和删除功能，以：
- 在列表页更方便地管理 Trip（Archive/Delete）
- 完成 Trip 后自动归档并返回列表页，提升用户体验
- 统一 Archive 和 Delete 的操作入口，无论 Trip 是否完成

---

## 2. 需求范围

### 2.1 功能需求

#### 需求 1：列表页 Archive 和 Delete 功能

**描述**：在列表页（HomeView）中，用户可以通过横滑操作对任何 Trip（已完成或未完成）进行 Archive 和 Delete 操作。

**具体要求**：
- **Active Trips（未归档）**：
  - 右侧横滑：显示 "Delete" 按钮（红色，带确认对话框）和 "Archive" 按钮（蓝色，无需确认）
  - Delete 操作需要显示确认对话框，Archive 不需要确认
- **Archived Trips（已归档）**：
  - 右侧横滑：显示 "Delete" 按钮（红色，带确认对话框）和 "Unarchive" 按钮（蓝色，无需确认）
  - Delete 操作需要显示确认对话框，Unarchive 不需要确认
- **适用范围**：所有 Trip，无论完成状态（progress=100% 或未完成）

**用户流程**：
1. 用户在列表页看到 Trip
2. 用户向右横滑 Trip 行
3. 显示对应的操作按钮（Delete，Archive/Unarchive）
4. 点击按钮执行操作（Archive 无需确认，Delete 需要确认，Unarchive 无需确认）

#### 需求 2：完成 Trip 后自动 Archive 并返回列表页

**描述**：当用户完成一个 Trip（progress=100%，即所有物品都已勾选）后，系统自动将该 Trip 归档，并在庆祝动画结束后自动返回列表页。

**具体要求**：
- **触发条件**：Trip 的 `isAllChecked` 状态从 `false` 变为 `true`（即 progress=100%）
- **自动操作**：
  1. 自动调用 `trip.archive()` 方法
  2. 结束 Live Activity（如果正在运行）
  3. 显示庆祝动画（CelebrationOverlay）
  4. 庆祝动画结束后（约 2.5 秒）自动调用 `dismiss()` 返回列表页
- **无需确认**：自动归档操作不需要用户确认
- **用户体验**：
  - 用户完成最后一个物品勾选
  - 显示庆祝动画和撒花效果
  - 自动归档并返回列表页
  - Trip 在列表页的 "Archived" 区域显示

**用户流程**：
1. 用户在详情页勾选最后一个物品
2. Trip 进度达到 100%
3. 系统自动归档 Trip
4. 显示庆祝动画（2.5 秒）
5. 自动返回列表页
6. Trip 显示在列表页的 "Archived" 区域

#### 需求 3：列表页 Unarchive 功能

**描述**：用户可以将已归档的 Trip 取消归档（Unarchive），使其重新显示在 Active Trips 区域，方便继续使用或修改。

**具体要求**：
- **触发方式**：在列表页（HomeView）的 Archived Trips 区域，通过右侧横滑操作触发
- **操作按钮**：
  - 显示位置：右侧横滑操作区域
  - 按钮样式：蓝色背景，图标为 "arrow.uturn.backward"
  - 按钮文字：中文显示 "取消归档"，英文显示 "Unarchive"
- **执行方式**：
  - 无需确认对话框，点击后直接执行
  - 调用 `trip.unarchive()` 方法
  - 自动保存到 SwiftData
- **执行结果**：
  - Trip 的 `isArchived` 状态从 `true` 变为 `false`
  - Trip 从 "Archived" 区域移动到 "Active" 区域
  - Trip 在 Active 区域按创建时间倒序排列
  - **重要：Trip 的 progress（进度）和已勾选的物品状态完全保持不变**
    - `checkedCount`（已勾选数量）保持不变
    - `totalCount`（总物品数）保持不变
    - `progress`（进度百分比）保持不变
    - `isAllChecked`（是否全部完成）状态保持不变
    - 所有物品的 `isChecked` 状态保持不变
  - 如果 Trip 未完成（progress < 100%），可以重新启动 Live Activity
- **适用范围**：
  - 所有已归档的 Trip，无论完成状态
  - 包括手动归档和自动归档的 Trip
- **视觉反馈**：
  - 操作后立即更新列表显示
  - Trip 行平滑移动到 Active 区域
  - 无需额外的成功提示（操作结果直观可见）

**用户流程**：
1. 用户在列表页的 "Archived" 区域看到已归档的 Trip
2. 用户向右横滑 Trip 行
3. 显示 "Unarchive" 按钮（蓝色）和 "Delete" 按钮（红色）
4. 用户点击 "Unarchive" 按钮
5. Trip 立即取消归档，移动到 "Active" 区域
6. 用户可以继续编辑或使用该 Trip

**使用场景**：
- 用户想要复用之前归档的 Trip 模板
- 用户误操作归档了 Trip，需要恢复
- 用户想要继续编辑已归档但未完成的 Trip
- 用户想要查看已归档 Trip 的详细信息

**注意事项**：
- Unarchive 操作是可逆的，用户可以再次 Archive
- **关键要求：Unarchive 后 Trip 的 progress 必须与 Archive 之前完全一致**
  - 所有物品的勾选状态（`isChecked`）必须保持不变
  - 进度百分比（`progress`）必须保持不变
  - 已勾选数量（`checkedCount`）必须保持不变
  - 完成状态（`isAllChecked`）必须保持不变
- Unarchive 后，如果 Trip 未完成，Live Activity 可以重新启动，并显示正确的进度
- Unarchive 操作是本地操作，无需网络连接
- Unarchive 操作只改变 `isArchived` 状态，不修改任何其他 Trip 属性

---

## 3. 功能详细设计

### 3.1 列表页 Archive/Delete/Unarchive 功能设计

#### 3.1.1 UI/UX 设计

**Active Trips 横滑操作**：
```
Trip Row → [Archive] [Delete]
  内容       蓝色      红色
```

**Archived Trips 横滑操作**：
```
Trip Row → [Unarchive] [Delete]
  内容        蓝色        红色
```

**操作反馈**：
- Archive：直接执行，无需确认
- Delete：显示确认对话框，文案："删除后无法恢复，确认删除？"
- Unarchive：直接执行，无需确认

#### 3.1.2 技术实现要点

**文件**：`SmartPack/SmartPack/Views/Main/HomeView.swift`

**需要添加**：
- `archiveTrip(_ trip: Trip)` - Archive 操作（直接执行，无需确认）
- `unarchiveTrip(_ trip: Trip)` - Unarchive 操作（直接执行，无需确认）

**修改点**：
- Active Trips 的 `ForEach`：在右侧横滑操作中添加 Archive 按钮（蓝色，无需确认）
- Archived Trips 的 `ForEach`：在右侧横滑操作中添加 Unarchive 按钮（蓝色，无需确认）
- Delete 按钮保留在右侧横滑操作中（红色，带确认对话框）

**Unarchive 方法实现要点**：
```swift
private func unarchiveTrip(_ trip: Trip) {
    // 重要：unarchive() 方法只修改 isArchived 状态
    // 不会影响 progress、checkedCount、items 等任何其他属性
    trip.unarchive()
    try? modelContext.save()
    
    // 如果 Trip 未完成，可以重新启动 Live Activity
    // Live Activity 会显示正确的进度（与 Archive 前一致）
    if !trip.isAllChecked {
        // 可选：重新启动 Live Activity，显示当前进度
        // activityManager.startActivity(
        //     tripName: trip.name,
        //     checkedCount: trip.checkedCount,  // 保持原有进度
        //     totalCount: trip.totalCount
        // )
    }
}
```

**Unarchive 后的行为**：
- Trip 立即从 Archived 区域移除
- Trip 立即添加到 Active 区域顶部
- **Trip 的 progress 和所有物品状态完全保持不变**
- 列表自动刷新，无需手动刷新
- 如果 Trip 未完成，可以重新启动 Live Activity 显示正确的进度（与 Archive 前一致）
- 进度圆环显示与 Archive 前相同的进度百分比

### 3.2 完成 Trip 后自动 Archive 设计

#### 3.2.1 UI/UX 设计

**完成流程**：
1. 用户勾选最后一个物品
2. 触发 `toggleItemAndCheckCompletion`
3. 检测到 `isAllChecked` 变为 `true`
4. 自动调用 `trip.archive()`
5. 显示庆祝动画（CelebrationOverlay）
6. 庆祝动画结束后自动返回列表页

**庆祝动画**：
- 显示时间：2.5 秒
- 内容：撒花效果 + "全部打包完成！🎉" / "All packed! 🎉"
- 完成后：自动调用 `dismiss()` 返回列表页

#### 3.2.2 技术实现要点

**文件**：`SmartPack/SmartPack/Views/Trip/PackingListView.swift`

**需要修改**：
- `onChange(of: trip.isAllChecked)`：添加自动归档逻辑
- `CelebrationOverlay` 的 `onComplete` 回调：改为直接 `dismiss()`，不再显示归档确认对话框

**关键代码逻辑**：
```swift
.onChange(of: trip.isAllChecked) { oldValue, newValue in
    if newValue {
        activityManager.endActivity()
        // 自动归档（无需确认）
        if !trip.isArchived {
            trip.archive()
        }
    }
}

// CelebrationOverlay 回调
CelebrationOverlay(
    isPresented: $showCelebration,
    title: localization.string(for: .allPacked)
) {
    // 自动返回列表页（已自动 archive）
    dismiss()
}
```

---

## 4. 改动影响范围

### 4.1 涉及文件

- **`SmartPack/SmartPack/Views/Main/HomeView.swift`**
  - 在右侧横滑操作中添加 Archive/Unarchive 按钮
  - Archive 和 Unarchive 操作直接执行，无需确认对话框
  - 添加相关方法（archiveTrip、unarchiveTrip）

- **`SmartPack/SmartPack/Views/Trip/PackingListView.swift`**
  - 修改完成 Trip 后的处理逻辑
  - 修改庆祝动画的回调逻辑
  - 移除手动归档确认对话框（完成时）

### 4.2 数据模型

- **`Trip` 模型**：无需修改，已有 `archive()` 和 `unarchive()` 方法
  - `archive()` 方法只修改 `isArchived = true`，不修改其他属性
  - `unarchive()` 方法只修改 `isArchived = false`，不修改其他属性
  - **重要：`unarchive()` 方法不会影响 `items`、`checkedCount`、`progress` 等任何属性**
- **数据持久化**：
  - Archive 操作会自动保存到 SwiftData
  - Unarchive 操作会自动保存到 SwiftData
  - 操作后立即持久化，无需手动保存
  - **重要：持久化时只保存 `isArchived` 状态的变化，不修改其他数据**

### 4.3 用户体验影响

- **正面影响**：
  - 列表页操作更便捷（横滑 Archive/Delete/Unarchive）
  - 完成 Trip 后自动归档，减少手动操作
  - Unarchive 功能让用户可以轻松恢复误操作或复用已归档的 Trip
  - 统一的操作入口，提升一致性
  - Archive/Unarchive 是可逆操作，降低用户操作风险

- **注意事项**：
  - 完成 Trip 后自动返回列表页，用户可能期望继续查看详情
  - 建议在庆祝动画中提示用户 Trip 已自动归档
  - Unarchive 后，如果 Trip 未完成，建议重新启动 Live Activity 以显示进度
  - Unarchive 操作应该立即生效，无需等待网络请求

---

## 5. 验收标准

### 5.1 功能验收

- ✅ **列表页 Archive 功能**：
  - Active Trips 可以右侧横滑 Archive（蓝色按钮）
  - Archive 操作无需确认，直接执行
  - Archive 后 Trip 移动到 Archived 区域

- ✅ **列表页 Delete 功能**：
  - Active/Archived Trips 都可以右侧横滑 Delete（红色按钮）
  - Delete 操作显示确认对话框
  - Delete 后 Trip 从列表中移除

- ✅ **列表页 Unarchive 功能**：
  - Archived Trips 可以右侧横滑 Unarchive（蓝色按钮）
  - Unarchive 操作无需确认，直接执行
  - Unarchive 后 Trip 移动到 Active 区域

- ✅ **完成 Trip 自动 Archive**：
  - 完成最后一个物品勾选后，Trip 自动归档
  - 显示庆祝动画
  - 庆祝动画结束后自动返回列表页
  - Trip 在列表页的 Archived 区域显示

- ✅ **列表页 Unarchive 功能**：
  - Archived Trips 可以右侧横滑 Unarchive（蓝色按钮）
  - Unarchive 操作无需确认，直接执行
  - Unarchive 后 Trip 立即移动到 Active 区域
  - Unarchive 后 Trip 按创建时间倒序排列
  - Unarchive 操作有平滑的视觉反馈
  - **关键验收：Unarchive 后 Trip 的 progress 必须与 Archive 前完全一致**
    - 进度百分比（progress）保持不变
    - 已勾选数量（checkedCount）保持不变
    - 总物品数（totalCount）保持不变
    - 所有物品的勾选状态（isChecked）保持不变
    - 完成状态（isAllChecked）保持不变

- ✅ **Live Activity 处理**：
  - 完成 Trip 时自动结束 Live Activity
  - Archive 操作时结束 Live Activity
  - Unarchive 操作后，如果 Trip 未完成，可以重新启动 Live Activity

### 5.2 用户体验验收

- ✅ 横滑操作流畅，按钮显示正确
- ✅ 确认对话框文案清晰，操作明确
- ✅ 庆祝动画显示正常，自动返回时机合适
- ✅ 所有操作都有适当的视觉反馈

### 5.3 边界情况验收

- ✅ 已完成但未归档的 Trip 可以正常 Archive
- ✅ 未完成的 Trip 可以正常 Archive
- ✅ 已归档的 Trip（已完成，progress=100%）可以正常 Unarchive
  - Unarchive 后 progress 仍为 100%，`isAllChecked` 仍为 `true`
  - 所有物品的 `isChecked` 状态保持不变
- ✅ 已归档的 Trip（未完成，progress < 100%）可以正常 Unarchive，且可以继续编辑
  - Unarchive 后 progress 与 Archive 前完全一致
  - 已勾选的物品保持勾选状态
  - 未勾选的物品保持未勾选状态
- ✅ **关键测试：Unarchive 后 Trip 的进度和勾选状态完全保持不变**
  - 测试场景 1：Archive 一个 progress=50% 的 Trip，然后 Unarchive，progress 仍为 50%
  - 测试场景 2：Archive 一个 progress=100% 的 Trip，然后 Unarchive，progress 仍为 100%
  - 测试场景 3：Archive 一个 progress=0% 的 Trip，然后 Unarchive，progress 仍为 0%
  - 测试场景 4：Archive 后 Unarchive，所有物品的 `isChecked` 状态与 Archive 前完全一致
- ✅ Unarchive 后列表自动刷新，Trip 正确显示在 Active 区域
- ✅ Unarchive 后进度圆环显示正确的进度百分比（与 Archive 前一致）
- ✅ 空列表状态正常显示
- ✅ 网络异常情况下操作正常（本地操作）
- ✅ 连续 Archive/Unarchive 操作正常（可逆操作）
- ✅ 多次 Archive/Unarchive 后，Trip 的 progress 始终保持一致

---

## 6. 技术实现建议

### 6.1 代码组织

- 保持现有代码风格和命名规范
- 添加适当的注释说明新功能
- 遵循现有的错误处理模式

### 6.2 测试建议

- 单元测试：
  - Archive 方法测试
  - Unarchive 方法测试
  - **关键测试：Unarchive 后 progress 保持不变**
    - 测试 Unarchive 后 `checkedCount` 不变
    - 测试 Unarchive 后 `totalCount` 不变
    - 测试 Unarchive 后 `progress` 不变
    - 测试 Unarchive 后所有物品的 `isChecked` 状态不变
  - Archive/Unarchive 可逆性测试
  - 数据持久化测试
  - **测试场景：Archive → Unarchive → 验证 progress 一致性**
- UI 测试：
  - 横滑操作和按钮显示
  - Archive/Unarchive 操作后的列表更新
  - Delete 确认对话框显示
- 集成测试：
  - 完成 Trip 后的完整流程
  - Archive → Unarchive → Archive 的完整流程
  - Unarchive 后 Live Activity 重新启动（如果适用）

### 6.3 性能考虑

- Archive/Unarchive 操作是本地操作，性能影响可忽略
- 庆祝动画和自动返回使用异步延迟，不影响主线程

---

## 7. 后续优化建议（可选）

### 7.1 用户体验优化

- 考虑在庆祝动画中添加提示："Trip 已自动归档"
- 考虑提供设置选项，允许用户选择是否自动归档完成的 Trip
- 考虑添加批量 Archive/Delete 功能

### 7.2 功能扩展

- 考虑添加 Archive 时间戳显示
- 考虑添加 Archive 原因记录（手动归档 vs 自动归档）
- 考虑添加 Archive 统计功能（已归档 Trip 数量）
- 考虑添加批量 Unarchive 功能
- 考虑在 Unarchive 后显示提示："Trip 已取消归档"
- 考虑添加 Unarchive 快捷操作（长按或其他手势）

---

## 8. 附录

### 8.1 相关文档

- `PRD-SmartPack-v1.0.md` - 主 PRD 文档
- `SPEC-SmartPack-v1.5.md` - SPEC v1.5 文档
- `HomeView.swift` - 列表页实现
- `PackingListView.swift` - 详情页实现
- `Trip.swift` - Trip 模型定义

### 8.2 参考资源

- SwiftUI SwipeActions 文档
- SwiftData 数据持久化文档
- iOS Human Interface Guidelines

---

**文档状态**：待评审  
**下一步**：评审通过后，按照本 PRD 进行技术实现。
