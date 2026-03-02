//
//  TripTests.swift
//  SmartPackTests
//
//  Tests for Trip @Model mutations, computed properties, and weather encoding.
//

import XCTest
import SwiftData
@testable import SmartPack

final class TripTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try TestModelContainer.create()
        context = ModelContext(container)
    }

    override func tearDown() {
        context = nil
        container = nil
    }

    // MARK: - Helpers

    /// Creates a Trip with the given items inserted into the context.
    private func makeTrip(items: [TripItem] = []) -> Trip {
        let trip = Trip(
            name: "Test Trip",
            gender: .male,
            duration: .short,
            selectedTags: [],
            items: items
        )
        context.insert(trip)
        return trip
    }

    private func makeItem(id: String = UUID().uuidString, isChecked: Bool = false) -> TripItem {
        TripItem(
            id: id,
            name: "Item \(id)",
            nameEn: "Item \(id)",
            category: "其他",
            categoryEn: "Other",
            isChecked: isChecked,
            sortOrder: 5
        )
    }

    // MARK: - toggleItem

    func testToggleItem_uncheckedToChecked() {
        let item = makeItem(id: "item1", isChecked: false)
        let trip = makeTrip(items: [item])

        trip.toggleItem("item1")

        XCTAssertTrue(item.isChecked)
        XCTAssertEqual(trip.checkedItemCount, 1)
    }

    func testToggleItem_checkedToUnchecked() {
        let item = makeItem(id: "item1", isChecked: true)
        let trip = makeTrip(items: [item])

        trip.toggleItem("item1")

        XCTAssertFalse(item.isChecked)
        XCTAssertEqual(trip.checkedItemCount, 0)
    }

    func testToggleItem_nonexistentId() {
        let item = makeItem(id: "item1", isChecked: false)
        let trip = makeTrip(items: [item])

        trip.toggleItem("nonexistent")

        XCTAssertFalse(item.isChecked)
        XCTAssertEqual(trip.checkedItemCount, 0)
    }

    // MARK: - addItem

    func testAddItem_unchecked() {
        let trip = makeTrip()
        let item = makeItem(id: "new1", isChecked: false)

        trip.addItem(item)

        XCTAssertEqual(trip.totalItemCount, 1)
        XCTAssertEqual(trip.checkedItemCount, 0)
    }

    func testAddItem_alreadyChecked() {
        let trip = makeTrip()
        let item = makeItem(id: "new1", isChecked: true)

        trip.addItem(item)

        XCTAssertEqual(trip.totalItemCount, 1)
        XCTAssertEqual(trip.checkedItemCount, 1)
    }

    // MARK: - removeItem

    func testRemoveItem_unchecked() {
        let item = makeItem(id: "item1", isChecked: false)
        let trip = makeTrip(items: [item])

        trip.removeItem("item1")

        XCTAssertEqual(trip.totalItemCount, 0)
        XCTAssertEqual(trip.checkedItemCount, 0)
    }

    func testRemoveItem_checked() {
        let item = makeItem(id: "item1", isChecked: true)
        let trip = makeTrip(items: [item])

        trip.removeItem("item1")

        XCTAssertEqual(trip.totalItemCount, 0)
        XCTAssertEqual(trip.checkedItemCount, 0)
    }

    func testRemoveItem_nonexistentId() {
        let item = makeItem(id: "item1")
        let trip = makeTrip(items: [item])

        trip.removeItem("nonexistent")

        XCTAssertEqual(trip.totalItemCount, 1)
    }

    // MARK: - resetAllChecks

    func testResetAllChecks() {
        let items = [
            makeItem(id: "a", isChecked: true),
            makeItem(id: "b", isChecked: true),
            makeItem(id: "c", isChecked: false)
        ]
        let trip = makeTrip(items: items)

        trip.resetAllChecks()

        XCTAssertTrue(trip.items.allSatisfy { !$0.isChecked })
        XCTAssertEqual(trip.checkedItemCount, 0)
    }

    func testResetAllChecks_alreadyUnchecked() {
        let items = [makeItem(id: "a", isChecked: false), makeItem(id: "b", isChecked: false)]
        let trip = makeTrip(items: items)

        trip.resetAllChecks()

        XCTAssertEqual(trip.checkedItemCount, 0)
        XCTAssertTrue(trip.items.allSatisfy { !$0.isChecked })
    }

    // MARK: - recalculateCounts

    func testRecalculateCounts() {
        let items = [
            makeItem(id: "a", isChecked: true),
            makeItem(id: "b", isChecked: false),
            makeItem(id: "c", isChecked: true)
        ]
        let trip = makeTrip(items: items)

        // Manually tamper with counts
        trip.checkedItemCount = 0
        trip.totalItemCount = 0

        trip.recalculateCounts()

        XCTAssertEqual(trip.totalItemCount, 3)
        XCTAssertEqual(trip.checkedItemCount, 2)
    }

    // MARK: - progress

    func testProgress_noItems() {
        let trip = makeTrip()
        XCTAssertEqual(trip.progress, 0.0)
    }

    func testProgress_someChecked() {
        let items = [
            makeItem(id: "a", isChecked: true),
            makeItem(id: "b", isChecked: false),
            makeItem(id: "c", isChecked: false),
            makeItem(id: "d", isChecked: false)
        ]
        let trip = makeTrip(items: items)
        XCTAssertEqual(trip.progress, 0.25, accuracy: 0.001)
    }

    func testProgress_allChecked() {
        let items = [
            makeItem(id: "a", isChecked: true),
            makeItem(id: "b", isChecked: true)
        ]
        let trip = makeTrip(items: items)
        XCTAssertEqual(trip.progress, 1.0)
    }

    // MARK: - isAllChecked

    func testIsAllChecked_true() {
        let items = [makeItem(id: "a", isChecked: true), makeItem(id: "b", isChecked: true)]
        let trip = makeTrip(items: items)
        XCTAssertTrue(trip.isAllChecked)
    }

    func testIsAllChecked_false() {
        let items = [makeItem(id: "a", isChecked: true), makeItem(id: "b", isChecked: false)]
        let trip = makeTrip(items: items)
        XCTAssertFalse(trip.isAllChecked)
    }

    func testIsAllChecked_empty() {
        let trip = makeTrip()
        XCTAssertFalse(trip.isAllChecked)
    }

    // MARK: - weatherForecasts encode/decode

    func testWeatherForecasts_encodeDecode() {
        let trip = makeTrip()
        let forecasts = [
            WeatherForecast(
                date: Date(),
                highTemp: 30,
                lowTemp: 20,
                condition: "clear",
                conditionDescription: "晴天",
                conditionDescriptionEn: "Clear",
                precipitationChance: 0.1,
                icon: "sun.max.fill"
            )
        ]

        trip.weatherForecasts = forecasts

        let retrieved = trip.weatherForecasts
        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved.first?.condition, "clear")
        XCTAssertEqual(retrieved.first?.highTemp, 30)
    }

    func testWeatherForecasts_nilData() {
        let trip = makeTrip()
        // weatherData is nil by default (no forecasts passed)
        XCTAssertTrue(trip.weatherForecasts.isEmpty)
    }

    // MARK: - archive / unarchive

    func testArchive() {
        let trip = makeTrip()
        XCTAssertFalse(trip.isArchived)

        trip.archive()
        XCTAssertTrue(trip.isArchived)
    }

    func testUnarchive() {
        let trip = makeTrip()
        trip.archive()

        trip.unarchive()
        XCTAssertFalse(trip.isArchived)
    }
}
