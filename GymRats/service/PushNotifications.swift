//
//  PushNotifications.swift
//  GymRats
//
//  Created by mack on 7/2/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UserNotifications
import RxSwift

enum PushNotifications {
  static let center = UNUserNotificationCenter.current()
  
  static func permissionStatus() -> Single<UNAuthorizationStatus> {
    return Single.create { subscriber -> Disposable in
      center.getNotificationSettings { settings in
        subscriber(.success(settings.authorizationStatus))
      }
      
      return Disposables.create()
    }
  }

  static func requestAuthorization() -> Single<Bool> {
    return Single.create { subscriber -> Disposable in
      center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
        subscriber(.success(granted))
      }
      
      return Disposables.create()
    }
  }
}
