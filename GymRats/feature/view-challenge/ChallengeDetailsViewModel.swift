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
    let loading = PublishSubject<Bool>()
  }

  let input = Input()
  let output = Output()

  func configure(challenge: Challenge) {
    self.challenge = challenge
  }
  
  init() {
    input.viewDidLoad
      .do(onNext: { _ in
        self.output.loading.on(.next(true))
      })
      .flatMap {
        Observable.combineLatest(gymRatsAPI.getMembers(for: self.challenge), gymRatsAPI.getRankings(challenge: self.challenge, scoreBy: self.challenge.scoreBy))
      }
      .do(onNext: { _ in
        self.output.loading.on(.next(false))
      })
      .compactMap { memberResult, rankingsResult -> ([Account], [Ranking])? in
        guard let members = memberResult.object, let rankings = rankingsResult.object else { return nil }
      
        return (members, rankings)
      }
      .map { members, rankings -> [ChallengeDetailsSection] in
        let myRank = rankings.firstIndex(where: { $0.account.id == GymRats.currentAccount.id })
        let firstRank = rankings.first
        let secondRank = rankings[safe: 1]
        
        let ordered: [(Ranking, place: Int)] = {
          if let myRank = myRank {
            let firstRank = firstRank!
            
            if firstRank.account.id != GymRats.currentAccount.id {
              let me = rankings[myRank]
              
              return [(firstRank, place: 1), (me, place: myRank + 1)]
            } else {
              if let secondRank = secondRank {
                return [(firstRank, place: 1), (secondRank, place: 2)]
              } else {
                return [(rankings.first!, place: 1)]
              }
            }
          } else if let firstRank = firstRank {
            return [(firstRank, place: 1)]
          } else {
            return []
          }
        }()
        
        let membersHeader: String = {
          if members.count == 1 {
            return "Solo challenge"
          } else {
            return "\(members.count) Rats"
          }
        }()
        
        return [
          ChallengeDetailsSection(model: nil, items: [.header(self.challenge)]),
          ChallengeDetailsSection(model: membersHeader, items: [.members(members)]),
          ChallengeDetailsSection(model: "Rankings", items: ordered.map { ranking in
            ChallengeDetailsRow.ranking(ranking.0, place: ranking.place, self.challenge.scoreBy)
          } + [.fullLeaderboard]),
          ChallengeDetailsSection(model: "Group stats", items: [.groupStats])
        ]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
  }
}
