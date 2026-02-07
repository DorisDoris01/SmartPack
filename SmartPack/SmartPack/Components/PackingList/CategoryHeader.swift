//
//  CategoryHeader.swift
//  SmartPack
//
//  打包清单组件 - 分类头部
//

import SwiftUI

/// 分类头部
struct CategoryHeader: View {
    let category: String
    let checkedCount: Int
    let totalCount: Int
    let icon: String
    let isExpanded: Bool
    let language: AppLanguage
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .font(Typography.subheadline)

                Text(category)
                    .font(Typography.headline)
                    .foregroundColor(AppColors.text)

                Spacer()

                Text("\(checkedCount)/\(totalCount)")
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)

                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(Typography.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category), \(checkedCount) of \(totalCount) items")
        .accessibilityHint(isExpanded ? (language == .chinese ? "双击折叠" : "Double tap to collapse") : (language == .chinese ? "双击展开" : "Double tap to expand"))
    }
}
