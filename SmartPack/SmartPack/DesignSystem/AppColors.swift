//
//  AppColors.swift
//  SmartPack
//
//  设计系统 - 颜色定义
//

import SwiftUI
import UIKit

/// 应用颜色定义
enum AppColors {
    private static func adaptive(
        light: (CGFloat, CGFloat, CGFloat),
        dark: (CGFloat, CGFloat, CGFloat)
    ) -> Color {
        Color(UIColor { trait in
            switch trait.userInterfaceStyle {
            case .dark:
                return UIColor(red: dark.0, green: dark.1, blue: dark.2, alpha: 1)
            default:
                return UIColor(red: light.0, green: light.1, blue: light.2, alpha: 1)
            }
        })
    }

    // MARK: - Core Palette

    /// 主题色 — Deep teal #0E7490 / Bright cyan #22D3EE
    static let primary = adaptive(light: (0.055, 0.455, 0.565), dark: (0.133, 0.827, 0.933))

    /// 次要颜色 — Teal-gray #4B6072 / #7A95AA
    static let secondary = adaptive(light: (0.294, 0.376, 0.447), dark: (0.478, 0.584, 0.667))

    /// 成功色 — Deep forest #166534 / Bright green #4ADE80
    static let success = adaptive(light: (0.086, 0.396, 0.204), dark: (0.290, 0.871, 0.502))

    /// 警告色 — Deep amber #B45309 / Gold #FBBF24
    static let warning = adaptive(light: (0.706, 0.325, 0.035), dark: (0.984, 0.749, 0.141))

    /// 错误色 — Deep red #B91C1C / Soft red #F87171
    static let error = adaptive(light: (0.725, 0.110, 0.110), dark: (0.973, 0.443, 0.443))

    // MARK: - Backgrounds

    /// 背景色 — Teal-tinted white #F0F4F5 / Very dark teal #0C1418
    static let background = adaptive(light: (0.941, 0.957, 0.961), dark: (0.047, 0.078, 0.094))

    /// 次要背景色 — #E4ECEF / #141E24
    static let secondaryBackground = adaptive(light: (0.894, 0.925, 0.937), dark: (0.078, 0.118, 0.141))

    /// 卡片背景 — #F8FAFB / #1A2830
    static let cardBackground = adaptive(light: (0.973, 0.980, 0.984), dark: (0.102, 0.157, 0.188))

    // MARK: - Text

    /// 文字主色 — Dark teal-black #0C1E24 / #EDF4F7
    static let text = adaptive(light: (0.047, 0.118, 0.141), dark: (0.929, 0.957, 0.969))

    /// 文字次要色 — #446070 / #7A9BAA
    static let textSecondary = adaptive(light: (0.267, 0.376, 0.439), dark: (0.478, 0.608, 0.667))

    // MARK: - Derived / Utility

    /// 主色浅底 — 12% opacity teal
    static let primaryLight = adaptive(light: (0.055, 0.455, 0.565), dark: (0.133, 0.827, 0.933)).opacity(0.12)

    /// 分割线
    static let divider = adaptive(light: (0.294, 0.376, 0.447), dark: (0.478, 0.584, 0.667)).opacity(0.15)

    /// 归档强调色 — Teal slate #4A7080 / #6A90A0
    static let archiveAccent = adaptive(light: (0.290, 0.439, 0.502), dark: (0.416, 0.565, 0.627))
}
