//
//  PackingActivityWidgetBundle.swift
//  SmartPack (Extension 通过 fileSystemSynchronizedGroups 编译)
//
//  SPEC v1.5: Widget Extension 入口点 (@main)
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
