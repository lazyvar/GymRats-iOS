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
  static func requestReview() {
    var count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.processCompletedCountKey)
    count += 1
    UserDefaults.standard.set(count, forKey: UserDefaultsKeys.processCompletedCountKey)
    
    let lastAskJulianDay = UserDefaults.standard.integer(forKey: UserDefaultsKeys.lastAskJulianDay)
    let currentJulianDay = Int(Date().julianDay)
    
    if count >= 8, currentJulianDay > (lastAskJulianDay + 60) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        SKStoreReviewController.requestReview()
        Track.event(.storeReviewRequested)
        UserDefaults.standard.set(currentJulianDay, forKey: UserDefaultsKeys.lastAskJulianDay)
      }
    }
  }
}

class UserDefaultsKeys {
  class var processCompletedCountKey: String { return "processCompletedCount" }
  class var lastAskJulianDay: String { return "lastAskJulianDay" }
}
