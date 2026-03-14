# ItemManagementView UI/UX Fix Plan

**File:** `SmartPack/Views/Settings/ItemManagementView.swift`
**Reviewed with:** UI/UX Pro Max (SwiftUI stack + UX guidelines)

---

## Status Overview

| ID | Severity | Issue | Status |
|----|----------|-------|--------|
| U1 | HIGH | Silent failure on last-item delete | **DONE** |
| U2 | HIGH | Tiny touch target on delete button | **Superseded by U4** |
| U3 | MEDIUM | No expand/collapse animation | Pending |
| U4 | MEDIUM | Inconsistent delete patterns | **DONE** |
| U5 | MEDIUM | TextField not auto-focused | **DONE** |
| U6 | LOW | Badge uses non-design-system color | **DONE** |
| U7 | LOW | No list animation on add/delete | Pending |

---

## U1: Silent failure on last-item delete [DONE]

**Problem:** When only 1 item remains in a tag, swiping to delete silently does nothing. Code comments say "提示用户不能删除最后一个" but no alert was shown.

**Solution:** Added `@State` alert flag, wired both delete functions to trigger it, added `.alert()` modifier with bilingual message.

```swift
// Added state (line 22)
@State private var showingDeleteConstraintAlert = false

// In deleteCustomItem() and deletePresetItem() — replaced bare `return`:
if !customItemManager.canDeleteItem(...) {
    showingDeleteConstraintAlert = true  // was just `return`
    return
}

// Added .alert() modifier on List (lines 51-60)
.alert(
    localization.currentLanguage == .chinese ? "无法删除" : "Cannot Delete",
    isPresented: $showingDeleteConstraintAlert
) {
    Button(localization.currentLanguage == .chinese ? "确定" : "OK") { }
} message: {
    Text(localization.currentLanguage == .chinese
         ? "每个标签至少需要保留一个物品。"
         : "Each tag must have at least one item.")
}
```

---

## U2: Tiny touch target on delete button [SUPERSEDED]

**Problem:** `minus.circle.fill` button was ~17pt with no `.frame()` — below Apple HIG 44pt minimum.

**Resolution:** U4 removed the minus button entirely in favor of swipe-to-delete. No standalone touch target to fix.

---

## U3: No expand/collapse animation [PENDING]

**Problem:** `expandedTags.insert/remove` in the DisclosureGroup binding (line 75-80) executes without `withAnimation`, causing the section to snap open/closed abruptly.

**Proposed solution:** Wrap the state mutations in `withAnimation`.

```swift
// CURRENT (line 75-80):
set: { newValue in
    if newValue {
        expandedTags.insert(tag.id)
    } else {
        expandedTags.remove(tag.id)
    }
}

// PROPOSED:
set: { newValue in
    withAnimation(.easeInOut(duration: 0.2)) {
        if newValue {
            expandedTags.insert(tag.id)
        } else {
            expandedTags.remove(tag.id)
        }
    }
}
```

---

## U4: Inconsistent delete patterns [DONE]

**Problem:** Preset items used swipe-to-delete (`.swipeActions`), but custom items used a visible `minus.circle.fill` button. Two different mental models in the same list.

**Solution:** Replaced the minus button in `customItemRow()` with `.swipeActions`, matching the preset item pattern exactly.

```swift
// BEFORE:
private func customItemRow(...) -> some View {
    HStack {
        Text(itemName)...
        Spacer()
        Button {                              // visible minus button
            deleteCustomItem(...)
        } label: {
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }
    .padding(.leading, 36)
}

// AFTER:
private func customItemRow(...) -> some View {
    HStack {
        Text(itemName)...
        Spacer()
    }
    .padding(.leading, 36)
    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
        Button {
            deleteCustomItem(...)
        } label: {
            Label(localization.currentLanguage == .chinese ? "删除" : "Delete",
                  systemImage: "trash")
        }
        .tint(.red)
    }
}
```

---

## U5: TextField not auto-focused in AddCustomItemSheet [DONE]

**Problem:** When the "Add Item" sheet opens, the user must manually tap the TextField to start typing. The keyboard doesn't appear automatically.

**Solution:** Added `@FocusState`, applied `.focused()` to the TextField, and `.onAppear` on the Form to trigger focus.

```swift
// Added state (line 229)
@FocusState private var isNameFieldFocused: Bool

// Added .focused() to TextField (line 238)
TextField(
    localization.currentLanguage == .chinese ? "输入物品名称" : "Enter item name",
    text: $itemName
)
.focused($isNameFieldFocused)

// Added .onAppear on Form (line 249)
.onAppear { isNameFieldFocused = true }
```

---

## U6: "Preset" badge uses non-design-system color [DONE]

**Problem:** The "Preset" badge background used `Color(.systemGray5)` instead of the app's `AppColors` design system. This didn't adapt correctly to the app's custom light/dark theme.

**Solution:** One-line change (line 143).

```swift
// BEFORE:
.background(Color(.systemGray5))

// AFTER:
.background(AppColors.secondaryBackground)
```

---

## U7: No list animation on item add/delete [PENDING]

**Problem:** When items are added or deleted, the list updates instantly without any transition — feels jarring compared to standard iOS list behavior.

**Proposed solution:** Wrap the data mutations in `withAnimation`.

```swift
// In deleteCustomItem() (line 200):
// CURRENT:
customItemManager.removeCustomItem(itemName, from: tagId)
// PROPOSED:
withAnimation { customItemManager.removeCustomItem(itemName, from: tagId) }

// In deletePresetItem() (line 213):
// CURRENT:
customItemManager.deletePresetItem(itemId)
// PROPOSED:
withAnimation { customItemManager.deletePresetItem(itemId) }

// In AddCustomItemSheet.addItem() (line 281):
// CURRENT:
let success = customItemManager.addCustomItem(itemName, to: tag.id)
// PROPOSED:
let success: Bool
withAnimation { success = customItemManager.addCustomItem(itemName, to: tag.id) }
```

---

## Verification Checklist

| # | Test | Expected |
|---|------|----------|
| 1 | `xcodebuild build` | BUILD SUCCEEDED |
| 2 | Delete last item in a tag | Alert: "Cannot Delete" / "无法删除" |
| 3 | Swipe custom item left | Red "Delete" action (same as preset items) |
| 4 | Tap tag row to expand/collapse | Smooth 200ms ease-in-out animation |
| 5 | Tap "Add Item" | Sheet opens with keyboard up, cursor in field |
| 6 | Check "Preset" badge in dark mode | Uses `AppColors.secondaryBackground` |
| 7 | Add or delete any item | Smooth list insertion/removal animation |
| 8 | Run `CustomItemManagerTests` | All pass (data layer unchanged) |
