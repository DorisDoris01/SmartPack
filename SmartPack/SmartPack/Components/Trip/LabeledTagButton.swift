//
//  LabeledTagButton.swift
//  SmartPack
//
//  行程组件 - 带文案的标签按钮
//

import SwiftUI

/// 带文案的标签按钮（支持文本换行）
struct LabeledTagButton: View {
    let tag: Tag
    let isSelected: Bool
    let language: AppLanguage
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tag.icon)
                    .font(Typography.title3)
                    .frame(height: 24) // 固定图标高度

                Text(tag.displayName(language: language))
                    .font(Typography.caption)
                    .lineLimit(2) // 允许最多2行
                    .multilineTextAlignment(.center) // 居中对齐
                    .minimumScaleFactor(0.9) // 允许轻微缩小以适应空间
                    .fixedSize(horizontal: false, vertical: true) // 垂直方向自适应
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 70) // 最小高度70，支持扩展
            .padding(.vertical, 8) // 添加垂直内边距
            .padding(.horizontal, 4) // 添加水平内边距
            .background(isSelected ? AppColors.primary : AppColors.cardBackground)
            .foregroundColor(isSelected ? .white : AppColors.text)
            .cornerRadius(CornerRadius.lg)
        }
        .buttonStyle(.plain)
    }
}
