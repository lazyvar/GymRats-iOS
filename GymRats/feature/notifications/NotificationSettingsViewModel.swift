//
//  NotificationSettingsViewModel.swift
//  GymRats
//
//  Created by mack on 7/1/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

final class NotificationSettingsViewModel: ViewModel {
  private let disposeBag = DisposeBag()
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let workoutSwitchChanged = PublishSubject<Bool>()
    let commentSwitchChanged = PublishSubject<Bool>()
    let chatMessageSwitchChanged = PublishSubject<Bool>()
  }
  
  struct Output {
    let workoutNotificationsEnabled = BehaviorSubject(value: false)
    let commentNotificationsEnabled = BehaviorSubject(value: false)
    let chatMessageNotificationsEnabled = BehaviorSubject(value: false)
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    let fetchNotificationSettings = input.viewDidLoad
//      .flatMap { gymRatsAPI.notificationSettings() }
//      .compactMap { $0.object }
      .map { NotificationSettings(workouts: true, comments: false, chatMessages: true) }
      .share()
    
    fetchNotificationSettings
      .map { $0.workouts }
      .bind(to: output.workoutNotificationsEnabled)
      .disposed(by: disposeBag)

    fetchNotificationSettings
      .map { $0.comments }
      .bind(to: output.commentNotificationsEnabled)
      .disposed(by: disposeBag)

    fetchNotificationSettings
      .map { $0.chatMessages }
      .bind(to: output.chatMessageNotificationsEnabled)
      .disposed(by: disposeBag)

    
  }
}
