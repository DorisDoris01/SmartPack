//
//  CustomItemManagerTests.swift
//  SmartPackTests
//
//  Tests for CustomItemManager CRUD, persistence, and preset item deletion.
//  Uses injected UserDefaults(suiteName:) for isolation.
//

import XCTest
@testable import SmartPack

final class CustomItemManagerTests: XCTestCase {

    private var suiteName: String!

    override func setUp() {
        suiteName = "com.smartpack.tests.\(UUID().uuidString)"
    }

    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        suiteName = nil
    }

    private func makeManager() -> CustomItemManager {
        let defaults = UserDefaults(suiteName: suiteName)!
        return CustomItemManager(userDefaults: defaults)
    }

    // MARK: - addCustomItem

    func testAddCustomItem_success() {
        let manager = makeManager()
        let result = manager.addCustomItem("Umbrella", to: "running")
        XCTAssertTrue(result)
        XCTAssertEqual(manager.getCustomItems(for: "running"), ["Umbrella"])
    }

    func testAddCustomItem_emptyName() {
        let manager = makeManager()
        let result = manager.addCustomItem("", to: "running")
        XCTAssertFalse(result)
        XCTAssertTrue(manager.getCustomItems(for: "running").isEmpty)
    }

    func testAddCustomItem_whitespaceOnly() {
        let manager = makeManager()
        let result = manager.addCustomItem("   ", to: "running")
        XCTAssertFalse(result)
    }

    func testAddCustomItem_caseInsensitiveDedup() {
        let manager = makeManager()
        XCTAssertTrue(manager.addCustomItem("Umbrella", to: "running"))
        XCTAssertFalse(manager.addCustomItem("umbrella", to: "running"))
        XCTAssertEqual(manager.getCustomItems(for: "running").count, 1)
    }

    func testAddCustomItem_trimming() {
        let manager = makeManager()
        XCTAssertTrue(manager.addCustomItem("  Umbrella  ", to: "running"))
        XCTAssertEqual(manager.getCustomItems(for: "running"), ["Umbrella"])
    }

    // MARK: - Persistence

    func testPersistence_acrossInstances() {
        let manager1 = makeManager()
        manager1.addCustomItem("Umbrella", to: "running")

        // Create a new manager with the same UserDefaults suite
        let defaults = UserDefaults(suiteName: suiteName)!
        let manager2 = CustomItemManager(userDefaults: defaults)

        XCTAssertEqual(manager2.getCustomItems(for: "running"), ["Umbrella"])
    }

    // MARK: - removeCustomItem

    func testRemoveCustomItem_exists() {
        let manager = makeManager()
        manager.addCustomItem("Umbrella", to: "running")
        manager.addCustomItem("Towel", to: "running")

        manager.removeCustomItem("Umbrella", from: "running")

        XCTAssertEqual(manager.getCustomItems(for: "running"), ["Towel"])
    }

    func testRemoveCustomItem_cleansEmptyTag() {
        let manager = makeManager()
        manager.addCustomItem("Umbrella", to: "running")

        manager.removeCustomItem("Umbrella", from: "running")

        XCTAssertTrue(manager.getCustomItems(for: "running").isEmpty)
        XCTAssertNil(manager.customItems["running"], "Empty tag should be removed from dictionary")
    }

    func testRemoveCustomItem_nonexistent() {
        let manager = makeManager()
        manager.addCustomItem("Umbrella", to: "running")

        // Should not crash or change anything
        manager.removeCustomItem("Nonexistent", from: "running")
        XCTAssertEqual(manager.getCustomItems(for: "running"), ["Umbrella"])
    }

    // MARK: - deletePresetItem / restorePresetItem

    func testDeletePresetItem() {
        let manager = makeManager()
        manager.deletePresetItem("base_ele_001")
        XCTAssertTrue(manager.isPresetItemDeleted("base_ele_001"))
    }

    func testRestorePresetItem() {
        let manager = makeManager()
        manager.deletePresetItem("base_ele_001")
        manager.restorePresetItem("base_ele_001")
        XCTAssertFalse(manager.isPresetItemDeleted("base_ele_001"))
    }

    func testIsPresetItemDeleted_notDeleted() {
        let manager = makeManager()
        XCTAssertFalse(manager.isPresetItemDeleted("base_ele_001"))
    }

    // MARK: - canDeleteItem

    func testCanDeleteItem_moreThanOne() {
        let manager = makeManager()
        let presetIds = ["item1", "item2", "item3"]
        XCTAssertTrue(manager.canDeleteItem(tagId: "running", presetItemIds: presetIds, customItemCount: 0))
    }

    func testCanDeleteItem_lastItem() {
        let manager = makeManager()
        let presetIds = ["item1"]
        XCTAssertFalse(manager.canDeleteItem(tagId: "running", presetItemIds: presetIds, customItemCount: 0))
    }

    func testCanDeleteItem_withCustomItems() {
        let manager = makeManager()
        // 1 preset + 1 custom = 2 total, can still delete
        let presetIds = ["item1"]
        XCTAssertTrue(manager.canDeleteItem(tagId: "running", presetItemIds: presetIds, customItemCount: 1))
    }

    func testCanDeleteItem_allPresetsDeleted_oneCustom() {
        let manager = makeManager()
        manager.deletePresetItem("item1")
        // 0 active preset + 1 custom = 1 total, cannot delete
        XCTAssertFalse(manager.canDeleteItem(tagId: "running", presetItemIds: ["item1"], customItemCount: 1))
    }
}
