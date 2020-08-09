//
//  ChallengeRow.swift
//  GymRats
//
//  Created by mack on 3/23/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxDataSources

enum ChallengeRow {
  case title(Challenge)
  case banner(Challenge, ChallengeInfo)
  case workout(Workout)
  case noWorkouts(Challenge)
  case 💀(Int)
}

extension ChallengeRow: Equatable {
  static func == (lhs: ChallengeRow, rhs: ChallengeRow) -> Bool {
    switch (lhs, rhs) {
    case (.title(let a), .title(let b)):
      return a == b
    case (.banner(let challenge1, let challegneInfo1), .banner(let challenge2, let challengeInfo2)):
      return challenge1 == challenge2 && challegneInfo1 == challengeInfo2
    case (.workout(let workout1), .workout(let workout2)):
      return workout1 == workout2
    case (.noWorkouts, noWorkouts): return true
    default: return false
    }
  }
}

extension ChallengeRow: IdentifiableType {
  public var identity: Int {
    switch self {
    case .title: return 2
    case .banner: return 0
    case .noWorkouts: return -1
    case .workout(let workout): return workout.id
    case .💀(let row): return row
    }
  }
}

extension Optional: IdentifiableType where Wrapped == Date {
  public var identity: Double {
    switch self {
    case .some(let date): return date.julianDay
    case .none: return 0
    }
  }
}
