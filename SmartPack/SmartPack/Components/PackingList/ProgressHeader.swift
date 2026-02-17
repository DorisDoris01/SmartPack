//
//  ProgressHeader.swift
//  SmartPack
//
//  打包清单组件 - 环形进度英雄卡片
//

import SwiftUI

/// 环形进度英雄卡片
struct ProgressHeader: View {
    let trip: Trip
    let language: AppLanguage
    let categories: [ItemCategory]

    @State private var animatedProgress: Double = 0

    private var ringColor: Color {
        trip.isAllChecked ? AppColors.success : AppColors.primary
    }

    private var percentage: Int {
        trip.totalCount > 0 ? Int(trip.progress * 100) : 0
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // 环形进度
            ZStack {
                // 轨道
                Circle()
                    .stroke(AppColors.secondary.opacity(0.12), lineWidth: 6)
                    .frame(width: 80, height: 80)

                // 填充
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                // 中心内容
                if trip.isAllChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.success)
                } else {
                    Text("\(percentage)%")
                        .font(Typography.title1)
                        .foregroundColor(AppColors.text)
                }
            }

            // 分类色点
            if !categories.isEmpty {
                HStack(spacing: Spacing.xs) {
                    ForEach(categories, id: \.self) { cat in
                        Circle()
                            .fill(cat.accentColor)
                            .frame(width: 6, height: 6)
                    }
                }
            }

            // 计数文字
            if trip.isAllChecked {
                Text(language == .chinese ? "全部打包完成！" : "All packed!")
                    .font(Typography.caption)
                    .foregroundColor(AppColors.success)
            } else {
                Text(language == .chinese
                     ? "\(trip.checkedCount) / \(trip.totalCount) 件物品"
                     : "\(trip.checkedCount) of \(trip.totalCount) items")
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            // 归档标签
            if trip.isArchived {
                Text(language == .chinese ? "已归档" : "Archived")
                    .font(Typography.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxs)
                    .background(AppColors.textSecondary.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(Spacing.cardPadding)
        .frame(maxWidth: .infinity)
        .elevatedCard()
        .onAppear {
            withAnimation(PremiumAnimation.standard) {
                animatedProgress = trip.progress
            }
        }
        .onChange(of: trip.progress) { _, newValue in
            withAnimation(PremiumAnimation.snappy) {
                animatedProgress = newValue
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(progressAccessibilityLabel)
    }

    private var progressAccessibilityLabel: String {
        if trip.isAllChecked {
            return language == .chinese ? "全部打包完成" : "All packed"
        }
        return language == .chinese
            ? "打包进度：已完成 \(trip.checkedCount) 件，共 \(trip.totalCount) 件，\(percentage) 百分比"
            : "Progress: \(trip.checkedCount) of \(trip.totalCount) items packed, \(percentage) percent"
    }
}
