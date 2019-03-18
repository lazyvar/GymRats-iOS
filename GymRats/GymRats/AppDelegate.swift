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
    
    let disposeBag = DisposeBag()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator(window: window!, application: application)
        
        appCoordinator.start()
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            appCoordinator.coldStartNotification = userInfo
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })

        gymRatsAPI.registerDevice(deviceToken: deviceTokenString)
            .subscribe { _ in
                // ...
            }.disposed(by: disposeBag)
    }

    func applicationWillResignActive(_ application: UIApplication) { }
    
    func applicationDidEnterBackground(_ application: UIApplication) { }
    
    func applicationWillEnterForeground(_ application: UIApplication) { }
    
    func applicationDidBecomeActive(_ application: UIApplication) { }
    
    func applicationWillTerminate(_ application: UIApplication) { }
    
}


extension Decodable {
    
    init(from anything: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: anything, options: .prettyPrinted)
        
        print(String(data: data, encoding: .utf8) ?? "")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self = try JSONDecoder.gymRatsAPIDecoder.decode(Self.self, from: data)
    }
    
}

extension Notification {
    static let commentNotification = Notification(name: .commentNotification)
    static let chatNotification = Notification(name: .chatNotification)
}

extension NSNotification.Name {
    static let commentNotification = NSNotification.Name.init("CommentNotification")
    static let chatNotification = NSNotification.Name.init("ChatNotification")
}
