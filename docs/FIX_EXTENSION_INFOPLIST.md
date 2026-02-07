# 修复 Widget Extension Info.plist 配置

> **错误**: `Appex bundle does not define an NSExtension dictionary in its Info.plist`

---

## ✅ 已完成的修复

1. ✅ 创建了专门的 Extension Info.plist: `SmartPack/Info-Extension.plist`
2. ✅ 修改了 Extension target 的 Build Settings，使用新的 Info.plist
3. ✅ 恢复了主 App 的 Info.plist（移除了 Extension 配置）

---

## 🔧 需要在 Xcode 中完成的步骤

### 步骤 1: 添加 Info-Extension.plist 到项目

1. 在 Xcode 中，右键点击 `SmartPack` 文件夹
2. 选择 **Add Files to "SmartPack"...**
3. 选择 `Info-Extension.plist` 文件
4. 确保勾选：
   - ✅ **Add to targets: smartpackExtension**
   - ❌ **不要勾选** `SmartPack` (主 App target)
5. 点击 **Add**

### 步骤 2: 验证 Extension target 配置

1. 选择项目根节点
2. 选择 `smartpackExtension` target
3. 进入 **Build Settings** 标签
4. 搜索 `INFOPLIST_FILE`
5. 确认值为 `SmartPack/Info-Extension.plist`
6. 搜索 `GENERATE_INFOPLIST_FILE`
7. 确认值为 `NO`（对于 Extension target）

### 步骤 3: 清理并重新编译

1. **清理构建**: Product → Clean Build Folder (⌘⇧K)
2. **重新编译**: Product → Build (⌘B)
3. **运行到设备**: Product → Run (⌘R)

---

## 📝 Info-Extension.plist 内容

新创建的 `Info-Extension.plist` 包含：

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>
<key>NSSupportsLiveActivities</key>
<true/>
```

这是 Widget Extension **必需的**配置：
- `NSExtension` 字典：标识这是一个 Widget Extension
- `NSExtensionPointIdentifier`: `com.apple.widgetkit-extension` 表示这是 Widget Extension
- `NSSupportsLiveActivities`: 启用 Live Activity 支持

---

## ✅ 验证修复

修复后，应该能够：

1. ✅ Extension target 编译成功
2. ✅ App 可以成功安装到设备
3. ✅ 没有 "NSExtension dictionary" 错误

---

## 🆘 如果问题仍然存在

1. **检查文件路径**:
   - 确保 `Info-Extension.plist` 在 `SmartPack/` 文件夹中
   - 确保 Build Settings 中的路径正确

2. **检查 Target Membership**:
   - `Info-Extension.plist` 应该只在 `smartpackExtension` target 中
   - 不应该在主 App target 中

3. **完全清理项目**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/SmartPack-*
   ```

---

*完成以上步骤后，Extension 应该能够正常安装和运行。*
