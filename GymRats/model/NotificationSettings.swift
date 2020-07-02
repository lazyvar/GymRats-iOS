//
//  NotificationSettings.swift
//  GymRats
//
//  Created by mack on 7/1/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation

struct NotificationSettings: Codable {
  let workouts: Bool
  let comments: Bool
  let chatMessages: Bool
}
