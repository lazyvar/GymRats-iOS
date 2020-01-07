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
        
        if count >= 8 && !UserDefaults.standard.bool(forKey: UserDefaultsKeys.requestReview) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                SKStoreReviewController.requestReview()
                Track.event(.storeReviewRequested)
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.requestReview)
            }
        }
    }

}

class UserDefaultsKeys {
  class var processCompletedCountKey: String { return "processCompletedCount" }
  class var requestReview: String { return "requestReview" }
}
