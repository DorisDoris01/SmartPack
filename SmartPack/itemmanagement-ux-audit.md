# ItemManagementView UI/UX Audit

## High Priority

| # | Issue | Detail |
|---|-------|--------|
| **U1** | **Silent failure on last-item delete** | When user tries to delete the last item in a tag, nothing happens — no alert, no haptic, no feedback at all. User thinks the app is broken. |
| **U2** | **No haptic feedback anywhere** | Every other view uses `HapticFeedback.light()` on taps, `.warning()` on delete, `.error()` on failures. This view has zero haptics. |
| **U3** | **Inconsistent delete UX** | Preset items use swipe-to-delete, custom items show a visible minus button. Same action, two different patterns — confusing. |

## Medium Priority

| # | Issue | Detail |
|---|-------|--------|
| **U4** | **No animation on add/delete/restore** | Items appear/disappear instantly. HomeView and PackingListView use `withAnimation` for all list mutations. |
| **U5** | **"Preset" badge uses `systemGray5`** | Hardcoded system color instead of design system `AppColors`. Inconsistent in dark mode. |
| **U6** | **Custom item row has no "Custom" badge** | Preset items get a badge, custom items don't — no way to distinguish them at a glance. |
| **U7** | **Add sheet is heavyweight for a single text field** | Other views (AddItemRow) use inline TextField, not a full modal sheet. Sheet requires 3 taps (button → type → Add) vs 2 taps inline. |

## Low Priority

| # | Issue | Detail |
|---|-------|--------|
| **U8** | **No success feedback on add** | Sheet dismisses silently. User doesn't know if item was added (especially if DisclosureGroup is collapsed). |
| **U9** | **Section headers use default List style** | Rest of app uses `.sectionHeaderStyle()` (overline, uppercase, extra-wide tracking). |
| **U10** | **Touch targets not verified at 44pt** | Item rows don't enforce minimum 44pt height like ItemRow/AddItemRow do. |
