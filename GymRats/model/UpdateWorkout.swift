//
//  UpdateWorkout.swift
//  GymRats
//
//  Created by mack on 8/6/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

struct UpdateWorkout {
  let id: Int
  let title: String
  let description: String?
  let photo: Either<UIImage, Workout>
  let duration: Int?
  let distance: String?
  let steps: Int?
  let calories: Int?
  let points: Int?
}
