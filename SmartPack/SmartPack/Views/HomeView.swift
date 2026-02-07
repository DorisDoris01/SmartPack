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

// MARK: - 行程行视图

struct TripRowView: View {
    let trip: Trip
    let language: AppLanguage
    var isArchived: Bool = false
    
    var body: some View {
        HStack(spacing: 14) {
            // 进度圆环
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: trip.progress)
                    .stroke(
                        trip.isAllChecked ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                
                if trip.isAllChecked {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                }
            }
            .opacity(isArchived ? 0.6 : 1)
            
            // 行程信息
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name)
                    .font(.headline)
                    .foregroundColor(isArchived ? .secondary : .primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(trip.formattedDate(language: language))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text("\(trip.checkedCount)/\(trip.totalCount)")
                        .font(.caption)
                        .foregroundColor(trip.isAllChecked ? .green : .secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 创建行程 Sheet

struct CreateTripSheet: View {
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    var onTripCreated: (Trip) -> Void
    
    @State private var tripConfig = TripConfig()
    
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    dateRangeSection
                    destinationSection
                    tagSection
                    generateButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(localization.currentLanguage == .chinese ? "新建行程" : "New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                    }
                }
            }
        }
    }
    
    // MARK: - SPEC: 出行时间（日期选择器）
    
    private var dateRangeSection: some View {
        SectionCard(
            title: localization.currentLanguage == .chinese ? "出行时间" : "Trip Dates",
            icon: "calendar"
        ) {
            VStack(spacing: 16) {
                DatePicker(
                    localization.currentLanguage == .chinese ? "出发日期" : "Start Date",
                    selection: $startDate,
                    displayedComponents: .date
                )
                
                DatePicker(
                    localization.currentLanguage == .chinese ? "返回日期" : "End Date",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: .date
                )
                
                if endDate >= startDate {
                    let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                    Text(localization.currentLanguage == .chinese ? "共 \(days + 1) 天" : "\(days + 1) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - SPEC: 目的地（城市选择器）
    
    private var destinationSection: some View {
        SectionCard(
            title: localization.currentLanguage == .chinese ? "目的地" : "Destination",
            icon: "mappin.circle"
        ) {
            TextField(
                localization.currentLanguage == .chinese ? "输入城市名称" : "Enter city name",
                text: $tripConfig.destination
            )
        }
    }
    
    // MARK: - SPEC: 标签选择（三组）
    
    private var tagSection: some View {
        VStack(spacing: 16) {
            // 旅行活动
            SectionCard(
                title: localization.currentLanguage == .chinese ? "旅行活动" : "Travel Activities",
                icon: "figure.run"
            ) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
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
        Button {
            createAndSaveTrip()
        } label: {
            Text(localization.currentLanguage == .chinese ? "生成行程" : "Generate Trip")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding(.top, 8)
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
        
        var items = PresetData.shared.generatePackingList(
            tagIds: tripConfig.allSelectedTags,
            gender: tripConfig.gender
        )
        
        let name = tripConfig.generateListName(language: localization.currentLanguage)
        
        // 计算 duration（兼容旧模型，根据天数映射）
        let duration: TripDuration
        if let dateRange = tripConfig.dateRange {
            duration = dateRange.toTripDuration()
        } else {
            duration = .medium // 默认值
        }
        
        // SPEC: Weather Integration v1.0 - 查询天气并调整物品
        Task {
            var weatherForecasts: [WeatherForecast] = []
            
            // 如果有目的地和日期范围，查询天气
            if !tripConfig.destination.isEmpty,
               let dateRange = tripConfig.dateRange {
                do {
                    weatherForecasts = try await WeatherService.shared.fetchWeatherForecast(
                        city: tripConfig.destination,
                        startDate: dateRange.startDate,
                        endDate: dateRange.endDate
                    )
                    
                    // 根据天气调整物品
                    items = WeatherService.shared.adjustItemsForWeather(
                        items: items,
                        forecasts: weatherForecasts
                    )
                } catch {
                    // 天气查询失败不影响创建行程，使用空数组
                    print("Weather fetch failed: \(error.localizedDescription)")
                }
            }
            
            // 在主线程创建 Trip
            await MainActor.run {
                let trip = Trip(
                    name: name,
                    gender: tripConfig.gender,
                    duration: duration,
                    selectedTags: Array(tripConfig.allSelectedTags),
                    items: items,
                    destination: tripConfig.destination,
                    startDate: tripConfig.dateRange?.startDate,
                    endDate: tripConfig.dateRange?.endDate,
                    weatherForecasts: weatherForecasts
                )
                
                modelContext.insert(trip)
                onTripCreated(trip)
            }
        }
    }
}

// MARK: - 带文案的标签按钮

struct LabeledTagButton: View {
    let tag: Tag
    let isSelected: Bool
    let language: AppLanguage
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tag.icon)
                    .font(.title3)
                
                Text(tag.displayName(language: language))
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(LocalizationManager.shared)
        .modelContainer(for: Trip.self, inMemory: true)
}
