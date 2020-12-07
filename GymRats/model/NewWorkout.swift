//
//  NewWorkout.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import YPImagePicker

struct NewWorkout {
  var title: String
  var description: String?
  var media: [YPMediaItem]
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
  
  struct Medium: Codable {
    let url: String
    let thumbnailUrl: String?
    let mediumType: Workout.Medium.MediumType
  }
}
