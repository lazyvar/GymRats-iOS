//
//  Stats.swift
//  GymRats
//
//  Created by mack on 10/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

struct Stats: Codable {
  let duration: String
  let distance: String
  let steps: String
  let calories: String
  let points: String
  let workouts: Int
}
