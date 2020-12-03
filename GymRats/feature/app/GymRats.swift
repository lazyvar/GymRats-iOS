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
import Segment
import Segment_Amplitude
import Segment_Firebase
import HealthKit
import YPImagePicker
import AVFoundation

/// God object. Handles AppDelegate functions among other things.
enum GymRats {
  /// Global reference to the logged in user.
  static var currentAccount: Account!
  static var segment: Segment.Analytics!

  static private var window: UIWindow!
  static private var application: UIApplication!
  static private var branch: Branch!

  static private let disposeBag = DisposeBag()
  static private let notificationHandler = NotificationHandler()
  static private let healthService: HealthServiceType = HealthService.shared
  
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
    
    self.configureSegment()

    self.segment = Analytics.shared()
    self.branch = Branch.getInstance()
  }
  
  /// Called at the very start of the application.
  static func start(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    coldStartNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any]
    currentAccount = Account.loadCurrent()
    
    window.rootViewController = {
      if currentAccount != nil {
        if UserDefaults.standard.bool(forKey: "account-is-onboarding") {
          return TodaysGoalViewController().inNav()
        } else {
          return LoadingViewController()
        }
      } else {
        return WelcomeViewController().inNav()
      }
    }()

    if currentAccount != nil {
      if healthService.autoSyncEnabled {
        healthService.observeWorkouts()
      }

      PushNotifications.center.getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized: registerForNotifications()
        case .notDetermined: popupPushNotificationSettings()
        default: break
        }
      }
    }
    
    window.makeKeyAndVisible()

    #if DEBUG
    NetworkActivityLogger.shared.level = .debug
    NetworkActivityLogger.shared.startLogging()
    #endif
    
    configureYPImagePicker()
    branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: branchCallback)
    GMSPlacesClient.provideAPIKey("AIzaSyD1X4TH-TneFnDqjiJ2rb2FGgxK8JZyrIo")
    FirebaseApp.configure()
  }
  
  /// Sets the current account and shows the home screen.
  static func login(_ user: Account) {
    currentAccount = user
    Account.saveCurrent(user)
  }

  /// Logs the account in an takes them to onboarding. Sets user default to true for `account-is-onboarding`.
  static func startOnboarding(_ account: Account) {
    GymRats.login(account)
    UserDefaults.standard.set(true, forKey: "account-is-onboarding")
    
    if let code = UserDefaults.standard.string(forKey: "join-code") {
      gymRatsAPI.getChallenge(code: code)
        .subscribe(onNext: { result in
          if let challenges = result.object, let challenge = challenges.first(where: { $0.code == code }) {
            let preview = ChallengePreviewViewController(challenge: challenge)
            let nav = preview.inNav()
            
            preview.navigationItem.leftBarButtonItem = UIBarButtonItem(
              image: .close,
              style: .plain,
              target: preview,
              action: #selector(ChallengePreviewViewController.completeOnboarding)
            )

            GymRats.replaceRoot(with: nav)
          } else {
            GymRats.replaceRoot(with: TodaysGoalViewController().inNav())
          }
        })
        .disposed(by: disposeBag)
    } else {
      GymRats.replaceRoot(with: TodaysGoalViewController().inNav())
    }
  }

  /// Shows the notification settings screen configured for onboarding
  static func popupPushNotificationSettings() {
    guard UserDefaults.standard.integer(forKey: "gym_rats_run_count") >= 2 && !UserDefaults.standard.bool(forKey: "asked_for_notifications") else { return }
    
    UserDefaults.standard.set(true, forKey: "asked_for_notifications")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      let topmost = UIViewController.topmost()
      let notificationSettings = NotificationSettingsViewController.forOnboarding()

      topmost.presentInNav(notificationSettings)
    }
  }
  
  /// Takes them to the main app and clears `account-is-onboarding`
  static func completeOnboarding() {
    UserDefaults.standard.removeObject(forKey: "join-code")
    UserDefaults.standard.removeObject(forKey: "account-is-onboarding")
    replaceRoot(with: LoadingViewController())
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      UIViewController.topmost().presentPanModal(SupportAlert())
    }
  }
  
  /// Animates the replacing of the rootViewController on the applications window.
  static func replaceRoot(with viewController: UIViewController) {
    window.rootViewController = viewController
    
    UIView.transition(
      with: window,
      duration: 0.15,
      options: .transitionCrossDissolve,
      animations: { },
      completion: nil
    )
  }
  
  /// Called when the app registered for notifications.
  static func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
    let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })

    gymRatsAPI
      .registerDevice(deviceToken: deviceTokenString)
      .ignore(disposedBy: disposeBag)
  }
  
  /// Called when the app enters the foreground state.
  static func willEnterForeground() {
    application.applicationIconBadgeNumber = 1
    application.applicationIconBadgeNumber = 0

    if currentAccount != nil {
      let count = UserDefaults.standard.integer(forKey: "gym_rats_run_count")
      
      UserDefaults.standard.set(count + 1, forKey: "gym_rats_run_count")
      NotificationCenter.default.post(.appEnteredForeground)
    }
  }
  
  /// Called when the app becomes active.
  static func didBecomeActive() {
    guard currentAccount != nil else { return }
    
    Challenge.State.all.fetch()
      .compactMap { $0.object }
      .subscribe(onNext: { challenges in
        let unseenCompletedChallenges = challenges.unseenCompletedChallenges()
        
        defer { unseenCompletedChallenges.witness() }
        
        if let last = unseenCompletedChallenges.sorted(by: { $0.id < $1.id }).last {
          UserDefaults.standard.set(0, forKey: "last_opened_challenge")
          ChallengeFlow.present(completedChallenge: last)
        }
      })
      .disposed(by: disposeBag)
  }
  
  /// Called when the app entered the background state.
  static func didEnterBackground() {
    if currentAccount != nil {
      NotificationCenter.default.post(.appEnteredBackground)
    }
  }
  
  /// Opens the URLs.
  static func open(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
    branch.application(application, open: url, options: options)
  }
  
  /// Continues user activities.
  static func `continue`(_ userActivity: NSUserActivity) -> Void {
    branch.continue(userActivity)
  }
  
  /// Shorthand for Application opening a URL
  static func open(url: String) {
    guard let url = URL(string: url) else { return }
    
    application.open(url, options: [:], completionHandler: nil)
  }
  
  /// Removes the current account and shows the welcome screen
  static func logout() {
    gymRatsAPI
      .deleteDevice()
      .ignore(disposedBy: disposeBag)

    UserDefaults.standard.removeObject(forKey: "join-code")
    currentAccount = nil
    healthService.autoSyncEnabled = false
    Account.removeCurrent()
    Membership.State.clear()
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
  private static func configureSegment() {
    let configuration = AnalyticsConfiguration(writeKey: Secrets.Segment.writeKey).apply {
      $0.recordScreenViews = false
      $0.trackApplicationLifecycleEvents = true
      $0.enableAdvertisingTracking = false
      $0.use(SEGAmplitudeIntegrationFactory())
      $0.use(SEGFirebaseIntegrationFactory())
    }

    Segment.Analytics.setup(with: configuration)
  }

  private static func branchCallback(params: [AnyHashable: Any]?, error: Error?) {
    guard let code = params?["code"] as? String else { return }
    
    if Account.loadCurrent() != nil {
      ChallengeFlow.join(code: code)
    } else {
      UserDefaults.standard.set(code, forKey: "join-code")
    }
  }
  
  private static func registerForNotifications() {
    PushNotifications.center.delegate = notificationHandler
    PushNotifications.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
      guard granted else { return }

      DispatchQueue.main.async { application.registerForRemoteNotifications() }
    }
  }
  
  private static func configureYPImagePicker() {
    var config = YPImagePickerConfiguration()
    config.screens = [.photo, .video, .library]
    config.startOnScreen = .photo
    config.shouldSaveNewPicturesToAlbum = false
    config.onlySquareImagesFromCamera = false
    config.showsVideoTrimmer = false
    config.showsPhotoFilters = false
    config.library.maxNumberOfItems = 3
    config.wordings.cameraTitle = "Camera"
    config.wordings.next = "Done"
    config.fonts.menuItemFont = UIFont.proRoundedSemibold(size: 17)
    config.filters = []
    config.video.recordingTimeLimit = 30
    config.video.libraryTimeLimit = 30
    config.video.minimumTimeLimit = 1
    config.video.compression = AVAssetExportPresetMediumQuality
//    config.icons.capturePhotoImage = UIImage(color: .brand) TODO
//    config.icons.captureVideoImage = UIImage(color: .brand) TODO

    YPImagePickerConfiguration.shared = config

    UINavigationBar.appearance().setBackgroundImage(UIImage(color: .background), for: .default)
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.proRoundedSemibold(size: 17)]
    UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.proRoundedRegular(size: 17)], for: .normal)
  }
}
