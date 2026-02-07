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
        VStack(spacing: Spacing.sm) {
            HStack {
                Text(language == .chinese ? "打包进度" : "Progress")
                    .font(Typography.headline)

                if trip.isArchived {
                    Text(language == .chinese ? "已归档" : "Archived")
                        .font(Typography.caption)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(AppColors.textSecondary.opacity(0.2))
                        .cornerRadius(CornerRadius.sm)
                }

                Spacer()

                Text("\(trip.checkedCount)/\(trip.totalCount)")
                    .font(Typography.headline)
                    .foregroundColor(AppColors.primary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(Color(.systemGray5))
                        .frame(height: Spacing.sm)

                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(trip.isAllChecked ? AppColors.success : AppColors.primary)
                        .frame(width: geometry.size.width * trip.progress, height: Spacing.sm)
                        .animation(.spring(response: 0.3), value: trip.progress)
                }
            }
            .frame(height: Spacing.sm)

            if trip.isAllChecked {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text(language == .chinese ? "全部打包完成！" : "All packed!")
                        .foregroundColor(AppColors.success)
                }
                .font(Typography.subheadline.bold())
                .padding(.vertical, Spacing.xxs)
            } else {
                let remaining = trip.totalCount - trip.checkedCount
                Text(language == .chinese
                     ? "还剩 \(remaining) 件物品"
                     : "\(remaining) items remaining")
                    .font(Typography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(trip.isAllChecked ? AppColors.success.opacity(0.08) : AppColors.background)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(progressAccessibilityLabel)
    }
    
    private var progressAccessibilityLabel: String {
        if trip.isAllChecked {
            return language == .chinese ? "全部打包完成" : "All packed"
        }
        let remaining = trip.totalCount - trip.checkedCount
        return language == .chinese
            ? "\(trip.checkedCount) 共 \(trip.totalCount) 件，还剩 \(remaining) 件"
            : "\(trip.checkedCount) of \(trip.totalCount) items packed, \(remaining) remaining"
    }
}
