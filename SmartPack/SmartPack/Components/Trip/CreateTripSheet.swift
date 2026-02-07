//
//  CreateTripSheet.swift
//  SmartPack
//
//  行程组件 - 创建行程 Sheet
//

import SwiftUI
import SwiftData

/// 创建行程 Sheet
struct CreateTripSheet: View {
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager

    var onTripCreated: (Trip) -> Void

    @State private var tripConfig = TripConfig()

    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    dateRangeSection
                    destinationSection
                    tagSection
                    generateButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(localization.currentLanguage == .chinese ? "新建行程" : "New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                    }
                }
            }
        }
    }

    // MARK: - SPEC: 出行时间（日期选择器）

    private var dateRangeSection: some View {
        SectionCard(
            title: localization.currentLanguage == .chinese ? "出行时间" : "Trip Dates",
            icon: "calendar"
        ) {
            VStack(spacing: 16) {
                DatePicker(
                    localization.currentLanguage == .chinese ? "出发日期" : "Start Date",
                    selection: $startDate,
                    displayedComponents: .date
                )

                DatePicker(
                    localization.currentLanguage == .chinese ? "返回日期" : "End Date",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: .date
                )

                if endDate >= startDate {
                    let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                    Text(localization.currentLanguage == .chinese ? "共 \(days + 1) 天" : "\(days + 1) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - SPEC: 目的地（城市选择器）

    private var destinationSection: some View {
        SectionCard(
            title: localization.currentLanguage == .chinese ? "目的地" : "Destination",
            icon: "mappin.circle"
        ) {
            TextField(
                localization.currentLanguage == .chinese ? "输入城市名称" : "Enter city name",
                text: $tripConfig.destination
            )
        }
    }

    // MARK: - SPEC: 标签选择（三组）

    private var tagSection: some View {
        VStack(spacing: 16) {
            // 旅行活动
            SectionCard(
                title: localization.currentLanguage == .chinese ? "旅行活动" : "Travel Activities",
                icon: "figure.run"
            ) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach(PresetData.shared.tags(for: .activity)) { tag in
                        LabeledTagButton(
                            tag: tag,
                            isSelected: tripConfig.selectedActivityTags.contains(tag.id),
                            language: localization.currentLanguage
                        ) {
                            toggleActivityTag(tag.id)
                        }
                    }
                }
            }

            // 特定场合
            SectionCard(
                title: localization.currentLanguage == .chinese ? "特定场合" : "Occasions",
                icon: "building.2"
            ) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach(PresetData.shared.tags(for: .occasion)) { tag in
                        LabeledTagButton(
                            tag: tag,
                            isSelected: tripConfig.selectedOccasionTags.contains(tag.id),
                            language: localization.currentLanguage
                        ) {
                            toggleOccasionTag(tag.id)
                        }
                    }
                }
            }

            // 出行配置
            SectionCard(
                title: localization.currentLanguage == .chinese ? "出行配置" : "Travel Config",
                icon: "gearshape"
            ) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach(PresetData.shared.tags(for: .config)) { tag in
                        LabeledTagButton(
                            tag: tag,
                            isSelected: tripConfig.selectedConfigTags.contains(tag.id),
                            language: localization.currentLanguage
                        ) {
                            toggleConfigTag(tag.id)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 生成按钮

    private var generateButton: some View {
        Button {
            createAndSaveTrip()
        } label: {
            Text(localization.currentLanguage == .chinese ? "生成行程" : "Generate Trip")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }

    // MARK: - 方法

    private func toggleActivityTag(_ tagId: String) {
        if tripConfig.selectedActivityTags.contains(tagId) {
            tripConfig.selectedActivityTags.remove(tagId)
        } else {
            tripConfig.selectedActivityTags.insert(tagId)
        }
    }

    private func toggleOccasionTag(_ tagId: String) {
        if tripConfig.selectedOccasionTags.contains(tagId) {
            tripConfig.selectedOccasionTags.remove(tagId)
        } else {
            tripConfig.selectedOccasionTags.insert(tagId)
        }
    }

    private func toggleConfigTag(_ tagId: String) {
        if tripConfig.selectedConfigTags.contains(tagId) {
            tripConfig.selectedConfigTags.remove(tagId)
        } else {
            tripConfig.selectedConfigTags.insert(tagId)
        }
    }

    private func createAndSaveTrip() {
        tripConfig.gender = localization.userGender

        // SPEC: 设置日期范围
        tripConfig.dateRange = TripDateRange(startDate: startDate, endDate: endDate)

        var items = PresetData.shared.generatePackingList(
            tagIds: tripConfig.allSelectedTags,
            gender: tripConfig.gender
        )

        let name = tripConfig.generateListName(language: localization.currentLanguage)

        // 计算 duration（兼容旧模型，根据天数映射）
        let duration: TripDuration
        if let dateRange = tripConfig.dateRange {
            duration = dateRange.toTripDuration()
        } else {
            duration = .medium // 默认值
        }

        // SPEC: Weather Integration v1.0 - 查询天气并调整物品
        Task {
            var weatherForecasts: [WeatherForecast] = []

            // 如果有目的地和日期范围，查询天气
            if !tripConfig.destination.isEmpty,
               let dateRange = tripConfig.dateRange {
                do {
                    weatherForecasts = try await WeatherService.shared.fetchWeatherForecast(
                        city: tripConfig.destination,
                        startDate: dateRange.startDate,
                        endDate: dateRange.endDate
                    )

                    // 根据天气调整物品
                    items = WeatherService.shared.adjustItemsForWeather(
                        items: items,
                        forecasts: weatherForecasts
                    )
                } catch {
                    // 天气查询失败不影响创建行程，使用空数组
                    print("Weather fetch failed: \(error.localizedDescription)")
                }
            }

            // 在主线程创建 Trip
            await MainActor.run {
                let trip = Trip(
                    name: name,
                    gender: tripConfig.gender,
                    duration: duration,
                    selectedTags: Array(tripConfig.allSelectedTags),
                    items: items,
                    destination: tripConfig.destination,
                    startDate: tripConfig.dateRange?.startDate,
                    endDate: tripConfig.dateRange?.endDate,
                    weatherForecasts: weatherForecasts
                )

                modelContext.insert(trip)
                onTripCreated(trip)
            }
        }
    }
}
