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
                            // SPEC v1.5 F-4.1: Trip 横滑删除
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteTrip(trip)
                                } label: {
                                    Label(
                                        localization.currentLanguage == .chinese ? "删除" : "Delete",
                                        systemImage: "trash"
                                    )
                                }
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
                            // SPEC v1.5 F-4.1: Trip 横滑删除
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteTrip(trip)
                                } label: {
                                    Label(
                                        localization.currentLanguage == .chinese ? "删除" : "Delete",
                                        systemImage: "trash"
                                    )
                                }
                            }
                        }
                    }
                }
                
                // 空状态
                if trips.isEmpty {
                    Section {
                        VStack(spacing: 20) {
                            Image(systemName: "suitcase")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(localization.currentLanguage == .chinese ? "还没有行程" : "No trips yet")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text(localization.currentLanguage == .chinese
                                 ? "点击右上角 + 开始你的第一次行程"
                                 : "Tap + to start your first trip")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
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
}

#Preview {
    HomeView()
        .environmentObject(LocalizationManager.shared)
        .modelContainer(for: Trip.self, inMemory: true)
}
