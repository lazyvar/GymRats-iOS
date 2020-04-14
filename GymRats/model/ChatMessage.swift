//
//  ChatMessage.swift
//  GymRats
//
//  Created by Mack on 3/16/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import MessageKit

struct ChatMessage: Codable, Hashable {
  let id: Int
  let challengeId: Int
  let content: String
  let createdAt: Date
  let account: Account
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension ChatMessage: MessageType {
  var sender: SenderType {
    return account
  }
  
  var messageId: String {
    return "\(id)"
  }
  
  var sentDate: Date {
    return createdAt
  }
  
  var kind: MessageKind {
    let color: UIColor
    
    if account.id == GymRats.currentAccount.id {
      color = .white
    } else {
      color = .primaryText
    }
    
    return .attributedText(.init(string: content, attributes: [.font: UIFont.body, .foregroundColor: color]))
  }
}
