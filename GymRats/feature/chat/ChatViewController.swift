//
//  ChatViewController.swift
//  GymRats
//
//  Created by mack on 3/15/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import MessageKit
import RxSwift

class ChatViewController: MessagesViewController {
  private let challenge: Challenge
  
  init(challenge: Challenge) {
    self.challenge = challenge
      
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
}
