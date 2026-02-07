//
//  AppColors.swift
//  SmartPack
//
//  设计系统 - 颜色定义
//

import SwiftUI

/// 应用颜色定义
enum AppColors {
    /// 主题色
    static let primary = Color.blue

    /// 次要颜色
    static let secondary = Color.gray

    /// 成功色
    static let success = Color.green

    /// 警告色
    static let warning = Color.orange

    /// 错误色
    static let error = Color.red

    /// 背景色
    static let background = Color(.systemBackground)

    /// 次要背景色
    static let secondaryBackground = Color(.secondarySystemBackground)

    /// 卡片背景
    static let cardBackground = Color(.systemGray6)

    /// 文字主色
    static let text = Color.primary

    /// 文字次要色
    static let textSecondary = Color.secondary
}
