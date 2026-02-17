//
//  ViewModifiers.swift
//  SmartPack
//
//  设计系统 - 可复用视图修饰器
//

import SwiftUI

// MARK: - Elevated Card

struct ElevatedCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Section Header

struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Typography.overline)
            .tracking(Typography.Tracking.extraWide)
            .textCase(.uppercase)
            .foregroundColor(AppColors.textSecondary)
    }
}

// MARK: - Warm Divider

struct WarmDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.divider)
            .frame(height: 1)
    }
}

// MARK: - Premium Animation

enum PremiumAnimation {
    /// State transitions — smooth and controlled
    static let standard = Animation.spring(response: 0.5, dampingFraction: 0.78)

    /// Micro-interactions — quick and responsive
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.72)

    /// Entrance effects — gentle fade-in/up
    static let entrance = Animation.spring(response: 0.65, dampingFraction: 0.82)
}

// MARK: - View Extensions

extension View {
    func elevatedCard() -> some View {
        modifier(ElevatedCardModifier())
    }

    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderModifier())
    }
}
