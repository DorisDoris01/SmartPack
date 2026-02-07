//
//  SectionCard.swift
//  SmartPack
//
//  通用组件 - Section 卡片容器
//

import SwiftUI

/// Section 卡片容器
struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: Spacing.lg)
                Text(title)
                    .font(.headline)
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(CornerRadius.lg)
    }
}
