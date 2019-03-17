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

class AppCoordinator: NSObject, Coordinator, UNUserNotificationCenterDelegate {
    
    let window: UIWindow
    let application: UIApplication
    
    var currentUser: User!
    var drawer: MMDrawerController!
    
    init(window: UIWindow, application: UIApplication) {
        self.window = window
        self.application = application
    }
    
    func start() {
        if let user = loadCurrentUser() {
            // show home
            login(user: user)
            registerForNotifications(on: application)
        } else {
            // show login/signup
            let nav = GRNavigationController(rootViewController: WelcomeViewController())
            nav.navigationBar.turnBrandColorSlightShadow()
            
            window.rootViewController = nav
        }
        
        window.makeKeyAndVisible()
        
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
                
        GMSPlacesClient.provideAPIKey("AIzaSyD1X4TH-TneFnDqjiJ2rb2FGgxK8JZyrIo")
        FirebaseApp.configure()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func userNotificationCenter (
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleNotification(userInfo: notification.request.content.userInfo, completionHandler: completionHandler)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotification(userInfo: response.notification.request.content.userInfo)
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
        let aps: ApplePushServiceObject
        do {
            aps = try ApplePushServiceObject(from: userInfo)
        } catch let error {
            print(error)
            return
        }
        
        guard GymRatsApp.coordinator.currentUser != nil else { return }
        
        switch aps.gr.notificationType {
        case .comment:
            guard let comment = aps.gr.comment else { return }
            
            if let openWorkoutId = openWorkoutId, openWorkoutId == comment.workoutId {
                NotificationCenter.default.post(name: .commentNotification, object: aps.gr.comment)
                completionHandler?(.sound)
            } else {
                if let completionHandler = completionHandler {
                    completionHandler(.alert)
                } else {
                    guard let user = aps.gr.user, let challenge = aps.gr.challenge, let workout = aps.gr.workout else { return }
                    
                    let workoutViewController = WorkoutViewController(user: user, workout: workout, challenge: challenge)

                    (GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController)?.pushViewController(workoutViewController, animated: true)
                }
            }
        case .chatMessage:
            guard let chatMessage = aps.gr.chatMessage else { return }

            if let openChallengeChatId = openChallengeChatId, openChallengeChatId == chatMessage.challengeId {
                NotificationCenter.default.post(name: .chatNotification, object: aps.gr.chatMessage)
                completionHandler?(.sound)
            } else {
                if let completionHandler = completionHandler {
                    completionHandler(.alert)
                } else {
                    guard let challenge = aps.gr.challenge else { return }
                    
                    let chatViewController = ChatViewController(challenge: challenge)
                    
                    (GymRatsApp.coordinator.drawer.centerViewController as? UINavigationController)?.pushViewController(chatViewController, animated: true)
                }
            }
        }
    }
    
    var openWorkoutId: Int?
    var openChallengeChatId: Int?

    func login(user: User) {
        self.currentUser = user
        
        let menu = MenuViewController()
        let home = HomeViewController()
        let nav = GRNavigationController(rootViewController: home)
        
        drawer = MMDrawerController(center: nav, leftDrawerViewController: menu)
        drawer.showsShadow = false
        drawer.maximumLeftDrawerWidth = MenuViewController.menuWidth
        drawer.centerHiddenInteractionMode = .full
        drawer.openDrawerGestureModeMask = [.all]
        drawer.closeDrawerGestureModeMask = [.all]
        drawer.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlock(withParallaxFactor: 2))
        drawer.setGestureCompletionBlock { drawer, _ in
            guard let drawer = drawer else { return }
            
            if drawer.openSide == .none {
                drawer.rightDrawerViewController = nil
            }
        }
        
        window.rootViewController = drawer
    }
    
    @objc func toggleMenu() {
        if drawer.openSide == .left {
            drawer.closeDrawer(animated: true, completion: nil)
        } else {
            drawer.open(.left, animated: true, completion: nil)
        }
    }
    
    func updateUser(_ user: User) {
        self.currentUser = user
        
        switch Keychain.gymRats.storeObject(user, forKey: .currentUser) {
        case .success:
            print("Woohoo!")
        case .error(let error):
            print("Bummer! \(error.description)")
        }
    }
    
    func logout() {
        self.currentUser = nil
        
        let nav = GRNavigationController(rootViewController: WelcomeViewController())
        nav.navigationBar.turnBrandColorSlightShadow()
        
        window.rootViewController = nav
        
        switch Keychain.gymRats.deleteObject(withKey: .currentUser) {
        case .success:
            print("Woohoo!")
        case .error(let error):
            print("Bummer! \(error.description)")
        }
    }
    
    func loadCurrentUser() -> User? {
        switch Keychain.gymRats.retrieveObject(forKey: .currentUser) {
        case .success(let user):
            return user
        case .error(let error):
            print("Bummer! \(error.description)")
            return nil
        }
    }
    
}

extension Keychain {
    static var gymRats = Keychain(group: nil)
}

extension Keychain.Key where Object == User {
    
    static var currentUser: Keychain.Key<User> {
        return Keychain.Key<User>(rawValue: "currentUser", synchronize: true)
    }
    
}


extension NSNotification.Name {
    
    static let updatedCurrentUser = NSNotification.Name(rawValue: "GRCurrentUserUpdated")
    
}
