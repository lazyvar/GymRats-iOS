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
import MapKit
import Branch

/// God object. Handles AppDelegate functions among other things.
enum GymRats {
  /// Global reference to the logged in user.
  static var currentAccount: Account!
  
  static private var window: UIWindow!
  static private var application: UIApplication!
  static private var branch: Branch!

  static private let disposeBag = DisposeBag()
  static private let notificationHandler = NotificationHandler()

  static private var coldStartNotification: [AnyHashable: Any]? {
    get {
      return notificationHandler.coldStartNotification
    }
    set {
      notificationHandler.coldStartNotification = newValue
    }
  }
  
  /// Initialize the app.
  static func initialize(window: UIWindow, application: UIApplication) {
    self.window = window
    self.application = application
    
    switch environment {
    case .development, .preProduction:
      Branch.setUseTestBranchKey(true)
    case .production:
      break
    }
    
    self.branch = Branch.getInstance()
  }
  
  /// Called at the very start of the application.
  static func start(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    coldStartNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any]
    currentAccount = Account.loadCurrent()
    
    UINavigationBar.appearance().barTintColor = .primaryText
    UINavigationBar.appearance().tintColor = .background
    
    window.rootViewController = {
      if currentAccount != nil {
        if UserDefaults.standard.bool(forKey: "account-is-onboarding") {
          return HowItWorksViewController().inNav()
        } else {
          return DrawerViewController()
        }
      } else {
        return WelcomeViewController().inNav()
      }
    }()
    
    if currentAccount != nil {
      Track.currentUser()
      registerForNotifications()
    }
    
    window.makeKeyAndVisible()
    
    branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: branchCallback)
    
    #if DEBUG
    NetworkActivityLogger.shared.level = .debug
    NetworkActivityLogger.shared.startLogging()
    #endif
    
    GMSPlacesClient.provideAPIKey("AIzaSyD1X4TH-TneFnDqjiJ2rb2FGgxK8JZyrIo")
    FirebaseApp.configure()
  }
  
  /// Sets the current account and shows the home screen.
  static func login(_ user: Account) {
    currentAccount = user
    Account.saveCurrent(user)
    Track.currentUser()
  }

  /// Logs the account in an takes them to onboarding. Sets user default to true for `account-is-onboarding`.
  static func startOnboarding(_ account: Account) {
    GymRats.login(account)
    UserDefaults.standard.set(true, forKey: "account-is-onboarding")
    GymRats.replaceRoot(with: HowItWorksViewController().inNav())
  }
  
  /// Takes them to the main app and clears `account-is-onboarding`
  static func completeOnboarding() {
    UserDefaults.standard.removeObject(forKey: "join-code")
    UserDefaults.standard.removeObject(forKey: "account-is-onboarding")
    replaceRoot(with: DrawerViewController())
  }
  
  /// Animates the replacing of the rootViewController on the applications window.
  static func replaceRoot(with viewController: UIViewController) {
    window.rootViewController = viewController
    
    UIView.transition(
      with: window,
      duration: 0.25,
      options: .transitionCrossDissolve,
      animations: {},
      completion: nil
    )
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

    if currentAccount != nil {
      NotificationCenter.default.post(.appEnteredForeground)
    }
  }
  
  /// Called when the app entered the background state.
  static func didEnterBackground() {
    if currentAccount != nil {
      NotificationCenter.default.post(.appEnteredBackground)
    }
  }
  
  static func open(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
    branch.application(application, open: url, options: options)
  }
  
  static func `continue`(_ userActivity: NSUserActivity) -> Void {
    branch.continue(userActivity)
  }
  
  /// Removes the current account and shows the welcome screen
  static func logout() {
    gymRatsAPI.deleteDevice()
      .ignore(disposedBy: disposeBag)

    UserDefaults.standard.removeObject(forKey: "join-code")
    currentAccount = nil
    Account.removeCurrent()
    window.rootViewController = WelcomeViewController().inNav()
  }
  
  /// Callled after home as loaded, handle the cold start notification
  static func handleColdStartNotification() {
    if let notification = coldStartNotification {
      notificationHandler.handleNotification(userInfo: notification)
      coldStartNotification = nil
    }
  }
}

private extension GymRats {
  private static func branchCallback(params: [AnyHashable: Any]?, error: Error?) {
    guard let nonBranchLink = params?["+non_branch_link"] as? String else { return }
    guard let codeSubstring = nonBranchLink.split(separator: "/").last else { return }

    let code = String(codeSubstring)
    
    if Account.loadCurrent() != nil {
      ChallengeFlow.join(code: code)
    } else {
      UserDefaults.standard.set(code, forKey: "join-code")
    }
  }
  
  private static func registerForNotifications() {
    UNUserNotificationCenter.current().delegate = notificationHandler
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      guard granted else { return }

      DispatchQueue.main.async { application.registerForRemoteNotifications() }
    }
  }
}
