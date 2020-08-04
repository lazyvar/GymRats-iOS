//
//  ChallengeDetailsViewModel.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class ChallengeDetailsViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  private var challenge: Challenge!
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let sections = PublishSubject<[ChallengeDetailsSection]>()
  }

  let input = Input()
  let output = Output()

  func configure(challenge: Challenge) {
    self.challenge = challenge
  }
  
  init() {
    let fetch = input.viewDidLoad.flatMap {
      Observable.combineLatest(gymRatsAPI.getMembers(for: self.challenge), gymRatsAPI.getRankings(challenge: self.challenge))
    }
    
    fetch.compactMap { memberResult, rankingsResult -> ([Account], [Ranking])? in
      guard let members = memberResult.object, let rankings = rankingsResult.object else { return nil }
      
      return (members, rankings)
    }
    .map { members, rankings -> [ChallengeDetailsSection] in
      return [
        ChallengeDetailsSection(model: nil, items: [.header(self.challenge)]),
        ChallengeDetailsSection(model: "Members", items: [.members(members)]),
        ChallengeDetailsSection(model: "Rankings", items: rankings.map { ChallengeDetailsRow.ranking($0) } + [.fullLeaderboard]),
        ChallengeDetailsSection(model: "Group stats", items: [.groupStats])
      ]
    }
    .bind(to: output.sections)
    .disposed(by: disposeBag)
  }
}
