//
//  StoreService.swift
//  GymRats
//
//  Created by mack on 11/9/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import StoreKit

class StoreService {
  private static let countKey = "processCompletedCount"
  private static let lastAskJulianDayKey = "lastAskJulianDay"

  static func requestReview() {
    let lastAskJulianDay = UserDefaults.standard.integer(forKey: lastAskJulianDayKey)
    let currentJulianDay = Int(Date().julianDay)
    let count = UserDefaults.standard.integer(forKey: countKey) + 1
    
    defer { UserDefaults.standard.set(count, forKey: countKey) }

    guard count >= 8, currentJulianDay > (lastAskJulianDay + 90) else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      SKStoreReviewController.requestReview()
      UserDefaults.standard.set(currentJulianDay, forKey: lastAskJulianDayKey)
      Track.event(.storeReviewRequested)
    }
  }
}
