//
//  ChallengeTabBarController.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class ChallengeTabBarController: ESTabBarController {

  // MARK: Init

  private let challenge: Challenge
  private let generator = UIImpactFeedbackGenerator(style: .heavy)
  
  init(challenge: Challenge) {
    self.challenge = challenge
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewControllers = [
      UIViewController().apply {
        $0.tabBarItem = UITabBarItem(title: nil, image: .standings, selectedImage: .standings)
      },
      ChallengeViewController(challenge: challenge).inNav().apply {
        $0.tabBarItem = ESTabBarItem(BigContentView(), title: nil, image: .activityLargeWhite, selectedImage: .activityLargeWhite)
      },
      UIViewController().apply {
        $0.tabBarItem = UITabBarItem(title: nil, image: .chatGray, selectedImage: .chatGray)
        $0.tabBarItem?.badgeColor = .brand
      }
    ]
    
    configureTabBar()
    didHijackHandler = hijack
    shouldHijackHandler = { _, _, _ in return true }
    selectedIndex = 1
  }
}

private extension ChallengeTabBarController {

  private func hijack(tabBar: UITabBarController, viewController: UIViewController, index: Int) {
    switch index {
    case 0: pushStats()
    case 1: presentCreateWorkout()
    case 2: pushChat()
    default: fatalError("Unexpected index.")
    }
  }
  
  private func pushStats() {
    push(
      ChallengeStatsViewController(challenge: challenge, users: [], workouts: [])
    )
  }
  
  private func presentCreateWorkout() {
    GymRatsApp.coordinator.menu.activeChallenges = [challenge] // TODO: don't do this
    generator.impactOccurred()

    let logWorkoutModal = LogWorkoutModalViewController() { image in
      let createWorkoutViewController = BadNewWorkoutViewController(workoutImage: image)
      createWorkoutViewController.delegate = self
      
      self.present(createWorkoutViewController.inNav(), animated: true, completion: nil)
    }
    
    presentPanModal(logWorkoutModal)
  }
  
  private func pushChat() {
    push(
      ChatViewController(challenge: challenge)
    )
  }
  
  private func configureTabBar() {
    let pxWhiteThing = UIView(frame: CGRect(x: 0, y: -1, width: tabBar.frame.width, height: 1)).apply {
      $0.backgroundColor = .background
    }

    tabBar.isTranslucent = false
    tabBar.shadowImage = UIImage()
    tabBar.backgroundImage = UIImage()
    tabBar.layer.shadowOffset = .zero
    tabBar.layer.shadowRadius = 10
    tabBar.layer.shadowColor = UIColor.shadow.cgColor
    tabBar.layer.shadowOpacity = 0.5
    tabBar.barTintColor = .background
    tabBar.addSubview(pxWhiteThing)
    tabBar.sendSubviewToBack(pxWhiteThing)
  }
}

extension ChallengeTabBarController: NewWorkoutDelegate {
  func newWorkoutController(_ newWorkoutController: BadNewWorkoutViewController, created workouts: [Workout]) {
    // TODO
  }
}
