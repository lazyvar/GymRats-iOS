//
//  LocalNotificationService.swift
//  GymRats
//
//  Created by mack on 8/4/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftDate
import RxSwift

enum LocalNotificationService {
  static private let disposeBag = DisposeBag()
  
  static func synchronize(challenges: [Challenge]) {
    PushNotifications.permissionStatus()
      .subscribe(onSuccess: { status in
        guard status == .authorized else { return }        
        
        PushNotifications.center.getPendingNotificationRequests { requests in
          print(requests)
        }
        
        for challenge in challenges where challenge.isActive || challenge.isUpcoming {
          if challenge.isUpcoming {
            registerForStart(challenge)
          }

          registerForEnd(challenge)
        }
      })
      .disposed(by: disposeBag)
  }
  
  static func registerForStart(_ challenge: Challenge) {
    let startDateComponents = challenge.startDate.dateComponents
    let content = UNMutableNotificationContent()
    content.title = "Challenge started"
    content.body = "\(challenge.name) has begun!"
    
    var notificationDateComponents = DateComponents()
    notificationDateComponents.calendar = Calendar.current
    notificationDateComponents.day = startDateComponents.day
    notificationDateComponents.year = startDateComponents.year
    notificationDateComponents.month = startDateComponents.month
    notificationDateComponents.hour = 9
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: false)
    let id = "challenge_\(challenge.id)_start"
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    
    PushNotifications.center.add(request) { error in
      if let error = error { print("Error registering notification: \(error)") }
    }
  }
  
  static func registerForEnd(_ challenge: Challenge) {
    let endDateComponents = (challenge.endDate + 1.days).dateComponents
    let content = UNMutableNotificationContent()
    content.title = "Challenge complete"
    content.body = "Congratulations on completing \(challenge.name)!"
    
    var notificationDateComponents = DateComponents()
    notificationDateComponents.calendar = Calendar.current
    notificationDateComponents.day = endDateComponents.day
    notificationDateComponents.year = endDateComponents.year
    notificationDateComponents.month = endDateComponents.month
    notificationDateComponents.hour = 9

    let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: false)
    let id = "challenge_\(challenge.id)_end"
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    
    PushNotifications.center.add(request) { error in
      if let error = error { print("Error registering notification: \(error)") }
    }
  }
}
