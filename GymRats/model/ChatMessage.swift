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
  let messageType: MessageType?
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  enum MessageType: String, Codable {
    case text
    case image
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
    switch (messageType ?? .text) {
    case .image:
      return .photo(ChatMessageImage(imageURL: content))
    case .text:
      let color: UIColor
      
      if account.id == GymRats.currentAccount.id {
        color = .white
      } else {
        color = .primaryText
      }
      
      return .attributedText(.init(string: content, attributes: [.font: UIFont.body, .foregroundColor: color]))
    }
  }
}

struct ChatMessageImage: MediaItem {
  let imageURL: String

  var url: URL? { return URL(string: imageURL) }
  var image: UIImage? { return nil }
  var placeholderImage: UIImage { return UIImage(color: .lightGray) }
  var size: CGSize { return .init(width: 150, height: 150) }
}
