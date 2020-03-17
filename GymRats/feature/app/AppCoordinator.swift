//
//  AppCoordinator.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift
import MMDrawerController
import GooglePlaces
import Firebase
import UserNotifications
import ESTabBarController_swift
import MessageUI
import Kingfisher

struct UserWorkout {
  let user: Account
  let workout: Workout?
}

class AppCoordinator: NSObject, UNUserNotificationCenterDelegate {
    
    let window: UIWindow
    let application: UIApplication
    
    var currentUser: Account!
    var drawer: MMDrawerController!
    
    var coldStartNotification: [AnyHashable: Any]?
    
    let disposeBag = DisposeBag()
    
    init(window: UIWindow, application: UIApplication) {
        self.window = window
        self.application = application
    }
    
    func start() {
      
    }
    
    func userNotificationCenter (
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleNotification(userInfo: notification.request.content.userInfo, completionHandler: completionHandler)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if GymRatsApp.coordinator.coldStartNotification == nil {
            handleNotification(userInfo: response.notification.request.content.userInfo)
        }
    }
    
    private func registerForNotifications(on application: UIApplication) {
        // check device notifications
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func handleNotification(userInfo: [AnyHashable: Any], completionHandler: ((UNNotificationPresentationOptions) -> Void)? = nil) {
//        let aps: ApplePushServiceObject
//        do {
//            aps = try ApplePushServiceObject(from: userInfo)
//        } catch let error {
//            print(error)
//            return
//        }
//
//        guard GymRats.currentAccount != nil else { return }
//
//        switch aps.gr.notificationType {
//        case .comment:
//            guard let comment = aps.gr.comment else { return }
//
//            if let openWorkoutId = openWorkoutId, openWorkoutId == comment.workoutId {
//                NotificationCenter.default.post(name: .commentNotification, object: aps.gr.comment)
//                completionHandler?(.sound)
//            } else {
//                if let completionHandler = completionHandler {
//                    completionHandler(.alert)
//                } else {
//                    guard let user = aps.gr.user, let challenge = aps.gr.challenge, let workout = aps.gr.workout else { return }
//
//                    let workoutViewController = WorkoutViewController(workout: workout, challenge: challenge)
//                    workoutViewController.hidesBottomBarWhenPushed = true
//
//                    if let nav = GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController {
//                        nav.pushViewController(workoutViewController, animated: true)
//                    } else if let tabBar = tabBarViewController {
//                        if let nav = tabBar.viewControllers?[safe: 1] as? UINavigationController {
//                            nav.pushViewController(workoutViewController, animated: true)
//                        }
//                    }
//                }
//            }
//        case .chatMessage:
//            guard let chatMessage = aps.gr.chatMessage else { return }
//
//            if let openChallengeChatId = openChallengeChatId, openChallengeChatId == chatMessage.challengeId {
//                NotificationCenter.default.post(name: .chatNotification, object: aps.gr.chatMessage)
//                completionHandler?(.sound)
//            } else {
//                if let completionHandler = completionHandler {
//                    completionHandler(.alert)
//                } else {
//                    guard let challenge = aps.gr.challenge else { return }
//
//                    let chatViewController = DeprecatedChatViewController(challenge: challenge)
//                    chatViewController.hidesBottomBarWhenPushed = true
//
//                    if let nav = GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController {
//                        nav.pushViewController(chatViewController, animated: true)
//                    } else if let tabBar = tabBarViewController {
//                        if let nav = tabBar.viewControllers?[safe: 1] as? UINavigationController {
//                            nav.pushViewController(chatViewController, animated: true)
//                        }
//                    }
//                }
//            }
//        }
    }
    
    var openWorkoutId: Int?
    var openChallengeChatId: Int?
}

extension Keychain {
    static var gymRats = Keychain(group: nil)
}

extension Keychain.Key where Object == Account {
    static var currentUser: Keychain.Key<Account> {
        return Keychain.Key<Account>(rawValue: "currentUser", synchronize: true)
    }
}


extension NSNotification.Name {
    static let updatedCurrentUser = NSNotification.Name(rawValue: "GRCurrentUserUpdated")
    static let updatedCurrentUserPic = NSNotification.Name(rawValue: "GRCurrentUserUpdatedPic")
}

extension UIWindow {
    func topmostViewController() -> UIViewController {
      func recurse(_ viewController: UIViewController) -> UIViewController {
        switch viewController {
          case let tabBarViewController as UITabBarController:
            return recurse(tabBarViewController.selectedViewController ?? tabBarViewController)
          case let navigationViewController as UINavigationController:
            return recurse(navigationViewController.viewControllers.last ?? navigationViewController)
          default:
            if let presentedViewController = viewController.presentedViewController, !presentedViewController.isBeingDismissed {
              return recurse(presentedViewController)
            } else {
              return viewController
            }
        }
      }
      
      return recurse(rootViewController!)
    }
}

extension UIViewController {
  static func topmost(for window: UIWindow = UIApplication.shared.keyWindow!) -> UIViewController {
    return window.topmostViewController()
  }
}
