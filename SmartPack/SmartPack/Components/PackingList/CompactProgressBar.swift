//
//  CompactProgressBar.swift
//  SmartPack
//
//  滚动时顶部紧凑进度条 — 迷你环形 + 毛玻璃
//

import SwiftUI

/// 紧凑进度条（滚动后浮动在顶部）
struct CompactProgressBar: View {
    let trip: Trip
    let language: AppLanguage
    let destination: String

    private var ringColor: Color {
        trip.isAllChecked ? AppColors.success : AppColors.primary
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 迷你环形进度
            ZStack {
                Circle()
                    .stroke(AppColors.secondary.opacity(0.12), lineWidth: 2)
                    .frame(width: 20, height: 20)

                Circle()
                    .trim(from: 0, to: trip.progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(-90))
            }

            Text("\(trip.checkedCount)/\(trip.totalCount)")
                .font(Typography.caption.weight(.semibold))
                .foregroundColor(ringColor)

            if !destination.isEmpty {
                Text(destination)
                    .font(Typography.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()
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
