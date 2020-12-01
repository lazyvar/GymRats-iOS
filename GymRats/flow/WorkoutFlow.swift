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
  private static let healthAppDelegate = HealthAppDelegate()
  private static let logWorkoutModalDelegate = LogWorkoutModalDelegate()
  private static let generator = UIImpactFeedbackGenerator(style: .heavy)
  private static let healthService: HealthServiceType = HealthService.shared
  
  static func logWorkout() {
    defer { healthService.markPromptSeen() }

    generator.impactOccurred()

    if healthService.didShowGymRatsPrompt {
      presentWorkoutModal()
    } else {
      let healthAppViewController = HealthAppViewController()
      healthAppViewController.delegate = healthAppDelegate
      healthAppViewController.title = "Sync with Health app?"
      
      UIViewController.topmost().presentInNav(healthAppViewController)
    }
  }
  
  static func presentWorkoutModal() {
    let logWorkoutModal = LogWorkoutModalViewController()
    logWorkoutModal.delegate = logWorkoutModalDelegate
      
    UIViewController.topmost().presentPanModal(logWorkoutModal)
  }
}
