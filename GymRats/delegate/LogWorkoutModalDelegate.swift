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
  func didImportWorkout(_ logWorkoutModalViewController: LogWorkoutModalViewController, workout: HKWorkout) {
    let createWorkoutViewController = CreateWorkoutViewController(healthKitWorkout: workout)

    logWorkoutModalViewController.presentForClose(createWorkoutViewController)
  }
  
  func didPickMedia(_ logWorkoutModalViewController: LogWorkoutModalViewController, media: [YPMediaItem]) {
    let createWorkoutViewController = CreateWorkoutViewController(media: media)

    logWorkoutModalViewController.presentForClose(createWorkoutViewController)
  }
}
