//
//  TrackMessageDelegate.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import MessageUI

class TrackMessageDelegate: NSObject, MFMessageComposeViewControllerDelegate {
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    controller.dismissSelf()
      
    if result == .sent {
      Track.event(.smsInviteSent)
    }
  }
}
