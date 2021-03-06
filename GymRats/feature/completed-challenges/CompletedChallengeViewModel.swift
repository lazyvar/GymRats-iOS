//
//  CompletedChallengeViewModel.swift
//  GymRats
//
//  Created by mack on 7/31/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class CompletedChallengeViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  private var challenge: Challenge!
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
  }
  
  struct Output {
    let sections = PublishSubject<[CompletedChallengeSection]>()
  }
  
  let input = Input()
  let output = Output()
  
  func configure(challenge: Challenge) {
    self.challenge = challenge
  }
  
  init() {
    input.viewDidLoad
      .flatMap { gymRatsAPI.getRankings(challenge: self.challenge, scoreBy: self.challenge.scoreBy) }
      .compactMap { $0.object }
      .map { rankings -> ([Ranking], [CompletedChallengeRow]) in
        return (
          rankings,
          [
            .title(self.challenge),
            .description(self.challenge.profilePictureUrl, self.description(for: self.challenge, rankings: rankings)),
            .share(self.challenge),
            .viewAllWorkouts(self.challenge)
          ]
        )
      }
      .map { rankings, rows -> [CompletedChallengeSection] in
        return [
          CompletedChallengeSection(model: nil, items: rows),
          CompletedChallengeSection(model: "Final rankings", items: rankings.enumerated().map { ranking in
            CompletedChallengeRow.ranking(ranking.element, ranking.offset + 1, self.challenge.scoreBy)
          })
        ]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
  }
  
  private func description(for challenge: Challenge, rankings: [Ranking]) -> NSAttributedString {
    let total = rankings.map { Double($0.score) ?? 0.0 }.reduce(0, +)
    let first = NSAttributedString(string: "\(Int(total)) \(challenge.scoreBy.description) were logged over the course of \(challenge.days.count) days by \(rankings.count) members. Nice job. Congratulations to ")
    let rest = NSAttributedString(string: " on first place.")
    let bold = NSAttributedString(string: "\(rankings.first?.account.fullName ?? "")", attributes: [
      NSAttributedString.Key.font: UIFont.bodyBold
    ])

    return NSMutableAttributedString().apply {
      $0.append(first)
      $0.append(bold)
      $0.append(rest)
    }
  }
}
