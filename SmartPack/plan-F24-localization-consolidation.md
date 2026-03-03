# F24 — Localization Consolidation Plan

> **Status:** Pending decision — pick an approach before implementing.

---

## Current State

- **70 inline ternaries** across 10 files: `localization.currentLanguage == .chinese ? "中文" : "English"`
- **~20 strings** use the `LocalizedKey` enum with centralized dictionary lookup
- A **`text(chinese:, english:)` helper** already exists on `LocalizationManager` but is barely used

### Files with inline ternaries (70 total occurrences)

| File | Count |
|------|-------|
| `ItemManagementView.swift` | 16 |
| `CreateTripSheet.swift` | 13 |
| `PackingListView.swift` | 12 |
| `HomeView.swift` | 12 |
| `SettingsView.swift` | 7 |
| `ItemRow.swift` | 4 |
| `AddItemRow.swift` | 3 |
| `WelcomeView.swift` | 1 |
| `CitySearchField.swift` | 1 |
| `SearchBar.swift` | 1 |

---

## Option A: `text()` helper (Recommended)

Convert all 70 inline ternaries to `localization.text(chinese:, english:)`.

```swift
// BEFORE (70 occurrences):
localization.currentLanguage == .chinese ? "删除" : "Delete"

// AFTER:
localization.text(chinese: "删除", english: "Delete")

// text() already exists on LocalizationManager:
func text(chinese: String, english: String) -> String {
    currentLanguage == .chinese ? chinese : english
}

// Adding 3rd language later:
func text(chinese: String, english: String, japanese: String? = nil) -> String { ... }
```

| | |
|-|-|
| **Pros** | Mechanical & safe, helper already exists, minimal risk, easy third-language extension |
| **Cons** | Translations stay scattered across files (not centralized) |
| **Effort** | Small-Medium (~1 hour) |

---

## Option B: Expand `LocalizedKey` enum

Add ~50+ new cases to `LocalizedKey`, centralize ALL strings in the dictionary.

```swift
// Add 50+ new enum cases:
enum LocalizedKey: String {
    case delete = "delete"
    case archive = "archive"
    case unarchive = "unarchive"
    case myTrips = "my_trips"
    case noTripsYet = "no_trips_yet"
    // ... 50+ more cases
}

// Update strings dictionary with all translations
// Change all call sites:
localization.string(for: .delete)
```

| | |
|-|-|
| **Pros** | Centralized translations, compiler-checked keys, easy to audit for missing strings |
| **Cons** | 50+ new enum cases, verbose, higher risk of typos in string dictionary |
| **Effort** | Medium (~2-3 hours) |

---

## Option C: Apple `.strings`/`.xcstrings`

Migrate to Apple's standard localization system with `String(localized:)`.

```swift
// Replace entire custom system with:
Text(String(localized: "delete_trip"))

// Localizable.xcstrings (Xcode-managed):
// {
//   "delete_trip": {
//     "localizations": {
//       "en": { "stringUnit": { "value": "Delete" }},
//       "zh-Hans": { "stringUnit": { "value": "删除" }}
//     }
//   }
// }
```

| | |
|-|-|
| **Pros** | Industry standard, Xcode tooling support, scales to any number of languages |
| **Cons** | Rip-and-replace entire custom system, highest risk, most disruptive |
| **Effort** | Large (~4-5 hours) |

---

## Recommendation

**Option A** — lowest risk, highest value-per-effort. It eliminates the inconsistency (one pattern everywhere), and the `text()` method is already written. Adding a third language later just means extending that one method.
