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
            VStack(alignment: .leading, spacing: 12) {
                // 头部：目的地和日期范围
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(destination.isEmpty ? (localization.currentLanguage == .chinese ? "目的地" : "Destination") : destination)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let start = startDate, let end = endDate {
                            Text(formatDateRange(start: start, end: end))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // 多日天气展示（横向滚动）
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(forecasts.prefix(7)) { forecast in
                            WeatherDayCard(forecast: forecast)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
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
        VStack(spacing: 8) {
            // 日期
            Text(formatDay(forecast.date))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 天气图标
            Image(systemName: forecast.weatherIcon)
                .font(.title2)
                .foregroundColor(temperatureColor(for: forecast))
                .symbolRenderingMode(.hierarchical)
            
            // 温度范围
            VStack(spacing: 2) {
                Text("\(Int(forecast.highTemp))°")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(Int(forecast.lowTemp))°")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // 降水概率（如果有）
            if forecast.hasPrecipitation {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(Int(forecast.precipitationChance * 100))%")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(width: 70)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(10)
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
        let avgTemp = (forecast.highTemp + forecast.lowTemp) / 2
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
