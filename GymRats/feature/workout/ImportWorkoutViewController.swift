//
//  ImportWorkoutViewController.swift
//  GymRats
//
//  Created by mack on 5/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import HealthKit

protocol ImportWorkoutViewControllerDelegate {
  func importWorkoutViewController(_ importWorkoutViewController: ImportWorkoutViewController, imported workout: HKWorkout)
}

class ImportWorkoutViewController: UIViewController {
  
}
