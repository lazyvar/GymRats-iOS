//
//  HealthAppDelegate.swift
//  GymRats
//
//  Created by mack on 11/30/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

class HealthAppDelegate: HealthAppViewControllerDelegate {
  func close(_ healthAppViewController: HealthAppViewController) {
    healthAppViewController.dismiss(animated: true) {
      WorkoutFlow.presentWorkoutModal()
    }
  }
  
  func closeButtonHidden() -> Bool {
    return false
  }
}
