//
//  TagButton.swift
//  SmartPack
//
//  通用组件 - 标签选择按钮 (PRD v1.2: 仅图标，去掉文案)
//

import SwiftUI

/// 标签选择按钮
struct TagButton: View {
    let tag: Tag
    let isSelected: Bool
    let language: AppLanguage
    let action: () -> Void

    // 统一按钮尺寸 (PRD v1.2 UI 规范)
    private let buttonSize: CGFloat = 60

    var body: some View {
        Button(action: action) {
            Image(systemName: tag.icon)
                .font(Typography.title2)
                .frame(width: buttonSize, height: buttonSize)
                .background(isSelected ? AppColors.primary : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(CornerRadius.lg)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tag.displayName(language: language))
    }
}
