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
    @State private var isGenerating = false
    @State private var weatherTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    dateRangeSection
                    destinationSection
                    tagSection
                    generateButton
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle(localization.currentLanguage == .chinese ? "新建行程" : "New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(Typography.body.weight(.medium))
                    }
                }
            }
            .onDisappear {
                weatherTask?.cancel()
            }
        }
    }

    // MARK: - SPEC: 出行时间（日期选择器）

    private var dateRangeSection: some View {
        SectionCard(
            title: localization.currentLanguage == .chinese ? "出行时间" : "Trip Dates",
            icon: "calendar"
        ) {
            VStack(spacing: Spacing.md) {
                DatePicker(selection: $startDate, displayedComponents: .date) {
                    Text(localization.currentLanguage == .chinese ? "出发日期" : "Start Date")
                        .font(Typography.body)
                }

                DatePicker(selection: $endDate, in: startDate..., displayedComponents: .date) {
                    Text(localization.currentLanguage == .chinese ? "返回日期" : "End Date")
                        .font(Typography.body)
                }
                .onChange(of: startDate) { oldStart, newStart in
                    let gap = Calendar.current.dateComponents([.day], from: oldStart, to: endDate).day ?? 3
                    if newStart >= endDate {
                        endDate = Calendar.current.date(
                            byAdding: .day, value: max(gap, 1), to: newStart
                        ) ?? newStart
                    }
                }

                let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                Text(localization.currentLanguage == .chinese ? "共 \(days + 1) 天" : "\(days + 1) days")
                    .font(Typography.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - SPEC: 目的地（城市选择器）

    private var destinationSection: some View {
        SectionCard(
            title: localization.currentLanguage == .chinese ? "目的地" : "Destination",
            icon: "mappin.circle"
        ) {
            CitySearchField(
                destination: $tripConfig.destination,
                latitude: $tripConfig.destinationLatitude,
                longitude: $tripConfig.destinationLongitude
            )
        }
        .zIndex(1)
    }

    // MARK: - SPEC: 标签选择（三组）

    private var tagSection: some View {
        VStack(spacing: Spacing.sm) {
            // 旅行活动
            SectionCard(
                title: localization.currentLanguage == .chinese ? "旅行活动" : "Travel Activities",
                icon: "figure.run"
            ) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: Spacing.sm)], spacing: Spacing.sm) {
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: Spacing.sm)], spacing: Spacing.sm) {
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: Spacing.sm)], spacing: Spacing.sm) {
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
        VStack(spacing: Spacing.sm) {
            if isGenerating {
                HStack(spacing: Spacing.xs) {
                    ProgressView()
                        .scaleEffect(0.9)
                    Text(localization.currentLanguage == .chinese ? "正在生成…" : "Creating list…")
                        .font(Typography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
            }
            
            Button {
                HapticFeedback.light()
                createAndSaveTrip()
            } label: {
                Text(localization.currentLanguage == .chinese ? "生成行程" : "Generate Trip")
                    .font(Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Spacing.buttonHeight)
                    .background(isGenerating ? AppColors.textSecondary : AppColors.primary)
                    .cornerRadius(CornerRadius.lg)
                    .shadow(color: AppColors.primary.opacity(0.25), radius: 6, x: 0, y: 3)
            }
            .disabled(isGenerating)
        }
        .padding(.top, Spacing.xs)
        .accessibilityLabel(localization.currentLanguage == .chinese ? "生成行程" : "Generate Trip")
        .accessibilityHint(isGenerating ? (localization.currentLanguage == .chinese ? "正在创建行程" : "Creating your trip") : "")
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

        // F7 fix: 在 async 边界前快照所有值，避免跨 async 的可变捕获
        let snapshotItems = PresetData.shared.generatePackingList(
            tagIds: tripConfig.allSelectedTags,
            gender: tripConfig.gender
        )
        let name = tripConfig.generateListName(language: localization.currentLanguage)
        let gender = tripConfig.gender
        let selectedTags = Array(tripConfig.allSelectedTags)
        let destination = tripConfig.destination
        let destinationLat = tripConfig.destinationLatitude
        let destinationLon = tripConfig.destinationLongitude
        let dateRangeStart = tripConfig.dateRange?.startDate
        let dateRangeEnd = tripConfig.dateRange?.endDate

        // 计算 duration（兼容旧模型，根据天数映射）
        let duration: TripDuration
        if let dateRange = tripConfig.dateRange {
            duration = dateRange.toTripDuration()
        } else {
            duration = .medium
        }

        // F7 fix: 存储 Task 句柄，以便 onDisappear 时取消
        weatherTask = Task {
            await MainActor.run { isGenerating = true }
            var items = snapshotItems
            var weatherForecasts: [WeatherForecast] = []

            print("🚀 开始创建行程: 目的地=\(destination), 开始日期=\(startDate), 结束日期=\(endDate)")

            // 如果有目的地和日期范围，查询天气
            if !destination.isEmpty, let rangeStart = dateRangeStart, let rangeEnd = dateRangeEnd {
                print("🚀 准备查询天气...")
                do {
                    if let lat = destinationLat, let lon = destinationLon {
                        weatherForecasts = try await WeatherService.shared.fetchWeatherForecast(
                            latitude: lat, longitude: lon,
                            startDate: rangeStart, endDate: rangeEnd
                        )
                    } else {
                        weatherForecasts = try await WeatherService.shared.fetchWeatherForecast(
                            city: destination,
                            startDate: rangeStart, endDate: rangeEnd
                        )
                    }
                    // F7 fix: 天气返回后检查是否已被取消
                    guard !Task.isCancelled else { return }

                    print("🚀 天气查询成功，获得 \(weatherForecasts.count) 天预报")

                    // 根据天气调整物品
                    items = WeatherService.shared.adjustItemsForWeather(
                        items: items,
                        forecasts: weatherForecasts
                    )
                } catch {
                    guard !Task.isCancelled else { return }
                    // 天气查询失败不影响创建行程，使用空数组
                    print("Weather fetch failed: \(error.localizedDescription)")
                }
            }

            // F7 fix: 插入前最终检查取消状态，防止幽灵行程
            guard !Task.isCancelled else { return }

            // 在主线程创建 Trip
            await MainActor.run {
                let trip = Trip(
                    name: name,
                    gender: gender,
                    duration: duration,
                    selectedTags: selectedTags,
                    items: items,
                    destination: destination,
                    startDate: dateRangeStart,
                    endDate: dateRangeEnd,
                    weatherForecasts: weatherForecasts
                )

                modelContext.insert(trip)
                isGenerating = false
                HapticFeedback.success()
                onTripCreated(trip)
            }
        }
    }
}
