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
  case workout(Workout, Challenge?)
  case profile(Account, Challenge)
  case currentAccount(Account)
  case completedChallenges
  case settings
  case about
  case challengeStats(Challenge, [Account], [Workout])
  
  var viewController: UIViewController {
    switch self {
    case .noChallenges:
      return NoChallengesViewController()
    case .home:
      return HomeViewController()
    case .activeChallenge(let challenge):
      return ChallengeTabBarController(challenge: challenge)
    case .challengeStats(let challenge, let members, let workouts):
      return ChallengeStatsViewController(challenge: challenge, members: members, workouts: workouts)
    case .createChallenge(let delegate):
      let createChallengeViewController = CreateChallengeViewController()
      createChallengeViewController.delegate = delegate
      
      return createChallengeViewController
    case .workout(let workout, let challenge):
      return WorkoutViewController(workout: workout, challenge: challenge)
    case .profile(let account, let challenge):
      return ProfileViewController(account: account, challenge: challenge)
    case .completedChallenges:
      return ArchivedChallengesTableViewController()
    case .settings:
      return SettingsViewController()
    case .about:
      return AboutViewController()
    case .currentAccount(let account):
      return ProfileViewController(account: account, challenge: nil).apply {
        $0.setupMenuButton()
        $0.navigationItem.rightBarButtonItem = UIBarButtonItem(
          image: .gear,
          style: .plain,
          target: $0,
          action: #selector(ProfileViewController.pushSettings)
        ).apply {
          $0.tintColor = .lightGray
        }
      }
    }
  }
}
