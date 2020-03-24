//
//  ChallengeRow.swift
//  GymRats
//
//  Created by mack on 3/23/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum ChallengeRow {
  case banner(Challenge, ChallengeInfo)
  case workout(Workout)
  case noWorkouts(Challenge, () -> Void)
}

extension ChallengeRow: Equatable {
  static func == (lhs: ChallengeRow, rhs: ChallengeRow) -> Bool {
    switch (lhs, rhs) {
    case (.banner(let challenge1, let challegneInfo1), .banner(let challenge2, let challengeInfo2)):
      return challenge1 == challenge2 && challegneInfo1 == challengeInfo2
    case (.workout(let workout1), .workout(let workout2)):
      return workout1 == workout2
    case (.noWorkouts, noWorkouts): return true
    default: return false
    }
  }
}
