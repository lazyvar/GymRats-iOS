//
//  WorkoutRow.swift
//  GymRats
//
//  Created by mack on 4/8/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

enum WorkoutRow {
  case image(url: String)
  case account(Workout)
  case details(Workout)
  case comment(Comment)
  case newComment(onSubmit: (String) -> Void)
}
