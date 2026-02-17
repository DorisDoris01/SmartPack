//
//  MyListsView.swift
//  SmartPack
//
//  [DEPRECATED] v1.2 清单列表功能已整合到 HomeView
//  此文件保留以兼容可能的旧引用
//

import SwiftUI
import SwiftData

/// [DEPRECATED] 请使用 HomeView
/// 此视图保留以兼容可能的旧引用
struct MyListsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localization: LocalizationManager
    
    @Query(sort: \Trip.createdAt, order: .reverse) private var trips: [Trip]
    
    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    emptyState
                } else {
                    listContent
                }
            }
            .navigationTitle(localization.currentLanguage == .chinese ? "我的清单" : "My Lists")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - 空状态
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "suitcase")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(localization.currentLanguage == .chinese
                 ? "还没有清单"
                 : "No lists yet")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(localization.currentLanguage == .chinese
                 ? "点击右下角 + 创建你的第一个打包清单"
                 : "Tap + to create your first packing list")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - 清单列表
    
    private var listContent: some View {
        List {
            ForEach(trips) { trip in
                NavigationLink {
                    PackingListView(trip: trip, isNewlyCreated: false)
                } label: {
                    TripRowView(trip: trip, language: localization.currentLanguage)
                }
            }
            .onDelete(perform: deleteTrips)
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - 删除
    
    private func deleteTrips(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(trips[index])
        }
    }
}

// TripRowView 已移至 HomeView.swift

#Preview {
    MyListsView()
        .environmentObject(LocalizationManager.shared)
        .modelContainer(for: [Trip.self, TripItem.self], inMemory: true)
}
