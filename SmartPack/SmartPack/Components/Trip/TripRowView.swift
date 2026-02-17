//
//  TripRowView.swift
//  SmartPack
//
//  行程组件 - 行程行视图
//

import SwiftUI

/// 行程行视图
struct TripRowView: View {
    let trip: Trip
    let language: AppLanguage
    var isArchived: Bool = false

    @State private var appeared = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            // 进度圆环 — 48pt, 3pt stroke
            ZStack {
                Circle()
                    .stroke(AppColors.secondary.opacity(0.15), lineWidth: 3)
                    .frame(width: 48, height: 48)

                Circle()
                    .trim(from: 0, to: appeared ? trip.progress : 0)
                    .stroke(
                        trip.isAllChecked ? AppColors.success : AppColors.primary,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))

                if trip.isAllChecked {
                    Image(systemName: "checkmark")
                        .font(Typography.caption.bold())
                        .foregroundColor(AppColors.success)
                } else {
                    Text("\(Int(trip.progress * 100))")
                        .font(Typography.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .opacity(isArchived ? 0.6 : 1)
            .onAppear {
                withAnimation(PremiumAnimation.standard) {
                    appeared = true
                }
            }

            // 行程信息
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(trip.name)
                    .font(Typography.headline)
                    .tracking(Typography.Tracking.tight)
                    .foregroundColor(isArchived ? AppColors.textSecondary : AppColors.text)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Text(trip.formattedDate(language: language))
                        .font(Typography.caption)
                        .tracking(Typography.Tracking.wide)
                        .foregroundColor(AppColors.textSecondary)

                    // Thin vertical bar separator
                    RoundedRectangle(cornerRadius: 0.5)
                        .fill(AppColors.textSecondary.opacity(0.3))
                        .frame(width: 1, height: 10)

                    Text("\(trip.checkedCount)/\(trip.totalCount)")
                        .font(Typography.caption)
                        .tracking(Typography.Tracking.wide)
                        .foregroundColor(trip.isAllChecked ? AppColors.success : AppColors.textSecondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(trip.name), \(trip.checkedCount) of \(trip.totalCount) items packed")

            Spacer()

            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(Typography.footnote)
                .foregroundColor(AppColors.textSecondary.opacity(0.4))
        }
        .padding(Spacing.cardPadding)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
    }
}
