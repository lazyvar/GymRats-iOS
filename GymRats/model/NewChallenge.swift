//
//  NewChallenge.swift
//  GymRats
//
//  Created by mack on 4/14/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

struct NewChallenge {
  var name: String
  var description: String?
  var startDate: Date
  var endDate: Date
  var scoreBy: ScoreBy
  var banner: UIImage?
}
