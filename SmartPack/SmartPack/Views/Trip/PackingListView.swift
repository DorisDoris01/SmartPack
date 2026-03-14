//
//  PackingListView.swift
//  SmartPack
//
//  行程物品页 - 原生 List(.insetGrouped) 布局
//  进度条 + 原生分类 Section
//

import SwiftUI
import SwiftData
import Foundation

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
    @State private var showWeatherCard = false
    @State private var showTripSettings = false

    var body: some View {
        ZStack(alignment: .top) {
            if let vm {
                mainContent(vm: vm)
            }

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
        .onAppear { onViewAppear() }
        .onDisappear { }
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
                    contextRow

                    if (showWeatherCard && trip.hasWeatherData) || (showTripSettings && trip.totalCount > 0) {
                        CombinedInfoCard(
                            trip: trip,
                            showWeather: showWeatherCard && trip.hasWeatherData,
                            showSettings: showTripSettings && trip.totalCount > 0
                        )
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
                        return vm.addItem(to: group.category, name: itemName, language: localization.currentLanguage)
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
        .contentMargins(.top, Spacing.xxs, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
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
                        Text(localization.string(for: .weather))
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
                        Text(localization.string(for: .settings))
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
                    Text(localization.string(for: .done))
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
                        localization.string(for: .resetTrip),
                        systemImage: "arrow.counterclockwise"
                    )
                }

                if !trip.isArchived && trip.isAllChecked {
                    Button {
                        showArchiveAlert = true
                    } label: {
                        Label(
                            localization.string(for: .archiveTrip),
                            systemImage: "archivebox"
                        )
                    }
                }

                if trip.isArchived {
                    Button {
                        vm?.unarchiveTrip()
                    } label: {
                        Label(
                            localization.string(for: .unarchive),
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
        localization.string(for: .resetTrip)
    }

    @ViewBuilder
    var resetAlertActions: some View {
        Button(localization.string(for: .cancel), role: .cancel) {}
        Button(localization.string(for: .confirmReset), role: .destructive) {
            vm?.resetAll(language: localization.currentLanguage)
        }
    }

    var resetAlertMessage: some View {
        Text(localization.string(for: .resetTripMessage))
    }

    var archiveAlertTitle: String {
        localization.string(for: .archiveTrip)
    }

    @ViewBuilder
    var archiveAlertActions: some View {
        Button(localization.string(for: .notNow), role: .cancel) {}
        Button(localization.string(for: .archive)) {
            vm?.archiveTrip()
            dismiss()
        }
    }

    var archiveAlertMessage: some View {
        Text(localization.string(for: .archiveTripMessage))
    }

}

// MARK: - Actions

private extension PackingListView {

    func onViewAppear() {
        if vm == nil {
            vm = PackingListViewModel(trip: trip, language: localization.currentLanguage)
        }

        // F1 fix: 预热天气缓存，避免在 View body 中变更 @Transient 状态
        trip.warmWeatherCache()

    }

    func toggleCategory(_ category: String, vm: PackingListViewModel) {
        if vm.expandedCategories.contains(category) {
            vm.expandedCategories.remove(category)
        } else {
            vm.expandedCategories.insert(category)
        }
    }

    func requestDeleteItem(_ itemId: String) {
        vm?.deleteItem(itemId, language: localization.currentLanguage)
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
