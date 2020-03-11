//
//  Screen.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

struct Navigation {
  static let push = Navigation { $0.push($1) }
  static let present = Navigation { $0.present($1.inNav()) }
  static let install = Navigation { $0.install($1) }
  
  let action: (_ from: UIViewController, _ to: UIViewController) -> ()
}

enum Screen {
  case activeChallenge(Challenge)
  case noChallenges
  case home
  case createChallenge(CreateChallengeDelegate)
  
  var viewController: UIViewController {
    switch self {
    case .noChallenges:
      return NoChallengesViewController()
    case .home:
      return HomeViewController()
    case .activeChallenge(let challenge):
      return ChallengeViewControllerGrr(challenge: challenge)
    case .createChallenge(let delegate):
      let createChallengeViewControllerGrr = CreateChallengeViewControllerGrr()
      createChallengeViewControllerGrr.delegate = delegate
      
      return createChallengeViewControllerGrr
    }
  }
}
