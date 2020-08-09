//
//  CompletedChallengeSection.swift
//  GymRats
//
//  Created by mack on 7/31/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxDataSources

typealias CompletedChallengeSection = SectionModel<String?, CompletedChallengeRow>

enum CompletedChallengeRow {
  case title(Challenge)
  case description(String?, NSAttributedString)
  case share(Challenge)
  case viewAllWorkouts(Challenge)
  case ranking(Ranking, Int, ScoreBy)
}
