//
//  ChallengeDetailsSection.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxDataSources
import UIKit

typealias ChallengeDetailsSection = SectionModel<String?, ChallengeDetailsRow>

enum ChallengeDetailsRow {
  case title(Challenge)
  case header(Challenge)
  case members([Account])
  case teams([Team])
  case ranking(Ranking, place: Int, ScoreBy)
  case teamRanking(TeamRanking, place: Int, ScoreBy)
  case fullIndividualLeaderboard
  case fullTeamLeaderboard
  case groupStats(Avatar?, UIImage?, top: String, bottom: String, right: String?)
}
