//
//  WorkoutFlow.swift
//  GymRats
//
//  Created by mack on 3/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

enum WorkoutFlow {
  private static let createWorkoutDelegate = CreateWorkoutDelegateObject()
  private static let generator = UIImpactFeedbackGenerator(style: .heavy)
  private static let healthService: HealthServiceType = HealthService.shared
  
  static func logWorkout() {
    generator.impactOccurred()

    if healthService.didShowGymRatsPrompt {
      presentWorkoutModal()
    } else {
      let healthAppViewController = HealthAppViewController()

      UIViewController.topmost().presentInNav(healthAppViewController)
    }
  }
  
  private static func presentWorkoutModal() {
    let logWorkoutModal = LogWorkoutModalViewController() { image in
      let createWorkoutViewController = CreateWorkoutViewController(workout: .left(image))
      createWorkoutViewController.delegate = createWorkoutDelegate
      
      UIViewController.topmost().present(createWorkoutViewController.inNav(), animated: true, completion: nil)
    }
    
    UIViewController.topmost().presentPanModal(logWorkoutModal)
  }
}
