//
//  NotificationSettingsViewController.swift
//  GymRats
//
//  Created by mack on 7/1/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: BindableViewController {
  private let viewModel = NotificationSettingsViewModel()
  
  @IBOutlet private weak var workoutLabel: UILabel! {
    didSet {
      workoutLabel.textColor = .primaryText
      workoutLabel.font = .body
    }
  }
  
  @IBOutlet private weak var commentLabel: UILabel! {
    didSet {
      commentLabel.textColor = .primaryText
      commentLabel.font = .body
    }
  }

  @IBOutlet private weak var chatMessageLabel: UILabel! {
    didSet {
      chatMessageLabel.textColor = .primaryText
      chatMessageLabel.font = .body
    }
  }
  
  @IBOutlet private weak var enableAllButton: UIButton! {
    didSet {
      
    }
  }
  
  @IBOutlet private weak var skipButton: UIButton! {
    didSet {
      
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    
  }
}
