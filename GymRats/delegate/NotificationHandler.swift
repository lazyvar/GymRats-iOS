//
//  NotificationHandler.swift
//  GymRats
//
//  Created by mack on 3/17/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
  var coldStartNotification: Any?
  
  func userNotificationCenter (_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    handleNotification(userInfo: notification.request.content.userInfo, completionHandler: completionHandler)
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    if coldStartNotification == nil {
      handleNotification(userInfo: response.notification.request.content.userInfo)
    }
  }
  
  private func handleNotification(userInfo: [AnyHashable: Any], completionHandler: ((UNNotificationPresentationOptions) -> Void)? = nil) {
      let aps: ApplePushServiceObject
      do {
        aps = try ApplePushServiceObject(from: userInfo)
      } catch let error {
          print(error)
          return
      }

      guard GymRats.currentAccount != nil else { return }

    if let completionHandler = completionHandler {
      completionHandler(.alert)
      return
    }
  }
}
