//
//  Typography.swift
//  SmartPack
//
//  设计系统 - 字体排版常量 (SF Rounded)
//

import SwiftUI

/// 统一的字体定义 — SF Rounded + heavier weights
enum Typography {
    /// 超大标题 - 34pt Semibold Rounded
    static let largeTitle = Font.system(size: 34, weight: .semibold, design: .rounded)

    /// 标题 1 - 28pt Semibold Rounded
    static let title1 = Font.system(size: 28, weight: .semibold, design: .rounded)

    /// 标题 2 - 22pt Semibold Rounded
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)

    /// 标题 3 - 20pt Semibold Rounded
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    /// 标题 - 17pt Bold Rounded
    static let headline = Font.system(size: 17, weight: .bold, design: .rounded)

    /// 副标题 - 15pt Medium Rounded
    static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)

    /// 正文 - 17pt Regular Rounded
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)

    /// 标注 - 12pt Semibold Rounded
    static let caption = Font.system(size: 12, weight: .semibold, design: .rounded)

    /// 小标注 - 11pt Semibold Rounded
    static let caption2 = Font.system(size: 11, weight: .semibold, design: .rounded)

    /// 脚注 - 13pt Medium Rounded
    static let footnote = Font.system(size: 13, weight: .medium, design: .rounded)

    // MARK: - Display

    /// 展示大号 - 40pt Medium Rounded
    static let displayLarge = Font.system(size: 40, weight: .medium, design: .rounded)

    /// 展示中号 - 32pt Regular Rounded
    static let displayMedium = Font.system(size: 32, weight: .regular, design: .rounded)

    /// 上标注 - 11pt Bold Rounded (for section headers / overlines)
    static let overline = Font.system(size: 11, weight: .bold, design: .rounded)

    // MARK: - Tracking

    enum Tracking {
        static let tight: CGFloat = -0.4
        static let normal: CGFloat = 0
        static let wide: CGFloat = 0.6
        static let extraWide: CGFloat = 1.6
    }
}
