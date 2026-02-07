# 修复 Bundle Identifier 错误

> **错误**: `Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier`

---

## ✅ 当前配置（已正确）

- **主 App Bundle ID**: `com.smartpack.app.doris`
- **Extension Bundle ID**: `com.smartpack.app.doris.smartpackExtension` ✅

Extension 的 Bundle ID 确实以主 App 的 Bundle ID 为前缀，配置是正确的。

---

## 🔧 解决步骤

### 步骤 1: 清理 Xcode 缓存

1. **在 Xcode 中**:
   - Product → Clean Build Folder (⌘⇧K)

2. **关闭 Xcode**

3. **删除 DerivedData**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/SmartPack-*
   ```

4. **重新打开 Xcode**

### 步骤 2: 在 Xcode 中验证配置

1. **选择项目根节点**（蓝色图标）

2. **选择 `smartpackExtension` target**

3. **进入 Build Settings 标签**

4. **搜索 `PRODUCT_BUNDLE_IDENTIFIER`**

5. **确认值为**: `com.smartpack.app.doris.smartpackExtension`

6. **选择主 App target (`SmartPack`)**

7. **确认 Bundle ID 为**: `com.smartpack.app.doris`

### 步骤 3: 手动重新设置（如果步骤 2 显示不正确）

1. **选择 `smartpackExtension` target**
2. **进入 General 标签**
3. **找到 Bundle Identifier**
4. **手动输入**: `com.smartpack.app.doris.smartpackExtension`
5. **按回车保存**

### 步骤 4: 检查 Signing & Capabilities

1. **选择 `smartpackExtension` target**
2. **进入 Signing & Capabilities 标签**
3. **确认 Team 设置正确**
4. **确认 Bundle Identifier 显示为**: `com.smartpack.app.doris.smartpackExtension`

### 步骤 5: 重新编译

1. **清理**: Product → Clean Build Folder (⌘⇧K)
2. **编译**: Product → Build (⌘B)

---

## 🔍 验证 Bundle ID 格式

Extension 的 Bundle ID **必须**遵循以下格式：

```
[主 App Bundle ID].[Extension 后缀]
```

例如：
- ✅ `com.smartpack.app.doris.smartpackExtension` - 正确
- ✅ `com.smartpack.app.doris.widget` - 正确
- ❌ `com.smartpack.app.doris.smartpack` - 可能冲突（如果主 App 有类似名称）
- ❌ `com.smartpack.widget` - 错误（不以主 App 为前缀）

---

## 🆘 如果问题仍然存在

### 方法 1: 完全重置项目配置

1. **关闭 Xcode**
2. **备份项目文件**
3. **删除 DerivedData**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/SmartPack-*
   ```
4. **删除 Module Cache**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
   ```
5. **重新打开 Xcode**
6. **重新编译**

### 方法 2: 检查项目文件

如果 Xcode UI 中显示的 Bundle ID 不正确，可能需要直接编辑项目文件，但建议先尝试方法 1。

### 方法 3: 重新创建 Extension Target

如果以上方法都不行，可能需要：
1. 删除现有的 Extension target
2. 重新创建 Widget Extension target
3. 确保 Bundle ID 正确设置

---

## 📝 注意事项

1. **Bundle ID 区分大小写**
2. **不能包含空格**
3. **Extension 的 Bundle ID 必须以主 App 的 Bundle ID 为前缀**
4. **确保在 Xcode 的 General 和 Build Settings 中都显示正确的 Bundle ID**

---

*完成以上步骤后，Bundle Identifier 错误应该能够解决。如果问题仍然存在，请提供 Xcode 中显示的 Bundle ID 值。*
