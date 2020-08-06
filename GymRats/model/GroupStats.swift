//
//  GroupStats.swift
//  GymRats
//
//  Created by mack on 8/5/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

struct GroupStats: Codable {
  let totalWorkouts: Int
  let totalScore: String
  let mostEarlyBirdWorkouts: MostEarlyBirdWorkouts
  
  struct MostEarlyBirdWorkouts: Codable {
    let account: Account
    let numberOfWorkouts: Int
  }
}
