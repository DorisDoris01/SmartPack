//
//  CombinedInfoCard.swift
//  SmartPack
//
//  Combined weather + settings card — Option C
//  Settings on top, weather on bottom, thin divider between
//

import SwiftUI

struct CombinedInfoCard: View {
    let trip: Trip
    let showWeather: Bool
    let showSettings: Bool
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            // Settings section (top)
            if showSettings {
                settingsSection
            }

            // Divider
            if showSettings && showWeather {
                Divider()
                    .padding(.horizontal, 14)
            }

            // Weather section (bottom)
            if showWeather {
                weatherSection
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Date range
            if let startDate = trip.startDate, let endDate = trip.endDate {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(Typography.footnote)
                        .foregroundStyle(.secondary)
                    Text(formatDateRange(start: startDate, end: endDate))
                        .font(Typography.footnote)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Tag chips
            if !trip.selectedTags.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(allSelectedTags) { tag in
                        TagChip(tag: tag)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Weather Section

    private var weatherSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(trip.weatherForecasts) { forecast in
                    CompactWeatherDay(forecast: forecast)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    // MARK: - Helpers

    private var allSelectedTags: [Tag] {
        trip.selectedTags.compactMap { tagId in
            PresetData.shared.allTags[tagId]
        }
    }

    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .chinese ? "yyyy/MM/dd" : "MMM d, yyyy"

        let startStr = formatter.string(from: start)

        if Calendar.current.isDate(start, inSameDayAs: end) {
            return startStr
        }

        let calendar = Calendar.current
        if calendar.component(.year, from: start) == calendar.component(.year, from: end) {
            formatter.dateFormat = localization.currentLanguage == .chinese ? "MM/dd" : "MMM d"
        }

        let endStr = formatter.string(from: end)
        return "\(startStr) - \(endStr)"
    }
}

// MARK: - Compact Weather Day Column

private struct CompactWeatherDay: View {
    let forecast: WeatherForecast

    var body: some View {
        VStack(spacing: 6) {
            // Date — M/d format, no "Today" highlight
            Text(formatDate(forecast.date))
                .font(Typography.caption2)
                .foregroundStyle(.secondary)

            // SF Symbol weather icon
            Image(systemName: forecast.weatherIcon)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundStyle(forecast.isAvailable ? temperatureColor : .secondary.opacity(0.6))
                .symbolRenderingMode(.hierarchical)
                .frame(height: 24)

            // High + Low temps (no precipitation)
            if forecast.isAvailable, let highTemp = forecast.highTemp, let lowTemp = forecast.lowTemp {
                VStack(spacing: 2) {
                    Text("\(Int(highTemp))°")
                        .font(Typography.headline)
                        .foregroundStyle(temperatureColor)

                    Text("\(Int(lowTemp))°")
                        .font(Typography.caption)
                        .foregroundStyle(.tertiary)
                }
            } else {
                Text("--")
                    .font(Typography.subheadline)
                    .foregroundStyle(.quaternary)
            }
        }
        .frame(width: 56)
    }

    // Always M/d format — no "Today" or weekday names
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    private var temperatureColor: Color {
        AppColors.primary
    }
}
