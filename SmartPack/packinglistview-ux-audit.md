# PackingListView UI/UX Pro Max 审计报告

## 问题清单（按视觉区域排列，从上到下）

### Section 1: ProgressHeader（进度条）

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| PA2 | **进度条文字对比度不足** — 11pt 白色/teal 文字叠加在进度条上，~50% 切换时对比度极低 | 高 | 待修复 |
| PC1 | **进度条文字阴影 hack** — `shadow(AppColors.background.opacity(0.8))` 在深色模式下不一致 | 中 | 待修复 |
| PL2 | **浮动触发阈值硬编码** — `maxY < 100` 对不同机型/Dynamic Type 不适配 | 低 | 待修复 |

### Section 2: Context Row（天气/设置胶囊）+ WeatherCard + TripSettingsCard

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| PX2 | **信息层级过深** — 天气/设置默认展开，4 层 overhead 推低核心打包清单 | 高 | ✅ 已修复 |
| PT3 | **胶囊间距不足** — `Spacing.sm` (12px)，胶囊高度 ~28px，低于 44px 触控标准 | 中 | 待修复 |
| PX1 | **胶囊尺寸跨语言不一致** — "天气"(2字) vs "Weather"(7字)，英文模式下宽度翻倍 | 中 | 待修复 |
| PX3 | **天气和设置是低频信息** — 用户反复操作的是勾选物品，给天气/设置过高首屏权重 | 中 | ✅ 已修复 |
| PX4 | **TripSettingsCard 日期格式宽度不固定** — `"2026/03/15 - 03/20"` vs `"Mar 15, 2026"` 宽度跳动 | 中 | 待修复 |
| PX5 | **WeatherCard + TripSettingsCard 信息重复** — 目的地、日期在导航栏/天气卡/设置卡多处出现 | 低 | ✅ 已修复 |
| PS1 | **TripSettingsCard 风格不一致** — 使用 `.ultraThinMaterial`，其他卡片用 `AppColors.cardBackground` | 中 | ✅ 已修复 |

### Section 3: CategorySection（分类区域）

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| PT1 | **ItemRow 触控目标偏小** — 行高 ~36px，低于 44px 最小标准；`listRowInsets` top/bottom = 0 | 高 | ✅ 已修复 |
| PT2 | **AddItemRow 触控目标偏小** — 纯文本按钮，无最小高度保障；右侧 Spacer 区域不可点击 | 中 | ✅ 已修复 |
| PT4 | **checkbox 弹跳 `asyncAfter` 硬编码** — 0.15s 延迟不可靠 | 低 | 待修复 |
| PP1 | **`categoryIcon` 字符串匹配** — 每次渲染对中英文 switch，应用枚举映射 | 低 | 待修复 |
| PM2 | **Section 级 `.animation` 范围过大** — 可能动画不相关子视图 | 低 | 待修复 |

### Section 4: Floating Progress Overlay（浮动进度条）

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| PL1 | **浮动条遮挡内容** — ZStack 顶部无 safe area 偏移 | 中 | 待修复 |
| PC2 | **百分比文字溢出** — 低进度时 `position` 计算可能裁切或与计数重叠 | 低 | 待修复 |

### Section 5: CelebrationOverlay（庆祝动画）

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| PM1 | **自动关闭竞态** — 手动点击 + 2.5s `asyncAfter` 双重触发 `dismissAndComplete` | 高 | 待修复 |
| PA3 | **无 VoiceOver 焦点管理** — 屏幕阅读器用户无法感知庆祝内容 | 中 | 待修复 |
| PP2 | **50 粒子同时动画** — 可能掉帧；`UIScreen.main.bounds` 已废弃 | 中 | 待修复 |
| PS2 | **`UIScreen.main.bounds` 已废弃** — iOS 16+ 应使用 GeometryReader | 低 | 待修复 |

### 跨区域

| # | 问题 | 严重性 | 状态 |
|---|------|--------|------|
| PA1 | **未尊重 `prefers-reduced-motion`** — ProgressHeader、ItemRow checkbox、CategorySection 展开、CelebrationOverlay 全部未检查 | 高 | 待修复 |

---

## 待执行的修复方案

### ✅ 已完成的修复

#### Section 2 重设计 — CombinedInfoCard（commit 1614578, ff79883）

| 改动 | 修复前 | 修复后 |
|------|--------|--------|
| 默认状态 | `showWeatherCard = true`, `showTripSettings = true` | `= false`, `= false` |
| 卡片结构 | 两个独立卡片（WeatherCard + TripSettingsCard） | 合并为 `CombinedInfoCard`（设置在上、天气在下、薄分割线） |
| 天气颜色 | 温度梯度色（蓝/青/绿/橙/红） | 统一使用 `AppColors.primary`（teal） |
| 天气布局 | 目的地头部 + 每日独立卡片 + 降水 | 横向滚动：M/d 日期 + 图标 + 高/低温，无降水，无 "Today" |
| 设置布局 | 独立卡片 | FlowLayout chip 流（日期 + 标签） |
| 风格一致性 | `.ultraThinMaterial` vs `cardBackground` 混用 | 统一 `.ultraThinMaterial` |
| 信息重复 | 目的地在导航栏 + 天气卡重复 | 移除天气卡目的地头部 |

**修复的问题：** PX2, PX3, PX5, PS1

#### 触控目标修复（commit 23c6cb7）

| 改动 | 修复前 | 修复后 |
|------|--------|--------|
| ItemRow | 行高 ~36px，低于 44px | `.frame(minHeight: 44)` 扩展点击区域，视觉不变 |
| AddItemRow | 行高 ~36px，右侧 Spacer 不可点击 | `.frame(minHeight: 44)` + `.contentShape(Rectangle())` + `.onTapGesture` 全宽可点击 |

**修复的问题：** PT1, PT2

### 待定修复

#### 高

| # | 修复方案 | 影响文件 |
|---|---------|---------|
| PA2 | 移除进度条上叠加文字，或改用固定对比度方案 | `ProgressHeader` |
| PM1 | 添加标志位防止 `dismissAndComplete` 重复调用 | `CelebrationOverlay` |
| PA1 | 添加 `@Environment(\.accessibilityReduceMotion)`，条件禁用动画 | 多个文件 |

#### 中

| # | 修复方案 | 影响文件 |
|---|---------|---------|
| PC1 | 进度条文字使用固定颜色或移除阴影 hack | `ProgressHeader` |
| PT3 | 胶囊添加 `.frame(minHeight: 44)` | `PackingListView` |
| PX1 | 胶囊使用固定宽度或 icon-only 模式 | `PackingListView` |
| PX4 | 日期格式宽度跳动 | `CombinedInfoCard` |
| PL1 | 浮动条下方添加内容偏移 | `PackingListView` |
| PA3 | 添加 `.accessibilityAddTraits(.isModal)` 和焦点管理 | `CelebrationOverlay` |
| PP2 | 减少粒子数量，替换 `UIScreen.main.bounds` | `CelebrationOverlay` |

#### 低

| # | 修复方案 | 影响文件 |
|---|---------|---------|
| PL2 | 浮动触发改用 GeometryReader 相对计算 | `PackingListView` |
| PT4 | checkbox 弹跳改用 `.animation` modifier 替代 asyncAfter | `ItemRow` |
| PP1 | categoryIcon 改用 ItemCategory 枚举直接映射 | `CategorySection` |
| PM2 | `.animation` 改为 `.animation(_, value:)` 精确作用域 | `CategorySection` |
| PC2 | 低进度时百分比文字改为固定位置 | `CompactProgressBar` |
| PS2 | 替换 `UIScreen.main.bounds` 为 GeometryReader | `CelebrationOverlay` |

---

## 预览文件

| 文件 | 内容 |
|------|------|
| `fix-preview-weather-redesign.html` | Section 2 重设计 Before/After |
| `fix-preview-weather-color.html` | 天气温度颜色统一 Before/After |
| `fix-preview-touch-targets.html` | 触控目标 Option A vs B 对比 |

---

**Total: 22 issues** (3 高 / 7 中 / 6 低 remaining), **6 已修复** (PX2, PX3, PX5, PS1, PT1, PT2)
