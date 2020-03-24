//
//  ChallengeRow.swift
//  GymRats
//
//  Created by mack on 3/23/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum ChallengeRow {
  case banner(Challenge, [Account], [Workout])
  case workout(Workout)
  case noWorkouts(Challenge, () -> Void)
}

extension ChallengeRow: Equatable {
  static func == (lhs: ChallengeRow, rhs: ChallengeRow) -> Bool {
    switch (lhs, rhs) {
    case (.banner(let challenge1, let members1, let workouts1), .banner(let challenge2, let members2, let workouts2)):
      return challenge1 == challenge2 && members1 == members2 && workouts1 == workouts2
    case (.workout(let workout1), .workout(let workout2)):
      return workout1 == workout2
    case (.noWorkouts, noWorkouts): return true
    default: return false
    }
  }
}
