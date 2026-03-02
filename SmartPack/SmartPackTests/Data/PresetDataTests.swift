//
//  PresetDataTests.swift
//  SmartPackTests
//
//  Tests for PresetData.shared.generatePackingList(tagIds:gender:).
//

import XCTest
@testable import SmartPack

final class PresetDataTests: XCTestCase {

    private let preset = PresetData.shared

    // MARK: - Base items

    func testBaseItems_alwaysIncluded() {
        let items = preset.generatePackingList(tagIds: [], gender: .male)
        let ids = Set(items.map(\.id))

        // Common base items should always be present
        for baseId in preset.commonBaseItemIds {
            XCTAssertTrue(ids.contains(baseId), "Missing common base item: \(baseId)")
        }
    }

    // MARK: - Gender filtering

    func testMaleGender_includesMaleExcludesFemale() {
        let items = preset.generatePackingList(tagIds: [], gender: .male)
        let ids = Set(items.map(\.id))

        for maleId in preset.maleSpecificItemIds {
            XCTAssertTrue(ids.contains(maleId), "Missing male item: \(maleId)")
        }
        for femaleId in preset.femaleSpecificItemIds {
            XCTAssertFalse(ids.contains(femaleId), "Should not contain female item: \(femaleId)")
        }
    }

    func testFemaleGender_includesFemaleExcludesMale() {
        let items = preset.generatePackingList(tagIds: [], gender: .female)
        let ids = Set(items.map(\.id))

        for femaleId in preset.femaleSpecificItemIds {
            XCTAssertTrue(ids.contains(femaleId), "Missing female item: \(femaleId)")
        }
        for maleId in preset.maleSpecificItemIds {
            XCTAssertFalse(ids.contains(maleId), "Should not contain male item: \(maleId)")
        }
    }

    // MARK: - Tag items

    func testTagItems_included() {
        let items = preset.generatePackingList(tagIds: ["running"], gender: .male)
        let ids = Set(items.map(\.id))

        // Running tag should add its items
        let runningTag = preset.allTags["running"]!
        for itemId in runningTag.itemIds {
            // Only check non-deleted items
            if !CustomItemManager.shared.isPresetItemDeleted(itemId) {
                XCTAssertTrue(ids.contains(itemId), "Missing running item: \(itemId)")
            }
        }
    }

    func testEmptyTags_baseItemsOnly() {
        let maleItems = preset.generatePackingList(tagIds: [], gender: .male)
        let expectedCount = preset.commonBaseItemIds.count + preset.maleSpecificItemIds.count
        XCTAssertEqual(maleItems.count, expectedCount)
    }

    // MARK: - Sort order

    func testSortedByCategorySortOrder() {
        let items = preset.generatePackingList(tagIds: ["running"], gender: .male)

        for i in 0..<(items.count - 1) {
            let current = items[i].sortOrder
            let next = items[i + 1].sortOrder
            if current != next {
                XCTAssertLessThanOrEqual(current, next,
                    "Items not sorted by category: \(items[i].name) (\(current)) > \(items[i+1].name) (\(next))")
            }
        }
    }

    // MARK: - Deduplication

    func testDeduplication_sameItemFromMultipleTags() {
        // Trail running and running both have "运动补给（能量胶）" and "运动手表"
        let items = preset.generatePackingList(tagIds: ["running", "trail_running"], gender: .male)
        let names = items.map(\.name)

        // Count occurrences of each name — should be exactly 1
        for name in Set(names) {
            let count = names.filter { $0 == name }.count
            XCTAssertEqual(count, 1, "Duplicate item found: \(name)")
        }
    }

    // MARK: - Multiple tags union

    func testMultipleTagsUnion() {
        let runningOnly = preset.generatePackingList(tagIds: ["running"], gender: .male)
        let campingOnly = preset.generatePackingList(tagIds: ["camping"], gender: .male)
        let both = preset.generatePackingList(tagIds: ["running", "camping"], gender: .male)

        // Combined should have at least as many items as either alone
        XCTAssertGreaterThanOrEqual(both.count, runningOnly.count)
        XCTAssertGreaterThanOrEqual(both.count, campingOnly.count)
    }

    // MARK: - Gender-specific tag items

    func testGenderSpecificTagItems_filtered() {
        // All generated items should match the requested gender or be gender-neutral
        let items = preset.generatePackingList(tagIds: ["beach"], gender: .male)
        for item in items {
            if let presetItem = preset.allItems[item.id] {
                if let genderSpecific = presetItem.genderSpecific {
                    XCTAssertEqual(genderSpecific, .male,
                        "Item \(item.name) has wrong gender: \(genderSpecific)")
                }
            }
        }
    }
}
