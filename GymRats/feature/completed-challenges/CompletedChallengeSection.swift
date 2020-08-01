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
  case banner(String)
  case description(NSAttributedString)
  case share(Challenge)
  case startNewChallenge(Challenge)
  case ranking(Ranking, Int)
}
