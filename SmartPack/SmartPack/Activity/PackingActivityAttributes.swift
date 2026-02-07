//
//  PackingActivityAttributes.swift
//  SmartPack
//
//  SPEC v1.5: Live Activity Attributes
//  iOS 16.1+ 锁屏显示打包进度
//

import Foundation
import ActivityKit

/// 打包进度 Live Activity 属性
struct PackingActivityAttributes: ActivityAttributes {
    /// 静态内容（不变）
    public struct ContentState: Codable, Hashable {
        var tripName: String
        var checkedCount: Int
        var totalCount: Int
        var progress: Double  // 0.0 - 1.0
    }
    
    // 静态属性（可选，当前不需要）
    // var tripId: String
}
