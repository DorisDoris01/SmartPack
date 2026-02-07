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

// MARK: - 已废弃：CategoryForAdd（v1.6 版本，v1.7 已移除）

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
    
    // SPEC v1.5: Live Activity 管理器
    private let activityManager = PackingActivityManagerCompat.shared
    
    private var groupedItems: [(category: String, items: [TripItem])] {
        PresetData.shared.groupByCategory(trip.items, language: localization.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            // 主内容 - SPEC v1.7: 使用 List 替代 ScrollView + LazyVStack
            VStack(spacing: 0) {
                progressHeader
                
                // SPEC: Weather Integration v1.0 - 天气卡片
                if trip.hasWeatherData {
                    WeatherCard(
                        forecasts: trip.weatherForecasts,
                        destination: trip.destination,
                        startDate: trip.startDate,
                        endDate: trip.endDate
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                List {
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
            }
            .background(Color(.systemGroupedBackground))
            
            // 庆祝动画覆盖层
            if showCelebration {
                CelebrationOverlay(isPresented: $showCelebration) {
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
        VStack(spacing: 12) {
            HStack {
                Text(localization.currentLanguage == .chinese ? "打包进度" : "Progress")
                    .font(.headline)
                
                if trip.isArchived {
                    Text(localization.currentLanguage == .chinese ? "已归档" : "Archived")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text("\(trip.checkedCount)/\(trip.totalCount)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(trip.isAllChecked ? Color.green : Color.blue)
                        .frame(width: geometry.size.width * trip.progress, height: 12)
                        .animation(.spring(response: 0.3), value: trip.progress)
                }
            }
            .frame(height: 12)
            
            if trip.isAllChecked {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(localization.currentLanguage == .chinese ? "全部打包完成！" : "All packed!")
                        .foregroundColor(.green)
                }
                .font(.subheadline.bold())
            } else {
                let remaining = trip.totalCount - trip.checkedCount
                Text(localization.currentLanguage == .chinese
                     ? "还剩 \(remaining) 件物品"
                     : "\(remaining) items remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
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

// MARK: - 庆祝动画覆盖层

struct CelebrationOverlay: View {
    @Binding var isPresented: Bool
    let onComplete: () -> Void
    
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAndComplete()
                }
            
            // 撒花粒子
            ForEach(confettiPieces) { piece in
                ConfettiView(piece: piece)
            }
            
            // 中心祝贺内容
            if showContent {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("🎉")
                        .font(.system(size: 60))
                    
                    Text("All Packed!")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            generateConfetti()
            withAnimation(.spring(response: 0.5)) {
                showContent = true
            }
            
            // 自动关闭
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                dismissAndComplete()
            }
        }
    }
    
    private func generateConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        
        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                color: colors.randomElement() ?? .blue,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                delay: Double.random(in: 0...0.5)
            )
            confettiPieces.append(piece)
        }
    }
    
    private func dismissAndComplete() {
        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    let x: CGFloat
    let delay: Double
}

struct ConfettiView: View {
    let piece: ConfettiPiece
    @State private var yOffset: CGFloat = -50
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .offset(x: piece.x - UIScreen.main.bounds.width / 2, y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeIn(duration: 2)
                    .delay(piece.delay)
                ) {
                    yOffset = UIScreen.main.bounds.height + 50
                    rotation = Double.random(in: 360...720)
                }
                
                withAnimation(
                    .easeIn(duration: 0.5)
                    .delay(piece.delay + 1.5)
                ) {
                    opacity = 0
                }
            }
    }
}

// MARK: - 分类区域（SPEC v1.7: 使用 List Section）

struct CategorySection: View {
    let category: String
    let items: [TripItem]
    let isExpanded: Bool
    let language: AppLanguage
    let trip: Trip
    let onToggleExpand: () -> Void
    let onToggleItem: (String) -> Void
    let onDeleteItem: (String) -> Void
    let onAddItem: (String) -> Void
    
    private var checkedCount: Int {
        items.filter { $0.isChecked }.count
    }
    
    private var categoryIcon: String {
        switch category {
        case "证件/钱财", "Documents & Money": return "wallet.pass"
        case "衣物", "Clothing": return "tshirt"
        case "洗漱用品", "Toiletries": return "drop"
        case "电子产品", "Electronics": return "laptopcomputer.and.iphone"
        case "运动装备", "Sports Gear": return "figure.run"
        default: return "ellipsis.circle"
        }
    }
    
    private var categoryEnum: ItemCategory {
        ItemCategory.allCases.first { cat in
            cat.nameCN == category || cat.nameEN == category
        } ?? .other
    }
    
    var body: some View {
        Section {
            if isExpanded {
                // Item 列表
                if items.isEmpty {
                    // 空状态处理
                    Text(language == .chinese ? "该分类暂无物品" : "No items in this category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(items) { item in
                        ItemRow(
                            item: item,
                            language: language,
                            onToggle: {
                                onToggleItem(item.id)
                            },
                            onDelete: {
                                onDeleteItem(item.id)
                            }
                        )
                    }
                }
                
                // SPEC v1.7 F-2.1: 添加输入框（参照 Reminders）
                AddItemRow(
                    category: category,
                    categoryEnum: categoryEnum,
                    existingItemIds: Set(trip.items.map { $0.id }),
                    onAddItem: { itemName in
                        onAddItem(itemName)
                    }
                )
            }
        } header: {
            // Section Header（分类名称 + 统计）
            CategoryHeader(
                category: category,
                checkedCount: checkedCount,
                totalCount: items.count,
                icon: categoryIcon,
                isExpanded: isExpanded,
                onToggle: onToggleExpand
            )
        }
    }
}

// MARK: - 分类头部

struct CategoryHeader: View {
    let category: String
    let checkedCount: Int
    let totalCount: Int
    let icon: String
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text(category)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(checkedCount)/\(totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 物品行（SPEC v1.7: 使用 List 原生样式）

struct ItemRow: View {
    let item: TripItem
    let language: AppLanguage
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        HStack(spacing: 12) {
            // 复选框（左侧）
            Button {
                onToggle()
            } label: {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isChecked ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Item 名称（可点击整行）
            Text(item.displayName(language: language))
                .font(.body)
                .foregroundColor(item.isChecked ? .secondary : .primary)
                .strikethrough(item.isChecked, color: .secondary)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        // SPEC v1.7 F-1.1: 横滑删除
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(localization.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - SPEC v1.7 F-2.1: 添加物品输入框（参照 Reminders）

struct AddItemRow: View {
    let category: String
    let categoryEnum: ItemCategory
    let existingItemIds: Set<String>
    let onAddItem: (String) -> Void
    
    @EnvironmentObject var localization: LocalizationManager
    @FocusState private var isFocused: Bool
    @State private var itemName = ""
    @State private var showPresetSuggestions = false
    
    // 获取当前分类下的预设 Item（用于自动补全）
    private var presetItemsForCategory: [Item] {
        PresetData.shared.allItems.values
            .filter { $0.category == categoryEnum }
            .filter { !existingItemIds.contains($0.id) }
            .sorted { $0.displayName(language: localization.currentLanguage) < $1.displayName(language: localization.currentLanguage) }
    }
    
    // 过滤后的预设 Item（基于输入）
    private var filteredPresetItems: [Item] {
        if itemName.isEmpty {
            return []
        }
        return presetItemsForCategory.filter { item in
            item.displayName(language: localization.currentLanguage)
                .localizedCaseInsensitiveContains(itemName)
        }
        .prefix(5)
        .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 输入框
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                TextField(
                    localization.currentLanguage == .chinese ? "添加物品..." : "Add item...",
                    text: $itemName
                )
                .focused($isFocused)
                .onSubmit {
                    addItem()
                }
                .onChange(of: itemName) { oldValue, newValue in
                    showPresetSuggestions = !newValue.isEmpty && !filteredPresetItems.isEmpty
                }
                
                if !itemName.isEmpty {
                    Button {
                        addItem()
                    } label: {
                        Text(localization.currentLanguage == .chinese ? "添加" : "Add")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.vertical, 4)
            
            // 预设 Item 建议（可选，类似 Reminders 的自动补全）
            if showPresetSuggestions && !filteredPresetItems.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filteredPresetItems) { item in
                            Button {
                                itemName = item.displayName(language: localization.currentLanguage)
                                addItem()
                            } label: {
                                Text(item.displayName(language: localization.currentLanguage))
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .listRowBackground(Color(.systemBackground))
    }
    
    private func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        onAddItem(trimmedName)
        itemName = ""
        isFocused = false
        showPresetSuggestions = false
    }
}

// MARK: - 已废弃：AddItemSheet（v1.6 版本，v1.7 已移除）

struct AddItemSheet: View {
    let category: String
    let categoryEnum: ItemCategory
    let existingItemIds: Set<String>
    let onAddItems: ([TripItem]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var selectedPresetItems: Set<String> = []
    @State private var customItemName = ""
    @State private var selectedTab = 0
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var searchText = ""
    
    // 获取当前分类下的所有预设 Item
    private var presetItemsForCategory: [Item] {
        PresetData.shared.allItems.values
            .filter { $0.category == categoryEnum }
            .sorted { $0.displayName(language: localization.currentLanguage) < $1.displayName(language: localization.currentLanguage) }
    }
    
    // 过滤后的预设 Item（支持搜索）
    private var filteredPresetItems: [Item] {
        if searchText.isEmpty {
            return presetItemsForCategory
        } else {
            return presetItemsForCategory.filter { item in
                item.displayName(language: localization.currentLanguage)
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Tab 1: 预设选择
                presetItemSelectorView
                    .tabItem {
                        Label(
                            localization.currentLanguage == .chinese ? "预设" : "Preset",
                            systemImage: "list.bullet"
                        )
                    }
                    .tag(0)
                
                // Tab 2: 自定义输入（与 AddCustomItemSheet 一致）
                customItemInputView
                    .tabItem {
                        Label(
                            localization.currentLanguage == .chinese ? "自定义" : "Custom",
                            systemImage: "pencil"
                        )
                    }
                    .tag(1)
            }
            .navigationTitle(localization.currentLanguage == .chinese ? "添加物品" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.currentLanguage == .chinese ? "取消" : "Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.currentLanguage == .chinese ? "添加" : "Add") {
                        addItems()
                    }
                    .disabled(!canAddItems)
                }
            }
            .alert(
                localization.currentLanguage == .chinese ? "错误" : "Error",
                isPresented: $showingError
            ) {
                Button(localization.currentLanguage == .chinese ? "确定" : "OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - 预设 Item 选择器视图
    
    private var presetItemSelectorView: some View {
        VStack(spacing: 0) {
            // 搜索栏
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            // Item 列表
            List {
                ForEach(filteredPresetItems) { item in
                    let isAlreadyAdded = existingItemIds.contains(item.id)
                    
                    Button {
                        if isAlreadyAdded {
                            // 已添加的 Item 不能再次选择
                            return
                        }
                        if selectedPresetItems.contains(item.id) {
                            selectedPresetItems.remove(item.id)
                        } else {
                            selectedPresetItems.insert(item.id)
                        }
                    } label: {
                        HStack {
                            Image(systemName: selectedPresetItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedPresetItems.contains(item.id) ? .blue : .gray)
                            
                            Text(item.displayName(language: localization.currentLanguage))
                                .foregroundColor(isAlreadyAdded ? .secondary : .primary)
                            
                            if isAlreadyAdded {
                                Spacer()
                                Text(localization.currentLanguage == .chinese ? "已添加" : "Added")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(isAlreadyAdded)
                }
            }
        }
    }
    
    // MARK: - 自定义 Item 输入视图
    
    private var customItemInputView: some View {
        Form {
            Section(header: Text(localization.currentLanguage == .chinese ? "物品名称" : "Item Name")) {
                TextField(
                    localization.currentLanguage == .chinese ? "输入物品名称" : "Enter item name",
                    text: $customItemName
                )
            }
            
            Section {
                Text(
                    localization.currentLanguage == .chinese
                        ? "新增的物品会添加到「\(category)」分类下。"
                        : "The new item will be added to the \"\(categoryEnum.nameEN)\" category."
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - 计算属性
    
    private var canAddItems: Bool {
        if selectedTab == 0 {
            return !selectedPresetItems.isEmpty
        } else {
            return !customItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    // MARK: - 方法
    
    private func addItems() {
        var itemsToAdd: [TripItem] = []
        
        if selectedTab == 0 {
            // 添加预设 Item
            let presetItems = presetItemsForCategory
                .filter { selectedPresetItems.contains($0.id) }
                .filter { !existingItemIds.contains($0.id) } // SPEC v1.6 F-2.4: 去重处理
            
            itemsToAdd.append(contentsOf: presetItems.map { $0.toTripItem() })
        } else {
            // 添加自定义 Item
            let trimmedName = customItemName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedName.isEmpty {
                errorMessage = localization.currentLanguage == .chinese
                    ? "物品名称不能为空"
                    : "Item name cannot be empty"
                showingError = true
                return
            }
            
            // SPEC v1.6 F-2.4: 检查重复（基于名称，通过 existingItemIds 无法检查名称，这里简化处理）
            // 注意：名称重复检查需要在调用方完成，这里仅做基本验证
            
            let customItem = TripItem(
                id: UUID().uuidString,
                name: trimmedName,
                nameEn: trimmedName,  // 简化：使用相同名称
                category: category,
                categoryEn: categoryEnum.nameEN,
                isChecked: false
            )
            itemsToAdd.append(customItem)
        }
        
        if itemsToAdd.isEmpty {
            errorMessage = localization.currentLanguage == .chinese
                ? "请至少选择一个物品"
                : "Please select at least one item"
            showingError = true
            return
        }
        
        // 调用回调添加 Item
        onAddItems(itemsToAdd)
        dismiss()
    }
}

// MARK: - 搜索栏组件

struct SearchBar: View {
    @Binding var text: String
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(
                localization.currentLanguage == .chinese ? "搜索物品" : "Search items",
                text: $text
            )
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
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
