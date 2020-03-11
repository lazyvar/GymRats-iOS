//
//  DayWorkouts.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxDataSources

struct DayWorkouts {
  var day: Date
  var items: [Item]
}

extension DayWorkouts: SectionModelType {
  typealias Item = Workout
  
  init(original: DayWorkouts, items: [Workout]) {
    self = original
    self.items = items
  }
}
