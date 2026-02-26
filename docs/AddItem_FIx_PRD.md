# 🔧 任务指令：修复 SwiftUI 列表输入框“首次点击失效”的 Bug

**目标执行者:** @Claude Code
**涉及文件:** `SmartPack/SmartPack/Components/PackingList/AddItemRow.swift`
**任务类型:** UI 交互 Bug 修复

---

## 一、 任务上下文与 Bug 根源 (Context)

**问题现象:** 在 `PackingListView` 的 `AddItemRow` 组件中，用户在 `TextField` 输入内容后，点击旁边的“添加”按钮或下方的“预设建议”按钮，第一次点击无效（仅收起了键盘），必须点击第二次才能成功触发 `addItem()`。

**Root Cause (请在未来的 SwiftUI 编码中规避此陷阱):**
在 SwiftUI 的 `List` 容器内，当 `TextField` 获取焦点 (`@FocusState` 激活) 时，点击其他区域会触发系统默认的“收起键盘”行为，该行为会**拦截掉第一次点击事件**。

---

## 二、 执行方案 (Execution Steps)

**修复策略：** 显式地为这些独立的交互按钮应用 `.buttonStyle(.borderless)` 修饰符。这会指示 SwiftUI 该按钮在 `List` 中是独立可交互的，要求直接响应点击，从而绕过 `List` 的默认手势拦截。

请修改 `AddItemRow.swift`，执行以下两处更新：

### 1. 修改文本框旁的“添加”按钮
定位到 `if !itemName.isEmpty` 条件块内的 `Button`，追加 `.buttonStyle(.borderless)`：

```swift
// 修改目标结构：
if !itemName.isEmpty {
    Button {
        addItem()
    } label: {
        Text(localization.currentLanguage == .chinese ? "添加" : "Add")
            .font(Typography.subheadline)
            .foregroundColor(AppColors.primary)
    }
    .buttonStyle(.borderless) // 👈 必须添加此修饰符
}


### 2. 修改“预设建议”按钮
定位到 ForEach(filteredPresetItems) { item in ... } 循环内的 Button，追加相同的修饰符：

Swift
// 修改目标结构：
ForEach(filteredPresetItems) { item in
    Button {
        itemName = item.displayName(language: localization.currentLanguage)
        addItem()
    } label: {
        Text(item.displayName(language: localization.currentLanguage))
            // ... 保持原有样式修饰符不变 ...
    }
    .buttonStyle(.borderless) // 👈 必须添加此修饰符
}


## 三、 验证标准 (Acceptance Criteria)
AddItemRow.swift 编译通过，无语法错误。

原有逻辑和 UI 样式未被破坏。

（逻辑验证）键盘弹起时，一次点击即可直接触发 addItem() 动作。


### 💡 Vibe Coding 专家的提示：
将文档改成这种 **“Context + Execution + Acceptance”** 的结构，Claude Code 就能清晰地知道：
1. **它在修什么**（防止它乱改其他逻辑）。
2. **为什么要这么修**（它会将这个 SwiftUI 的 List/Focus 陷阱作为经验学进去，后续写代码会更聪明）。
3. **具体要改哪里**（精准定位）。



