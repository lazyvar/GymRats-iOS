//
//  LogWorkoutModalDelegate.swift
//  GymRats
//
//  Created by mack on 12/1/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import HealthKit
import YPImagePicker

class LogWorkoutModalDelegate: LogWorkoutModalViewControllerDelegate {
  func didImportSteps(_ logWorkoutModalViewController: LogWorkoutModalViewController, steps: StepCount) {
    let createWorkoutViewController = CreateWorkoutViewController(healthAppSource: .right(steps))
    createWorkoutViewController.delegate = self

    logWorkoutModalViewController.presentForClose(createWorkoutViewController)
  }

  func didImportWorkout(_ logWorkoutModalViewController: LogWorkoutModalViewController, workout: HKWorkout) {
    let createWorkoutViewController = CreateWorkoutViewController(healthAppSource: .left(workout))
    createWorkoutViewController.delegate = self

    logWorkoutModalViewController.presentForClose(createWorkoutViewController)
  }
  
  func didPickMedia(_ logWorkoutModalViewController: LogWorkoutModalViewController, media: [YPMediaItem]) {
    let createWorkoutViewController = CreateWorkoutViewController(media: media)
    createWorkoutViewController.delegate = self

    logWorkoutModalViewController.presentForClose(createWorkoutViewController)
  }
}

extension LogWorkoutModalDelegate: CreatedWorkoutDelegate {
  func createWorkoutController(created workout: Workout) {
    NotificationCenter.default.post(name: .workoutCreated, object: workout)
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
  }
}
