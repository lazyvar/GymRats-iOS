//
//  NewWorkout.swift
//  GymRats
//
//  Created by mack on 3/10/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

struct NewWorkout: Encodable {
  let title: String
  let description: String?
  let photoUrl: String?
  let googlePlaceId: String?
  let duration: Int?
  let distance: String?
  let steps: Int?
  let calories: Int?
  let points: Int?
}
