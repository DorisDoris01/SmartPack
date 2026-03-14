//
//  LocalizationManager.swift
//  SmartPack
//
//  多语言管理器 & 用户偏好管理
//  PRD v1.2: 增加性别存储和首次启动标记
//

import Foundation
import SwiftUI
import Combine

/// App 语言
enum AppLanguage: String, CaseIterable, Identifiable {
    case chinese = "zh"
    case english = "en"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .chinese: return "中文"
        case .english: return "English"
        }
    }
}

/// 本地化字符串 Key
enum LocalizedKey: String {
    // 通用
    case appName = "app_name"
    case confirm = "confirm"
    case cancel = "cancel"
    case done = "done"
    case ok = "ok"
    case delete = "delete"
    case add = "add"
    case error = "error_title"
    case preset = "preset"
    case restore = "restore"
    case archive = "archive"
    case unarchive = "unarchive"
    case archived = "archived"
    case notNow = "not_now"
    case weather = "weather"
    case about = "about"
    case searchItems = "search_items"
    case cannotDelete = "cannot_delete"
    case getStarted = "get_started"

    // 首页
    case myTrips = "my_trips"
    case noTripsYet = "no_trips_yet"
    case noTripsHint = "no_trips_hint"
    case deleteTrip = "delete_trip"
    case deleteTripMessage = "delete_trip_message"
    case itemManagement = "item_management"

    // 行程配置页
    case newTrip = "new_trip"
    case selectGender = "select_gender"
    case tripDuration = "trip_duration"
    case days = "days"
    case selectScenarios = "select_scenarios"
    case generateList = "generate_list"
    case selectAtLeastOneTag = "select_at_least_one_tag"
    case tripDates = "trip_dates"
    case startDate = "start_date"
    case endDate = "end_date"
    case destination = "destination"
    case travelActivities = "travel_activities"
    case occasions = "occasions"
    case travelConfig = "travel_config"
    case creatingList = "creating_list"
    case generateTrip = "generate_trip"
    case creatingTrip = "creating_trip"
    case enterCityName = "enter_city_name"

    // 清单页
    case packingList = "packing_list"
    case progress = "progress"
    case allPacked = "all_packed"
    case itemsRemaining = "items_remaining"
    case newList = "new_list"
    case resetTrip = "reset_trip"
    case confirmReset = "confirm_reset"
    case resetTripMessage = "reset_trip_message"
    case archiveTrip = "archive_trip"
    case archiveTripMessage = "archive_trip_message"
    case addItem = "add_item"
    case addItemPlaceholder = "add_item_placeholder"
    case checkedHint = "checked_hint"
    case uncheckedHint = "unchecked_hint"

    // 物品管理
    case itemManagementTitle = "item_management_title"
    case itemName = "item_name"
    case enterItemName = "enter_item_name"
    case deleteConstraintMessage = "delete_constraint_message"
    case itemExistsOrEmpty = "item_exists_or_empty"

    // 欢迎页
    case welcomeSubtitle = "welcome_subtitle"
    case selectYourGender = "select_your_gender"

    // 设置
    case settings = "settings"
    case language = "language"
    case gender = "gender"
    case genderFooter = "gender_footer"
    case appDescription = "app_description"
}

/// 本地化管理器 & 用户偏好管理
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    // MARK: - 语言设置
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
        }
    }
    
    // MARK: - 性别设置 (PRD v1.2)
    
    @Published var userGender: Gender {
        didSet {
            UserDefaults.standard.set(userGender.rawValue, forKey: "user_gender")
        }
    }
    
    // MARK: - 首次启动标记 (PRD v1.2)

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "has_completed_onboarding")
        }
    }
    
    private init() {
        // 从 UserDefaults 读取首次启动标记
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "has_completed_onboarding")

        // 从 UserDefaults 读取保存的语言，默认跟随系统
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // 根据系统语言自动选择
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = systemLanguage.hasPrefix("zh") ? .chinese : .english
        }

        // 从 UserDefaults 读取保存的性别，默认男性
        if let savedGender = UserDefaults.standard.string(forKey: "user_gender"),
           let gender = Gender(rawValue: savedGender) {
            self.userGender = gender
        } else {
            self.userGender = .male
        }
    }
    
    /// 获取本地化字符串
    func string(for key: LocalizedKey) -> String {
        return strings[currentLanguage]?[key] ?? key.rawValue
    }
    
    /// 切换语言
    func toggleLanguage() {
        currentLanguage = currentLanguage == .chinese ? .english : .chinese
    }

    /// 根据当前语言返回对应的文本（简化的本地化辅助方法）
    func text(chinese: String, english: String) -> String {
        return currentLanguage == .chinese ? chinese : english
    }

    // MARK: - 本地化字符串表
    
    private let strings: [AppLanguage: [LocalizedKey: String]] = [
        .chinese: [
            // 通用
            .appName: "HeyPackie",
            .confirm: "确定",
            .cancel: "取消",
            .done: "完成",
            .ok: "确定",
            .delete: "删除",
            .add: "添加",
            .error: "错误",
            .preset: "预设",
            .restore: "恢复",
            .archive: "归档",
            .unarchive: "取消归档",
            .archived: "已归档",
            .notNow: "暂不归档",
            .weather: "天气",
            .about: "关于",
            .searchItems: "搜索物品",
            .cannotDelete: "无法删除",
            .getStarted: "开始使用",

            // 首页
            .myTrips: "我的行程",
            .noTripsYet: "还没有行程",
            .noTripsHint: "点击右上角 + 开始你的第一次行程",
            .deleteTrip: "删除行程",
            .deleteTripMessage: "删除后无法恢复，确认删除？",
            .itemManagement: "物品管理",

            // 行程配置页
            .newTrip: "新建行程",
            .selectGender: "选择性别",
            .tripDuration: "出行时长",
            .days: "天",
            .selectScenarios: "选择场景",
            .generateList: "生成清单",
            .selectAtLeastOneTag: "请至少选择一个场景标签",
            .tripDates: "出行时间",
            .startDate: "出发日期",
            .endDate: "返回日期",
            .destination: "目的地",
            .travelActivities: "旅行活动",
            .occasions: "特定场合",
            .travelConfig: "出行配置",
            .creatingList: "正在生成…",
            .generateTrip: "生成行程",
            .creatingTrip: "正在创建行程",
            .enterCityName: "输入城市名称",

            // 清单页
            .packingList: "打包清单",
            .progress: "打包进度",
            .allPacked: "全部打包完成！🎉",
            .itemsRemaining: "还剩 %d 件物品",
            .newList: "新建清单",
            .resetTrip: "重置行程",
            .confirmReset: "确认重置",
            .resetTripMessage: "将清空所有已勾选的物品，确认继续？",
            .archiveTrip: "归档行程",
            .archiveTripMessage: "归档后的行程将在列表底部显示，方便下次复用。",
            .addItem: "添加物品",
            .addItemPlaceholder: "添加物品...",
            .checkedHint: "已勾选，双击取消",
            .uncheckedHint: "未勾选，双击勾选",

            // 物品管理
            .itemManagementTitle: "Item 管理",
            .itemName: "物品名称",
            .enterItemName: "输入物品名称",
            .deleteConstraintMessage: "每个标签至少需要保留一个物品。",
            .itemExistsOrEmpty: "物品名称已存在或为空",

            // 欢迎页
            .welcomeSubtitle: "基于场景的智能行程助手\n帮你减少出行遗漏",
            .selectYourGender: "选择你的性别",

            // 设置
            .settings: "设置",
            .language: "语言",
            .gender: "性别",
            .genderFooter: "修改后将影响后续新建清单的物品过滤",
            .appDescription: "基于场景的智能打包清单助手",
        ],
        .english: [
            // 通用
            .appName: "HeyPackie",
            .confirm: "Confirm",
            .cancel: "Cancel",
            .done: "Done",
            .ok: "OK",
            .delete: "Delete",
            .add: "Add",
            .error: "Error",
            .preset: "Preset",
            .restore: "Restore",
            .archive: "Archive",
            .unarchive: "Unarchive",
            .archived: "Archived",
            .notNow: "Not Now",
            .weather: "Weather",
            .about: "About",
            .searchItems: "Search items",
            .cannotDelete: "Cannot Delete",
            .getStarted: "Get Started",

            // 首页
            .myTrips: "My Trips",
            .noTripsYet: "No trips yet",
            .noTripsHint: "Tap + to start your first trip",
            .deleteTrip: "Delete Trip",
            .deleteTripMessage: "This action cannot be undone. Are you sure?",
            .itemManagement: "Item Management",

            // 行程配置页
            .newTrip: "New Trip",
            .selectGender: "Select Gender",
            .tripDuration: "Trip Duration",
            .days: "days",
            .selectScenarios: "Select Scenarios",
            .generateList: "Generate List",
            .selectAtLeastOneTag: "Please select at least one scenario",
            .tripDates: "Trip Dates",
            .startDate: "Start Date",
            .endDate: "End Date",
            .destination: "Destination",
            .travelActivities: "Travel Activities",
            .occasions: "Occasions",
            .travelConfig: "Travel Config",
            .creatingList: "Creating list…",
            .generateTrip: "Generate Trip",
            .creatingTrip: "Creating your trip",
            .enterCityName: "Enter city name",

            // 清单页
            .packingList: "Packing List",
            .progress: "Progress",
            .allPacked: "All packed! 🎉",
            .itemsRemaining: "%d items remaining",
            .newList: "New List",
            .resetTrip: "Reset Trip",
            .confirmReset: "Reset",
            .resetTripMessage: "This will uncheck all items. Continue?",
            .archiveTrip: "Archive Trip",
            .archiveTripMessage: "Archived trips will be shown at the bottom of the list for easy reuse.",
            .addItem: "Add Item",
            .addItemPlaceholder: "Add item...",
            .checkedHint: "Checked, double tap to uncheck",
            .uncheckedHint: "Unchecked, double tap to check",

            // 物品管理
            .itemManagementTitle: "Item Management",
            .itemName: "Item Name",
            .enterItemName: "Enter item name",
            .deleteConstraintMessage: "Each tag must have at least one item.",
            .itemExistsOrEmpty: "Item name already exists or is empty",

            // 欢迎页
            .welcomeSubtitle: "Smart trip packing assistant\nNever forget essentials again",
            .selectYourGender: "Select your gender",

            // 设置
            .settings: "Settings",
            .language: "Language",
            .gender: "Gender",
            .genderFooter: "Changes will affect items in future lists",
            .appDescription: "Smart packing list assistant based on scenarios",
        ]
    ]
}

// MARK: - View Extension

extension View {
    func localized(_ key: LocalizedKey) -> String {
        LocalizationManager.shared.string(for: key)
    }
}
