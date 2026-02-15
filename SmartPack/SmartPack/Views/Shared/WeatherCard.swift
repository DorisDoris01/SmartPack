//
//  WeatherCard.swift
//  SmartPack
//
//  天气卡片组件 - 精致简约的天气展示
//  SPEC: Weather Integration v1.0 + Frontend Design Refresh
//

import SwiftUI

struct WeatherCard: View {
    let forecasts: [WeatherForecast]
    let destination: String
    let startDate: Date?
    let endDate: Date?
    @Binding var isCollapsed: Bool  // PRD: 收起/展开状态

    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        if !forecasts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // PRD: Packing List UI Enhancement - 头部带收起/展开按钮，移除日期范围
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text(destination.isEmpty ? (localization.currentLanguage == .chinese ? "目的地" : "Destination") : destination)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    // 收起/展开按钮
                    Button {
                        #if DEBUG
                        print("🌤️ Weather button tapped, current state: \(isCollapsed)")
                        #endif
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isCollapsed.toggle()
                        }
                        #if DEBUG
                        print("🌤️ Weather after toggle: \(isCollapsed)")
                        #endif
                    } label: {
                        Image(systemName: isCollapsed ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                // PRD: 天气详情根据 isCollapsed 状态显示/隐藏
                if !isCollapsed {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(forecasts) { forecast in
                                WeatherDayCard(forecast: forecast)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                    }
                } else {
                    // 收起状态下添加底部内边距
                    Spacer()
                        .frame(height: 4)
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
    }

    // PRD: formatDateRange 方法已移除，不再显示日期范围
}

// MARK: - 单日天气卡片（精致版）

struct WeatherDayCard: View {
    let forecast: WeatherForecast

    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 6) {
            // 日期 - 更精致的排版
            Text(formatDay(forecast.date))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.3)

            // 天气图标 - 更小巧精致
            Image(systemName: forecast.weatherIcon)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(forecast.isAvailable ? temperatureColor(for: forecast) : Color.secondary.opacity(0.6))
                .symbolRenderingMode(.hierarchical)
                .frame(height: 26)

            // 温度范围 - 主要信息
            if forecast.isAvailable, let highTemp = forecast.highTemp, let lowTemp = forecast.lowTemp {
                VStack(spacing: 2) {
                    // 高温 - 更突出
                    Text("\(Int(highTemp))°")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [temperatureColor(for: forecast), temperatureColor(for: forecast).opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // 低温 - 更低调
                    Text("\(Int(lowTemp))°")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            } else {
                Text("--")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.quaternary)
            }

            // 降水概率 - 极简处理
            if forecast.hasPrecipitation, let precipChance = forecast.precipitationChance {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 8, weight: .semibold))
                    Text("\(Int(precipChance * 100))")
                        .font(.system(size: 9, weight: .medium))
                }
                .foregroundStyle(Color.blue.opacity(0.7))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.08))
                )
            }
        }
        .frame(width: 52)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .opacity(forecast.isAvailable ? 1.0 : 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(forecast.isAvailable ? 0.06 : 0.03), lineWidth: 0.5)
        )
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
    
    /// 根据温度计算颜色 - 更精致的色彩
    private func temperatureColor(for forecast: WeatherForecast) -> Color {
        guard let highTemp = forecast.highTemp, let lowTemp = forecast.lowTemp else {
            return .secondary
        }

        let avgTemp = (highTemp + lowTemp) / 2
        switch avgTemp {
        case ..<5:
            return Color(red: 0.2, green: 0.6, blue: 0.95) // 冰蓝
        case 5..<15:
            return Color(red: 0.3, green: 0.7, blue: 0.85) // 青色
        case 15..<25:
            return Color(red: 0.3, green: 0.75, blue: 0.4) // 翠绿
        case 25..<30:
            return Color(red: 0.95, green: 0.6, blue: 0.2) // 暖橙
        default:
            return Color(red: 0.95, green: 0.3, blue: 0.3) // 热红
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
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
        isCollapsed: .constant(false)  // PRD: 添加 isCollapsed 参数
    )
    .environmentObject(LocalizationManager.shared)
    .padding()
}
