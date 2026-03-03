# SmartPack Code Bug Review (Consolidated)

Two independent code reviews were performed across all 40+ Swift source files:
- **Review A**: General-purpose bug scanner (32 findings)
- **Review B**: Superpowers architecture reviewer (16 findings)

This document merges both, deduplicates overlapping findings, and assigns a final consensus severity.

---

## Summary

| Severity | Count | Fixed | IDs |
|----------|-------|-------|-----|
| Critical | 5 | 5 | ~~F1~~, ~~F2~~, ~~F3~~, ~~F4~~, ~~F5~~ |
| High | 8 | 7 | F6, ~~F7~~, ~~F8~~, ~~F9~~, ~~F10~~, ~~F11~~, ~~F12~~, ~~F13~~ |
| Medium | 13 | 3 | F14, F15, ~~F16~~, ~~F17~~, ~~F18~~, F19 - F26 |
| Low | 12 | 3 | F27 - F34, ~~F35~~, ~~F36~~, ~~F37~~, F38 |
| **Total** | **38** | **18** | |

**Top 5 to fix first:**
1. ~~**F1**~~ ✓ FIXED — `weatherForecasts` getter mutates state (infinite re-render / crash)
2. ~~**F2**~~ ✓ FIXED — No SwiftData migration strategy (data loss on app update)
3. ~~**F3**~~ ✓ FIXED — Category sorting silently broken (wrong list order for all users)
4. ~~**F4**~~ ✓ FIXED — CelebrationOverlay double-dismiss (navigation crash)
5. **F5** — Zero test coverage (no safety net for any regression)

---

## Strengths (from both reviews)

Both reviewers noted the following positives:

1. **Clean MVVM separation** — `PackingListViewModel` encapsulates business logic; views stay presentational. The three-phase toggle strategy (sync mutation, deferred Live Activity, deferred completion check) is thoughtful.
2. **Well-designed design system** — `AppColors`, `Typography`, `Spacing`, `CornerRadius` provide a consistent vocabulary. `AppColors` properly supports light/dark mode with `UIColor { trait in }`.
3. **Performance-conscious data model** — Pre-computed `checkedItemCount`/`totalItemCount` counters with O(1) reads. `@Transient` weather cache avoids repeated JSON decoding.
4. **Robust weather service** — Handles geocoding failures, network errors, HTTP errors, and JSON parse errors gracefully. Dual-language geocoding fallback is practical.
5. **Good accessibility coverage** — `ItemRow`, `CategoryHeader`, and `ProgressHeader` include bilingual `accessibilityLabel` and `accessibilityHint`.
6. **Thorough bilingual support** — Every user-facing string has Chinese and English variants with model-level `displayName(language:)`.
7. **Correct SwiftData relationship design** — `@Relationship(deleteRule: .cascade)` prevents orphaned records.

---

## CRITICAL

### F1 — `weatherForecasts` Getter Mutates `@Transient` Cache (Infinite Re-render + SwiftData Violation)

| | |
|-|-|
| **File** | `Models/Trip.swift:222-236` |
| **Source** | Review A (B1, B6) + Review B (R1) — both flagged Critical |
| **Description** | The `weatherForecasts` computed getter sets `cachedWeather` as a side effect. Since `Trip` is `@Model` (implicitly `@Observable`), mutating a property inside a getter can trigger an infinite observation loop: read triggers write, write triggers re-read. SwiftData may also fire change-tracking during the getter, causing unexpected saves. Additionally, `@Transient` properties can be reset during fault/unfault cycles, making the cache unreliable. |
| **Impact** | UI freeze/hang from infinite re-render, unexpected SwiftData persistence writes, or data race crash under concurrent access. |
| **Fix** | Decode weather data in `didSet` of `weatherData` or on explicit refresh call — never inside the getter. A `lazy var` will not work with `@Model`. |

### F2 — No SwiftData Schema Migration Strategy

| | |
|-|-|
| **File** | `SmartPackApp.swift:38` |
| **Source** | Review B (R2) only — Critical |
| **Description** | The model container uses `.modelContainer(for: [Trip.self, TripItem.self])` with no `VersionedSchema` or `SchemaMigrationPlan`. The `Trip` model has added `destination`, `startDate`, `endDate`, `weatherData`, `isArchived`, `checkedItemCount`, `totalItemCount` over its evolution. |
| **Impact** | If any user on an older schema updates the app, SwiftData attempts automatic lightweight migration. If it fails, the app crashes on launch with an unrecoverable Core Data migration error — complete data loss. All new properties do have defaults, which makes lightweight migration viable, but this must be explicitly tested. |
| **Fix** | Implement `VersionedSchema` (V1, V2) and a `SchemaMigrationPlan`. At minimum, formally declare a V1 schema so future changes have a migration path. |

### F3 — Category Sorting Completely Broken

| | |
|-|-|
| **File** | `Data/PresetData.swift:446-452` |
| **Source** | Review A (B3) Critical + Review B (R11) Minor — **upgraded to Critical** because it's actively broken |
| **Description** | Sorting uses `ItemCategory(rawValue: item.category.lowercased())`, but `item.category` stores Chinese names (e.g. `"证件/钱财"`) while `ItemCategory` raw values are English (e.g. `"documents"`). The `rawValue` init always returns `nil`, so all items fall back to `sortOrder = 5` (`.other`). |
| **Impact** | All packing list items are effectively unsorted by category for every user. |
| **Fix** | Use `item.sortOrder` directly (already set correctly when creating `TripItem` from `Item`), or match on the `ItemCategory` enum instead of raw strings. |

### F4 — `CelebrationOverlay` Double-Dismiss Race Condition

| | |
|-|-|
| **File** | `Components/PackingList/CelebrationOverlay.swift:58,82` |
| **Source** | Review A (B2) only — Critical |
| **Description** | `dismissAndComplete()` fires from both the 2.5s auto-dismiss timer (`asyncAfter`) and user tap. If the user taps before the timer fires, `onComplete()` runs twice — calling `dismiss()` twice can corrupt the navigation stack. |
| **Impact** | Navigation stack corruption, blank screen, or crash. |
| **Fix** | Add `@State private var hasDismissed = false` guard flag, or use a cancellable `DispatchWorkItem`. |

### F5 — ✓ FIXED Zero Test Coverage

| | |
|-|-|
| **File** | Entire project (no `*Test*.swift` files) |
| **Source** | Review B (R3) only — Critical |
| **Status** | ✓ FIXED — SmartPackTests target added with 6 test files: TripTests, TripDateRangeTests, WeatherForecastTests, PresetDataTests, CustomItemManagerTests, TestModelContainer helper. All tests pass. |
| **Description** | No unit or integration tests exist. `PackingListViewModel`, `PresetData.generatePackingList`, `WeatherService`, `CustomItemManager`, and `Trip` model logic are all untested. |
| **Impact** | Any regression (counter drift, dedup bugs, weather adjustment errors) is caught only by manual testing. |
| **Fix** | Add test targets. Highest-value targets: (1) `Trip` counter integrity, (2) `PresetData.generatePackingList` output, (3) `PackingListViewModel` toggle/add/delete, (4) `CustomItemManager` persistence. |

---

## HIGH

### F6 — `PackingActivityManager.endActivity()` Race Condition

| | |
|-|-|
| **File** | `Activity/PackingActivityManager.swift:90-102` |
| **Source** | Review A (B4) |
| **Description** | `endActivity()` launches a `Task` to call `activity.end(...)` then immediately sets `currentActivity = nil`. If `startActivity` is called in between, a new activity starts while the old one hasn't ended. No synchronization on `currentActivity`. |
| **Impact** | Orphaned Live Activities that never end, or crash from data race. |
| **Fix** | Make `PackingActivityManager` an `actor` or add `@MainActor` isolation. |

### F7 — `CreateTripSheet` Weather Task Not Cancelled on Dismissal + Mutable Capture

| | |
|-|-|
| **File** | `Components/Trip/CreateTripSheet.swift:216-287` |
| **Source** | Review A (B5, B21) + Review B (R8) — both flagged High/Important |
| **Description** | The `Task` for weather fetch is unstructured and not cancelled on sheet dismissal. If the user dismisses while the fetch is in-flight, the task continues and calls `modelContext.insert(trip)` + `onTripCreated(trip)`, creating a phantom trip. Additionally, `items` is captured mutably across the async boundary while form inputs remain active. |
| **Impact** | Ghost trip created after user dismissed creation sheet. Possible inconsistent trip data. |
| **Fix** | Store the `Task` and cancel it in `onDisappear`, or use `.task {}` modifier. Snapshot all values before entering the Task. |

### F8 — `@StateObject` Misused with Singleton + Mixed Observation Systems

| | |
|-|-|
| **File** | `Views/Settings/ItemManagementView.swift:16,213` + `Data/CustomItemManager.swift:16` |
| **Source** | Review A (B7) + Review B (R5) — both flagged High/Important |
| **Description** | `@StateObject` is used with `CustomItemManager.shared` (a singleton). `@StateObject` is designed to own lifecycle; using it with a shared singleton is semantically wrong. Additionally, `CustomItemManager` uses `ObservableObject`/`@Published` while the rest of the app uses `@Observable` — mixing observation systems. |
| **Impact** | Violates SwiftUI's ownership model. Could cause subtle lifecycle issues or missed updates. |
| **Fix** | Use `@ObservedObject` for singletons, or migrate `CustomItemManager` to `@Observable`. |

### F9 — ✓ FIXED `UIScreen.main.bounds` Deprecated and Wrong on iPad

| | |
|-|-|
| **File** | `Components/PackingList/CelebrationOverlay.swift:71,108,115` |
| **Source** | Review A (B8) + Review B (R7) — both flagged High/Important |
| **Status** | ✓ FIXED — Replaced all `UIScreen.main.bounds` with `GeometryReader`. Confetti x-positions stored as fractions (0...1), resolved to actual view bounds in `ConfettiView`. Works correctly on iPad multitasking. |
| **Description** | `UIScreen.main.bounds` is deprecated (iOS 16+). On iPad with Split View / Slide Over / Stage Manager, it returns the full screen size, not the app window size. |
| **Impact** | Confetti animation positioned incorrectly on iPad multitasking. |
| **Fix** | Use `GeometryReader` to get actual view bounds. |

### F10 — ✓ FIXED `checkedItemCount` / `totalItemCount` Can Go Out of Sync

| | |
|-|-|
| **File** | `Models/Trip.swift:146-178` |
| **Source** | Review A (B9) |
| **Status** | ✓ FIXED — Added `max(0, ...)` bounds to `toggleItem()` and `removeItem()` to prevent negative counters. Added `recalculateCounts()` safety net call in `PackingListViewModel.init()`. |
| **Description** | Counters are maintained incrementally. If anything directly mutates `TripItem.isChecked` without going through `Trip.toggleItem()`, `addItem()`, or `removeItem()`, counters become stale. SwiftData allows direct property mutation. |
| **Impact** | Wrong progress percentage; `isAllChecked` incorrect; trip may auto-archive prematurely or never archive. |
| **Fix** | Add `recalculateCounts()` as a safety net at critical checkpoints, or add `max(0, ...)` bounds. |

### F11 — Weather Descriptions Hardcoded in Chinese (Broken English Mode)

| | |
|-|-|
| **File** | `Services/WeatherService.swift:244-273` + `Models/WeatherForecast.swift:48,62-69` |
| **Source** | Review A (B15, B26, B31) + Review B (R6, R16) — both flagged this cluster |
| **Description** | `weatherCodeToCondition` returns only Chinese descriptions (`"晴天"`, `"多云"`). `displayCondition(language:)` returns the same value for both languages (dead switch). `WeatherForecast.unavailable` defaults to Chinese `"数据不可用"`. |
| **Impact** | English users see Chinese weather text everywhere. |
| **Fix** | Store both CN and EN descriptions, or localize at display time from the `condition` code. |

### F12 — ✓ FIXED `PackingListViewModel` Missing `@MainActor`

| | |
|-|-|
| **File** | `ViewModels/PackingListViewModel.swift` (entire file) |
| **Source** | Review A (B17) + Review B (R4) — both flagged |
| **Status** | ✓ FIXED — Added `@MainActor` annotation to the class. |
| **Description** | `@Observable` class without `@MainActor`. Holds and mutates a SwiftData `@Model` (which is main-actor-isolated). Currently all callers are SwiftUI views (main thread), but no enforcement. |
| **Impact** | Data races from future background callers. Will fail to compile under Swift 6 strict concurrency. |
| **Fix** | Add `@MainActor` to the class. |

### F13 — ✓ FIXED `hasCompletedOnboarding` Setter Does Not Trigger `@Published`

| | |
|-|-|
| **File** | `Localization/LocalizationManager.swift:80-83` |
| **Source** | Review A (B10) |
| **Status** | ✓ FIXED — Converted to `@Published` property with `didSet` syncing to UserDefaults. Updated `WelcomeView` to use `localization.hasCompletedOnboarding = true` instead of writing directly to UserDefaults. |
| **Description** | Computed property backed by `UserDefaults`, not `@Published`. Setting it doesn't trigger `objectWillChange`. Currently works due to binding pattern, but fragile. |
| **Impact** | Any future view observing `hasCompletedOnboarding` won't react to changes. |
| **Fix** | Make it a `@Published` property that syncs with UserDefaults. |

---

## MEDIUM

### F14 — `try? modelContext.save()` Silently Swallows Errors

| | |
|-|-|
| **File** | `Views/Main/HomeView.swift:278,286,292` |
| **Source** | Review B (R9) |
| **Description** | All `modelContext.save()` calls use `try?`, silently ignoring errors (disk full, corruption). |
| **Impact** | Silent data loss — user sees UI update but data doesn't persist. |
| **Fix** | Log errors at minimum. Consider using SwiftData's auto-save instead of explicit calls. |

### F15 — `TripRowView.appeared` State Resets on List Re-render

| | |
|-|-|
| **File** | `Components/Trip/TripRowView.swift:16,48,77-81` |
| **Source** | Review A (B11) |
| **Description** | `@State private var appeared = false` controls ring animation. List re-renders may recreate the view, replaying the animation from zero. |
| **Impact** | Ring animation replays unnecessarily, visual flickering. |
| **Fix** | Use `.animation` on the trim value directly. |

### F16 — ✓ FIXED `addItem` Deduplication Only Checks Chinese Name

| | |
|-|-|
| **File** | `ViewModels/PackingListViewModel.swift:109-111` |
| **Source** | Review A (B12) |
| **Status** | ✓ FIXED — Changed dedup check from `map { $0.name }` to `flatMap { [$0.name, $0.nameEn] }`, checking both CN and EN names. |
| **Description** | Duplicate check uses `$0.name.lowercased()` — only the Chinese field. English-mode users typing English names bypass the check. |
| **Impact** | Duplicate items in English mode. |
| **Fix** | Check both `name` and `nameEn`. |

### F17 — ✓ FIXED `PackingListView.vm` May Hold Stale ViewModel

| | |
|-|-|
| **File** | `Views/Trip/PackingListView.swift:32,346-349` |
| **Source** | Review A (B14) |
| **Status** | ✓ FIXED — Added `.id(trip.id)` on both `PackingListView` navigation destinations in `HomeView.swift`, forcing SwiftUI to recreate the view (and its `@State` VM) for each different trip. |
| **Description** | ViewModel is `@State` and created lazily with `if vm == nil` guard. If SwiftUI reuses the view with a different `trip` (NavigationStack caching), the VM still points to the old trip. |
| **Impact** | Editing the wrong trip's packing list. |
| **Fix** | Use `.id(trip.id)` on `PackingListView` in the navigation destination. |

### F18 — ~~Deprecated Files Still Compiled~~ ✓ FIXED

| | |
|-|-|
| **File** | `Views/Main/MainTabView.swift`, `Views/Shared/MyListsView.swift` |
| **Source** | Review B (R10) + Review A (B16) |
| **Description** | Both files are marked `[DEPRECATED]` in comments but still compiled. `MyListsView` has deletion without confirmation and missing `modelContext.save()`. |
| **Impact** | Dead code, maintenance burden, inconsistent behavior if accidentally used. |
| **Fix** | Remove from project or mark with `@available(*, deprecated)`. |
| **Status** | ✓ FIXED — Both files deleted from disk. No references in any other Swift file. Build verified clean. |

### F19 — `WelcomeView.dismissCard()` Non-Cancellable `asyncAfter`

| | |
|-|-|
| **File** | `Views/Main/WelcomeView.swift:142-149` |
| **Source** | Review A (B13) |
| **Description** | `asyncAfter(deadline: .now() + 0.3)` with no cancellation. Rapid swiping could call `dismissCard()` twice. |
| **Impact** | Double-dismiss of welcome screen. |
| **Fix** | Add a guard flag. |

### F20 — `ItemRow` Checkbox Animation Pile-up

| | |
|-|-|
| **File** | `Components/PackingList/ItemRow.swift:25-33` |
| **Source** | Review A (B18) |
| **Description** | Rapid tapping schedules overlapping `asyncAfter` callbacks for `checkboxScale`, producing janky visuals. |
| **Impact** | Glitchy checkbox bounce animation. |
| **Fix** | Debounce the tap or use `.animation` modifier. |

### F21 — Preset Suggestion Chips Can Show Already-Existing Items

| | |
|-|-|
| **File** | `Components/PackingList/AddItemRow.swift:113-115` |
| **Source** | Review A (B19) |
| **Description** | Suggestion chips filter by `existingItemIds` but `addItem()` deduplicates by name. Mismatch causes chips to show items that fail silently when tapped. |
| **Impact** | Confusing UX — tap chip, nothing happens, error haptic. |
| **Fix** | Filter suggestions by both ID and name match. |

### F22 — `Trip.id` Shadows SwiftData's `PersistentIdentifier`

| | |
|-|-|
| **File** | `Models/Trip.swift:66` |
| **Source** | Review A (B20) |
| **Description** | Explicit `var id: UUID` creates two identity systems. SwiftUI uses `Identifiable.id` while SwiftData uses `PersistentIdentifier`. |
| **Impact** | Subtle identity resolution issues during migration. |
| **Fix** | Annotate with `@Attribute(.unique)`. |

### F23 — Duplicate Toggle Methods Across Two Trip Creation Views

| | |
|-|-|
| **File** | `Components/Trip/CreateTripSheet.swift:192-214` + `Views/Trip/TripConfigView.swift:141-155` |
| **Source** | Review B (R12) |
| **Description** | `toggleActivityTag`, `toggleOccasionTag`, `toggleConfigTag` are duplicated identically across both files. |
| **Impact** | DRY violation — changes must be made in two places. |
| **Fix** | Extract toggle methods into `TripConfig` itself. |

### F24 — ~~Inconsistent Localization Approach~~ FIXED

| | |
|-|-|
| **File** | `Localization/LocalizationManager.swift` + 10 views |
| **Source** | Review B (R13) |
| **Status** | **FIXED** — Expanded `LocalizedKey` enum with ~50 new cases (Option B). Converted all ~85 inline ternaries across 10 files to `localization.string(for:)`. Only 2 interpolated strings remain as `text()`. All translations centralized in dictionary. |

### F25 — `HomeView` Has Two Conflicting Navigation Destinations for `Trip`

| | |
|-|-|
| **File** | `Views/Main/HomeView.swift:182-183,243` |
| **Source** | Review A (B27) |
| **Description** | Both `.navigationDestination(for: Trip.self)` and `.navigationDestination(item: $selectedTrip)` navigate to `PackingListView`. Two destinations for the same type can confuse `NavigationStack`. |
| **Impact** | Possible navigation stack confusion or double-navigation. |
| **Fix** | Use a single navigation mechanism. |

### F26 — `ItemManagementView.deleteCustomItem` Uses Stale Count

| | |
|-|-|
| **File** | `Views/Settings/ItemManagementView.swift:181-190` |
| **Source** | Review A (B32) |
| **Description** | `customCount` is computed at render time and passed as parameter. Rapid deletions use the stale count. |
| **Impact** | Could bypass "at least 1 item" constraint. |
| **Fix** | Re-fetch count inside `deleteCustomItem`. |

---

## LOW

### F27 — `PresetData` Singleton Not Thread-Safe

| | |
|-|-|
| **File** | `Data/PresetData.swift:14-15,21-27` |
| **Source** | Review A (B22) |
| **Description** | `lazy var` on shared singleton without synchronization. |
| **Fix** | Add `@MainActor` or `nonisolated(unsafe)`. |

### F28 — `WeatherService` Missing `Sendable` Conformance

| | |
|-|-|
| **File** | `Services/WeatherService.swift:12` |
| **Source** | Review A (B23) |
| **Description** | Singleton class in async contexts without `Sendable`. |
| **Fix** | Add `Sendable` conformance. |

### F29 — `HapticFeedback` Generators Not Pre-Prepared

| | |
|-|-|
| **File** | `Configuration/HapticFeedback.swift:12-14` |
| **Source** | Review A (B24) + Review B (R14) |
| **Description** | New `UIImpactFeedbackGenerator` created each call without `prepare()`. |
| **Fix** | Use static generator instances with `prepare()`. |

### F30 — `TripConfigView` Has Different Navigation Pattern (Possibly Dead Code)

| | |
|-|-|
| **File** | `Views/Trip/TripConfigView.swift:157-196` |
| **Source** | Review A (B25) + Review B (R12) |
| **Description** | `TripConfigView` pushes navigation within itself while `CreateTripSheet` uses callback. May be unused legacy code. |
| **Fix** | Verify if still used; remove or align. |

### F31 — `TagChip` Relies on `@EnvironmentObject` — Fragile for Reuse

| | |
|-|-|
| **File** | `Components/PackingList/TripSettingsCard.swift` (TagChip) |
| **Source** | Review A (B28) |
| **Description** | `TagChip` uses `@EnvironmentObject var localization`. Crashes if reused outside hierarchy that provides it. |
| **Fix** | Pass `language` as a parameter. |

### F32 — Custom Item Dedup Key Inconsistent with Preset Items

| | |
|-|-|
| **File** | `Data/PresetData.swift:426` |
| **Source** | Review A (B29) |
| **Description** | Custom items use `"\(name)|\(name)"` dedup key; presets use `"\(nameCN)|\(nameEN)"`. |
| **Fix** | Normalize dedup key. |

### F33 — Item Deletion Has No Undo/Confirmation

| | |
|-|-|
| **File** | `Views/Trip/PackingListView.swift:362-364` |
| **Source** | Review A (B30) |
| **Description** | `requestDeleteItem` deletes immediately without confirmation. (`allowsFullSwipe: false` is set, which is good.) |
| **Fix** | Consider adding an undo toast. |

### F34 — `print()` Debug Statements in Production Code

| | |
|-|-|
| **File** | `WeatherService.swift` (~25 prints), `SmartPackApp.swift:18`, `PresetData.swift:408,440`, `PackingActivityManager.swift:50-65` |
| **Source** | Review B (R15) |
| **Description** | Emoji-prefixed debug prints scattered throughout with no `#if DEBUG` guards. |
| **Fix** | Wrap in `#if DEBUG` or use `os.Logger`. |

### F35 — ✓ FIXED `WeatherForecast.unavailable` Defaults to Chinese

| | |
|-|-|
| **File** | `Models/WeatherForecast.swift:48` |
| **Source** | Review A (B31) |
| **Status** | ✓ FIXED as part of F11 |
| **Description** | `unavailable(for:language:)` defaults to `.chinese`. Callers don't pass language. |
| **Fix** | Fixed in F11 — now stores both CN and EN descriptions. |

### F36 — ✓ FIXED `displayCondition(language:)` Is Dead Code

| | |
|-|-|
| **File** | `Models/WeatherForecast.swift:62-69` |
| **Source** | Review A (B26) + Review B (R16) |
| **Status** | ✓ FIXED as part of F11 |
| **Description** | Switch returns same value for both languages. |
| **Fix** | Fixed in F11 — now correctly returns CN or EN based on language parameter. |

### F37 — ~~`MyListsView.deleteTrips` Missing `modelContext.save()`~~ ✓ FIXED

| | |
|-|-|
| **File** | `Views/Shared/MyListsView.swift:76-79` |
| **Source** | Review A (B16) |
| **Description** | Delete without save. (File is deprecated — part of F18.) |
| **Fix** | Remove file entirely (F18), or add `save()`. |
| **Status** | ✓ FIXED — File deleted as part of F18 fix. |

### F38 — `TripRowView.appeared` Ring Animation on Reuse

| | |
|-|-|
| **File** | `Components/Trip/TripRowView.swift:16,48` |
| **Source** | Review A (B11) |
| **Description** | Covered by F15 — same issue. |
| **Fix** | Same as F15. |

---

## Cross-Reference: Review A ↔ Review B ↔ Final

| Final ID | Review A | Review B | Consensus Severity |
|----------|----------|----------|--------------------|
| F1 | B1, B6 | R1 | Critical |
| F2 | — | R2 | Critical (new) |
| F3 | B3 | R11 | Critical (upgraded from R's Minor) |
| F4 | B2 | — | Critical |
| F5 | — | R3 | Critical (new) |
| F6 | B4 | — | High |
| F7 | B5, B21 | R8 | High (merged) |
| F8 | B7 | R5 | High (merged) |
| F9 | B8 | R7 | High |
| F10 | B9 | — | High |
| F11 | B15, B26, B31 | R6, R16 | High (merged cluster) |
| F12 | B17 | R4 | High |
| F13 | B10 | — | High |
| F14 | — | R9 | Medium (new) |
| F15 | B11 | — | Medium |
| F16 | B12 | — | Medium |
| F17 | B14 | — | Medium |
| F18 | B16 | R10 | Medium (merged) |
| F19 | B13 | — | Medium |
| F20 | B18 | — | Medium |
| F21 | B19 | — | Medium |
| F22 | B20 | — | Medium |
| F23 | — | R12 | Medium (new) |
| F24 | — | R13 | Medium (new) |
| F25 | B27 | — | Medium |
| F26 | B32 | — | Medium |
| F27 | B22 | — | Low |
| F28 | B23 | — | Low |
| F29 | B24 | R14 | Low |
| F30 | B25 | R12 | Low |
| F31 | B28 | — | Low |
| F32 | B29 | — | Low |
| F33 | B30 | — | Low |
| F34 | — | R15 | Low (new) |
| F35 | B31 | — | Low (part of F11) |
| F36 | B26 | R16 | Low (part of F11) |
| F37 | B16 | R10 | Low (part of F18) |
| F38 | B11 | — | Low (dup of F15) |

---

## Recommended Fix Priority

### Phase 1: Ship-Blockers (Critical) — 4/4 DONE
1. ~~**F1**~~ ✓ — Fix `weatherForecasts` getter mutation
2. ~~**F2**~~ ✓ — Add SwiftData `VersionedSchema` + migration plan
3. ~~**F3**~~ ✓ — Fix category sorting (use `sortOrder` instead of rawValue)
4. ~~**F4**~~ ✓ — Add dismiss guard to `CelebrationOverlay`

### Phase 2: Quality Gate (High) — 6/6 DONE
5. ~~**F7**~~ ✓ — Cancel weather Task on sheet dismiss
6. ~~**F8**~~ ✓ — Migrate `CustomItemManager` to `@Observable`
7. ~~**F11**~~ ✓ — Localize weather descriptions for English
8. ~~**F12**~~ ✓ — Add `@MainActor` to `PackingListViewModel`
9. ~~**F9**~~ ✓ — Replace `UIScreen.main.bounds` with `GeometryReader`
10. ~~**F13**~~ ✓ — Fix `hasCompletedOnboarding` setter

### Phase 3: Polish (Medium) — 2/4 DONE
9. ~~**F16**~~ ✓ — Fix addItem dedup for English mode
10. ~~**F17**~~ ✓ — Add `.id(trip.id)` to prevent stale ViewModel
11. ~~**F18**~~ ✓ — Remove deprecated files
12. **F25** — Consolidate navigation destinations

### Phase 4: Hardening (Low + Tests)
13. **F5** — Add unit test target (Trip counters, PackingList generation, ViewModel)
14. **F34** — Wrap prints in `#if DEBUG`
15. Remaining Low items

---

*Generated: 2026-03-01 | Updated: 2026-03-03 | 19 of 38 fixed (F1-F5, F7-F13, F16-F18, F24, F35-F37)*
*Two-pass review: General Bug Scanner + Superpowers Architecture Reviewer*
