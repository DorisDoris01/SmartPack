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

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 进度圆环
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: Spacing.xxs)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: trip.progress)
                    .stroke(
                        trip.isAllChecked ? AppColors.success : AppColors.primary,
                        style: StrokeStyle(lineWidth: Spacing.xxs, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: trip.progress)

                if trip.isAllChecked {
                    Image(systemName: "checkmark")
                        .font(Typography.caption.bold())
                        .foregroundColor(AppColors.success)
                }
            }
            .opacity(isArchived ? 0.6 : 1)

            // 行程信息
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(trip.name)
                    .font(Typography.headline)
                    .foregroundColor(isArchived ? AppColors.textSecondary : AppColors.text)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Text(trip.formattedDate(language: language))
                        .font(Typography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Text("·")
                        .foregroundColor(AppColors.textSecondary)

                    Text("\(trip.checkedCount)/\(trip.totalCount)")
                        .font(Typography.caption)
                        .foregroundColor(trip.isAllChecked ? AppColors.success : AppColors.textSecondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(trip.name), \(trip.checkedCount) of \(trip.totalCount) items packed")

            Spacer()
        }
        .padding(.vertical, Spacing.xxs)
    }
}
