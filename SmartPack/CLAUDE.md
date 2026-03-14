# CLAUDE.md — SmartPack

## Project Overview

SmartPack is an iOS packing list app (SwiftUI + SwiftData, iOS 17+).
Users create trips, get weather forecast of the destinations, and check off items.
Bilingual: Chinese (primary) + English. All user-facing strings must have both languages.

## Build & Test

```bash
# Build
xcodebuild -scheme SmartPack -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests (6 test files, hosted in SmartPack.app)
xcodebuild -scheme SmartPack -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Targets: `SmartPack` (app), `SmartPackTests` (unit tests).

## Architecture

**MVVM** with SwiftData persistence.

```
SmartPack/
├── Models/          Trip.swift (SwiftData @Model), TripItem.swift, TripConfig.swift,
│                    WeatherForecast.swift, SchemaVersions.swift
├── ViewModels/      PackingListViewModel.swift (@Observable, @MainActor)
├── Views/           Main/ (HomeView), Trip/ (PackingListView), Settings/, Shared/
├── Components/      PackingList/ (ItemRow, AddItemRow, CategorySection, CelebrationOverlay)
│                    Trip/ (CreateTripSheet, CitySearchField, TripRowView)
│                    Shared/ (SectionCard, WarmDivider, FlowLayout)
├── Services/        WeatherService.swift, LocationSearchService.swift (MKLocalSearchCompleter)
├── Data/            PresetData.swift (packing item presets), CustomItemManager.swift (@Observable)
├── DesignSystem/    AppColors, Typography, Spacing, CornerRadius, ViewModifiers
├── Localization/    LocalizationManager.swift (ObservableObject, @EnvironmentObject)
└── Configuration/   AppConfig.swift, HapticFeedback.swift
```

**Data flow:** `HomeView` → NavigationStack → `PackingListView` + `PackingListViewModel` → `Trip` (@Model).
Trip creation: `CreateTripSheet` → `TripConfig` (struct) → persisted `Trip` + `[TripItem]`.

## Key Conventions

### Bilingual strings
Every user-facing string needs Chinese and English. Two patterns exist:
- **Inline ternary:** `localization.currentLanguage == .chinese ? "中文" : "English"`
- **Helper:** `localization.text(chinese: "中文", english: "English")`

`LocalizationManager.shared` is injected via `@EnvironmentObject`. Access language with `localization.currentLanguage`.

### Design system — always use tokens, never hardcode
- **Colors:** `AppColors.primary`, `.background`, `.cardBackground`, `.text`, `.textSecondary` — never `Color.blue` or `Color(.systemGray5)`
- **Typography:** `Typography.headline`, `.body`, `.caption`, `.footnote` — SF Rounded throughout
- **Spacing:** `Spacing.xs` (8), `.sm` (12), `.md` (20), `.lg` (28) — never magic numbers
- **Corners:** `CornerRadius.sm` (6), `.md` (12), `.lg` (16)
- Files are in `SmartPack/DesignSystem/`

### SwiftUI constraints (hard-won bugs)
1. **List + FocusState tap interception:** When a TextField has focus inside a List, the List intercepts the first tap to dismiss the keyboard. Always apply `.buttonStyle(.borderless)` to any Button inside a List that coexists with a focused TextField.
2. **Action callbacks must communicate results:** If an action involves validation (dedup, network, DB writes), never use `() -> Void`. Use `() -> Bool` or a Result type so the UI can show errors, revert state, etc.
3. **Touch targets:** Enforce `.frame(minHeight: 44)` on all interactive rows per Apple HIG.

### SwiftData
- Models: `Trip` and `TripItem` (cascade delete relationship).
- `Trip` has pre-computed `checkedItemCount`/`totalItemCount` — always mutate via `Trip.toggleItem()`, `.addItem()`, `.removeItem()`, never set `isChecked` directly.
- Schema versioning: `SchemaVersions.swift` has V1. When adding fields, create V2 + migration plan.
- `@Transient` properties (weather cache) can reset on fault/unfault — never mutate inside computed getters.

### Observation
- ViewModels use `@Observable` (Observation framework), **not** `ObservableObject`.
- `LocalizationManager` still uses `ObservableObject`/`@EnvironmentObject` — do not mix patterns in new code.
- ViewModels that touch SwiftData models must be `@MainActor`.

### Haptics
Use `HapticFeedback.light()` on taps, `.warning()` on delete, `.error()` on validation failures. Don't skip haptics in new interactive elements.

## Tests

Test files in `SmartPackTests/`:
- `TripTests.swift` — Trip counter integrity
- `TripDateRangeTests.swift` — Date range logic
- `WeatherForecastTests.swift` — Forecast model
- `PresetDataTests.swift` — Packing list generation
- `CustomItemManagerTests.swift` — Custom item CRUD
- `TestModelContainer.swift` — In-memory SwiftData helper

When fixing bugs, write a failing test first when feasible.

## Known Issues

See `pending-issues-guide.md` for 49 tracked issues with severity and fix plans.
