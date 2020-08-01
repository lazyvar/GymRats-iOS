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
  case chooseChallengeMode
  case workout(Workout, Challenge?)
  case profile(Account, Challenge)
  case currentAccount(Account)
  case completedChallenges
  case settings
  case about
  case challengeStats(Challenge)
  case chat(Challenge)
  case upcomingChallenge(Challenge)
  case login
  case getStarted
  case map(placeID: String)
  case completedChallenge(Challenge)
  
  var viewController: UIViewController {
    switch self {
    case .completedChallenge(let challenge):
      return CompletedChallengeViewController(challenge: challenge)
    case .map(placeID: let place):
      return MapViewController(placeID: place)
    case .noChallenges:
      return NoChallengesViewController()
    case .home:
      return HomeViewController()
    case .upcomingChallenge(let challenge):
      return UpcomingChallengeViewController(challenge: challenge)
    case .activeChallenge(let challenge):
      return ChallengeTabBarController(challenge: challenge)
    case .challengeStats(let challenge):
      return ChallengeStatsViewController(challenge: challenge)
    case .chooseChallengeMode:
      return ChooseChallengeModeViewController()
    case .workout(let workout, let challenge):
      return WorkoutViewController(workout: workout, challenge: challenge)
    case .profile(let account, let challenge):
      return ProfileViewController(account: account, challenge: challenge)
    case .completedChallenges:
      return CompletedChallengesViewController()
    case .chat(let challenge):
      return ChatViewController(challenge: challenge)
    case .settings:
      return SettingsViewController()
    case .login:
      return LoginViewController()
    case .getStarted:
      return CreateAccountViewController()
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
        )
      }
    }
  }
}
