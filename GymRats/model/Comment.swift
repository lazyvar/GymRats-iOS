//
//  Comment.swift
//  GymRats
//
//  Created by Mack on 3/14/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct Comment: Codable {
  let id: Int
  let workoutId: Int
  let content: String
  let createdAt: Date
  let account: Account
}
