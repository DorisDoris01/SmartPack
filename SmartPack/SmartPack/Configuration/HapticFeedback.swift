//
//  HapticFeedback.swift
//  SmartPack
//
//  UI/UX: Haptic feedback for key actions
//

import UIKit

enum HapticFeedback {
    /// Light tap (e.g. toggle item, button tap)
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Success (e.g. all packed, trip created)
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning (e.g. delete confirmation)
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
