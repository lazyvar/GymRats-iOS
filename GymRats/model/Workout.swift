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
  let createdAt: Date
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
    case other
  }
}

extension Workout: Avatar {
  var avatarName: String? { return title }
  var avatarImageURL: String? { return photoUrl }
}
