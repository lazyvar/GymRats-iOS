//
//  Workout.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct Workout: Codable, Hashable {
  let id: Int
  let account: Account
  let challengeId: Int
  let title: String
  let description: String?
  let photoUrl: String?
  let googlePlaceId: String?
  let duration: Int?
  let distance: String?
  let steps: Int?
  let calories: Int?
  let points: Int?
  let appleDeviceName: String?
  let appleSourceName: String?
  let appleWorkoutUuid: String?
  let activityType: Activity?
  let occurredAt: Date
  
  var gymRatsUserId: Int {
    return account.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  enum Activity: String, Codable {
    case walking
    case running
    case cycling
    case hiit
    case yoga
    case hiking
    case baseketball
    case rowing
    case climbing
    case stairs
    case crossTraining
    case dance
    case cooldown
    case elliptical
    case wheelchair
    case functionalStrengthTraining
    case traditionalStrengthTraining
    case coreTraining
    case swimming
    case volleyball
    case other
    
    var title: String {
      switch self {
      case .hiit: return "HIIT"
      case .crossTraining: return "Cross training"
      case .functionalStrengthTraining: return "Functional strength training"
      case .traditionalStrengthTraining: return "Traditional strngth training"
      case .coreTraining: return "Core training"
      case .baseketball: return "Basketball"
        
      default: return rawValue
      }
    }
  }
}

extension Workout: Avatar {
  var avatarName: String? { return title }
  var avatarImageURL: String? { return photoUrl }
}
