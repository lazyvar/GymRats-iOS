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

        let infoDictionaryKey = kCFBundleVersionKey as String
        
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else { fatalError("Expected to find a bundle version in the info dictionary") }
        
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
        
        if count >= 10 && currentVersion != lastVersionPromptedForReview {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
            }
        }
    }
    
}

class UserDefaultsKeys {
  class var processCompletedCountKey: String { return "processCompletedCount" }
  class var lastVersionPromptedForReviewKey: String { return "lastVersionPromptedForReview" }
}
