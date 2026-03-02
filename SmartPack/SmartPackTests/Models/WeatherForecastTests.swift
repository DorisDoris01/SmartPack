//
//  WeatherForecastTests.swift
//  SmartPackTests
//
//  Tests for WeatherForecast computed properties.
//

import XCTest
@testable import SmartPack

final class WeatherForecastTests: XCTestCase {

    // MARK: - isAvailable

    func testIsAvailable_true() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 25,
            lowTemp: 15,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: 0.0,
            icon: "sun.max.fill"
        )
        XCTAssertTrue(forecast.isAvailable)
    }

    func testIsAvailable_false_nilHighTemp() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: nil,
            lowTemp: 15,
            condition: "unavailable",
            conditionDescription: "不可用",
            precipitationChance: nil,
            icon: "questionmark.circle"
        )
        XCTAssertFalse(forecast.isAvailable)
    }

    func testIsAvailable_false_nilLowTemp() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 25,
            lowTemp: nil,
            condition: "unavailable",
            conditionDescription: "不可用",
            precipitationChance: nil,
            icon: "questionmark.circle"
        )
        XCTAssertFalse(forecast.isAvailable)
    }

    // MARK: - hasPrecipitation

    func testHasPrecipitation_true() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 20,
            lowTemp: 10,
            condition: "rain",
            conditionDescription: "小雨",
            precipitationChance: 0.8,
            icon: "cloud.rain.fill"
        )
        XCTAssertTrue(forecast.hasPrecipitation)
    }

    func testHasPrecipitation_false_lowChance() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 20,
            lowTemp: 10,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: 0.1,
            icon: "sun.max.fill"
        )
        XCTAssertFalse(forecast.hasPrecipitation)
    }

    func testHasPrecipitation_false_nil() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 20,
            lowTemp: 10,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: nil,
            icon: "sun.max.fill"
        )
        XCTAssertFalse(forecast.hasPrecipitation)
    }

    // MARK: - needsWarmClothing

    func testNeedsWarmClothing_true() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 10,
            lowTemp: 5,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: 0.0,
            icon: "sun.max.fill"
        )
        XCTAssertTrue(forecast.needsWarmClothing)
    }

    func testNeedsWarmClothing_false() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 30,
            lowTemp: 20,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: 0.0,
            icon: "sun.max.fill"
        )
        XCTAssertFalse(forecast.needsWarmClothing)
    }

    func testNeedsWarmClothing_nilLowTemp() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 10,
            lowTemp: nil,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: 0.0,
            icon: "sun.max.fill"
        )
        XCTAssertFalse(forecast.needsWarmClothing)
    }

    // MARK: - needsSunProtection

    func testNeedsSunProtection_true() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 35,
            lowTemp: 25,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: 0.0,
            icon: "sun.max.fill"
        )
        XCTAssertTrue(forecast.needsSunProtection)
    }

    func testNeedsSunProtection_false_cloudy() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 35,
            lowTemp: 25,
            condition: "cloudy",
            conditionDescription: "多云",
            precipitationChance: 0.0,
            icon: "cloud.fill"
        )
        XCTAssertFalse(forecast.needsSunProtection)
    }

    func testNeedsSunProtection_false_lowTemp() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 20,
            lowTemp: 10,
            condition: "clear",
            conditionDescription: "晴天",
            precipitationChance: 0.0,
            icon: "sun.max.fill"
        )
        XCTAssertFalse(forecast.needsSunProtection)
    }

    // MARK: - unavailable factory

    func testUnavailable() {
        let date = Date()
        let forecast = WeatherForecast.unavailable(for: date)

        XCTAssertNil(forecast.highTemp)
        XCTAssertNil(forecast.lowTemp)
        XCTAssertEqual(forecast.condition, "unavailable")
        XCTAssertFalse(forecast.isAvailable)
    }

    // MARK: - displayCondition

    func testDisplayCondition_chinese() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 25,
            lowTemp: 15,
            condition: "clear",
            conditionDescription: "晴天",
            conditionDescriptionEn: "Clear",
            precipitationChance: 0.0,
            icon: "sun.max.fill"
        )
        XCTAssertEqual(forecast.displayCondition(language: .chinese), "晴天")
    }

    func testDisplayCondition_english() {
        let forecast = WeatherForecast(
            date: Date(),
            highTemp: 25,
            lowTemp: 15,
            condition: "clear",
            conditionDescription: "晴天",
            conditionDescriptionEn: "Clear",
            precipitationChance: 0.0,
            icon: "sun.max.fill"
        )
        XCTAssertEqual(forecast.displayCondition(language: .english), "Clear")
    }
}
