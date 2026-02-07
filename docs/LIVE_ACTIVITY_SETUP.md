# Live Activity 设置指南

> **SPEC v1.5**: iOS 16.1+ 锁屏进度显示

## 前置要求

- Xcode 14.1+
- iOS 16.1+ 设备或模拟器
- ActivityKit 框架

---

## 步骤 1: 创建 Widget Extension Target

1. 在 Xcode 中，选择 **File → New → Target**
2. 选择 **Widget Extension**
3. 配置：
   - **Product Name**: `SmartPackWidgetExtension`
   - **Organization Identifier**: 与主 App 一致
   - **Language**: Swift
   - **Include Configuration Intent**: ❌ 取消勾选
4. 点击 **Finish**

---

## 步骤 2: 配置 App Target

1. 选择主 App Target (`SmartPack`)
2. 进入 **Signing & Capabilities**
3. 添加 **Background Modes** capability（如果还没有）
4. 勾选 **Background processing** 和 **Remote notifications**（可选）

---

## 步骤 3: 配置 Widget Extension

1. 选择 Widget Extension Target (`SmartPackWidgetExtension`)
2. 进入 **Info** tab
3. 在 **Custom iOS Target Properties** 中添加：
   - Key: `NSSupportsLiveActivities`
   - Type: `Boolean`
   - Value: `YES`

---

## 步骤 4: 共享文件

### 4.1 共享 Activity Attributes

1. 选择 `PackingActivityAttributes.swift` 文件
2. 在 **File Inspector** 中，勾选 **SmartPackWidgetExtension** target

### 4.2 复制 Widget 文件到 Extension

1. 将以下文件复制到 Widget Extension target：
   - `PackingActivityWidget.swift`
   - `PackingActivityWidgetBundle.swift`

2. 确保这些文件**只**属于 Widget Extension target（不勾选主 App target）

---

## 步骤 5: 更新 Widget Extension Bundle

确保 `PackingActivityWidgetBundle.swift` 是 Widget Extension 的入口点：

```swift
@main
struct PackingActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        PackingActivityWidget()
    }
}
```

---

## 步骤 6: 测试

1. 运行主 App
2. 进入一个未完成的 Trip
3. 锁屏查看 Live Activity
4. 勾选 Item，观察进度更新

---

## 故障排除

### Live Activity 不显示

1. **检查系统版本**：确保设备是 iOS 16.1+
2. **检查权限**：设置 → SmartPack → Live Activities（确保开启）
3. **检查 Info.plist**：确保 `NSSupportsLiveActivities = YES`
4. **重启设备**：有时需要重启才能生效

### 编译错误

1. **ActivityKit 未找到**：确保 Deployment Target ≥ iOS 16.1
2. **文件未共享**：确保 `PackingActivityAttributes.swift` 在两个 target 中都可见
3. **Widget Bundle 错误**：确保只有一个 `@main` 入口点

---

## 文件结构

```
SmartPack/
├── Activity/
│   ├── PackingActivityAttributes.swift      (共享)
│   └── PackingActivityManager.swift         (主 App)
├── WidgetExtension/
│   ├── PackingActivityWidget.swift          (Extension only)
│   └── PackingActivityWidgetBundle.swift    (Extension only)
└── Views/
    └── PackingListView.swift                (已集成)
```

---

## 注意事项

1. **Widget Extension 是独立的 target**，不能直接访问主 App 的数据
2. **ActivityAttributes 必须共享**，在两个 target 中都可见
3. **Live Activity 有时长限制**：Dynamic Island 8 小时，锁屏 12 小时
4. **iOS 15 及以下**：代码会自动降级，不会崩溃

---

*完成设置后，Live Activity 功能即可正常使用。*
