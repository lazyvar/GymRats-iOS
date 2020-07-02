//
//  NotificationSettingsViewController.swift
//  GymRats
//
//  Created by mack on 7/1/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class NotificationSettingsViewController: BindableViewController {
  private let viewModel = NotificationSettingsViewModel()
  private let disposeBag = DisposeBag()
  
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
  
  @IBOutlet private weak var commentSwitch: UISwitch!
  @IBOutlet private weak var workoutSwitch: UISwitch!
  @IBOutlet private weak var chatMessageSwitch: UISwitch!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.input.viewDidLoad.trigger()
  }
  
  override func bindViewModel() {
    viewModel.output.workoutNotificationsEnabled
      .bind(to: workoutSwitch.rx.isOn)
      .disposed(by: disposeBag)
    
    viewModel.output.commentNotificationsEnabled
      .bind(to: commentSwitch.rx.isOn)
      .disposed(by: disposeBag)
    
    viewModel.output.chatMessageNotificationsEnabled
      .bind(to: chatMessageSwitch.rx.isOn)
      .disposed(by: disposeBag)
  }
  
  @IBAction private func workoutSwitchChanged(_ sender: UISwitch) {
    viewModel.input.workoutSwitchChanged.onNext(sender.isOn)
  }
  
  @IBAction private func commentSwitchChanged(_ sender: UISwitch) {
    viewModel.input.commentSwitchChanged.onNext(sender.isOn)
  }
  
  @IBAction private func chatMessageSwitchChanged(_ sender: UISwitch) {
    viewModel.input.chatMessageSwitchChanged.onNext(sender.isOn)
  }
}
