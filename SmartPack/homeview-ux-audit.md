# HomeView UI/UX Pro Max 审计报告

## 问题清单

### 优先级 1: 无障碍（严重）

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| A1 | **未尊重 `prefers-reduced-motion`** — 圆环动画和空状态入场动画从未检查 `accessibilityReduceMotion` | 高 | 待修复 |
| A2 | **仅通过颜色传达完成状态** — 色盲用户无法区分进行中/已完成 | 高 | **已修复** → **U2 回退**（用户偏好仅保留圆环内 ✓） |
| A3 | **NavigationLink 缺少合并的无障碍标签** | 中 | 待修复 |

### 优先级 2: 触控与交互（严重）

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| T1 | **双重箭头** — NavigationLink 系统箭头 + 手动 chevron.right | 高 | **已随 L3 修复**（chevron 已移除） |
| T2 | **卡片样式与 swipeActions 冲突** — 圆角卡片内滑动操作裁切异常 | 高 | **已修复**（最小补丁） |
| T3 | **工具栏触控目标间距不足** | 中 | 待修复 |
| T4 | **导航竞态** — 硬编码 0.3s 延迟 + 两个 navigationDestination 冲突 | 中 | **已修复** |

### 优先级 3: 性能

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| P1 | **每次渲染重新过滤** — activeTrips/archivedTrips 计算属性 | 低 | 待修复 |

### 优先级 4: 布局

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| L1 | **空状态未垂直居中** — 包在 List > Section 内 | 中 | **已修复** |
| L2 | **活跃/归档分区缺少视觉分隔** | 中 | **不修复**（用户决定） |
| L3 | **行程名被截断** — HStack 布局 + lineLimit(1) 导致标题仅 ~150px | 高 | **已修复** |

### 优先级 5: 字体与颜色

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| C1 | **CreateTripSheet 背景色不一致** — 系统灰 vs 设计系统青色调 | 中 | **已修复** |
| C2 | **空状态标题对比度不足** — ~3.5:1，低于 WCAG AA 4.5:1 | 中 | 待修复 |
| C3 | **中英文混用** — `"Item 管理"` 应为 `"物品管理"` | 低 | **已修复** |

### 优先级 6: 动画

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| M1 | **每行独立入场动画** — 5+ 行程同时动画造成视觉干扰 | 中 | 待修复 |

### 优先级 7: 风格一致性

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| S1 | **卡片 + List 混合范式** — swipe/separator/insets 冲突 | 高 | **已随 T2 缓解**（最小补丁） |

---

## 已完成的修复

### L3 行程名截断 — Hybrid C+D 方案 ✅

**改动文件：** `TripRowView.swift`, `HomeView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 布局 | HStack（ring \| info \| chevron） | VStack + `.overlay` corner ring |
| 圆环 | 48px 行内左侧, 3pt 描边 | 38px 右上角 badge, 2.5pt 描边 |
| 内边距 | 24px 全方向 | 16px 垂直, 22px 水平 |
| 标题 | 20px, lineLimit(1) 截断 | 17px, lineLimit(2) 自然换行 |
| 元信息 | 日期 + X/X | 仅日期（ring % 为唯一进度指示） |
| Chevron | 手动 chevron.right | 无 |
| 行间距 | 8px top/bottom | 6px top/bottom |
| 可见卡片 | ~3 | ~5 |

**附带解决：** T1（双重箭头）— chevron 已移除

### A2 完成状态 Badge ✅ → U2 回退

**改动文件：** `TripRowView.swift`

A2 添加了 18px badge，但用户反馈双重 ✓ 冗余。U2 移除了 A2 badge，仅保留圆环内 ✓。
最终状态：圆环内 ✓（完成）vs 百分比数字（进行中）作为非颜色区分。

### T2+S1 卡片 swipe 裁切 — 最小补丁 ✅

**改动文件：** `TripRowView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 背景 | `.background(color)` + `.clipShape(RoundedRect)` | `.background(RoundedRect.fill(...).shadow(...))` |
| 裁切 | `clipShape` 裁切整个视图（含 swipe 边缘） | 无裁切，背景形状仅视觉圆角 |
| 点击区域 | 由 clipShape 隐式定义 | `.contentShape(RoundedRect)` 显式定义 |
| swipe 效果 | 圆角边缘裁切异常 | 按钮正常滑出 |

### T4 导航竞态 ✅

**改动文件：** `HomeView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 导航触发 | `DispatchQueue.main.asyncAfter(0.3s)` | `.sheet(onDismiss:)` 回调 |
| 状态 | 直接设 `selectedTrip` | `pendingTrip` 暂存 → `onDismiss` 时赋值 |
| 竞态风险 | 动画未完成时导航可能失败 | 保证 sheet 完全关闭后导航 |

### L1 空状态垂直居中 ✅

**改动文件：** `HomeView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 容器 | `List > Section` 内 | `Group { if/else }` 独立视图 |
| 定位 | 偏上（List 内部 inset） | `frame(maxHeight: .infinity)` 垂直居中 |
| List | 始终渲染 | 仅有行程时渲染 |

### C1 CreateTripSheet 背景色 ✅

**改动文件：** `CreateTripSheet.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 背景 | `Color(.systemGroupedBackground)` | `AppColors.background` |

### C3 中英文混用 ✅

**改动文件：** `HomeView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 菜单文案 | `"Item 管理"` | `"物品管理"` |

### U1 日期改为出发日期 ✅

**改动文件：** `Trip.swift`, `TripRowView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 数据源 | `trip.createdAt` | `trip.startDate`（可选） |
| 方法 | `formattedDate()` | 新增 `formattedStartDate()` |
| 显示 | `"2026年2月20日"` | `"3月15日 出发"` / `"Departs Mar 15"` |
| 无日期 | — | `"未设定出发日期"` / `"No departure date"` |

### U2 移除 A2 Badge ✅

**改动文件：** `TripRowView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| A2 badge | 18px 白勾 + 绿色圆形 | 删除整个 `.overlay(alignment: .bottomTrailing)` |
| 圆环内 ✓ | 保留 | 保留（唯一完成指示） |

### U3 删除平滑动画 ✅

**改动文件：** `HomeView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 删除代码 | `modelContext.delete(trip)` | `withAnimation(.easeInOut(duration: 0.3)) { modelContext.delete(trip) }` |
| 归档区行为 | 跳上 → 跳回 | 平滑上移 |

### U4 移除系统 Chevron ✅

**改动文件：** `HomeView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| NavigationLink | `NavigationLink(value:) { TripRowView }` | `ZStack { NavigationLink.opacity(0) + TripRowView }` |
| 系统 Chevron | 可见（灰色 ›） | 隐藏 |
| 应用范围 | — | active + archived 两个 Section |

### U5 归档/取消归档动画 ✅ → U8 回退

**改动文件：** `HomeView.swift`

U5 添加了 `withAnimation(.easeInOut(duration: 0.3))`，但与 SwiftUI List 的跨 Section 动画冲突（卡片消失/重叠）。
U8 移除了 `withAnimation`，改用 SwiftUI 默认 List 过渡。

### U6 移除标题中的日期后缀 ✅

**改动文件：** `TripConfig.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| generateListName | `"东京 - 商务 - 2026/03/15"` | `"东京 - 商务"` |
| 日期显示 | 标题 + 卡片（U1）双重显示 | 仅卡片出发日期（U1） |
| 影响范围 | 仅新建行程 | 仅新建行程（已有行程不变） |

### U7 删除确认前布局跳动 ✅

**改动文件：** `HomeView.swift`

| 属性 | 修复前 | 修复后 |
|------|--------|--------|
| 删除按钮（active） | `Button(role: .destructive)` | `Button { ... }.tint(.red)` |
| 删除按钮（archived） | `Button(role: .destructive)` | `Button { ... }.tint(.red)` |
| 确认前行为 | `role: .destructive` 自动移除行 → 归档区跳上 → alert 出现 → 行回位 → 归档区跳回 | 行保持原位，alert 出现，确认后平滑删除 |
| 按钮颜色 | 红色（role 自动） | 红色（`.tint(.red)` 手动） |

### U8 归档/取消归档动画 — 移除 withAnimation ✅

**改动文件：** `HomeView.swift`

| 属性 | 修复前（U5） | 修复后（U8） |
|------|-------------|-------------|
| archiveTrip | `withAnimation(.easeInOut(0.3)) { trip.archive(); save() }` | `trip.archive(); save()` |
| unarchiveTrip | `withAnimation(.easeInOut(0.3)) { trip.unarchive(); save() }` | `trip.unarchive(); save()` |
| 动画 | 自定义 .easeInOut 与 List 跨 Section 冲突 | SwiftUI 默认 List 过渡接管 |

---

## 待执行的修复方案

### 严重

| # | 修复方案 | 影响文件 |
|---|---------|---------|
| A1 | 添加 `@Environment(\.accessibilityReduceMotion)`，条件禁用 spring 动画 | `TripRowView`, `HomeView` |

### 中

| # | 修复方案 | 影响文件 |
|---|---------|---------|
| C2 | 空状态标题改用 `AppColors.text`，对比度 ≥ 4.5:1 | `HomeView` |
| M1 | 圆环动画仅首次进入执行一次 | `TripRowView` |

---

## 预览文件

| 文件 | 内容 |
|------|------|
| `fix-preview-A1-A2-T1.html` | A1, A2, T1 的 Before/After 对比 |
| `fix-preview-title-truncation.html` | 4 种标题截断方案对比 |
| `fix-preview-hybrid-CD.html` | L3 最终方案预览（已实施） |
| `fix-preview-U1-U2-U3.html` | U1 日期移除, U2 双重勾, U3 删除跳动, U4 移除 chevron Before/After |
