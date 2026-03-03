//
//  HomeView.swift
//  SmartPack
//
//  首页 - 完全使用原生组件重构
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localization: LocalizationManager

    @Query(sort: \Trip.createdAt, order: .reverse) private var trips: [Trip]

    @State private var showingCreateTrip = false
    @State private var showingSettings = false
    @State private var showingItemManagement = false
    @State private var selectedTrip: Trip?
    @State private var pendingTrip: Trip?
    @State private var tripToDelete: Trip?
    @State private var showingDeleteAlert = false
    @State private var emptyStateAppeared = false

    // Performance: @Query 已按 createdAt 倒序排序，无需再次排序
    private var activeTrips: [Trip] {
        trips.filter { !$0.isArchived }
    }

    private var archivedTrips: [Trip] {
        trips.filter { $0.isArchived }
    }

    var body: some View {
        NavigationStack {
            // L1: 空状态移出 List，条件切换视图实现垂直居中
            Group {
            if trips.isEmpty {
                VStack(spacing: Spacing.lg) {
                    // Halo: two concentric circles + suitcase icon
                    ZStack {
                        Circle()
                            .stroke(AppColors.primary.opacity(0.06), lineWidth: 1)
                            .frame(width: 120, height: 120)
                        Circle()
                            .stroke(AppColors.primary.opacity(0.12), lineWidth: 1)
                            .frame(width: 88, height: 88)
                        Image(systemName: "suitcase")
                            .font(.system(size: 42, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.primary)
                    }

                    Text(localization.string(for: .noTripsYet))
                        .font(Typography.title1)
                        .foregroundColor(AppColors.textSecondary)

                    Text(localization.string(for: .noTripsHint))
                        .font(Typography.subheadline)
                        .tracking(Typography.Tracking.wide)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
                .opacity(emptyStateAppeared ? 1 : 0)
                .offset(y: emptyStateAppeared ? 0 : 12)
                .onAppear {
                    withAnimation(PremiumAnimation.entrance) {
                        emptyStateAppeared = true
                    }
                }
            } else {
                List {
                    // Active 行程
                    if !activeTrips.isEmpty {
                        Section {
                            ForEach(activeTrips) { trip in
                                // U4: ZStack 隐藏系统 chevron
                                ZStack {
                                    NavigationLink(value: trip) { EmptyView() }
                                        .opacity(0)
                                    TripRowView(trip: trip, language: localization.currentLanguage)
                                }
                                // PRD: Trip Archive Enhancement - Active trips 横滑操作
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    // 删除按钮（红色，需要确认）
                                    // 不使用 role: .destructive — 它会在确认前自动移除行
                                    Button {
                                        deleteTrip(trip)
                                    } label: {
                                        Label(
                                            localization.string(for: .delete),
                                            systemImage: "trash"
                                        )
                                    }
                                    .tint(.red)

                                    // 归档按钮
                                    Button {
                                        archiveTrip(trip)
                                    } label: {
                                        Label(
                                            localization.string(for: .archive),
                                            systemImage: "archivebox"
                                        )
                                    }
                                    .tint(AppColors.archiveAccent)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(
                                    top: 6,
                                    leading: Spacing.md,
                                    bottom: 6,
                                    trailing: Spacing.md
                                ))
                            }
                        }
                    }

                    // Archived 行程
                    if !archivedTrips.isEmpty {
                        Section {
                            ForEach(archivedTrips) { trip in
                                // U4: ZStack 隐藏系统 chevron
                                ZStack {
                                    NavigationLink(value: trip) { EmptyView() }
                                        .opacity(0)
                                    TripRowView(trip: trip, language: localization.currentLanguage, isArchived: true)
                                }
                                // PRD: Trip Archive Enhancement - Archived trips 横滑操作
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    // 删除按钮（红色，需要确认）
                                    // 不使用 role: .destructive — 它会在确认前自动移除行
                                    Button {
                                        deleteTrip(trip)
                                    } label: {
                                        Label(
                                            localization.string(for: .delete),
                                            systemImage: "trash"
                                        )
                                    }
                                    .tint(.red)

                                    // 取消归档按钮
                                    Button {
                                        unarchiveTrip(trip)
                                    } label: {
                                        Label(
                                            localization.string(for: .unarchive),
                                            systemImage: "arrow.uturn.backward"
                                        )
                                    }
                                    .tint(AppColors.archiveAccent)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(
                                    top: 6,
                                    leading: Spacing.md,
                                    bottom: 6,
                                    trailing: Spacing.md
                                ))
                            }
                        } header: {
                            Text(localization.string(for: .archived))
                                .sectionHeaderStyle()
                                .padding(.leading, Spacing.xxs)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.background)
            }
            } // Group
            .navigationTitle(localization.string(for: .myTrips))
            .navigationDestination(for: Trip.self) { trip in
                // F17: .id() forces view recreation per trip, preventing stale @State ViewModel
                PackingListView(trip: trip, isNewlyCreated: false)
                    .id(trip.id)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateTrip = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingItemManagement = true
                        } label: {
                            Label(
                                localization.string(for: .itemManagement),
                                systemImage: "checklist"
                            )
                        }

                        Button {
                            showingSettings = true
                        } label: {
                            Label(
                                localization.string(for: .settings),
                                systemImage: "gearshape"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            // T4: onDismiss 回调替代硬编码延迟，避免导航竞态
            .sheet(isPresented: $showingCreateTrip, onDismiss: {
                if let trip = pendingTrip {
                    selectedTrip = trip
                    pendingTrip = nil
                }
            }) {
                CreateTripSheet(modelContext: modelContext) { trip in
                    pendingTrip = trip
                    showingCreateTrip = false
                }
                .environmentObject(localization)
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    SettingsView()
                        .environmentObject(localization)
                }
            }
            .sheet(isPresented: $showingItemManagement) {
                NavigationStack {
                    ItemManagementView()
                        .environmentObject(localization)
                }
            }
            .navigationDestination(item: $selectedTrip) { trip in
                PackingListView(trip: trip, isNewlyCreated: true)
                    .id(trip.id)
            }
            // SPEC v1.5 F-4.2: 删除确认对话框
            .alert(
                localization.string(for: .deleteTrip),
                isPresented: $showingDeleteAlert
            ) {
                Button(localization.string(for: .cancel), role: .cancel) {
                    tripToDelete = nil
                }
                Button(localization.string(for: .delete), role: .destructive) {
                    if let trip = tripToDelete {
                        deleteTripConfirmed(trip)
                    }
                }
            } message: {
                Text(localization.string(for: .deleteTripMessage))
            }
            .tint(AppColors.primary)
        }
    }

    // SPEC v1.5 F-4.1: 删除 Trip（带确认）
    private func deleteTrip(_ trip: Trip) {
        tripToDelete = trip
        showingDeleteAlert = true
    }

    // U3: 确认删除 — withAnimation 避免归档区跳动
    private func deleteTripConfirmed(_ trip: Trip) {
        withAnimation(.easeInOut(duration: 0.3)) {
            modelContext.delete(trip)
            try? modelContext.save()
        }
        tripToDelete = nil
    }

    // U8: 归档操作 — 移除 withAnimation，使用 SwiftUI 默认 List 过渡
    private func archiveTrip(_ trip: Trip) {
        trip.archive()
        try? modelContext.save()
    }

    // U8: 取消归档操作 — 移除 withAnimation，使用 SwiftUI 默认 List 过渡
    private func unarchiveTrip(_ trip: Trip) {
        trip.unarchive()
        try? modelContext.save()
    }
}

#Preview {
    HomeView()
        .environmentObject(LocalizationManager.shared)
        .modelContainer(for: [Trip.self, TripItem.self], inMemory: true)
}
