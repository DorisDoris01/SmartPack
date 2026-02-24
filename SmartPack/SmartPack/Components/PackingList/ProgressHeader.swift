//
//  ProgressHeader.swift
//  SmartPack
//
//  打包清单组件 - 进度条（常规 / 浮动两种密度）
//

import SwiftUI

/// 进度条 — 常规模式：厚条+计数叠加；浮动模式：纯细条
struct ProgressHeader: View {
    let trip: Trip
    let language: AppLanguage
    var isFloating: Bool = false

    @State private var animatedProgress: Double = 0

    private var barColor: Color {
        trip.isAllChecked ? AppColors.success : AppColors.primary
    }

    private var countText: String {
        if trip.isAllChecked {
            return language == .chinese ? "全部打包完成！" : "All packed!"
        }
        return "\(trip.checkedCount)/\(trip.totalCount)"
    }

    var body: some View {
        Group {
            if isFloating {
                floatingBar
            } else {
                normalBar
            }
        }
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

    // MARK: - 常规模式：24pt 厚条 + 计数文字叠加

    @ViewBuilder
    private var normalBar: some View {
        VStack(spacing: Spacing.xxs) {
            progressCapsule(height: 24, showCount: true)

            if trip.isArchived {
                HStack {
                    Text(language == .chinese ? "已归档" : "Archived")
                        .font(Typography.caption2)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(AppColors.textSecondary.opacity(0.12))
                        .clipShape(Capsule())
                    Spacer()
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.xxs)
        .padding(.bottom, Spacing.xs)
        .frame(maxWidth: .infinity)
    }

    // MARK: - 浮动模式：4pt 细条，无文字

    @ViewBuilder
    private var floatingBar: some View {
        progressCapsule(height: 4, showCount: false)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }

    // MARK: - 共享：进度胶囊条

    @ViewBuilder
    private func progressCapsule(height: CGFloat, showCount: Bool) -> some View {
        GeometryReader { geo in
            let fillWidth = geo.size.width * animatedProgress
            let barY = geo.size.height / 2

            // 轨道
            Capsule()
                .fill(AppColors.secondary.opacity(0.12))
                .frame(width: geo.size.width, height: height)
                .position(x: geo.size.width / 2, y: barY)

            // 填充
            if animatedProgress > 0 {
                Capsule()
                    .fill(barColor)
                    .frame(width: fillWidth, height: height)
                    .position(x: fillWidth / 2, y: barY)
            }

            // 计数文字（仅常规模式）
            if showCount {
                Text(countText)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(animatedProgress > 0.5 ? Color.white : barColor)
                    .shadow(color: AppColors.background.opacity(0.8), radius: 1)
                    .position(x: geo.size.width / 2, y: barY)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: height)
    }

    // MARK: - 无障碍

    private var progressAccessibilityLabel: String {
        if trip.isAllChecked {
            return language == .chinese ? "全部打包完成" : "All packed"
        }
        return language == .chinese
            ? "打包进度：已完成 \(trip.checkedCount) 件，共 \(trip.totalCount) 件"
            : "Progress: \(trip.checkedCount) of \(trip.totalCount) items packed"
    }
}
