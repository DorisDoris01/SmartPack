//
//  LabeledTagButton.swift
//  SmartPack
//
//  行程组件 - 带文案的标签按钮
//

import SwiftUI

/// 带文案的标签按钮
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
