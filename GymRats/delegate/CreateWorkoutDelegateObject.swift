//
//  CreateWorkoutDelegateOjbect.swift
//  GymRats
//
//  Created by mack on 3/16/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

class CreateWorkoutDelegateObject: CreatedWorkoutDelegate {
  func createWorkoutController(_ createWorkoutController: CreateWorkoutViewController, created workout: Workout) {
    createWorkoutController.dismissSelf()
    NotificationCenter.default.post(name: .workoutCreated, object: workout)
  }
}
