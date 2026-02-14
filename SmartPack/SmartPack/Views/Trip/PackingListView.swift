//
//  PackingListView.swift
//  SmartPack
//
//  行程物品页 - 分类展示、勾选交互、一键清空
//  PRD v1.3: 完成庆祝动画 + 归档确认弹窗
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - 用于检测进度/天气区域是否已滚出屏幕
private struct HeaderBoundsKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct PackingListView: View {
    @Bindable var trip: Trip
    let isNewlyCreated: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var expandedCategories: Set<String> = []
    @State private var showResetAlert = false
    @State private var showCelebration = false
    @State private var showArchiveAlert = false
    @State private var previousCheckedCount = 0
    // SPEC v1.6 F-1.2: 删除确认对话框
    @State private var itemToDelete: TripItem?
    @State private var showDeleteAlert = false
    /// 用户向下滑动后显示顶部紧凑进度条
    @State private var isHeaderCollapsed = false
    
    // SPEC v1.5: Live Activity 管理器
    private let activityManager = PackingActivityManagerCompat.shared
    
    private var groupedItems: [(category: String, items: [TripItem])] {
        PresetData.shared.groupByCategory(trip.items, language: localization.currentLanguage)
    }
    
    /// 当进度/天气区域顶部滚出此高度时显示紧凑条
    private let collapseThreshold: CGFloat = 60
    
    var body: some View {
        ZStack(alignment: .top) {
            // 主内容：进度 + 天气 + 清单 同在一个 List 内，一起滚动
            List {
                Section {
                    VStack(spacing: 0) {
                        progressHeader
                        if trip.hasWeatherData {
                            WeatherCard(
                                forecasts: trip.weatherForecasts,
                                destination: trip.destination,
                                startDate: trip.startDate,
                                endDate: trip.endDate
                            )
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.xs)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .background(
                        GeometryReader { g in
                            Color.clear.preference(
                                key: HeaderBoundsKey.self,
                                value: g.frame(in: .global)
                            )
                        }
                    )
                }
                .listSectionSpacing(Spacing.sm)

                ForEach(groupedItems, id: \.category) { group in
                    CategorySection(
                        category: group.category,
                        items: group.items,
                        isExpanded: expandedCategories.contains(group.category),
                        language: localization.currentLanguage,
                        trip: trip,
                        onToggleExpand: {
                            toggleCategory(group.category)
                        },
                        onToggleItem: { itemId in
                            toggleItemAndCheckCompletion(itemId)
                        },
                        onDeleteItem: { itemId in
                            requestDeleteItem(itemId)
                        },
                        onAddItem: { itemName in
                            addItemToCategory(group.category, itemName: itemName)
                        }
                    )
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .onPreferenceChange(HeaderBoundsKey.self) { frame in
                // 忽略初始 .zero，仅当头部区域顶部滚出阈值时折叠
                let collapsed = frame.height > 1 && frame.maxY < collapseThreshold
                if isHeaderCollapsed != collapsed {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isHeaderCollapsed = collapsed
                    }
                }
            }

            // 向下滑动后：顶部紧凑进度条（带出现/消失动画）
            if isHeaderCollapsed {
                CompactProgressBar(
                    trip: trip,
                    language: localization.currentLanguage,
                    destination: trip.destination
                )
                .padding(.top, Spacing.xxs)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .zIndex(1)
            }
            
            // 庆祝动画覆盖层
            if showCelebration {
                CelebrationOverlay(
                    isPresented: $showCelebration,
                    title: localization.string(for: .allPacked)
                ) {
                    showArchiveAlert = true
                }
            }
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isNewlyCreated)
        .toolbar {
            if isNewlyCreated {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(localization.currentLanguage == .chinese ? "完成" : "Done")
                            .fontWeight(.medium)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showResetAlert = true
                    } label: {
                        Label(
                            localization.currentLanguage == .chinese ? "重置行程" : "Reset Trip",
                            systemImage: "arrow.counterclockwise"
                        )
                    }
                    
                    if !trip.isArchived && trip.isAllChecked {
                        Button {
                            showArchiveAlert = true
                        } label: {
                            Label(
                                localization.currentLanguage == .chinese ? "归档行程" : "Archive Trip",
                                systemImage: "archivebox"
                            )
                        }
                    }
                    
                    if trip.isArchived {
                        Button {
                            trip.unarchive()
                        } label: {
                            Label(
                                localization.currentLanguage == .chinese ? "取消归档" : "Unarchive",
                                systemImage: "arrow.uturn.backward"
                            )
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .alert(
            localization.currentLanguage == .chinese ? "重置行程" : "Reset Trip",
            isPresented: $showResetAlert
        ) {
            Button(localization.currentLanguage == .chinese ? "取消" : "Cancel", role: .cancel) {}
            Button(localization.currentLanguage == .chinese ? "确认重置" : "Reset", role: .destructive) {
                trip.resetAllChecks()
            }
        } message: {
            Text(localization.currentLanguage == .chinese
                 ? "将清空所有已勾选的物品，确认继续？"
                 : "This will uncheck all items. Continue?")
        }
        .alert(
            localization.currentLanguage == .chinese ? "归档行程" : "Archive Trip",
            isPresented: $showArchiveAlert
        ) {
            Button(localization.currentLanguage == .chinese ? "暂不归档" : "Not Now", role: .cancel) {}
            Button(localization.currentLanguage == .chinese ? "归档" : "Archive") {
                trip.archive()
                // SPEC v1.5 F-5.4: 归档时结束 Live Activity
                activityManager.endActivity()
                // SPEC v1.5 F-3.1: 归档后返回列表页
                dismiss()
            }
        } message: {
            Text(localization.currentLanguage == .chinese
                 ? "归档后的行程将在列表底部显示，方便下次复用。"
                 : "Archived trips will be shown at the bottom of the list for easy reuse.")
        }
        // SPEC v1.6 F-1.2: 删除确认对话框
        .alert(
            localization.currentLanguage == .chinese ? "删除物品" : "Delete Item",
            isPresented: $showDeleteAlert,
            presenting: itemToDelete
        ) { item in
            Button(localization.currentLanguage == .chinese ? "取消" : "Cancel", role: .cancel) {
                itemToDelete = nil
            }
            Button(localization.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                HapticFeedback.light()
                confirmDeleteItem(item.id)
            }
        } message: { item in
            Text(localization.currentLanguage == .chinese
                 ? "确定要删除「\(item.displayName(language: localization.currentLanguage))」吗？"
                 : "Are you sure you want to delete \"\(item.displayName(language: localization.currentLanguage))\"?")
        }
        .onAppear {
            expandedCategories = Set(groupedItems.map { $0.category })
            previousCheckedCount = trip.checkedCount
            
            // SPEC v1.5 F-5.1: 启动 Live Activity（如果未完成）
            if !trip.isArchived && !trip.isAllChecked {
                activityManager.startActivity(
                    tripName: trip.name,
                    checkedCount: trip.checkedCount,
                    totalCount: trip.totalCount
                )
            }
        }
        .onDisappear {
            // SPEC v1.5 F-5.4: 页面消失时结束 Live Activity
            // 注意：归档时会自动返回，这里也会触发
            activityManager.endActivity()
        }
        .onChange(of: trip.checkedCount) { oldValue, newValue in
            // SPEC v1.5 F-5.2: 实时更新 Live Activity 进度
            if !trip.isArchived {
                activityManager.updateActivity(
                    checkedCount: newValue,
                    totalCount: trip.totalCount
                )
            }
        }
        .onChange(of: trip.isArchived) { oldValue, newValue in
            // SPEC v1.5 F-5.4: 归档时结束 Live Activity
            if newValue {
                activityManager.endActivity()
            }
        }
        .onChange(of: trip.isAllChecked) { oldValue, newValue in
            // SPEC v1.5 F-5.4: 全部完成时结束 Live Activity
            if newValue {
                activityManager.endActivity()
            }
        }
    }
    
    // MARK: - 进度头部

    private var progressHeader: some View {
        ProgressHeader(trip: trip, language: localization.currentLanguage)
    }
    
    // MARK: - 方法
    
    private func toggleCategory(_ category: String) {
        if expandedCategories.contains(category) {
            expandedCategories.remove(category)
        } else {
            expandedCategories.insert(category)
        }
    }
    
    private func toggleItemAndCheckCompletion(_ itemId: String) {
        let wasAllChecked = trip.isAllChecked
        trip.toggleItem(itemId)
        
        // 检查是否刚刚完成全部勾选（且未归档）
        if !wasAllChecked && trip.isAllChecked && !trip.isArchived {
            HapticFeedback.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCelebration = true
            }
        }
    }
    
    // SPEC v1.6 F-1.2: 请求删除 Item（显示确认对话框）
    private func requestDeleteItem(_ itemId: String) {
        if let item = trip.items.first(where: { $0.id == itemId }) {
            itemToDelete = item
            showDeleteAlert = true
        }
    }
    
    // SPEC v1.6 F-1.2: 确认删除 Item
    private func confirmDeleteItem(_ itemId: String) {
        var currentItems = trip.items
        currentItems.removeAll { $0.id == itemId }
        trip.items = currentItems
        // 数据会自动持久化（SwiftData @Bindable）
        // SPEC v1.6 F-1.3: 删除后更新 Live Activity
        if !trip.isArchived {
            activityManager.updateActivity(
                checkedCount: trip.checkedCount,
                totalCount: trip.totalCount
            )
        }
        itemToDelete = nil
    }
    
    // SPEC v1.7 F-2.3: 添加 Item 到指定分类
    private func addItemToCategory(_ category: String, itemName: String) {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // 根据分类名称获取 ItemCategory 枚举值
        let categoryEnum = ItemCategory.allCases.first { cat in
            cat.nameCN == category || cat.nameEN == category
        } ?? .other
        
        // SPEC v1.7 F-2.4: 去重处理
        let existingIds = Set(trip.items.map { $0.id })
        let existingNames = Set(trip.items.map { $0.name.lowercased() })
        
        // 检查是否已存在（基于名称）
        if existingNames.contains(trimmedName.lowercased()) {
            return // 已存在，不添加
        }
        
        // 检查是否是预设 Item（基于名称匹配）
        let presetItem = PresetData.shared.allItems.values.first { item in
            (item.name == trimmedName || item.nameEn == trimmedName) && 
            item.category == categoryEnum &&
            !existingIds.contains(item.id)
        }
        
        let newItem: TripItem
        if let preset = presetItem {
            // 使用预设 Item
            newItem = preset.toTripItem()
        } else {
            // 创建自定义 Item
            newItem = TripItem(
                id: UUID().uuidString,
                name: trimmedName,
                nameEn: trimmedName,
                category: category,
                categoryEn: categoryEnum.nameEN,
                isChecked: false
            )
        }
        
        // 添加到 Trip
        var currentItems = trip.items
        currentItems.append(newItem)
        trip.items = currentItems
        
        // SPEC v1.7 F-2.5: 添加后更新 Live Activity
        if !trip.isArchived {
            activityManager.updateActivity(
                checkedCount: trip.checkedCount,
                totalCount: trip.totalCount
            )
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, configurations: config)
    let context = container.mainContext
    
    let trip = Trip(
        name: "商务会面 - 2026/02/01",
        gender: .male,
        duration: .medium,
        selectedTags: ["business_meeting"],
        items: PresetData.shared.generatePackingList(tagIds: ["business_meeting"], gender: .male)
    )
    context.insert(trip)
    
    return NavigationStack {
        PackingListView(trip: trip, isNewlyCreated: true)
            .environmentObject(LocalizationManager.shared)
    }
    .modelContainer(container)
}
