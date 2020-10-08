//
//  NewChallenge.swift
//  GymRats
//
//  Created by mack on 4/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

struct NewChallenge {
  var name: String
  var description: String?
  var startDate: Date
  var endDate: Date
  var scoreBy: ScoreBy
  var banner: Either<UIImage, String>?
  var teamsEnabled: Bool
  var firstTeam: NewTeam?
}

struct NewTeam {
  var name: String
  var photoUrl: UIImage?
}

extension NewChallenge {
  var days: Int {
    let daysGone: Int = abs(startDate.utcDateIsDaysApartFromUtcDate(endDate)) + 1
    
    return daysGone
  }
}
