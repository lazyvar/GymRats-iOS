//
//  AppDelegate.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import UserNotifications
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  var window: UIWindow?
  var appCoordinator: AppCoordinator!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    application.applicationIconBadgeNumber = 1
    application.applicationIconBadgeNumber = 0

    window = UIWindow(frame: UIScreen.main.bounds)
    GymRats.initialize(window: window!, application: application)
    appCoordinator = AppCoordinator(window: window!, application: application)

    guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return true }
    
    GymRats.start(launchOptions: launchOptions)
      
    return true
  }
    
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    GymRats.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
  }
    
  func applicationWillEnterForeground(_ application: UIApplication) {
    GymRats.willEnterForeground()
  }
}
