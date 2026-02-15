//
//  ProgressHeader.swift
//  SmartPack
//
//  打包清单组件 - 进度头部
//

import SwiftUI

/// 进度头部
struct ProgressHeader: View {
    let trip: Trip
    let language: AppLanguage

    var body: some View {
        VStack(spacing: Spacing.xs) {
            // PRD: Packing List UI Enhancement - 简化进度显示，将计数叠加在进度条上
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景进度条
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(Color(.systemGray5))
                        .frame(height: Spacing.sm)

                    // 填充进度条
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(trip.isAllChecked ? AppColors.success : AppColors.primary)
                        .frame(width: geometry.size.width * trip.progress, height: Spacing.sm)
                        .animation(.spring(response: 0.3), value: trip.progress)

                    // 计数文字叠加在进度条上（居中）
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(trip.checkedCount)/\(trip.totalCount)")
                                .font(Typography.caption.weight(.semibold))
                                .foregroundColor(trip.isAllChecked ? AppColors.success : AppColors.primary)
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 0.5)

                            // 已归档标签
                            if trip.isArchived {
                                Text(language == .chinese ? "已归档" : "Archived")
                                    .font(Typography.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.textSecondary.opacity(0.2))
                                    .cornerRadius(CornerRadius.sm)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: Spacing.sm)

            // 保留完成状态提示
            if trip.isAllChecked {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text(language == .chinese ? "全部打包完成！" : "All packed!")
                        .foregroundColor(AppColors.success)
                }
                .font(Typography.subheadline.bold())
                .padding(.vertical, Spacing.xxs)
            }
        }
        .padding(Spacing.sm) // 减小内边距使布局更紧凑
        .background(trip.isAllChecked ? AppColors.success.opacity(0.08) : AppColors.background)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(progressAccessibilityLabel)
    }
    
    private var progressAccessibilityLabel: String {
        if trip.isAllChecked {
            return language == .chinese ? "全部打包完成" : "All packed"
        }
        return language == .chinese
            ? "打包进度：已完成 \(trip.checkedCount) 件，共 \(trip.totalCount) 件"
            : "Progress: \(trip.checkedCount) of \(trip.totalCount) items packed"
    }
}
