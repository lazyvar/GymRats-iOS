//
//  Screen.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

enum Screen {
  case activeChallenge(Challenge)
  case noChallenges
  case home
  case createChallenge(CreateChallengeDelegate)
  case workout(Workout)
  
  var viewController: UIViewController {
    switch self {
    case .noChallenges:
      return NoChallengesViewController()
    case .home:
      return HomeViewController()
    case .activeChallenge(let challenge):
      return ChallengeTabBarController(challenge: challenge)
    case .createChallenge(let delegate):
      let createChallengeViewController = CreateChallengeViewController()
      createChallengeViewController.delegate = delegate
      
      return createChallengeViewController
    case .workout(let workout):
      return WorkoutViewController(workout: workout, challenge: nil)
    }
  }
}
