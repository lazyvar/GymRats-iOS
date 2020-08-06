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
  case header(Challenge)
  case members([Account])
  case ranking(Ranking, place: Int, ScoreBy)
  case fullLeaderboard
  case groupStats(Avatar?, UIImage?, top: String, bottom: String, right: String?)
}
