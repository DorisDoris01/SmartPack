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
                        trip.isAllChecked ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: Spacing.xxs, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))

                if trip.isAllChecked {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                }
            }
            .opacity(isArchived ? 0.6 : 1)

            // 行程信息
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(trip.name)
                    .font(.headline)
                    .foregroundColor(isArchived ? .secondary : .primary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Text(trip.formattedDate(language: language))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("·")
                        .foregroundColor(.secondary)

                    Text("\(trip.checkedCount)/\(trip.totalCount)")
                        .font(.caption)
                        .foregroundColor(trip.isAllChecked ? .green : .secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, Spacing.xxs)
    }
}
