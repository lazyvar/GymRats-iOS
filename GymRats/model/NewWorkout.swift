//
//  NewWorkout.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

struct NewWorkout {
  var title: String
  var description: String?
  var photo: UIImage?
  var googlePlaceId: String?
  var duration: Int?
  var distance: String?
  var steps: Int?
  var calories: Int?
  var points: Int?
  var appleDeviceName: String?
  var appleSourceName: String?
  var appleWorkoutUuid: String?
  var activityType: Workout.Activity?
  var occurredAt: Date?
}
