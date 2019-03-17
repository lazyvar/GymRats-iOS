//
//  APS.swift
//  GymRats
//
//  Created by Mack on 3/16/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation

struct ApplePushServiceObject: Codable {
    let aps: APS
    let gr: GymRatsNotification
    
    struct GymRatsNotification: Codable {
        let notificationType: NotificationType
        let comment: Comment?
        let chatMessage: ChatMessage?
        
        enum NotificationType: String, Codable {
            case comment
            case chatMessage = "chat_message"
        }
    }
    
    struct APS: Codable {
        let alert: String
        let badge: Int
    }
}
