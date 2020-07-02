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
    let workoutsEnabled = BehaviorSubject(value: false)
    let commentsEnabled = BehaviorSubject(value: false)
    let chatMessagesEnabled = BehaviorSubject(value: false)
    let permissionDenied = PublishSubject<Bool>()
  }
  
  let input = Input()
  let output = Output()
  
  init() {
    func ensurePushSettingEnabled() -> Observable<Bool> {
      let permission = Observable<Bool>.create { subscriber -> Disposable in
        let auth = PushNotifications.requestAuthorization().asObservable()
        let granted = auth
          .filter { $0 }
          .subscribe(onNext: { _ in
            subscriber.onNext(true)
          })
        
        let requested = auth
          .filter { !$0 }
          .subscribe(onNext: { enabled in
            subscriber.onNext(enabled)
          })

        return Disposables.create(granted, requested)
      }.share()
      
      permission
        .map { !$0 }
        .bind(to: output.permissionDenied)
        .disposed(by: disposeBag)
      
      return permission
    }
    
    func updateSettings(workouts: Bool? = nil, comments: Bool? = nil, chatMessages: Bool? = nil) -> Observable<NetworkResult<Account>> {
      return gymRatsAPI.updateNotificationSettings(workouts: workouts, comments: comments, chatMessages: chatMessages)
        .do(onNext: { result in
          guard let account = result.object else { return }
          
          GymRats.currentAccount = account
          Account.saveCurrent(account)
          NotificationCenter.default.post(name: .currentAccountUpdated, object: account)
        })
    }
    
    let appEnteredForeground = NotificationCenter.default.rx.notification(.appEnteredForeground).map { _ in () }.share()
    
    input.viewDidLoad
      .map { GymRats.currentAccount.workoutNotificationsEnabled ?? false }
      .bind(to: output.workoutsEnabled)
      .disposed(by: disposeBag)
    
    input.viewDidLoad
      .map { GymRats.currentAccount.commentNotificationsEnabled ?? false }
      .bind(to: output.commentsEnabled)
      .disposed(by: disposeBag)

    input.viewDidLoad
      .map { GymRats.currentAccount.chatMessageNotificationsEnabled ?? false }
      .bind(to: output.chatMessagesEnabled)
      .disposed(by: disposeBag)

    Observable.merge(input.viewDidLoad, appEnteredForeground)
      .flatMap { PushNotifications.permissionStatus() }
      .map { $0 == .denied }
      .bind(to: output.permissionDenied)
      .disposed(by: disposeBag)
    
    input.workoutSwitchChanged
      .flatMap { Observable.combineLatest(Observable<Bool>.just($0), ensurePushSettingEnabled()) }
      .filter { _, enabled in enabled }
      .flatMap { workouts, _ in updateSettings(workouts: workouts) }
      .ignore(disposedBy: disposeBag)

    input.commentSwitchChanged
      .flatMap { Observable.combineLatest(Observable<Bool>.just($0), ensurePushSettingEnabled()) }
      .filter { _, enabled in enabled }
      .flatMap { comments, _ in updateSettings(comments: comments) }
      .ignore(disposedBy: disposeBag)

    input.chatMessageSwitchChanged
      .flatMap { Observable.combineLatest(Observable<Bool>.just($0), ensurePushSettingEnabled()) }
      .filter { _, enabled in enabled }
      .flatMap { chatMessages, _ in updateSettings(chatMessages: chatMessages) }
      .ignore(disposedBy: disposeBag)
  }
}
