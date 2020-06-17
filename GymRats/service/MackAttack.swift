//
//  MackAttack.swift
//  GymRats
//
//  Created by Mack on 6/3/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import SwiftDate

extension TimeZone {
  static let utc = TimeZone(abbreviation: "UTC")!
}

extension Date {
  var serverDateIsToday: Bool {
    return utcDateIsDaysApartFromLocalDate(Date()) == 0
  }
  
  var serverDateIsYesterday: Bool {
    return utcDateIsDaysApartFromLocalDate(Date()) == -1
  }
  
  var serverDateIsTomorrow: Bool {
    return utcDateIsDaysApartFromLocalDate(Date()) == 1
  }
  
  func utcDateIsDaysApartFromUtcDate(_ date: Date) -> Int {
    return inTimeZone(.utc, daysApartFrom: date, inTimeZone: .utc)
  }
  
  func utcDateIsDaysApartFromLocalDate(_ date: Date) -> Int {
    return inTimeZone(.utc, daysApartFrom: date, inTimeZone: .current)
  }
  
  func localDateIsDaysApartFromUTCDate(_ date: Date) -> Int {
    return inTimeZone(.current, daysApartFrom: date, inTimeZone: .utc)
  }
  
  func localDateIsSameDayAsUTCDate(_ date: Date) -> Bool {
    return inTimeZone(.current, isSameDayAs: date, inTimeZone: .utc)
  }

  func localDateIsLessThanUTCDate(_ date: Date) -> Bool {
    return inTimeZone(.current, isLessThan: date, inTimeZone: .utc)
  }
  
  func localDateIsGreaterThanUTCDate(_ date: Date) -> Bool {
    return inTimeZone(.current, isGreaterThan: date, inTimeZone: .utc)
  }

  func localDateIsLessThanOrEqualToUTCDate(_ date: Date) -> Bool {
    return inTimeZone(.current, isLessThanOrEqualTo: date, inTimeZone: .utc)
  }
  
  func localDateIsGreaterThanOrEqualToUTCDate(_ date: Date) -> Bool {
    return inTimeZone(.current, isGreaterThanOrEqualTo: date, inTimeZone: .utc)
  }

  func inTimeZone(_ timeZoneA: TimeZone, isLessThan dateB: Date, inTimeZone timeZoneB: TimeZone) -> Bool {
    return inTimeZone(timeZoneA, compareTo: dateB, inTimeZone: timeZoneB) == .orderedAscending
  }
  
  func inTimeZone(_ timeZoneA: TimeZone, isGreaterThan dateB: Date, inTimeZone timeZoneB: TimeZone) -> Bool {
    return inTimeZone(timeZoneA, compareTo: dateB, inTimeZone: timeZoneB) == .orderedDescending
  }

  func inTimeZone(_ timeZoneA: TimeZone, isLessThanOrEqualTo dateB: Date, inTimeZone timeZoneB: TimeZone) -> Bool {
    let comparision = inTimeZone(timeZoneA, compareTo: dateB, inTimeZone: timeZoneB)
    return comparision == .orderedAscending || comparision == .orderedSame
  }
  
  func inTimeZone(_ timeZoneA: TimeZone, isGreaterThanOrEqualTo dateB: Date, inTimeZone timeZoneB: TimeZone) -> Bool {
    let comparision = inTimeZone(timeZoneA, compareTo: dateB, inTimeZone: timeZoneB)
    return comparision == .orderedDescending || comparision == .orderedSame
  }

  func inTimeZone(_ timeZoneA: TimeZone, isSameDayAs dateB: Date, inTimeZone timeZoneB: TimeZone) -> Bool {
    return inTimeZone(timeZoneA, compareTo: dateB, inTimeZone: timeZoneB) == .orderedSame
  }
  
  func inTimeZone(_ timeZoneA: TimeZone, compareTo dateB: Date, inTimeZone timeZoneB: TimeZone) -> ComparisonResult {
    let jdA = self.jd(inTimeZone: timeZoneA)
    let jdB = dateB.jd(inTimeZone: timeZoneB)
    
    if jdA < jdB {
        return .orderedAscending
    } else if jdA > jdB {
        return .orderedDescending
    } else {
        return .orderedSame
    }
  }
  
  func localTimeZoneDaysApartFromUTCDate(_ date: Date) -> Int {
    return inTimeZone(.current, daysApartFrom: date, inTimeZone: .utc)
  }
  
  func inTimeZone(_ timeZoneA: TimeZone, daysApartFrom dateB: Date, inTimeZone timeZoneB: TimeZone) -> Int {
    let jdA = self.dayInTimeZone(timeZoneA)
    let jdB = dateB.dayInTimeZone(timeZoneB)
    
    return jdA - jdB
  }
  
  func dayInTimeZone(_ timeZone: TimeZone) -> Int {
    return ldFromJd(jd(inTimeZone: timeZone))
  }
  
  func ldFromJd(_ jd: Double) -> Int {
    let LILIAN_DAY_BASE = 2_299_159.5
    return Int(jd - LILIAN_DAY_BASE)
  }

  func jd(inTimeZone timeZone: TimeZone) -> Double {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    
    let flags: Set<Calendar.Component> = Set(arrayLiteral: .year, .month, .day)
    let comps = calendar.dateComponents(flags, from: date)
    let year = comps.year!, month = comps.month!, day = comps.day!
    
    return jd(year: year, month: month, day: day)
  }
  
  func jd(year: Int, month: Int, day: Int) -> Double {
    let a = (14 - month) / 12
    let y = year + 4800 - a
    let m = month + 12 * a - 3
    let jd = day + (153 * m + 2) / 5 + y * 365 + y / 4 - y / 100 + y / 400 - 32045

    return Double(jd) - 0.5
  }
}
