//
//  SettingsView.swift
//  SmartPack
//
//  设置页：性别设置、语言切换等
//  PRD v1.2: 增加性别设置，可修改首次欢迎页的选择
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        List {
            // 性别设置 (PRD v1.2: F-4.2)
            Section {
                genderRow
            } header: {
                Text(localization.currentLanguage == .chinese ? "性别" : "Gender")
            } footer: {
                Text(localization.currentLanguage == .chinese
                     ? "修改后将影响后续新建清单的物品过滤"
                     : "Changes will affect items in future lists")
                    .font(Typography.caption)
            }
            
            // 语言设置
            Section {
                languageRow
            } header: {
                Text(localization.currentLanguage == .chinese ? "语言" : "Language")
            }
            
            // 关于
            Section {
                aboutRow
            } header: {
                Text(localization.currentLanguage == .chinese ? "关于" : "About")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(localization.currentLanguage == .chinese ? "设置" : "Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text(localization.currentLanguage == .chinese ? "完成" : "Done")
                        .font(Typography.body)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    // MARK: - 性别设置 (PRD v1.2)
    
    private var genderRow: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            Text(localization.currentLanguage == .chinese ? "性别" : "Gender")
                .font(Typography.body)

            Spacer()
            
            Picker("", selection: Binding(
                get: { localization.userGender },
                set: { localization.userGender = $0 }
            )) {
                ForEach(Gender.allCases) { gender in
                    Text(gender.displayName(language: localization.currentLanguage)).tag(gender)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    // MARK: - 语言切换
    
    private var languageRow: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            Text(localization.currentLanguage == .chinese ? "语言" : "Language")
                .font(Typography.body)

            Spacer()
            
            Picker("", selection: Binding(
                get: { localization.currentLanguage },
                set: { localization.currentLanguage = $0 }
            )) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayName).tag(language)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    // MARK: - 关于
    
    private var aboutRow: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                Text("SmartPack")
                    .font(Typography.headline)
                
                Spacer()
                
                Text(appVersion)
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(localization.currentLanguage == .chinese
                 ? "基于场景的智能打包清单助手"
                 : "Smart packing list assistant based on scenarios")
                .font(Typography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, Spacing.xxs)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? "v\(version)" : "v\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(LocalizationManager.shared)
    }
}
