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
    @Binding var isCollapsed: Bool  // PRD: Trip Settings Enhancement - 收起/展开状态（从父组件传入）
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // PRD: Trip Settings Enhancement - 头部（始终显示）
            HStack(spacing: 6) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(localization.currentLanguage == .chinese ? "清单设置" : "List Settings")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                // PRD: 收起/展开按钮
                Button {
                    #if DEBUG
                    print("🔧 TripSettings toggle: \(isCollapsed) -> \(!isCollapsed)")
                    #endif
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isCollapsed.toggle()
                    }
                } label: {
                    Image(systemName: isCollapsed ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // PRD: Trip Settings Enhancement - 设置详情（根据 isCollapsed 显示/隐藏）
            if !isCollapsed {
                VStack(alignment: .leading, spacing: 6) {
                    // 行程日期范围
                    if let startDate = trip.startDate, let endDate = trip.endDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            Text(formatDateRange(start: startDate, end: endDate))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.primary)
                        }
                    }

                    // PRD: Trip Settings Enhancement - 标签不分组显示
                    if !trip.selectedTags.isEmpty {
                        FlowLayout(spacing: 4) {
                            ForEach(allSelectedTags) { tag in
                                TagChip(tag: tag)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            } else {
                // 收起状态下添加底部内边距
                Spacer()
                    .frame(height: 4)
            }
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
    // PRD: 收起状态现在由 PackingListView 管理，确保 Trip Settings 和 Weather 独立控制

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
                .font(.system(size: 10))
            Text(tag.displayName(language: localization.currentLanguage))
                .font(.system(size: 11, weight: .medium))
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

    TripSettingsCard(trip: trip, isCollapsed: .constant(false))
        .environmentObject(LocalizationManager.shared)
        .padding()
}
