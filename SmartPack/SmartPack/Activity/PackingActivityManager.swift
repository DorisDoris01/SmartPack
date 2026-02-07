//
//  PackingActivityManager.swift
//  SmartPack
//
//  SPEC v1.5: Live Activity 管理器
//  管理打包进度的锁屏显示
//

import Foundation
import ActivityKit

/// Live Activity 管理器
@available(iOS 16.1, *)
class PackingActivityManager {
    static let shared = PackingActivityManager()
    
    private var currentActivity: Activity<PackingActivityAttributes>?
    
    private init() {}
    
    /// SPEC v1.5 F-5.1: 启动 Live Activity
    /// - Parameters:
    ///   - tripName: 行程名称
    ///   - checkedCount: 已勾选数量
    ///   - totalCount: 总数量
    func startActivity(tripName: String, checkedCount: Int, totalCount: Int) {
        // 如果已有 Activity，先结束
        if currentActivity != nil {
            endActivity()
        }
        
        guard totalCount > 0 else { return }
        
        let attributes = PackingActivityAttributes()
        let initialState = PackingActivityAttributes.ContentState(
            tripName: tripName,
            checkedCount: checkedCount,
            totalCount: totalCount,
            progress: Double(checkedCount) / Double(totalCount)
        )
        
        do {
            // iOS 16.2+ API: 使用 content 而不是 contentState
            let activity = try Activity<PackingActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil  // 本地更新，不使用推送
            )
            currentActivity = activity
            print("✅ Live Activity started successfully: \(tripName)")
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
            print("   Error details: \(error.localizedDescription)")
            
            // 检查常见错误原因（通过错误描述判断）
            let errorDescription = error.localizedDescription.lowercased()
            if errorDescription.contains("authorization") || errorDescription.contains("permission") {
                print("   ⚠️ Live Activity authorization denied. Check Settings → SmartPack → Live Activities")
            } else if errorDescription.contains("maximum") || errorDescription.contains("count") {
                print("   ⚠️ Exceeded maximum Live Activity count (iOS limit: 5)")
            } else if errorDescription.contains("NSSupportsLiveActivities") {
                print("   ⚠️ Missing NSSupportsLiveActivities in Info.plist. Check Widget Extension configuration.")
            } else {
                print("   ⚠️ ActivityKit error: \(error)")
            }
        }
    }
    
    /// SPEC v1.5 F-5.2: 更新 Live Activity 进度
    /// - Parameters:
    ///   - checkedCount: 已勾选数量
    ///   - totalCount: 总数量
    func updateActivity(checkedCount: Int, totalCount: Int) {
        guard let activity = currentActivity, totalCount > 0 else { return }
        
        let updatedState = PackingActivityAttributes.ContentState(
            tripName: activity.content.state.tripName,
            checkedCount: checkedCount,
            totalCount: totalCount,
            progress: Double(checkedCount) / Double(totalCount)
        )
        
        // iOS 16.2+ API: 使用 update(_:) 而不是 update(using:)
        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
        }
    }
    
    /// SPEC v1.5 F-5.4: 结束 Live Activity
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        // iOS 16.2+ API: 使用 end(content:dismissalPolicy:) 而不是 end(dismissalPolicy:)
        Task {
            await activity.end(
                ActivityContent(state: activity.content.state, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
        
        currentActivity = nil
    }
    
    /// 检查是否有活跃的 Activity
    var hasActiveActivity: Bool {
        return currentActivity != nil
    }
}

/// iOS 16.1 以下版本的兼容包装
class PackingActivityManagerCompat {
    static let shared = PackingActivityManagerCompat()
    
    private init() {}
    
    func startActivity(tripName: String, checkedCount: Int, totalCount: Int) {
        if #available(iOS 16.1, *) {
            PackingActivityManager.shared.startActivity(
                tripName: tripName,
                checkedCount: checkedCount,
                totalCount: totalCount
            )
        }
        // iOS 16.1 以下不做任何操作
    }
    
    func updateActivity(checkedCount: Int, totalCount: Int) {
        if #available(iOS 16.1, *) {
            PackingActivityManager.shared.updateActivity(
                checkedCount: checkedCount,
                totalCount: totalCount
            )
        }
    }
    
    func endActivity() {
        if #available(iOS 16.1, *) {
            PackingActivityManager.shared.endActivity()
        }
    }
}
