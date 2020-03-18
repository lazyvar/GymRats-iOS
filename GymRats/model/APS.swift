//
//  APS.swift
//  GymRats
//
//  Created by Mack on 3/16/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct ApplePushServiceObject: Codable {
  let gr: GymRatsNotification
  
  struct GymRatsNotification: Codable {
    let notificationType: NotificationType
    let workoutId: Int?
    let challengeId: Int?
    
    enum NotificationType: String, Codable {
      case workoutComment = "workout_comment"
      case chatMessage = "chat_message"
    }
  }
}
