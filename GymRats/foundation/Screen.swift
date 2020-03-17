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
  case profile(Account, Challenge?)
  case completedChallenges
  case settings
  case about
  
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
    case .workout(let workout, let challenge):
      return WorkoutViewController(workout: workout, challenge: challenge)
    case .profile(let account, let challenge):
      return ProfileViewController(user: account, challenge: challenge)
    case .completedChallenges:
      return ArchivedChallengesTableViewController()
    case .settings:
      return SettingsViewController()
    case .about:
      return AboutViewController()
    }
  }
}

//let profile = ProfileViewController(user: GymRats.currentAccount, challenge: nil)
//let nav = UINavigationController(rootViewController: profile)
//
//profile.setupMenuButton()
//let gear = UIImage(named: "gear")!.withRenderingMode(.alwaysTemplate)
//let gearItem = UIBarButtonItem(image: gear, style: .plain, target: profile, action: #selector(ProfileViewController.transitionToSettings))
//gearItem.tintColor = .lightGray
//
//profile.navigationItem.rightBarButtonItem = gearItem
//
//GymRatsApp.coordinator.drawer.setCenterView(nav, withCloseAnimation: true, completion: nil)
