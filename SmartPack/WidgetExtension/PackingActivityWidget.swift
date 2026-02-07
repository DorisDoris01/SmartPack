//
//  PackingActivityWidget.swift
//  SmartPackWidgetExtension
//
//  SPEC v1.5: Live Activity Widget UI
//  注意：此文件需要在 Widget Extension target 中使用
//

import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct PackingActivityWidget: Widget {
    let kind: String = "PackingActivityWidget"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PackingActivityAttributes.self) { context in
            // Lock Screen 显示
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // 紧凑视图（Dynamic Island 左侧）
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "suitcase.fill")
                            .foregroundColor(.blue)
                        Text(context.state.tripName)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                
                // 紧凑视图（Dynamic Island 右侧）
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                // 展开视图（底部）
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(value: context.state.progress)
                            .tint(.blue)
                        
                        HStack {
                            Text("\(context.state.checkedCount)/\(context.state.totalCount) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // 最小视图（左侧）
                Image(systemName: "suitcase.fill")
                    .foregroundColor(.blue)
            } compactTrailing: {
                // 最小视图（右侧）
                Text("\(Int(context.state.progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(.blue)
            } minimal: {
                // 最小化视图
                Image(systemName: "suitcase.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Lock Screen Live Activity View

@available(iOS 16.1, *)
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PackingActivityAttributes>
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧图标
            Image(systemName: "suitcase.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                // 行程名称
                Text(context.state.tripName)
                    .font(.headline)
                    .lineLimit(1)
                
                // 进度条
                ProgressView(value: context.state.progress)
                    .tint(.blue)
                
                // 进度文本
                HStack {
                    Text("\(context.state.checkedCount)/\(context.state.totalCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
