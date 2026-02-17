//
//  CompactProgressBar.swift
//  SmartPack
//
//  滚动时顶部紧凑进度条 — 进度条 + 毛玻璃浮动
//

import SwiftUI

/// 紧凑进度条（滚动后浮动在顶部）
struct CompactProgressBar: View {
    let trip: Trip
    let language: AppLanguage

    private var barColor: Color {
        trip.isAllChecked ? AppColors.success : AppColors.primary
    }

    private var percentage: Int {
        trip.totalCount > 0 ? Int(trip.progress * 100) : 0
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 进度条 + 百分比叠加
            GeometryReader { geo in
                let fillWidth = geo.size.width * trip.progress
                let barY = geo.size.height / 2

                // 轨道
                Capsule()
                    .fill(AppColors.secondary.opacity(0.12))
                    .frame(width: geo.size.width, height: 4)
                    .position(x: geo.size.width / 2, y: barY)

                // 填充
                if trip.progress > 0 {
                    Capsule()
                        .fill(barColor)
                        .frame(width: fillWidth, height: 4)
                        .position(x: fillWidth / 2, y: barY)
                }

                // 百分比文字
                if percentage > 0 && !trip.isAllChecked {
                    Text("\(percentage)%")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(barColor)
                        .shadow(color: AppColors.background.opacity(0.9), radius: 1)
                        .position(
                            x: trip.progress <= 0.15
                                ? max(fillWidth / 2, 12)
                                : min(fillWidth, geo.size.width - 12),
                            y: barY
                        )
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 14)

            // 计数
            Text("\(trip.checkedCount)/\(trip.totalCount)")
                .font(Typography.caption.weight(.semibold))
                .foregroundColor(barColor)
                .fixedSize()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal, Spacing.md)
    }
}
