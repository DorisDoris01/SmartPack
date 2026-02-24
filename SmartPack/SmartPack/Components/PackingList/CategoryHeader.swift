//
//  CategoryHeader.swift
//  SmartPack
//
//  打包清单组件 - 分类头部（iOS Reminders 风格）
//

import SwiftUI

/// 分类头部 — Reminders 风格
struct CategoryHeader: View {
    let category: String
    let checkedCount: Int
    let totalCount: Int
    let icon: String
    let isExpanded: Bool
    let language: AppLanguage
    let accentColor: Color
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: Spacing.xs) {
                // 图标圆圈背景
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 28, height: 28)

                    Image(systemName: icon)
                        .font(Typography.footnote)
                        .foregroundColor(accentColor)
                }

                Text(category)
                    .font(Typography.title3)
                    .foregroundColor(AppColors.text)

                // 计数
                Text("\(checkedCount)/\(totalCount)")
                    .font(Typography.footnote)
                    .foregroundColor(Color(.systemGray))

                Spacer()

                // 旋转展开箭头
                Image(systemName: "chevron.right")
                    .font(Typography.footnote)
                    .foregroundColor(Color(.systemGray2))
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(PremiumAnimation.snappy, value: isExpanded)
            }
            .padding(.vertical, Spacing.xxs)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category), \(checkedCount) of \(totalCount) items")
        .accessibilityHint(isExpanded
            ? (language == .chinese ? "双击折叠" : "Double tap to collapse")
            : (language == .chinese ? "双击展开" : "Double tap to expand"))
    }
}
