//
//  WorkoutFlow.swift
//  GymRats
//
//  Created by mack on 3/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

enum WorkoutFlow {
  private static let logWorkoutModalDelegate = LogWorkoutModalDelegate()
  private static let generator = UIImpactFeedbackGenerator(style: .heavy)
  private static let healthService: HealthServiceType = HealthService.shared
  
  static func logWorkout() {
    generator.impactOccurred()

    let logWorkoutModal = LogWorkoutModalViewController()
    logWorkoutModal.delegate = logWorkoutModalDelegate
      
    UIViewController.topmost().presentPanModal(logWorkoutModal)
  }
}
