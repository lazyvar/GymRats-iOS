//
//  UpcomingChallengeViewModel.swift
//  GymRats
//
//  Created by mack on 4/9/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class UpcomingChallengeViewModel: ViewModel {
  private let disposeBag = DisposeBag()

  struct Input {
    let refresh = PublishSubject<Void>()
    let viewDidLoad = PublishSubject<Void>()
  }

  struct Output {
    let sections = PublishSubject<[UpcomingChallengeSection]>()
    let error = PublishSubject<Error>()
    let navigation = PublishSubject<(Navigation, Screen)>()
    let loading = PublishSubject<Bool>()
  }

  let input = Input()
  let output = Output()

  init(challenge: Challenge) {
    let joinedTeam = NotificationCenter.default.rx.notification(.joinedTeam).map { _ in () }

    let refresh = Observable.merge(input.viewDidLoad, input.refresh, joinedTeam)
      .share()

    let fetchMembers = refresh
      .flatMap { gymRatsAPI.getMembers(for: challenge) }
      .share()

    let fetchTeams = refresh
      .flatMap { gymRatsAPI.fetchTeams(challenge: challenge) }
      .share()

    refresh
      .map { _ in true }
      .bind(to: output.loading)
      .disposed(by: disposeBag)

    fetchMembers
      .compactMap { $0.error }
      .bind(to:output.error)
      .disposed(by: disposeBag)

    fetchTeams
      .compactMap { $0.error }
      .bind(to:output.error)
      .disposed(by: disposeBag)

    let members = Observable.merge(.just([]), fetchMembers.compactMap { $0.object })
    let teams = Observable.merge(.just([]), fetchTeams.compactMap { $0.object })

    let membersAndTeams = Observable.combineLatest(members, teams)
      .skip(1)
      .share()
    
    membersAndTeams
      .map { _ in false }
      .bind(to: output.loading)
      .disposed(by: disposeBag)

    membersAndTeams
      .map { members, teams in
        print(members)
        print(teams)

        let info = UpcomingChallengeSection(model: nil, items: [.challengeInfo(challenge), .invite(challenge)])
        let rats = UpcomingChallengeSection(model: "Rats", items: members.map { UpcomingChallengeRow.rat($0) })
        let teamSection = UpcomingChallengeSection(model: "Teams", items: [.teams(teams)])

        if challenge.teamsEnabled {
          return [info, teamSection, rats]
        } else {
          return  [info, rats]
        }
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)

  }
}
