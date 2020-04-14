//
//  ScoreBy.swift
//  GymRats
//
//  Created by mack on 4/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum ScoreBy: Int, CaseIterable {
  case totalWorkouts
  case exerciseMinutes
  case miles
  case steps
  case calories
  case points
  
  var display: String {
    switch self {
    case .totalWorkouts: return "Total workouts"
    case .exerciseMinutes: return "Minutes"
    case .miles: return "Miles"
    case .steps: return "Steps"
    case .calories: return "Calories"
    case .points: return "Points"
    }
  }
}
