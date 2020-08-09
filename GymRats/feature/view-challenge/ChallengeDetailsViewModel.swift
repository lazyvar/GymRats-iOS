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
        Observable.combineLatest(gymRatsAPI.getGroupStats(for: self.challenge), gymRatsAPI.getRankings(challenge: self.challenge, scoreBy: self.challenge.scoreBy))
      }
      .do(onNext: { _ in
        self.output.loading.on(.next(false))
      })
      .compactMap { groupStatsResult, rankingsResult -> (GroupStats, [Ranking])? in
        guard let groupStats = groupStatsResult.object, let rankings = rankingsResult.object else { return nil }
      
        return (groupStats, rankings)
      }
      .map { groupStats, rankings -> [ChallengeDetailsSection] in
        let members = rankings.shuffled().map { $0.account }
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
        
        let workoutsPerDay = String(format: "%.2f", CGFloat(groupStats.totalWorkouts) / CGFloat(self.challenge.days.count))
        
        let groupStats: [ChallengeDetailsRow] = {
          if self.challenge.scoreBy == .workouts {
            return [
              .groupStats(nil, UIImage.activity, top: String(groupStats.totalWorkouts), bottom: "Total workouts", right: nil),
              .groupStats(nil, UIImage.cal, top: workoutsPerDay, bottom: "Average workouts per day", right: nil),
              .groupStats(groupStats.mostEarlyBirdWorkouts.account, nil, top: groupStats.mostEarlyBirdWorkouts.account.fullName, bottom: "Most early bird workouts", right: String(groupStats.mostEarlyBirdWorkouts.numberOfWorkouts)),
            ]
          } else {
            return [
              .groupStats(nil, UIImage.activity, top: String(groupStats.totalWorkouts), bottom: "Total workouts", right: nil),
              .groupStats(nil, UIImage.star, top: String(groupStats.totalScore), bottom: "Total \(self.challenge.scoreBy.description)", right: nil),
              .groupStats(nil, UIImage.cal, top: workoutsPerDay, bottom: "Average workouts per day", right: nil),
              .groupStats(groupStats.mostEarlyBirdWorkouts.account, nil, top: groupStats.mostEarlyBirdWorkouts.account.fullName, bottom: "Most early bird workouts", right: String(groupStats.mostEarlyBirdWorkouts.numberOfWorkouts)),
            ]
          }
        }()
        
        return [
          ChallengeDetailsSection(model: nil, items: [.title(self.challenge), .header(self.challenge)]),
          ChallengeDetailsSection(model: membersHeader, items: [.members(members)]),
          ChallengeDetailsSection(model: "Rankings", items: ordered.map { ranking in
            ChallengeDetailsRow.ranking(ranking.0, place: ranking.place, self.challenge.scoreBy)
          } + [.fullLeaderboard]),
          ChallengeDetailsSection(model: "Group stats", items: groupStats)
        ]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
  }
}
