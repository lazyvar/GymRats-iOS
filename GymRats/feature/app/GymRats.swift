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

/// God object. Handles AppDelegate functions among other things.
enum GymRats {
  /// Global reference to the logged in user.
  static var currentAccount: Account!
  
  static private var window: UIWindow!
  static private var application: UIApplication!
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
  }
  
  /// Called at the very start of the application.
  static func start(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    coldStartNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any]
    currentAccount = Account.loadCurrent()
    
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
    FirebaseApp.configure()
    preloadMaps()
  }
  
  /// Sets the current account and shows the home screen.
  static func login(_ user: Account) {
    currentAccount = user
    Account.saveCurrent(user)
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

    NotificationCenter.default.post(.appEnteredForeground)
  }
  
  /// Removes the current account and shows the welcome screen
  static func logout() {
    gymRatsAPI.deleteDevice()
      .ignore(disposedBy: disposeBag)

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
  private static func registerForNotifications() {
    UNUserNotificationCenter.current().delegate = notificationHandler
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      guard granted else { return }

      DispatchQueue.main.async { application.registerForRemoteNotifications() }
    }
  }
  
  private static func preloadMaps() {
    DispatchQueue.main.async {
      let cood = CLLocationCoordinate2D(latitude: 0, longitude: 0)
      let coordinateRegion = MKCoordinateRegion(center: cood, latitudinalMeters: 500, longitudinalMeters: 500)
      let annotation = PlaceAnnotation(title: "", coordinate: cood)
      
      _ = MKMapView(frame: CGRect(x: 1000, y: 1000, width: 1, height: 1)).apply {
        $0.setRegion(coordinateRegion, animated: false)
        $0.mapType = .standard
        $0.isUserInteractionEnabled = false
        $0.addAnnotation(annotation)
      }
    }
  }
}
