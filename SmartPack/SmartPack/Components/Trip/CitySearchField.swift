//
//  CitySearchField.swift
//  SmartPack
//
//  城市搜索输入框 + 下拉建议列表
//

import SwiftUI
import MapKit

/// 城市搜索输入框（替换原有 TextField，增加搜索建议下拉）
struct CitySearchField: View {
    @Binding var destination: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?

    @EnvironmentObject var localization: LocalizationManager
    @StateObject private var searchService = LocationSearchService()
    @FocusState private var isFocused: Bool
    @State private var showSuggestions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(
                localization.string(for: .enterCityName),
                text: $destination
            )
            .focused($isFocused)
            .onChange(of: destination) { _, newValue in
                searchService.updateQuery(newValue)
                showSuggestions = true
                latitude = nil
                longitude = nil
            }
            .onSubmit {
                showSuggestions = false
                clearIfNoSelection()
            }

            if showSuggestions && !searchService.suggestions.isEmpty {
                suggestionList
            }
        }
        .onChange(of: isFocused) { _, focused in
            if !focused {
                // Delay to let tap gesture register before hiding
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(200))
                    showSuggestions = false
                    clearIfNoSelection()
                }
            }
        }
    }

    private var suggestionList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(searchService.suggestions.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    WarmDivider()
                }

                Button {
                    selectSuggestion(item)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.completion.title)
                            .font(Typography.body)
                            .foregroundColor(AppColors.text)
                        if !item.completion.subtitle.isEmpty {
                            Text(item.completion.subtitle)
                                .font(Typography.footnote)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, Spacing.xs)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, Spacing.xs)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(PremiumAnimation.snappy, value: searchService.suggestions.map(\.id))
    }

    /// If user typed text without selecting a suggestion, clear it back to empty
    private func clearIfNoSelection() {
        if !destination.isEmpty && latitude == nil {
            destination = ""
        }
    }

    private func selectSuggestion(_ item: CityCompletion) {
        destination = item.completion.title
        showSuggestions = false
        isFocused = false
        searchService.clear()
        HapticFeedback.light()

        Task {
            if let coords = await searchService.resolveCoordinates(for: item.completion) {
                await MainActor.run {
                    latitude = coords.latitude
                    longitude = coords.longitude
                }
            }
        }
    }
}
