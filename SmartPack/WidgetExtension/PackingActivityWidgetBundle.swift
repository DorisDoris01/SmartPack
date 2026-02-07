//
//  PackingActivityWidgetBundle.swift
//  SmartPackWidgetExtension
//
//  SPEC v1.5: Widget Extension Bundle
//  注意：此文件需要在 Widget Extension target 中使用
//

import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
@main
struct PackingActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        PackingActivityWidget()
    }
}
