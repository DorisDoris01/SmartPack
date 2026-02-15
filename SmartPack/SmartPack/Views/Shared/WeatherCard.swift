//
//  WeatherCard.swift
//  SmartPack
//
//  天气卡片组件 - 简约美观的天气展示
//  SPEC: Weather Integration v1.0
//

import SwiftUI

struct WeatherCard: View {
    let forecasts: [WeatherForecast]
    let destination: String
    let startDate: Date?
    let endDate: Date?
    
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        if !forecasts.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // 头部：目的地和日期范围
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .foregroundColor(AppColors.primary)
                        .font(Typography.title3)
                    
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(destination.isEmpty ? (localization.currentLanguage == .chinese ? "目的地" : "Destination") : destination)
                            .font(Typography.headline)
                            .foregroundColor(AppColors.text)
                        
                        if let start = startDate, let end = endDate {
                            Text(formatDateRange(start: start, end: end))
                                .font(Typography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // 多日天气展示（横向滚动）
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(forecasts) { forecast in
                            WeatherDayCard(forecast: forecast)
                        }
                    }
                    .padding(.horizontal, Spacing.xxs)
                }
            }
            .padding(Spacing.md)
            .background(AppColors.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(AppColors.primary.opacity(0.15), lineWidth: 1)
            )
            .cornerRadius(CornerRadius.lg)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .chinese ? "M月d日" : "MMM d"
        
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        
        return "\(startStr) - \(endStr)"
    }
}

// MARK: - 单日天气卡片

struct WeatherDayCard: View {
    let forecast: WeatherForecast
    
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            // 日期
            Text(formatDay(forecast.date))
                .font(Typography.caption2)
                .foregroundColor(AppColors.textSecondary)

            // 天气图标
            Image(systemName: forecast.weatherIcon)
                .font(Typography.title2)
                .foregroundColor(forecast.isAvailable ? temperatureColor(for: forecast) : AppColors.textSecondary)
                .symbolRenderingMode(.hierarchical)

            // 温度范围或不可用标识
            if forecast.isAvailable, let highTemp = forecast.highTemp, let lowTemp = forecast.lowTemp {
                VStack(spacing: Spacing.xxs) {
                    Text("\(Int(highTemp))°")
                        .font(Typography.subheadline.weight(.semibold))
                        .foregroundColor(AppColors.text)

                    Text("\(Int(lowTemp))°")
                        .font(Typography.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
            } else {
                Text("N/A")
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            // 降水概率（如果有）
            if forecast.hasPrecipitation, let precipChance = forecast.precipitationChance {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "drop.fill")
                        .font(Typography.caption2)
                        .foregroundColor(AppColors.primary)
                    Text("\(Int(precipChance * 100))%")
                        .font(Typography.caption2)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .frame(width: 70)
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.xs)
        .background(AppColors.cardBackground.opacity(forecast.isAvailable ? 0.6 : 0.3))
        .cornerRadius(CornerRadius.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: forecast))
    }
    
    private func accessibilityLabel(for forecast: WeatherForecast) -> String {
        let day = formatDay(forecast.date)

        if !forecast.isAvailable {
            return "\(day), weather data not available"
        }

        guard let high = forecast.highTemp, let low = forecast.lowTemp else {
            return "\(day), weather data not available"
        }

        let highInt = Int(high)
        let lowInt = Int(low)

        if forecast.hasPrecipitation, let precipChance = forecast.precipitationChance {
            let pct = Int(precipChance * 100)
            return "\(day), high \(highInt)°, low \(lowInt)°, \(pct)% chance of rain"
        }
        return "\(day), high \(highInt)°, low \(lowInt)°"
    }
    
    private func formatDay(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            return localization.currentLanguage == .chinese ? "今天" : "Today"
        } else if calendar.isDateInTomorrow(date) {
            return localization.currentLanguage == .chinese ? "明天" : "Tomorrow"
        } else {
            formatter.dateFormat = localization.currentLanguage == .chinese ? "M/d" : "M/d"
            return formatter.string(from: date)
        }
    }
    
    /// 根据温度计算颜色
    private func temperatureColor(for forecast: WeatherForecast) -> Color {
        guard let highTemp = forecast.highTemp, let lowTemp = forecast.lowTemp else {
            return AppColors.textSecondary
        }

        let avgTemp = (highTemp + lowTemp) / 2
        if avgTemp < 5 {
            return .blue
        } else if avgTemp < 15 {
            return .cyan
        } else if avgTemp < 25 {
            return .green
        } else if avgTemp < 30 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    let forecasts = [
        WeatherForecast(
            date: Date(),
            highTemp: 22,
            lowTemp: 12,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: 0.1,
            icon: "01d"
        ),
        WeatherForecast(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            highTemp: 18,
            lowTemp: 8,
            condition: "rain",
            conditionDescription: "小雨",
            precipitationChance: 0.7,
            icon: "10d"
        ),
        WeatherForecast(
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            highTemp: 20,
            lowTemp: 10,
            condition: "cloudy",
            conditionDescription: "多云",
            precipitationChance: 0.2,
            icon: "03d"
        )
    ]
    
    return WeatherCard(
        forecasts: forecasts,
        destination: "北京",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
    )
    .environmentObject(LocalizationManager.shared)
    .padding()
}
