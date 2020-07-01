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
  }
  
  struct Output {
    let workoutNotificationsEnabled = PublishSubject<Bool>()
    let commentNotificationsEnabled = PublishSubject<Bool>()
    let chatNotificationsEnabled = PublishSubject<Bool>()
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    
  }
}
