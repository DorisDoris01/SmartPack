//
//  ItemRow.swift
//  SmartPack
//
//  打包清单组件 - 物品行（iOS Reminders 风格圆形复选框）
//

import SwiftUI

/// 物品行 — 模仿 iOS Reminders
struct ItemRow: View {
    let item: TripItem
    let language: AppLanguage
    let accentColor: Color
    let onToggle: () -> Void
    let onDelete: () -> Void

    @EnvironmentObject var localization: LocalizationManager
    @State private var checkboxScale: CGFloat = 1.0

    private let circleSize: CGFloat = 22

    var body: some View {
        Button {
            HapticFeedback.light()
            withAnimation(PremiumAnimation.snappy) {
                checkboxScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(PremiumAnimation.snappy) {
                    checkboxScale = 1.0
                }
            }
            onToggle()
        } label: {
            HStack(spacing: Spacing.sm) {
                // 圆形复选框 — Reminders 风格
                ZStack {
                    Circle()
                        .stroke(
                            item.isChecked ? accentColor : Color(.systemGray3),
                            lineWidth: 1.5
                        )
                        .frame(width: circleSize, height: circleSize)

                    if item.isChecked {
                        Circle()
                            .fill(accentColor)
                            .frame(width: circleSize, height: circleSize)

                        Image(systemName: "checkmark")
                            .font(Typography.caption2)
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(checkboxScale)

                // 物品名称
                Text(item.displayName(language: language))
                    .font(Typography.body)
                    .foregroundColor(item.isChecked ? Color(.systemGray) : AppColors.text)
                    .strikethrough(item.isChecked, color: Color(.systemGray3))

                Spacer()
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                HapticFeedback.light()
                onDelete()
            } label: {
                Label(
                    localization.currentLanguage == .chinese ? "删除" : "Delete",
                    systemImage: "trash"
                )
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(
                    localization.currentLanguage == .chinese ? "删除" : "Delete",
                    systemImage: "trash"
                )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.displayName(language: language))
        .accessibilityHint(item.isChecked
            ? (localization.currentLanguage == .chinese ? "已勾选，双击取消" : "Checked, double tap to uncheck")
            : (localization.currentLanguage == .chinese ? "未勾选，双击勾选" : "Unchecked, double tap to check"))
    }
}
