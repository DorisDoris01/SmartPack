//
//  TestModelContainer.swift
//  SmartPackTests
//
//  In-memory ModelContainer factory for SwiftData unit tests.
//  Each test gets a fresh container — no state leaks, no disk I/O.
//

import Foundation
import SwiftData
@testable import SmartPack

enum TestModelContainer {
    /// Creates a fresh in-memory ModelContainer for Trip and TripItem.
    static func create() throws -> ModelContainer {
        let schema = Schema([Trip.self, TripItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
