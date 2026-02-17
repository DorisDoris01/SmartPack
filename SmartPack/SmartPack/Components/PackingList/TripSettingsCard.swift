//
//  TripSettingsCard.swift
//  SmartPack
//
//  PRD: Packing List UI Enhancement - Trip 基本设置展示组件
//

import SwiftUI
import SwiftData

/// Trip 基本设置卡片 - 显示行程日期和场景标签
struct TripSettingsCard: View {
    let trip: Trip
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 设置详情
            VStack(alignment: .leading, spacing: 6) {
                // 行程日期范围
                if let startDate = trip.startDate, let endDate = trip.endDate {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(Typography.footnote)
                            .foregroundStyle(.secondary)
                        Text(formatDateRange(start: startDate, end: endDate))
                            .font(Typography.footnote)
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // 标签显示
                if !trip.selectedTags.isEmpty {
                    FlowLayout(spacing: 4) {
                        ForEach(allSelectedTags) { tag in
                            TagChip(tag: tag)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
    // 可见性由 PackingListView 的 pill 按钮控制

    // PRD: Trip Settings Enhancement - 获取所有选定的标签（不分组）
    private var allSelectedTags: [Tag] {
        trip.selectedTags.compactMap { tagId in
            PresetData.shared.allTags[tagId]
        }
    }

    /// 格式化日期范围
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .chinese ? "yyyy/MM/dd" : "MMM d, yyyy"

        let startStr = formatter.string(from: start)

        // 如果开始和结束是同一天，只显示一次
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return startStr
        }

        // 如果是同一年，结束日期省略年份
        let calendar = Calendar.current
        if calendar.component(.year, from: start) == calendar.component(.year, from: end) {
            formatter.dateFormat = localization.currentLanguage == .chinese ? "MM/dd" : "MMM d"
        }

        let endStr = formatter.string(from: end)
        return "\(startStr) - \(endStr)"
    }

    // PRD: tagsForGroup 方法已移除，标签不再分组显示
}

/// 标签 Chip 组件 - 紧凑样式
struct TagChip: View {
    let tag: Tag
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: tag.icon)
                .font(.system(size: 10, weight: .regular, design: .rounded))
            Text(tag.displayName(language: localization.currentLanguage))
                .font(Typography.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

/// FlowLayout - 自动换行的水平布局
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // 换行
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))

                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                maxX = max(maxX, currentX - spacing)
            }

            self.size = CGSize(width: maxX, height: currentY + lineHeight)
        }
    }
}

#Preview {
    let trip = Trip(
        name: "北京之旅",
        gender: .male,
        duration: .medium,
        selectedTags: ["act_run", "act_climb", "occ_party", "cfg_intl"],
        items: [],
        destination: "北京",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())
    )

    TripSettingsCard(trip: trip)
        .environmentObject(LocalizationManager.shared)
        .padding()
}
