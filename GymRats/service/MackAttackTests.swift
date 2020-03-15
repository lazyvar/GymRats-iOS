//
//  MackAttackTests.swift
//  GymRatsTests
//
//  Created by Mack on 6/3/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import XCTest
import SwiftDate

@testable import GymRats

class MackAttackTests: XCTestCase {

    func testStartDateToLocal() {
        let startDate = Date(timeIntervalSince1970: 1560124800) // 2019-06-10 00:00:00
        let threeHoursBefore = startDate - 3.hours
        let threeHoursAfter = startDate + 3.hours
        let fourHoursAfter = startDate + 4.hours
        let easternTimeZone = TimeZone(abbreviation: "EST")!
        let germanyTimeZone = TimeZone(abbreviation: "CET")!
        
        XCTAssertFalse(threeHoursBefore.inTimeZone(easternTimeZone, isSameDayAs: startDate, inTimeZone: .utc))
        XCTAssertFalse(threeHoursAfter.inTimeZone(easternTimeZone, isSameDayAs: startDate, inTimeZone: .utc))
        XCTAssertTrue(fourHoursAfter.inTimeZone(easternTimeZone, isSameDayAs: startDate, inTimeZone: .utc))
        XCTAssertFalse(threeHoursBefore.inTimeZone(germanyTimeZone, isSameDayAs: startDate, inTimeZone: .utc))
        XCTAssertTrue(threeHoursAfter.inTimeZone(germanyTimeZone, isSameDayAs: startDate, inTimeZone: .utc))
        XCTAssertTrue(fourHoursAfter.inTimeZone(germanyTimeZone, isSameDayAs: startDate, inTimeZone: .utc))
    }
    
    func testDaysApart() {
        let startDate = Date(timeIntervalSince1970: 1560124800) // 2019-06-10 00:00:00
        let threeHoursBefore = startDate - 3.hours
        let dayBefore = startDate - 1.days
        let easternTimeZone = TimeZone(abbreviation: "EST")!

        XCTAssertEqual(threeHoursBefore.dayInTimeZone(easternTimeZone), startDate.dayInTimeZone(.utc) - 1)
        XCTAssertEqual(dayBefore.dayInTimeZone(easternTimeZone), startDate.dayInTimeZone(.utc) - 2)
    }

}
