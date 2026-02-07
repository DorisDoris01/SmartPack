//
//  ProgressHeader.swift
//  SmartPack
//
//  打包清单组件 - 进度头部
//

import SwiftUI

/// 进度头部
struct ProgressHeader: View {
    let trip: Trip
    let language: AppLanguage

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text(language == .chinese ? "打包进度" : "Progress")
                    .font(.headline)

                if trip.isArchived {
                    Text(language == .chinese ? "已归档" : "Archived")
                        .font(.caption)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(CornerRadius.sm)
                }

                Spacer()

                Text("\(trip.checkedCount)/\(trip.totalCount)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: Spacing.sm)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(trip.isAllChecked ? Color.green : Color.blue)
                        .frame(width: geometry.size.width * trip.progress, height: Spacing.sm)
                        .animation(.spring(response: 0.3), value: trip.progress)
                }
            }
            .frame(height: Spacing.sm)

            if trip.isAllChecked {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(language == .chinese ? "全部打包完成！" : "All packed!")
                        .foregroundColor(.green)
                }
                .font(.subheadline.bold())
            } else {
                let remaining = trip.totalCount - trip.checkedCount
                Text(language == .chinese
                     ? "还剩 \(remaining) 件物品"
                     : "\(remaining) items remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
