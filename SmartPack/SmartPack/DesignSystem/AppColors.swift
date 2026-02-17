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

    /// 主题色 — Steel blue #6998AB
    static let primary = adaptive(light: (0.41, 0.60, 0.67), dark: (0.52, 0.70, 0.77))

    /// 次要颜色 — Cool slate gray
    static let secondary = adaptive(light: (0.47, 0.51, 0.55), dark: (0.60, 0.64, 0.68))

    /// 成功色 — Teal-green
    static let success = adaptive(light: (0.35, 0.62, 0.50), dark: (0.45, 0.72, 0.58))

    /// 警告色 — Gold amber
    static let warning = adaptive(light: (0.80, 0.64, 0.32), dark: (0.88, 0.72, 0.42))

    /// 错误色 — Muted coral-red
    static let error = adaptive(light: (0.77, 0.40, 0.38), dark: (0.85, 0.50, 0.47))

    // MARK: - Backgrounds

    /// 背景色 — Cool off-white / dark charcoal
    static let background = adaptive(light: (0.96, 0.965, 0.97), dark: (0.10, 0.11, 0.12))

    /// 次要背景色 — Subtle cool gray
    static let secondaryBackground = adaptive(light: (0.93, 0.935, 0.94), dark: (0.14, 0.15, 0.16))

    /// 卡片背景 — Near-white card
    static let cardBackground = adaptive(light: (0.98, 0.98, 0.985), dark: (0.17, 0.18, 0.19))

    // MARK: - Text

    /// 文字主色 — Cool near-black
    static let text = adaptive(light: (0.12, 0.13, 0.16), dark: (0.93, 0.94, 0.95))

    /// 文字次要色 — Medium cool gray
    static let textSecondary = adaptive(light: (0.48, 0.51, 0.55), dark: (0.62, 0.65, 0.69))

    // MARK: - Derived / Utility

    /// 主色浅底 — 12% opacity steel blue
    static let primaryLight = adaptive(light: (0.41, 0.60, 0.67), dark: (0.52, 0.70, 0.77)).opacity(0.12)

    /// 分割线
    static let divider = adaptive(light: (0.47, 0.51, 0.55), dark: (0.60, 0.64, 0.68)).opacity(0.15)

    /// 归档强调色 — Muted slate
    static let archiveAccent = adaptive(light: (0.50, 0.52, 0.60), dark: (0.61, 0.63, 0.71))
}
