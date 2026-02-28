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

    private let ringSize: CGFloat = 38
    private let ringStroke: CGFloat = 2.5

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // 行程名 — 最多 2 行，右侧留出圆环空间
            Text(trip.name)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .tracking(Typography.Tracking.tight)
                .foregroundColor(isArchived ? AppColors.textSecondary : AppColors.text)
                .lineLimit(2)
                .padding(.trailing, ringSize + Spacing.sm)

            // U1: 出发日期（非创建日期）
            Text(trip.formattedStartDate(language: language))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .tracking(Typography.Tracking.wide)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(trip.name), \(trip.checkedCount) of \(trip.totalCount) items packed")
        .overlay(alignment: .topTrailing) {
            // 进度圆环 — 38pt corner badge
            ZStack {
                Circle()
                    .stroke(AppColors.secondary.opacity(0.12), lineWidth: ringStroke)
                    .frame(width: ringSize, height: ringSize)

                Circle()
                    .trim(from: 0, to: appeared ? trip.progress : 0)
                    .stroke(
                        trip.isAllChecked ? AppColors.success : AppColors.primary,
                        style: StrokeStyle(lineWidth: ringStroke, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))

                if trip.isAllChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.success)
                } else {
                    Text("\(Int(trip.progress * 100))")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .opacity(isArchived ? 0.6 : 1)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                .fill(AppColors.cardBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
        .onAppear {
            withAnimation(PremiumAnimation.standard) {
                appeared = true
            }
        }
    }
}
