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
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.subheadline)

                Text(category)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(checkedCount)/\(totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
