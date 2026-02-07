# Live Activity 故障排除指南

> **问题**: 创建清单后，锁屏界面没有显示 Live Activity

---

## 🔍 检查清单

### 1. 系统版本检查

**Live Activity 需要 iOS 16.1+**

- ✅ 确保设备或模拟器是 iOS 16.1 或更高版本
- ✅ 检查方式：设置 → 通用 → 关于本机 → 软件版本

### 2. Widget Extension 配置检查

#### 2.1 检查 Extension Target 是否存在

1. 在 Xcode 中，选择项目根节点
2. 查看 Targets 列表，确认有 `smartpackExtension` target

#### 2.2 检查 Info.plist 配置

1. 选择 `smartpackExtension` target
2. 进入 **Info** tab
3. 检查是否有 `NSSupportsLiveActivities` 键，值为 `YES`

如果没有，添加：
- Key: `NSSupportsLiveActivities`
- Type: `Boolean`
- Value: `YES`

#### 2.3 检查 Widget Bundle 文件

确保以下文件在 Extension target 中：
- ✅ `WidgetExtension/PackingActivityWidgetBundle.swift` - 有 `@main` 标记
- ✅ `WidgetExtension/PackingActivityWidget.swift` - Widget UI 定义
- ✅ `Activity/PackingActivityAttributes.swift` - **必须在两个 target 中都可见**

### 3. 权限检查

**Live Activity 权限可能被关闭**

1. 打开 **设置** app
2. 找到 **SmartPack**
3. 检查 **Live Activities** 开关是否开启
4. 如果关闭，请开启

### 4. 代码检查

#### 4.1 检查启动条件

Live Activity 只在以下条件**同时满足**时启动：
- ✅ Trip 未归档 (`!trip.isArchived`)
- ✅ Trip 未全部完成 (`!trip.isAllChecked`)
- ✅ 总数量大于 0 (`totalCount > 0`)

#### 4.2 检查控制台输出

在 Xcode 中运行 App，查看控制台输出：

**成功启动**：
```
✅ Live Activity started successfully: [行程名称]
```

**失败**：
```
❌ Failed to start Live Activity: [错误信息]
```

常见错误：
- `authorizationDenied` - 权限被拒绝，检查设置
- `exceededMaximumCount` - 超过最大数量限制（iOS 限制最多 5 个）
- `invalidContent` - Widget Extension 配置错误

### 5. Widget Extension 编译检查

确保 Widget Extension 能够正常编译：

1. 在 Xcode 顶部的 Scheme 选择器中，选择 `smartpackExtension`
2. 编译：Product → Build (⌘B)
3. 确认没有编译错误

---

## 🛠️ 常见问题解决

### 问题 1: "Cannot find 'PackingActivityAttributes' in scope"

**原因**: `PackingActivityAttributes.swift` 没有添加到 Extension target

**解决**:
1. 选择 `PackingActivityAttributes.swift` 文件
2. 打开 File Inspector (⌥⌘1)
3. 在 Target Membership 中，确保两个 target 都勾选：
   - ✅ `SmartPack` (主 App)
   - ✅ `smartpackExtension` (Widget Extension)

### 问题 2: "authorizationDenied" 错误

**原因**: Live Activity 权限被关闭

**解决**:
1. 设置 → SmartPack → Live Activities → 开启
2. 如果找不到这个选项，可能需要重新安装 App

### 问题 3: Widget Extension 编译失败

**原因**: Extension target 配置不正确

**解决**:
1. 检查 `PackingActivityWidgetBundle.swift` 是否有 `@main` 标记
2. 检查 Extension target 的 Info.plist 中是否有 `NSSupportsLiveActivities = YES`
3. 确保所有必需文件都在 Extension target 中

### 问题 4: Live Activity 启动但没有显示

**可能原因**:
1. 设备上已有 5 个 Live Activity（iOS 限制）
2. 锁屏界面被其他 Live Activity 占据
3. 需要在锁屏界面向上滑动查看

**解决**:
1. 结束其他 Live Activity
2. 锁屏后向上滑动，查看是否有 SmartPack 的 Live Activity

---

## 🧪 调试步骤

### 步骤 1: 添加调试日志

代码中已经添加了调试日志，运行 App 后查看 Xcode 控制台：

```swift
// 成功启动
✅ Live Activity started successfully: [行程名称]

// 失败
❌ Failed to start Live Activity: [错误信息]
```

### 步骤 2: 检查启动条件

在 `PackingListView.swift` 的 `onAppear` 中添加调试信息：

```swift
.onAppear {
    print("🔍 PackingListView appeared")
    print("   Trip archived: \(trip.isArchived)")
    print("   Trip all checked: \(trip.isAllChecked)")
    print("   Total count: \(trip.totalCount)")
    
    if !trip.isArchived && !trip.isAllChecked {
        print("✅ Conditions met, starting Live Activity...")
        activityManager.startActivity(...)
    } else {
        print("❌ Conditions not met, skipping Live Activity")
    }
}
```

### 步骤 3: 测试 Widget Extension

1. 在 Xcode 中，选择 `smartpackExtension` scheme
2. 运行到设备或模拟器
3. 检查是否有编译或运行时错误

### 步骤 4: 验证权限

1. 运行主 App
2. 进入一个未完成的 Trip
3. 查看 Xcode 控制台，确认是否有错误信息
4. 锁屏查看 Live Activity

---

## 📝 验证清单

完成以上检查后，确认：

- [ ] iOS 版本 ≥ 16.1
- [ ] Extension target 存在且可编译
- [ ] `NSSupportsLiveActivities = YES` 在 Extension Info.plist 中
- [ ] `PackingActivityAttributes.swift` 在两个 target 中都可见
- [ ] `PackingActivityWidgetBundle.swift` 有 `@main` 标记
- [ ] 设置 → SmartPack → Live Activities 已开启
- [ ] Trip 未归档且未全部完成
- [ ] 控制台没有错误信息
- [ ] 设备上 Live Activity 数量 < 5

---

## 🆘 如果问题仍然存在

1. **完全清理项目**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/SmartPack-*
   ```

2. **重新安装 App**:
   - 删除设备上的 App
   - 重新编译并安装

3. **检查 Xcode 版本**:
   - 确保使用 Xcode 14.1+（支持 Live Activity）

4. **查看详细错误信息**:
   - 运行 App 后查看 Xcode 控制台的完整错误信息
   - 检查是否有 ActivityKit 相关的错误

---

*如果按照以上步骤操作后问题仍然存在，请提供 Xcode 控制台的错误信息。*
