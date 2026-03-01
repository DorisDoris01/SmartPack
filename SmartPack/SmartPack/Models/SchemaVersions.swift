//
//  SchemaVersions.swift
//  SmartPack
//
//  SwiftData 版本化 Schema + 迁移计划
//  F2 fix: 防止 App 更新时因 Schema 变更导致数据丢失
//
//  ⚠️ 新增/删除/重命名 Trip 或 TripItem 的持久化字段时，必须：
//  1. 创建 SchemaV2（在下方新增 enum）
//  2. 在 SmartPackMigrationPlan.schemas 中追加 SchemaV2.self
//  3. 在 stages 中添加 .lightweight(...) 或 .custom(...) 迁移步骤
//  4. 在 SmartPackApp.swift 中切换为:
//       try ModelContainer(for: SchemaV2.self, migrationPlan: SmartPackMigrationPlan.self)
//

import Foundation
import SwiftData

// MARK: - Schema V1（当前版本，首次正式声明）

/// V1 是当前已发布的完整 Schema，包含所有已有字段。
/// 后续新增字段应创建 SchemaV2 并在 MigrationPlan 中添加迁移步骤。
enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Trip.self, TripItem.self]
    }
}

// MARK: - Migration Plan

/// 迁移计划：定义从旧版本到新版本的迁移路径。
/// 当前只有 V1，无需迁移步骤。新增 V2 时在 stages 中添加 MigrationStage。
enum SmartPackMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }

    static var stages: [MigrationStage] {
        // 当前只有 V1，无迁移步骤。
        // 新增 V2 时取消注释并调整:
        // .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)
        []
    }
}

// MARK: - 新版本模板（需要时取消注释并修改）
//
// enum SchemaV2: VersionedSchema {
//     static var versionIdentifier: Schema.Version = Schema.Version(2, 0, 0)
//     static var models: [any PersistentModel.Type] {
//         [Trip.self, TripItem.self]
//     }
// }
