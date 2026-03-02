//
//  TripDateRangeTests.swift
//  SmartPackTests
//
//  Tests for TripDateRange (dayCount, toTripDuration) and TripConfig
//  (allSelectedTags, hasSelectedTags, generateListName).
//

import XCTest
@testable import SmartPack

final class TripDateRangeTests: XCTestCase {

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return Calendar.current.date(from: comps)!
    }

    // MARK: - dayCount

    func testDayCount_sameDay() {
        let range = TripDateRange(startDate: date(2025, 6, 1), endDate: date(2025, 6, 1))
        XCTAssertEqual(range.dayCount, 1)
    }

    func testDayCount_multiDay() {
        let range = TripDateRange(startDate: date(2025, 6, 1), endDate: date(2025, 6, 5))
        XCTAssertEqual(range.dayCount, 5)
    }

    func testDayCount_crossMonth() {
        let range = TripDateRange(startDate: date(2025, 6, 28), endDate: date(2025, 7, 3))
        XCTAssertEqual(range.dayCount, 6)
    }

    // MARK: - toTripDuration

    func testToTripDuration_3days_short() {
        let range = TripDateRange(startDate: date(2025, 6, 1), endDate: date(2025, 6, 3))
        XCTAssertEqual(range.toTripDuration(), .short)
    }

    func testToTripDuration_4days_medium() {
        let range = TripDateRange(startDate: date(2025, 6, 1), endDate: date(2025, 6, 4))
        XCTAssertEqual(range.toTripDuration(), .medium)
    }

    func testToTripDuration_7days_medium() {
        let range = TripDateRange(startDate: date(2025, 6, 1), endDate: date(2025, 6, 7))
        XCTAssertEqual(range.toTripDuration(), .medium)
    }

    func testToTripDuration_8days_long() {
        let range = TripDateRange(startDate: date(2025, 6, 1), endDate: date(2025, 6, 8))
        XCTAssertEqual(range.toTripDuration(), .long)
    }

    func testToTripDuration_14days_long() {
        let range = TripDateRange(startDate: date(2025, 6, 1), endDate: date(2025, 6, 14))
        XCTAssertEqual(range.toTripDuration(), .long)
    }

    func testToTripDuration_15days_extraLong() {
        let range = TripDateRange(startDate: date(2025, 6, 1), endDate: date(2025, 6, 15))
        XCTAssertEqual(range.toTripDuration(), .extraLong)
    }

    // MARK: - TripConfig.allSelectedTags

    func testAllSelectedTags() {
        var config = TripConfig()
        config.selectedActivityTags = ["running"]
        config.selectedOccasionTags = ["party"]
        config.selectedConfigTags = ["international"]

        XCTAssertEqual(config.allSelectedTags, ["running", "party", "international"])
    }

    // MARK: - TripConfig.hasSelectedTags

    func testHasSelectedTags_true() {
        var config = TripConfig()
        config.selectedActivityTags = ["running"]
        XCTAssertTrue(config.hasSelectedTags)
    }

    func testHasSelectedTags_false() {
        let config = TripConfig()
        XCTAssertFalse(config.hasSelectedTags)
    }

    // MARK: - TripConfig.generateListName

    func testGenerateListName_withDestination() {
        var config = TripConfig()
        config.destination = "Tokyo"
        let name = config.generateListName(language: .english)
        XCTAssertTrue(name.contains("Tokyo"))
    }

    func testGenerateListName_fallback() {
        let config = TripConfig()
        let nameCN = config.generateListName(language: .chinese)
        XCTAssertEqual(nameCN, "日常出行")

        let nameEN = config.generateListName(language: .english)
        XCTAssertEqual(nameEN, "Daily Travel")
    }
}
