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

  var gymRatsUserId: Int {
    return account.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Workout: AvatarProtocol {
  var pictureUrl: String? {
    return photoUrl
  }

  var myName: String? {
    return title
  }
}
