//
//  CompactProgressBar.swift
//  SmartPack
//
//  滚动时顶部紧凑进度条
//

import SwiftUI

/// 紧凑进度条（滚动后显示在顶部）
struct CompactProgressBar: View {
    let trip: Trip
    let language: AppLanguage
    let destination: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(trip.isAllChecked ? AppColors.success : AppColors.primary)
                        .frame(width: max(0, geometry.size.width * trip.progress), height: 4)
                }
            }
            .frame(height: 4)

            Text("\(trip.checkedCount)/\(trip.totalCount)")
                .font(Typography.caption.weight(.semibold))
                .foregroundColor(trip.isAllChecked ? AppColors.success : AppColors.primary)
                .frame(minWidth: 28, alignment: .trailing)

            if !destination.isEmpty {
                Text(destination)
                    .font(Typography.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(AppColors.background)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
    }
}
