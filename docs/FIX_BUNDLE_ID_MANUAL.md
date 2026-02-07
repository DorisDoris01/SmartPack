# 手动修复 Bundle Identifier 错误

> **错误**: `Embedded binary's bundle identifier is not prefixed with the parent app's bundle identifier`

---

## 🎯 在 Xcode 中手动修复（推荐）

### 步骤 1: 检查主 App Bundle ID

1. 在 Xcode 中，**选择项目根节点**（最顶部的蓝色图标）
2. 在中间面板，**选择 `SmartPack` target**（主 App target）
3. 点击 **General** 标签
4. 找到 **Identity** 部分
5. **记录显示的 Bundle Identifier**：应该是 `com.smartpack.app.doris`

### 步骤 2: 设置 Extension Bundle ID

1. **选择 `smartpackExtension` target**
2. 点击 **General** 标签
3. 找到 **Identity** 部分
4. **Bundle Identifier** 字段应该显示：`com.smartpack.app.doris.smartpackExtension`
5. **如果显示不正确或为空**：
   - 点击 Bundle Identifier 字段
   - **手动输入**：`com.smartpack.app.doris.smartpackExtension`
   - 按 **回车** 保存

### 步骤 3: 验证 Build Settings

1. **保持选择 `smartpackExtension` target**
2. 点击 **Build Settings** 标签
3. 在搜索框中输入：`PRODUCT_BUNDLE_IDENTIFIER`
4. 找到 **Product Bundle Identifier** 设置
5. **确认值为**：`com.smartpack.app.doris.smartpackExtension`
6. **如果显示不正确**：
   - 双击该值
   - 输入：`com.smartpack.app.doris.smartpackExtension`
   - 按 **回车** 保存

### 步骤 4: 检查 Signing

1. **保持选择 `smartpackExtension` target**
2. 点击 **Signing & Capabilities** 标签
3. 确认 **Automatically manage signing** 已勾选
4. 确认 **Team** 选择正确
5. 确认 **Bundle Identifier** 显示为：`com.smartpack.app.doris.smartpackExtension`

### 步骤 5: 清理并重新编译

1. **Product → Clean Build Folder** (⌘⇧K)
2. **关闭 Xcode**
3. **删除 DerivedData**（在终端运行）：
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/SmartPack-*
   ```
4. **重新打开 Xcode**
5. **Product → Build** (⌘B)

---

## 🔍 如果 General 标签中没有 Bundle Identifier 字段

某些 Xcode 版本可能需要在 Build Settings 中设置：

1. **选择 `smartpackExtension` target**
2. **Build Settings** 标签
3. 搜索：`bundle identifier`
4. 找到 **Product Bundle Identifier**
5. 双击，输入：`com.smartpack.app.doris.smartpackExtension`

---

## ⚠️ 常见问题

### 问题 1: Bundle ID 字段是灰色的，无法编辑

**解决**：
1. 取消勾选 **Automatically manage signing**
2. 重新勾选 **Automatically manage signing**
3. 然后应该可以编辑 Bundle Identifier

### 问题 2: 输入后显示红色错误

**检查**：
- 确保没有空格
- 确保全部小写
- 确保格式为：`[主 App Bundle ID].[Extension 后缀]`

### 问题 3: 保存后又被重置

**解决**：
1. 检查是否有多个 Build Configuration（Debug/Release）
2. 确保两个配置都设置了正确的 Bundle ID
3. 在 Build Settings 中检查是否有条件设置覆盖了值

---

## 📝 验证清单

修复后，确认：

- [ ] 主 App Bundle ID: `com.smartpack.app.doris`
- [ ] Extension Bundle ID: `com.smartpack.app.doris.smartpackExtension`
- [ ] Extension Bundle ID 以主 App Bundle ID 开头
- [ ] General 和 Build Settings 中显示一致
- [ ] 清理缓存后重新编译

---

## 🆘 如果仍然报错

请提供以下信息：

1. **Xcode General 标签中显示的 Bundle Identifier**（主 App 和 Extension）
2. **Build Settings 中 PRODUCT_BUNDLE_IDENTIFIER 的值**
3. **完整的错误信息**（包括错误代码）

这样我可以进一步诊断问题。

---

*按照以上步骤在 Xcode UI 中手动设置后，错误应该能够解决。*
