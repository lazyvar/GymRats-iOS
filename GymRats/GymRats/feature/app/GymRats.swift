//
//  GymRats.swift
//  GymRats
//
//  Created by mack on 3/11/20.
//  Copyright © 2020 Mack Hasz. All rights reserved.
//

import UIKit
import RxSwift
import UserNotifications
import GooglePlaces
import Firebase

/// God object. Handles AppDelegate functions among other things.
enum GymRats {
  /// Global reference to the logged in user.
  static var currentAccount: User!
  
  static private var window: UIWindow!
  static private var application: UIApplication!
  static private var coldStartNotification: [AnyHashable: Any]?
  static private let disposeBag = DisposeBag()

  /// Initialize the app.
  static func initialize(window: UIWindow, application: UIApplication) {
    self.window = window
    self.application = application
  }
  
  /// Called at the very start of the application.
  static func start(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    coldStartNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any]
    currentAccount = User.loadCurrent()
    
    UINavigationBar.appearance().barTintColor = .primaryText
    UINavigationBar.appearance().tintColor = .background
    
    window.rootViewController = {
      if currentAccount != nil {
        return DrawerViewController()
      } else {
        return WelcomeViewController().inNav()
      }
    }()
    
    if currentAccount != nil {
      Track.currentUser()
      registerForNotifications()
    }

    window.makeKeyAndVisible()
    
    #if DEBUG
    NetworkActivityLogger.shared.level = .debug
    NetworkActivityLogger.shared.startLogging()
    #endif
    
    GMSPlacesClient.provideAPIKey("AIzaSyD1X4TH-TneFnDqjiJ2rb2FGgxK8JZyrIo")
    
    #if RELEASE
    FirebaseApp.configure()
    #endif
  }
  
  /// Sets the current account and shows the home screen.
  static func login(_ user: User) {
    currentAccount = user
    User.saveCurrent(user)
    window.rootViewController = DrawerViewController()
    Track.currentUser()
  }
  
  /// Called when the app registered for notifications.
  static func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
    let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })

    gymRatsAPI.registerDevice(deviceToken: deviceTokenString)
      .ignore(disposedBy: disposeBag)
  }
  
  /// Called when the app enters the foreground state.
  static func willEnterForeground() {
    application.applicationIconBadgeNumber = 1
    application.applicationIconBadgeNumber = 0

    // TODO: Refresh
  }
}

private extension GymRats {
  private static func registerForNotifications() {
    // TODO: UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      guard granted else { return }

      DispatchQueue.main.async { application.registerForRemoteNotifications() }
    }
  }
}
