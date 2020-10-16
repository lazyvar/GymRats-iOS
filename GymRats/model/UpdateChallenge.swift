//
//  UpdateChallenge.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

struct UpdateChallenge: Codable {
  var id: Int
  var name: String
  var description: String?
  var startDate: Date
  var endDate: Date
  var scoreBy: ScoreBy
  var banner: String?
  var teamsEnabled: Bool
}
