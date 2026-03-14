# Plan: Apple MapKit City Search Autocomplete (Option B)

## Context

The weather card in SmartPack relies on Open-Meteo's geocoding API to convert city names to coordinates. This API has critical bugs:
- 2-char Chinese city names fail ("赣州") or return **wrong cities** ("北京" → village in Chongqing)
- Chinese names for foreign places don't exist in the database ("龙目岛", "巴厘岛")
- Ambiguous English names return wrong locations ("Lombok" → Netherlands, "Bali" → India)

**Solution:** Replace the plain text field with a search-as-you-type dropdown powered by Apple's `MKLocalSearchCompleter`. When the user selects a suggestion, we get coordinates directly and **bypass the broken Open-Meteo geocoding entirely**. The UI stays identical except for the new dropdown that appears while typing.

---

## Files Overview

| Action | File | What changes |
|--------|------|-------------|
| **CREATE** | `Services/LocationSearchService.swift` | MKLocalSearchCompleter wrapper (~70 lines) |
| **CREATE** | `Components/Trip/CitySearchField.swift` | TextField + dropdown view (~100 lines) |
| **MODIFY** | `Models/TripConfig.swift` | Add 2 optional Double properties |
| **MODIFY** | `Services/WeatherService.swift` | Add coordinate-based fetch overload, refactor existing method |
| **MODIFY** | `Components/Trip/CreateTripSheet.swift` | Swap TextField → CitySearchField, branch weather fetch |

**NOT modified:** Trip.swift (no schema migration), SectionCard.swift, any UI files.

---

## Step 1: Add coordinates to TripConfig

**File:** `SmartPack/Models/TripConfig.swift`

Add two optional properties after `destination` (line 121):

```swift
var destination: String = ""
var destinationLatitude: Double? = nil    // NEW
var destinationLongitude: Double? = nil   // NEW
```

These are transient (TripConfig is a plain struct used only during creation). No SwiftData migration needed.

---

## Step 2: Add coordinate-based fetch to WeatherService

**File:** `SmartPack/Services/WeatherService.swift`

**2a.** Add a new public method that takes lat/lon directly (after line 95):

```swift
func fetchWeatherForecast(
    latitude: Double,
    longitude: Double,
    startDate: Date,
    endDate: Date
) async throws -> [WeatherForecast]
```

This contains the URL-building and fetch logic currently in lines 42-94 of the existing method, but skips geocoding entirely.

**2b.** Refactor the existing `fetchWeatherForecast(city:...)` to call `geocodeCity()` then delegate to the new coordinate method. This removes code duplication — the URL construction and response parsing live in one place.

The existing `geocodeCity()` and `geocodeWithLanguage()` private methods remain untouched as fallback for manual text input.

---

## Step 3: Create LocationSearchService

**File:** `SmartPack/Services/LocationSearchService.swift` (NEW)

An `ObservableObject` wrapping `MKLocalSearchCompleter`:

- **Class:** `LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate`
- **Published state:** `suggestions: [CityCompletion]` (wrapped for stable identity)
- **`updateQuery(_ query: String)`** — 300ms debounce via cancellable `Task.sleep`, then sets `completer.queryFragment`
- **`resolveCoordinates(for:)`** — async method using `MKLocalSearch(request: MKLocalSearch.Request(completion:))` to get lat/lon
- **`clear()`** — cancels debounce, clears suggestions
- **Completer config:** `resultTypes = .address`, `pointOfInterestFilter = .excludingAll`
- **Delegate methods:** `completerDidUpdateResults` maps results to `[CityCompletion]` with `.prefix(5)`

**CityCompletion wrapper** (for stable ForEach identity):
```swift
struct CityCompletion: Identifiable {
    let id: String  // "\(title)|\(subtitle)"
    let completion: MKLocalSearchCompletion
}
```

---

## Step 4: Create CitySearchField

**File:** `SmartPack/Components/Trip/CitySearchField.swift` (NEW)

A SwiftUI view that replaces the bare `TextField` inside `destinationSection`'s SectionCard.

**Bindings:**
- `destination: Binding<String>`
- `latitude: Binding<Double?>`
- `longitude: Binding<Double?>`

**Structure:**
```
VStack(alignment: .leading, spacing: 0) {
    TextField(...)          ← identical appearance to current
    if showSuggestions {
        suggestion list     ← the only new UI element
    }
}
```

**TextField** — same placeholder text (bilingual via `@EnvironmentObject var localization`), same font. Wired with:
- `.onChange(of: destination)` → calls `searchService.updateQuery()`, sets `showSuggestions = true`, resets lat/lon to nil
- `.onSubmit` → dismisses suggestions

**Suggestion list** — vertical VStack of tappable rows inside the SectionCard (card expands naturally with `PremiumAnimation.snappy`):
- Each row: `completion.title` in `Typography.body` + `completion.subtitle` in `Typography.footnote` / `AppColors.textSecondary`
- Rows separated by `WarmDivider`
- Background: `AppColors.cardBackground`, corner radius: `CornerRadius.md`, subtle shadow
- `padding(.top, Spacing.xs)` gap between TextField and dropdown
- `.transition(.opacity.combined(with: .move(edge: .top)))` for smooth appear/disappear

**On suggestion tap:**
1. Set `destination = completion.title`
2. Set `showSuggestions = false`, `isFocused = false`
3. Call `searchService.clear()`
4. `HapticFeedback.light()`
5. Async: `resolveCoordinates(for:)` → write lat/lon bindings. On failure, coordinates stay nil (fallback to city-name geocoding)

**Keyboard dismissal:** `.onChange(of: isFocused)` — when focus is lost, delay 200ms then hide suggestions (delay lets tap gesture register first).

---

## Step 5: Wire into CreateTripSheet

**File:** `SmartPack/Components/Trip/CreateTripSheet.swift`

**5a.** Replace destinationSection (lines 82-92):

```swift
// BEFORE
SectionCard(...) {
    TextField(..., text: $tripConfig.destination)
}

// AFTER
SectionCard(...) {
    CitySearchField(
        destination: $tripConfig.destination,
        latitude: $tripConfig.destinationLatitude,
        longitude: $tripConfig.destinationLongitude
    )
}
.zIndex(1)  // dropdown floats above tag sections below
```

SectionCard title, icon, and wrapper stay identical. Only the content inside changes.

**5b.** In `createAndSaveTrip()`, add coordinate snapshots (after line 236):

```swift
let destinationLat = tripConfig.destinationLatitude
let destinationLon = tripConfig.destinationLongitude
```

**5c.** Branch the weather fetch (replace lines 257-262):

```swift
if let lat = destinationLat, let lon = destinationLon {
    // Coordinates from autocomplete — skip geocoding
    weatherForecasts = try await WeatherService.shared.fetchWeatherForecast(
        latitude: lat, longitude: lon,
        startDate: rangeStart, endDate: rangeEnd
    )
} else {
    // Manual text input — fallback to city-name geocoding
    weatherForecasts = try await WeatherService.shared.fetchWeatherForecast(
        city: destination,
        startDate: rangeStart, endDate: rangeEnd
    )
}
```

---

## Implementation Order

1. **TripConfig** — add 2 properties (zero risk, compiles immediately)
2. **WeatherService** — add coordinate overload + refactor (testable independently)
3. **LocationSearchService** — new file (testable with Xcode previews)
4. **CitySearchField** — new file (depends on step 3)
5. **CreateTripSheet** — wire together (depends on steps 1-4)

---

## Verification

1. **Build:** Project compiles with no errors or warnings
2. **Test "赣州":** Type "赣州" → dropdown shows "赣州市, 江西省, 中国" → tap → weather loads correctly
3. **Test "北京":** Type "北京" → dropdown shows Beijing capital (not village) → correct weather
4. **Test "龙目岛":** Type "龙目岛" → dropdown shows Lombok Island, Indonesia → correct weather
5. **Test "Bali":** Type "Bali" → dropdown shows Bali, Indonesia prominently → correct weather
6. **Test manual input:** Type a city name and press Return (don't tap suggestion) → old geocoding path still works
7. **Test empty input:** Leave destination blank → trip creates without weather (existing behavior)
8. **UI check:** SectionCard appearance identical when not typing. Dropdown appears/disappears with smooth animation
