//
//  ChatMessage.swift
//  GymRats
//
//  Created by Mack on 3/16/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import MessageKit

struct ChatMessage: Codable {
  let id: Int
  let challengeId: Int
  let content: String
  let createdAt: Date
  let account: Account
}

extension ChatMessage: MessageType {
  var sender: SenderType {
    return account.asSender
  }
  
  var messageId: String {
    return "\(id)"
  }
  
  var sentDate: Date {
    return createdAt
  }
  
  var kind: MessageKind {
      return .text(content)
  }
}