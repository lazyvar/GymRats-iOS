//
//  MenuViewModel.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class MenuViewModel: ViewModel {
  
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tappedRow = PublishSubject<IndexPath>()
  }
  
  struct Output {
    let error = PublishSubject<Error>()
    let sections = PublishSubject<[MenuSection]>()
    let navigation = PublishSubject<(Navigation, Screen)>()
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    let profile = Observable.just(
      MenuSection(model: false, items: [.profile(GymRats.currentAccount)])
    )

    let challenges = Challenge.State.all.observe()
      .compactMap { $0.object }
      .map { challenges in
        return challenges.filter { $0.isActive || $0.isUpcoming }
      }
      .share()
    
    let challengeSection = Observable.merge(.just([]), challenges)
      .map { challenges -> MenuSection in
        let items: [MenuRow] = challenges.isNotEmpty ? challenges.map { MenuRow.challenge($0) } : [.home]
        
        return .init(model: false, items: items)
      }
    
    let items = Observable<[MenuRow.Item]>.just([.completed, .join, .start, .settings, .about])
      .map { MenuSection(model: true, items: $0.map { MenuRow.item($0) }) }
     
    let stuff = Observable.combineLatest(profile, challengeSection, items)
    let viewDidLoadWithStuff = input.viewDidLoad.withLatestFrom(stuff)
    
    Observable.merge(viewDidLoadWithStuff, stuff)
      .map { things in
        let (profile, challenges, items) = things

        return [profile, challenges, items]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
    
    input.tappedRow
      .filter { $0.section == 2 && $0.row == 1 }
      .flatMap { _ in ChallengeFlow.join() }
      .do(onNext: { challenge in
        UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
      })
      .map { challenge -> (Navigation, Screen) in (.replaceDrawerCenter(animated: true), .activeChallenge(challenge)) }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)

    input.tappedRow.withLatestFrom(challenges, resultSelector: { ($0, $1) })
      .compactMap { stuff -> (Navigation, Screen)? in
        let (indexPath, challenges) = stuff
        
        switch indexPath.section {
        case 0: return (.replaceDrawerCenterInNav(animated: true), .currentAccount(GymRats.currentAccount))
        case 1:
          if challenges.isEmpty {
            return (.replaceDrawerCenterInNav(animated: true), .home)
          } else {
            let challenge = challenges[indexPath.row]
            
            UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")

            return (.replaceDrawerCenter(animated: true), .activeChallenge(challenge))
          }
        case 2: return {
          switch indexPath.row {
          case 0: return (.replaceDrawerCenterInNav(animated: true), .completedChallenges)
          case 1: return nil
          case 2: return (.presentInNav(animated: true), .createChallenge(self))
          case 3: return (.replaceDrawerCenterInNav(animated: true), .settings)
          case 4: return (.replaceDrawerCenterInNav(animated: true), .about)
          default: fatalError("Unhandled row")
          }
        }()
        default: fatalError("Unhandled section")
        }
      }
      .bind(to: output.navigation)
      .disposed(by: disposeBag)
  }
}

extension MenuViewModel: CreateChallengeDelegate {
  func challengeCreated(challenge: Challenge) {
    Challenge.State.all.fetch().ignore(disposedBy: disposeBag)
    UserDefaults.standard.set(challenge.id, forKey: "last_opened_challenge")
    output.navigation.on(.next((.replaceDrawerCenter(animated: true), .activeChallenge(challenge))))
  }
}
