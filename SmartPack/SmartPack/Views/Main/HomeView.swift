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
    @State private var tripToDelete: Trip?
    @State private var showingDeleteAlert = false
    
    // 排序：Active 在前，Archived 置底
    private var activeTrips: [Trip] {
        trips.filter { !$0.isArchived }.sorted { $0.createdAt > $1.createdAt }
    }
    
    private var archivedTrips: [Trip] {
        trips.filter { $0.isArchived }.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Active 行程
                if !activeTrips.isEmpty {
                    Section {
                        ForEach(activeTrips) { trip in
                            NavigationLink(value: trip) {
                                TripRowView(trip: trip, language: localization.currentLanguage)
                            }
                            // PRD: Trip Archive Enhancement - Active trips 横滑操作
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // 删除按钮（红色，需要确认）
                                Button(role: .destructive) {
                                    deleteTrip(trip)
                                } label: {
                                    Label(
                                        localization.currentLanguage == .chinese ? "删除" : "Delete",
                                        systemImage: "trash"
                                    )
                                }

                                // 归档按钮（蓝色，无需确认）
                                Button {
                                    archiveTrip(trip)
                                } label: {
                                    Label(
                                        localization.currentLanguage == .chinese ? "归档" : "Archive",
                                        systemImage: "archivebox"
                                    )
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
                
                // Archived 行程
                if !archivedTrips.isEmpty {
                    Section(header: Text(localization.currentLanguage == .chinese ? "已归档" : "Archived")) {
                        ForEach(archivedTrips) { trip in
                            NavigationLink(value: trip) {
                                TripRowView(trip: trip, language: localization.currentLanguage, isArchived: true)
                            }
                            // PRD: Trip Archive Enhancement - Archived trips 横滑操作
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // 删除按钮（红色，需要确认）
                                Button(role: .destructive) {
                                    deleteTrip(trip)
                                } label: {
                                    Label(
                                        localization.currentLanguage == .chinese ? "删除" : "Delete",
                                        systemImage: "trash"
                                    )
                                }

                                // 取消归档按钮（蓝色，无需确认）
                                Button {
                                    unarchiveTrip(trip)
                                } label: {
                                    Label(
                                        localization.currentLanguage == .chinese ? "取消归档" : "Unarchive",
                                        systemImage: "arrow.uturn.backward"
                                    )
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
                
                // 空状态
                if trips.isEmpty {
                    Section {
                        VStack(spacing: Spacing.lg) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primary.opacity(0.08))
                                    .frame(width: 120, height: 120)
                                Image(systemName: "suitcase.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppColors.primary)
                            }
                            Image(systemName: "plus.circle.dashed")
                                .font(.system(size: 28))
                                .foregroundColor(AppColors.textSecondary.opacity(0.6))
                            
                            Text(localization.currentLanguage == .chinese ? "还没有行程" : "No trips yet")
                                .font(Typography.title2)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text(localization.currentLanguage == .chinese
                                 ? "点击右上角 + 开始你的第一次行程"
                                 : "Tap + to start your first trip")
                                .font(Typography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Spacing.xl)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xxl + 20)
                    }
                }
            }
            .navigationTitle(localization.currentLanguage == .chinese ? "我的行程" : "My Trips")
            .navigationDestination(for: Trip.self) { trip in
                PackingListView(trip: trip, isNewlyCreated: false)
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
                                localization.currentLanguage == .chinese ? "Item 管理" : "Item Management",
                                systemImage: "checklist"
                            )
                        }
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Label(
                                localization.currentLanguage == .chinese ? "设置" : "Settings",
                                systemImage: "gearshape"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingCreateTrip) {
                CreateTripSheet(modelContext: modelContext) { trip in
                    showingCreateTrip = false
                    // 延迟导航到新创建的行程
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedTrip = trip
                    }
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
            }
            // SPEC v1.5 F-4.2: 删除确认对话框
            .alert(
                localization.currentLanguage == .chinese ? "删除行程" : "Delete Trip",
                isPresented: $showingDeleteAlert
            ) {
                Button(localization.currentLanguage == .chinese ? "取消" : "Cancel", role: .cancel) {
                    tripToDelete = nil
                }
                Button(localization.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                    if let trip = tripToDelete {
                        deleteTripConfirmed(trip)
                    }
                }
            } message: {
                Text(localization.currentLanguage == .chinese
                     ? "删除后无法恢复，确认删除？"
                     : "This action cannot be undone. Are you sure?")
            }
        }
    }
    
    // SPEC v1.5 F-4.1: 删除 Trip（带确认）
    private func deleteTrip(_ trip: Trip) {
        tripToDelete = trip
        showingDeleteAlert = true
    }
    
    // SPEC v1.5 F-4.3: 确认删除
    private func deleteTripConfirmed(_ trip: Trip) {
        modelContext.delete(trip)
        try? modelContext.save()
        tripToDelete = nil
    }

    // PRD: Trip Archive Enhancement - 归档操作（无需确认）
    private func archiveTrip(_ trip: Trip) {
        trip.archive()
        try? modelContext.save()
    }

    // PRD: Trip Archive Enhancement - 取消归档操作（无需确认）
    private func unarchiveTrip(_ trip: Trip) {
        trip.unarchive()
        try? modelContext.save()
    }
}

#Preview {
    HomeView()
        .environmentObject(LocalizationManager.shared)
        .modelContainer(for: Trip.self, inMemory: true)
}
