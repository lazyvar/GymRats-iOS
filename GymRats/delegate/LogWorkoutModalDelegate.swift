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
  func didImportSteps(_ navigationController: UINavigationController, steps: StepCount) {
    let createWorkoutViewController = GoodGoodNotBadViewController(healthAppSource: .right(steps))
//    createWorkoutViewController.delegate = self

    navigationController.pushViewController(createWorkoutViewController, animated: true)
  }

  func didImportWorkout(_ navigationController: UINavigationController, workout: HKWorkout) {
    let createWorkoutViewController = GoodGoodNotBadViewController(healthAppSource: .left(workout))
//    createWorkoutViewController.delegate = self

    navigationController.pushViewController(createWorkoutViewController, animated: true)
  }

  func didPickMedia(_ picker: YPImagePicker, media: [YPMediaItem]) {
    let createWorkoutViewController = GoodGoodNotBadViewController(media: media)
//    createWorkoutViewController.delegate = self

    picker.pushViewController(createWorkoutViewController, animated: true)
  }
}

extension LogWorkoutModalDelegate: CreatedWorkoutDelegate {
  func createWorkoutController(created workout: Workout) {
    NotificationCenter.default.post(name: .workoutCreated, object: workout)
    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
  }
}
