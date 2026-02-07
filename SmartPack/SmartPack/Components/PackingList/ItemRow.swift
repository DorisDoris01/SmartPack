//
//  ItemRow.swift
//  SmartPack
//
//  打包清单组件 - 物品行（SPEC v1.7: 使用 List 原生样式）
//

import SwiftUI

/// 物品行
struct ItemRow: View {
    let item: TripItem
    let language: AppLanguage
    let onToggle: () -> Void
    let onDelete: () -> Void

    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 复选框（左侧）
            Button {
                onToggle()
            } label: {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isChecked ? .green : .gray)
            }
            .buttonStyle(.plain)

            // Item 名称（可点击整行）
            Text(item.displayName(language: language))
                .font(.body)
                .foregroundColor(item.isChecked ? .secondary : .primary)
                .strikethrough(item.isChecked, color: .secondary)

            Spacer()
        }
        .padding(.vertical, Spacing.xxs)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        // SPEC v1.7 F-1.1: 横滑删除
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(localization.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
            }
        }
    }
}
