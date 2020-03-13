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
    
    let challenges = Challenge.State.all.resource
      .compactMap { $0?.object }
      .map { challenges in
        return challenges.filter { $0.isActive || $0.isUpcoming }
      }
      .share()
      
    let challengeSection = challenges
      .map { challenges -> MenuSection in
        let items: [MenuRow] = challenges.isNotEmpty ? challenges.map { MenuRow.challenge($0) } : [.home]
        
        return .init(model: false, items: items)
      }
    
    let items = Observable<[MenuRow.Item]>.just([.completed, .join, .start, .settings, .about])
      .map { MenuSection(model: true, items: $0.map { MenuRow.item($0) }) }
     
    Observable.combineLatest(profile, challengeSection, items)
      .map { things in
        let (profile, challenges, items) = things

        return [profile, challenges, items]
      }
      .bind(to: output.sections)
      .disposed(by: disposeBag)
    
    Observable.combineLatest(input.tappedRow, challenges)
      .compactMap { stuff -> (Navigation, Screen)? in
        let (indexPath, challenges) = stuff
        
        switch indexPath.section {
        case 0: return (.replaceDrawerCenterInNav(animated: true), .profile(GymRats.currentAccount))
        case 1: return {
          if challenges.isEmpty {
            return (.replaceDrawerCenterInNav(animated: true), .home)
          } else {
            return (.replaceDrawerCenter(animated: true), .activeChallenge(challenges[indexPath.row]))
          }
        }()
        case 2: return {
          switch indexPath.row {
          case 0: return (.replaceDrawerCenterInNav(animated: true), .completedChallenges)
          case 1: ChallengeFlow.join(); return nil
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
    
  }
}
