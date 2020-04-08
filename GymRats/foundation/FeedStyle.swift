//
//  FeedStyle.swift
//  GymRats
//
//  Created by mack on 4/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

enum FeedStyle: String {
  case list
  case big
  
  var image: UIImage {
    switch self {
    case .list: return .big
    case .big: return .list
    }
  }
  
  static func stlye(for challenge: Challenge) -> FeedStyle {
    let cached = UserDefaults.standard.string(forKey: "challenge_\(challenge.id)_feed_style") ?? ""
    
    return FeedStyle(rawValue: cached) ?? .list
  }
  
  static func set(style: FeedStyle, for challenge: Challenge) {
    UserDefaults.standard.set(style.rawValue, forKey: "challenge_\(challenge.id)_feed_style")
  }
  
  static func toggleStyle(for challenge: Challenge) {
    switch stlye(for: challenge) {
    case .list: set(style: .big, for: challenge)
    case .big: set(style: .list, for: challenge)
    }
  }
}
