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
        HStack(spacing: 14) {
            // 进度圆环
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: trip.progress)
                    .stroke(
                        trip.isAllChecked ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
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
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name)
                    .font(.headline)
                    .foregroundColor(isArchived ? .secondary : .primary)
                    .lineLimit(1)

                HStack(spacing: 8) {
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
        .padding(.vertical, 4)
    }
}
