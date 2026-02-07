//
//  SearchBar.swift
//  SmartPack
//
//  通用组件 - 搜索栏
//

import SwiftUI

/// 搜索栏组件
struct SearchBar: View {
    @Binding var text: String
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(
                localization.currentLanguage == .chinese ? "搜索物品" : "Search items",
                text: $text
            )

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color(.systemGray6))
        .cornerRadius(CornerRadius.md)
    }
}
