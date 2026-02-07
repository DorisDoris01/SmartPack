# SmartPack 项目结构说明

> **最后更新**: 2026-02-02  
> **版本**: v1.5

---

## 📁 项目目录结构

```
Project-packing-app/
├── docs/                                    # 文档目录
│   ├── LIVE_ACTIVITY_SETUP.md              # Live Activity 设置指南
│   ├── SPEC-SmartPack-MVP-Input-Output-Mapping.md  # SPEC v1.4
│   ├── SPEC-SmartPack-v1.5.md              # SPEC v1.5
│   ├── SPEC-v1.5-IMPLEMENTATION.md         # 实现总结
│   └── PROJECT_STRUCTURE.md                 # 本文件
│
├── PRD-SmartPack-v1.0.md                   # 主 PRD 文档
│
└── SmartPack/
    ├── SmartPack.xcodeproj/                 # Xcode 项目文件
    │
    ├── SmartPack/                           # 主 App Target
    │   ├── Activity/                        # Live Activity 相关
    │   │   ├── PackingActivityAttributes.swift    # Activity 属性（需共享到 Extension）
    │   │   └── PackingActivityManager.swift       # Activity 管理器（主 App only）
    │   │
    │   ├── Data/                            # 数据层
    │   │   ├── CustomItemManager.swift      # 自定义 Item 管理器
    │   │   └── PresetData.swift             # 预设数据（标签、Item）
    │   │
    │   ├── Localization/                    # 本地化
    │   │   └── LocalizationManager.swift    # 多语言管理器
    │   │
    │   ├── Models/                          # 数据模型
    │   │   ├── Item.swift                   # Item 模型
    │   │   ├── Tag.swift                    # 标签模型
    │   │   ├── Trip.swift                   # 行程模型（SwiftData）
    │   │   └── TripConfig.swift             # 行程配置模型
    │   │
    │   ├── Views/                           # 视图层
    │   │   ├── HomeView.swift               # 首页（行程列表）
    │   │   ├── PackingListView.swift        # 打包清单页
    │   │   ├── ItemManagementView.swift    # Item 管理页
    │   │   ├── SettingsView.swift           # 设置页
    │   │   ├── WelcomeView.swift            # 欢迎页
    │   │   ├── TripConfigView.swift         # 行程配置页（旧版）
    │   │   ├── MyListsView.swift            # 我的列表页（已废弃）
    │   │   └── MainTabView.swift            # Tab 视图（已废弃）
    │   │
    │   ├── SmartPackApp.swift               # App 入口
    │   ├── Info.plist                       # App 配置
    │   │
    │   └── Widget 相关文件（Extension target，旧版）:
    │       ├── smartpack.swift              # 普通 Widget
    │       ├── smartpackControl.swift       # Control Widget
    │       ├── smartpackLiveActivity.swift  # Live Activity Widget（旧版）
    │       └── AppIntent.swift              # Widget Intent
    │
    └── WidgetExtension/                     # Widget Extension 文件（Extension target）
        ├── PackingActivityWidget.swift      # Live Activity Widget UI ✅
        └── PackingActivityWidgetBundle.swift # Widget Bundle 入口点 ✅（@main）
```

---

## 🎯 Target 说明

### 主 App Target: `SmartPack`
- **类型**: iOS App
- **最低版本**: iOS 15.0（Live Activity 需 16.1+）
- **主要功能**: 
  - 行程管理
  - 打包清单
  - Item 管理
  - 设置

### Widget Extension Target: `smartpackExtension`
- **类型**: Widget Extension
- **最低版本**: iOS 16.1（Live Activity）
- **包含 Widget**:
  - `smartpack` - 普通 Widget
  - `smartpackControl` - Control Widget
  - `smartpackLiveActivity` - Live Activity Widget ✅

---

## 📋 文件 Target 成员资格

### 主 App Target Only
- `SmartPackApp.swift` ⚠️ **App 入口点（@main）** - 必须在主 App target，不能在 Extension target
- `PackingActivityManager.swift` - Activity 管理器
- `Views/*.swift` - 所有视图文件
- `Models/*.swift` - 数据模型
- `Data/*.swift` - 数据层
- `Localization/*.swift` - 本地化

### Widget Extension Target Only
- `WidgetExtension/PackingActivityWidgetBundle.swift` ⚠️ **Extension 入口点（@main）**
- `WidgetExtension/PackingActivityWidget.swift` ⚠️ **Live Activity Widget UI**
- `smartpack.swift`（旧版 Widget，可选）
- `smartpackControl.swift`（旧版 Widget，可选）
- `smartpackLiveActivity.swift`（旧版 Widget，可选）
- `AppIntent.swift`

### 两个 Target 共享（重要！）
- **`PackingActivityAttributes.swift`** ⚠️ 必须在两个 target 中都可见

---

## ⚙️ 配置检查清单

### App Target (`SmartPack`)
- [x] Background Modes 已配置
- [x] SwiftData Model Container 已配置
- [x] LocalizationManager 已配置

### Widget Extension Target (`smartpackExtension`)
- [x] `NSSupportsLiveActivities = YES` (已在 project.pbxproj 中配置)
- [ ] `PackingActivityAttributes.swift` 需添加到 Extension target（需在 Xcode 中手动操作）
- [x] Widget Bundle 已配置

---

## 🔧 需要手动完成的步骤

### 1. 共享 PackingActivityAttributes.swift

在 Xcode 中：
1. 选择 `PackingActivityAttributes.swift` 文件
2. 打开 **File Inspector** (⌥⌘1)
3. 在 **Target Membership** 中勾选：
   - ✅ `SmartPack` (主 App)
   - ✅ `smartpackExtension` (Widget Extension)

### 2. 验证 Widget Extension 配置

1. 选择 `smartpackExtension` target
2. 进入 **Build Settings**
3. 搜索 `NSSupportsLiveActivities`
4. 确认值为 `YES`

### 3. 测试 Live Activity

1. 运行主 App
2. 进入一个未完成的 Trip
3. 锁屏查看 Live Activity
4. 勾选 Item，观察进度更新

---

## 📦 核心功能模块

### 1. 数据模型层 (`Models/`)
- **Trip**: SwiftData 模型，存储行程数据
- **TripConfig**: 行程配置（新建时使用）
- **Tag**: 标签模型（标签组、标签）
- **Item**: Item 模型（预设 Item）

### 2. 数据层 (`Data/`)
- **PresetData**: 预设标签和 Item 数据
- **CustomItemManager**: 用户自定义 Item 管理（UserDefaults）

### 3. 视图层 (`Views/`)
- **HomeView**: 首页，行程列表
- **PackingListView**: 打包清单页，支持横滑删除
- **ItemManagementView**: Item 管理，支持预设 Item 删除
- **SettingsView**: 设置页
- **WelcomeView**: 首次欢迎页

### 4. Activity 层 (`Activity/`)
- **PackingActivityAttributes**: Activity 属性定义
- **PackingActivityManager**: Activity 生命周期管理

---

## 🚀 当前版本功能

### SPEC v1.5 已实现功能
- ✅ Trip Item 横滑删除
- ✅ Trip 列表横滑删除
- ✅ 归档后返回列表页
- ✅ Item 管理预设删除（数据层）
- ✅ Item 管理预设 Item 横滑删除
- ✅ Live Activity 代码完成（需配置 Extension）

### PRD v1.4 功能
- ✅ 标签组/标签/Item 关系修正
- ✅ Item 管理（自定义 Item 增删）
- ✅ 行程归档

### SPEC Input-Output Mapping 功能
- ✅ 新的标签组结构（旅行活动/特定场合/出行配置）
- ✅ 基础清单（共有项 + 性别特有项）
- ✅ 日期选择器和目的地输入

---

## 📝 注意事项

1. **Widget Extension 是独立 target**
   - 不能直接访问主 App 的数据
   - 必须通过 ActivityAttributes 传递数据

2. **文件共享**
   - `PackingActivityAttributes.swift` 必须在两个 target 中都可见
   - 其他文件按需分配

3. **版本兼容性**
   - Live Activity 仅 iOS 16.1+
   - 代码已添加版本检查，低版本自动降级

4. **数据持久化**
   - SwiftData: Trip 数据
   - UserDefaults: 自定义 Item、已删除预设 Item、用户偏好

---

## 🔍 关键文件说明

### 核心业务逻辑
- `PresetData.swift`: 所有预设数据和生成逻辑
- `CustomItemManager.swift`: 用户自定义 Item 管理
- `Trip.swift`: 行程数据模型（SwiftData）

### UI 入口
- `SmartPackApp.swift`: App 入口，配置 Model Container
- `HomeView.swift`: 主界面，行程列表
- `PackingListView.swift`: 打包清单，支持横滑删除和 Live Activity

### Widget 相关
- `smartpackLiveActivity.swift`: Live Activity Widget UI（已更新为使用 PackingActivityAttributes）
- `PackingActivityManager.swift`: Activity 管理器（主 App 中使用）

---

*项目结构清晰，模块划分合理。所有 SPEC v1.5 功能代码已完成。*
