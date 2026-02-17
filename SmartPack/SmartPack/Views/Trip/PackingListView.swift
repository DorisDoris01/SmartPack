//
//  PackingListView.swift
//  SmartPack
//
//  行程物品页 - 原生 List(.insetGrouped) 布局
//  环形进度 + 原生分类 Section + 毛玻璃浮动条
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - PreferenceKey for header scroll detection

private struct HeaderBoundsKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - PackingListView

struct PackingListView: View {
    @Bindable var trip: Trip
    let isNewlyCreated: Bool

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager

    // MARK: ViewModel（业务逻辑全部委托）
    @State private var vm: PackingListViewModel?

    // MARK: 纯 UI 状态
    @State private var showResetAlert = false
    @State private var showArchiveAlert = false
    @State private var itemToDelete: TripItem?
    @State private var showDeleteAlert = false
    @State private var isHeaderCollapsed = false
    @State private var showWeatherCard = true
    @State private var showTripSettings = true

    var body: some View {
        ZStack(alignment: .top) {
            if let vm {
                mainContent(vm: vm)
            }

            compactProgressOverlay
            celebrationOverlay
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isNewlyCreated)
        .toolbar { toolbarContent }
        .alert(resetAlertTitle, isPresented: $showResetAlert) { resetAlertActions }
            message: { resetAlertMessage }
        .alert(archiveAlertTitle, isPresented: $showArchiveAlert) { archiveAlertActions }
            message: { archiveAlertMessage }
        .alert(deleteAlertTitle, isPresented: $showDeleteAlert, presenting: itemToDelete) { deleteAlertActions($0) }
            message: { deleteAlertMessage($0) }
        .onAppear { onViewAppear() }
        .onDisappear { vm?.stopLiveActivity() }
        .onChange(of: localization.currentLanguage) { _, newValue in
            vm?.rebuildGroups(language: newValue)
        }
    }
}

// MARK: - 主内容

private extension PackingListView {

    /// 根据分类名称获取强调色
    func accentColor(for categoryName: String) -> Color {
        let cat = ItemCategory.allCases.first { $0.nameCN == categoryName || $0.nameEN == categoryName }
        return cat?.accentColor ?? AppColors.textSecondary
    }

    func mainContent(vm: PackingListViewModel) -> some View {
        List {
            // MARK: 英雄进度环 + 上下文行 + 天气 + 设置
            Section {
                VStack(spacing: Spacing.md) {
                    ProgressHeader(
                        trip: trip,
                        language: localization.currentLanguage
                    )
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: HeaderBoundsKey.self, value: proxy.frame(in: .global).maxY)
                        }
                    )

                    contextRow

                    if showWeatherCard && trip.hasWeatherData {
                        WeatherCard(
                            forecasts: trip.weatherForecasts,
                            destination: trip.destination,
                            startDate: trip.startDate,
                            endDate: trip.endDate
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }

                    if showTripSettings && trip.totalCount > 0 {
                        TripSettingsCard(trip: trip)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // MARK: 分类 Section
            ForEach(vm.groupedItems, id: \.category) { group in
                CategorySection(
                    category: group.category,
                    items: group.items,
                    isExpanded: vm.expandedCategories.contains(group.category),
                    language: localization.currentLanguage,
                    existingItemIds: vm.existingItemIds,
                    accentColor: accentColor(for: group.category),
                    onToggleExpand: {
                        toggleCategory(group.category, vm: vm)
                    },
                    onToggleItem: { itemId in
                        vm.toggleItem(itemId)
                    },
                    onDeleteItem: { itemId in
                        requestDeleteItem(itemId)
                    },
                    onAddItem: { itemName in
                        vm.addItem(to: group.category, name: itemName, language: localization.currentLanguage)
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .onPreferenceChange(HeaderBoundsKey.self) { maxY in
            // 当 ProgressHeader 底部滚动到导航栏下方时，显示浮动进度条
            let collapsed = maxY < 100
            if isHeaderCollapsed != collapsed {
                withAnimation(PremiumAnimation.snappy) {
                    isHeaderCollapsed = collapsed
                }
            }
        }
    }

    // 上下文行：天气 + 设置胶囊按钮
    @ViewBuilder
    var contextRow: some View {
        HStack(spacing: Spacing.sm) {
            // 天气胶囊
            if trip.hasWeatherData {
                Button {
                    withAnimation(PremiumAnimation.standard) {
                        showWeatherCard.toggle()
                    }
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "cloud.sun.fill")
                            .font(Typography.caption)
                        Text(localization.currentLanguage == .chinese ? "天气" : "Weather")
                            .font(Typography.caption)
                    }
                    .foregroundColor(showWeatherCard ? .white : AppColors.primary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(showWeatherCard ? AppColors.primary : AppColors.primary.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            // 设置胶囊
            if trip.totalCount > 0 {
                Button {
                    withAnimation(PremiumAnimation.standard) {
                        showTripSettings.toggle()
                    }
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "gearshape.fill")
                            .font(Typography.caption)
                        Text(localization.currentLanguage == .chinese ? "设置" : "Settings")
                            .font(Typography.caption)
                    }
                    .foregroundColor(showTripSettings ? .white : AppColors.secondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(showTripSettings ? AppColors.secondary : AppColors.secondary.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }
}

// MARK: - 覆盖层

private extension PackingListView {

    @ViewBuilder
    var compactProgressOverlay: some View {
        if isHeaderCollapsed {
            ProgressHeader(
                trip: trip,
                language: localization.currentLanguage,
                isFloating: true
            )
            .padding(.top, 8)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
            .zIndex(1000)
        }
    }

    @ViewBuilder
    var celebrationOverlay: some View {
        if let vm, vm.showCelebration {
            CelebrationOverlay(
                isPresented: Binding(
                    get: { vm.showCelebration },
                    set: { vm.showCelebration = $0 }
                ),
                title: localization.string(for: .allPacked)
            ) {
                dismiss()
            }
        }
    }
}

// MARK: - Toolbar

private extension PackingListView {

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if isNewlyCreated {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text(localization.currentLanguage == .chinese ? "完成" : "Done")
                        .font(Typography.body)
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
                        vm?.unarchiveTrip()
                    } label: {
                        Label(
                            localization.currentLanguage == .chinese ? "取消归档" : "Unarchive",
                            systemImage: "arrow.uturn.backward"
                        )
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(Typography.body)
                    .frame(width: 44, height: 44)
            }
        }
    }
}

// MARK: - Alerts

private extension PackingListView {

    var resetAlertTitle: String {
        localization.currentLanguage == .chinese ? "重置行程" : "Reset Trip"
    }

    @ViewBuilder
    var resetAlertActions: some View {
        Button(localization.currentLanguage == .chinese ? "取消" : "Cancel", role: .cancel) {}
        Button(localization.currentLanguage == .chinese ? "确认重置" : "Reset", role: .destructive) {
            vm?.resetAll(language: localization.currentLanguage)
        }
    }

    var resetAlertMessage: some View {
        Text(localization.currentLanguage == .chinese
             ? "将清空所有已勾选的物品，确认继续？"
             : "This will uncheck all items. Continue?")
    }

    var archiveAlertTitle: String {
        localization.currentLanguage == .chinese ? "归档行程" : "Archive Trip"
    }

    @ViewBuilder
    var archiveAlertActions: some View {
        Button(localization.currentLanguage == .chinese ? "暂不归档" : "Not Now", role: .cancel) {}
        Button(localization.currentLanguage == .chinese ? "归档" : "Archive") {
            vm?.archiveTrip()
            dismiss()
        }
    }

    var archiveAlertMessage: some View {
        Text(localization.currentLanguage == .chinese
             ? "归档后的行程将在列表底部显示，方便下次复用。"
             : "Archived trips will be shown at the bottom of the list for easy reuse.")
    }

    var deleteAlertTitle: String {
        localization.currentLanguage == .chinese ? "删除物品" : "Delete Item"
    }

    func deleteAlertActions(_ item: TripItem) -> some View {
        Group {
            Button(localization.currentLanguage == .chinese ? "取消" : "Cancel", role: .cancel) {
                itemToDelete = nil
            }
            Button(localization.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                HapticFeedback.light()
                vm?.deleteItem(item.id, language: localization.currentLanguage)
                itemToDelete = nil
            }
        }
    }

    func deleteAlertMessage(_ item: TripItem) -> some View {
        Text(localization.currentLanguage == .chinese
             ? "确定要删除「\(item.displayName(language: localization.currentLanguage))」吗？"
             : "Are you sure you want to delete \"\(item.displayName(language: localization.currentLanguage))\"?")
    }
}

// MARK: - Actions

private extension PackingListView {

    func onViewAppear() {
        if vm == nil {
            vm = PackingListViewModel(trip: trip, language: localization.currentLanguage)
        }

        vm?.startLiveActivityIfNeeded()
    }

    func toggleCategory(_ category: String, vm: PackingListViewModel) {
        if vm.expandedCategories.contains(category) {
            vm.expandedCategories.remove(category)
        } else {
            vm.expandedCategories.insert(category)
        }
    }

    func requestDeleteItem(_ itemId: String) {
        if let item = trip.items.first(where: { $0.id == itemId }) {
            itemToDelete = item
            showDeleteAlert = true
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, TripItem.self, configurations: config)
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
