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
    
    // 行程配置页
    case newTrip = "new_trip"
    case selectGender = "select_gender"
    case tripDuration = "trip_duration"
    case days = "days"
    case selectScenarios = "select_scenarios"
    case generateList = "generate_list"
    case selectAtLeastOneTag = "select_at_least_one_tag"
    
    // 清单页
    case packingList = "packing_list"
    case progress = "progress"
    case allPacked = "all_packed"
    case itemsRemaining = "items_remaining"
    case newList = "new_list"
    
    // 设置
    case settings = "settings"
    case language = "language"
    case gender = "gender"
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
    
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "has_completed_onboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "has_completed_onboarding") }
    }
    
    private init() {
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
    
    // MARK: - 本地化字符串表
    
    private let strings: [AppLanguage: [LocalizedKey: String]] = [
        .chinese: [
            .appName: "SmartPack",
            .confirm: "确定",
            .cancel: "取消",
            .done: "完成",
            
            .newTrip: "新建行程",
            .selectGender: "选择性别",
            .tripDuration: "出行时长",
            .days: "天",
            .selectScenarios: "选择场景",
            .generateList: "生成清单",
            .selectAtLeastOneTag: "请至少选择一个场景标签",
            
            .packingList: "打包清单",
            .progress: "打包进度",
            .allPacked: "全部打包完成！🎉",
            .itemsRemaining: "还剩 %d 件物品",
            .newList: "新建清单",
            
            .settings: "设置",
            .language: "语言"
        ],
        .english: [
            .appName: "SmartPack",
            .confirm: "Confirm",
            .cancel: "Cancel",
            .done: "Done",
            
            .newTrip: "New Trip",
            .selectGender: "Select Gender",
            .tripDuration: "Trip Duration",
            .days: "days",
            .selectScenarios: "Select Scenarios",
            .generateList: "Generate List",
            .selectAtLeastOneTag: "Please select at least one scenario",
            
            .packingList: "Packing List",
            .progress: "Progress",
            .allPacked: "All packed! 🎉",
            .itemsRemaining: "%d items remaining",
            .newList: "New List",
            
            .settings: "Settings",
            .language: "Language"
        ]
    ]
}

// MARK: - View Extension

extension View {
    func localized(_ key: LocalizedKey) -> String {
        LocalizationManager.shared.string(for: key)
    }
}
