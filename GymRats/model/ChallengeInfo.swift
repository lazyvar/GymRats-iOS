//
//  ChallengeInfo.swift
//  GymRats
//
//  Created by mack on 3/24/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

struct ChallengeInfo: Decodable, Equatable {
  let memberCount: Int
  let workoutCount: Int
  let leader: Account
  let teamLeader: Team?
  let teamLeaderScore: String?
  let currentTeamScore: String?
  let currentTeam: Team?
  let leaderScore: String
  let currentAccountScore: String
}
