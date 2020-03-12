//
//  ChallengeFlow.swift
//  GymRats
//
//  Created by mack on 3/12/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import MessageUI

enum ChallengeFlow {
  static private var delegate = TrackMessageDelegate()
  
  static func invite(to challenge: Challenge) {
    let topMost = UIViewController.topmost()
    
    guard MFMessageComposeViewController.canSendText() else {
      topMost.presentAlert(title: "Uh-oh", message: "This device cannot send text message.")
      return
    }
      
    let messageViewController = MFMessageComposeViewController().apply {
      $0.body = "Let's workout together! Join my GymRats challenge using invite code \"\(challenge.code)\" https://apps.apple.com/us/app/gymrats-group-challenge/id1453444814"
      $0.messageComposeDelegate = delegate
    }
    
    topMost.present(messageViewController, animated: true, completion: nil)
  }
}
