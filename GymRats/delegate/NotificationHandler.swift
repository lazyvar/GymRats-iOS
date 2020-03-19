//
//  NotificationHandler.swift
//  GymRats
//
//  Created by mack on 3/17/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
  var coldStartNotification: [AnyHashable: Any]?
  private let disposeBag = DisposeBag()
  
  func userNotificationCenter (_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    handleNotification(userInfo: notification.request.content.userInfo, completionHandler: completionHandler)
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    if coldStartNotification == nil {
      handleNotification(userInfo: response.notification.request.content.userInfo)
    }
  }
  
  func handleNotification(userInfo: [AnyHashable: Any], completionHandler: ((UNNotificationPresentationOptions) -> Void)? = nil) {
    let aps: ApplePushServiceObject
    let viewController = UIViewController.topmost()
    
    guard GymRats.currentAccount != nil else { return }

    if let completionHandler = completionHandler {
      completionHandler(.alert)
      return
    }

    do {
      aps = try ApplePushServiceObject(from: userInfo)
    } catch let error {
      print(error); return
    }
    
    switch aps.gr.notificationType {
    case .chatMessage:
      guard let id = aps.gr.challengeId else { return }
      
      gymRatsAPI.getChallenge(id: id)
        .subscribe { event in
          if let challenge = event.element?.object {
            let chatViewController = Screen.chat(challenge).viewController
            let nav = chatViewController.inNav()

            chatViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: chatViewController, action: #selector(UIViewController.dismissSelf))
            
            viewController.present(nav, animated: true, completion: nil)
          }
          
          if let error = event.element?.error {
            viewController.presentAlert(with: error)
          }
        }
        .disposed(by: disposeBag)
    case .workoutComment:
      guard let id = aps.gr.workoutId else { return }
      
      Observable.zip(gymRatsAPI.getWorkout(id: id), gymRatsAPI.getChallenge(id: id))
        .subscribe { event in
          guard let (w, c) = event.element else { return }
          
          if let workout = w.object, let challenge = c.object {
            let workoutViewController = Screen.workout(workout, challenge).viewController
            let nav = workoutViewController.inNav()

            workoutViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: workoutViewController, action: #selector(UIViewController.dismissSelf))
            
            viewController.present(nav, animated: true, completion: nil)
          }
        }
        .disposed(by: disposeBag)
    }
  }
}
