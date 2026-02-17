//
//  TripConfigView.swift
//  SmartPack
//
//  行程配置界面 - 新建行程（独立页面版本）
//  PRD v1.3: 标签显示 icon + 文案
//

import SwiftUI
import SwiftData

struct TripConfigView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var tripConfig = TripConfig()
    @State private var showingPackingList = false
    @State private var createdTrip: Trip?
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Section 1: 出行时间（日期选择器）
                    dateRangeSection

                    // Section 2: 场景选择
                    sceneSection

                    // Section 3: 运动选择
                    sportsSection

                    // 生成清单按钮
                    generateButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(localization.text(chinese: "新建行程", english: "New Trip"))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showingPackingList) {
                if let trip = createdTrip {
                    PackingListView(trip: trip, isNewlyCreated: true)
                }
            }
        }
    }
    
    // MARK: - Section 1: 出行时间（日期选择器）
    
    private var dateRangeSection: some View {
        SectionCard(
            title: localization.text(chinese: "出行时间", english: "Trip Dates"),
            icon: "calendar"
        ) {
            VStack(spacing: Spacing.md) {
                DatePicker(
                    localization.text(chinese: "出发日期", english: "Start Date"),
                    selection: $startDate,
                    displayedComponents: .date
                )
                
                DatePicker(
                    localization.text(chinese: "返回日期", english: "End Date"),
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: .date
                )
                
                if endDate >= startDate {
                    let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                    Text(localization.text(chinese: "共 \(days + 1) 天", english: "\(days + 1) days"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Section 2: 场景选择（已废弃，使用新的标签组）
    
    private var sceneSection: some View {
        SectionCard(
            title: localization.text(chinese: "特定场合", english: "Occasions"),
            icon: "building.2"
        ) {
            HStack(spacing: Spacing.sm) {
                ForEach(PresetData.shared.tags(for: .occasion)) { tag in
                    TagButton(
                        tag: tag,
                        isSelected: tripConfig.selectedOccasionTags.contains(tag.id),
                        language: localization.currentLanguage
                    ) {
                        toggleOccasionTag(tag.id)
                    }
                }
            }
        }
    }
    
    // MARK: - Section 3: 运动选择（已废弃，使用新的标签组）
    
    private var sportsSection: some View {
        SectionCard(
            title: localization.text(chinese: "旅行活动", english: "Travel Activities"),
            icon: "figure.run"
        ) {
            HStack(spacing: Spacing.sm) {
                ForEach(PresetData.shared.tags(for: .activity)) { tag in
                    TagButton(
                        tag: tag,
                        isSelected: tripConfig.selectedActivityTags.contains(tag.id),
                        language: localization.currentLanguage
                    ) {
                        toggleActivityTag(tag.id)
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
            Text(localization.text(chinese: "生成行程", english: "Generate Trip"))
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Spacing.buttonHeight)
                .background(Color.blue)
                .cornerRadius(CornerRadius.lg)
        }
        .padding(.top, Spacing.xs)
    }
    
    // MARK: - 方法
    
    private func toggleOccasionTag(_ tagId: String) {
        if tripConfig.selectedOccasionTags.contains(tagId) {
            tripConfig.selectedOccasionTags.remove(tagId)
        } else {
            tripConfig.selectedOccasionTags.insert(tagId)
        }
    }
    
    private func toggleActivityTag(_ tagId: String) {
        if tripConfig.selectedActivityTags.contains(tagId) {
            tripConfig.selectedActivityTags.remove(tagId)
        } else {
            tripConfig.selectedActivityTags.insert(tagId)
        }
    }
    
    private func createAndSaveTrip() {
        // 从设置中读取性别
        tripConfig.gender = localization.userGender
        
        // 设置日期范围
        tripConfig.dateRange = TripDateRange(startDate: startDate, endDate: endDate)
        
        // 生成物品列表
        let items = PresetData.shared.generatePackingList(
            tagIds: tripConfig.allSelectedTags,
            gender: tripConfig.gender
        )
        
        // 创建清单名称
        let name = tripConfig.generateListName(language: localization.currentLanguage)
        
        // 计算 duration（根据日期范围）
        let duration = tripConfig.dateRange?.toTripDuration() ?? .medium
        
        // 创建 Trip 实例
        let trip = Trip(
            name: name,
            gender: tripConfig.gender,
            duration: duration,
            selectedTags: Array(tripConfig.allSelectedTags),
            items: items
        )
        
        // 保存到数据库
        modelContext.insert(trip)
        
        // 导航到清单页
        createdTrip = trip
        showingPackingList = true
        
        // 重置配置
        tripConfig = TripConfig()
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    }
}

// MARK: - 通用选择按钮 (PRD v1.2: 统一按钮尺寸)

struct SelectionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    // 统一按钮尺寸 (PRD v1.2 UI 规范)
    private let buttonHeight: CGFloat = 60
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray6))
                .foregroundColor(isSelected ? .blue : .primary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

// MARK: - 时长选择按钮 (PRD v1.2: 统一按钮尺寸)

struct DurationButton: View {
    let duration: TripDuration
    let isSelected: Bool
    let language: AppLanguage
    let action: () -> Void
    
    // 统一按钮高度 (PRD v1.2 UI 规范)
    private let buttonHeight: CGFloat = 50
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: duration.icon)
                    .font(.title3)
                    .frame(width: 28)
                
                Text(duration.displayName(language: language))
                    .font(.subheadline)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .frame(height: buttonHeight)
            .padding(.horizontal, Spacing.md)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(CornerRadius.md)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(duration.displayName(language: language))
    }
}

#Preview {
    TripConfigView()
        .environmentObject(LocalizationManager.shared)
        .modelContainer(for: [Trip.self, TripItem.self], inMemory: true)
}
