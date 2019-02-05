//
//  AppCoordinator.swift
//  GymRats
//
//  Created by Mack Hasz on 2/4/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import Foundation
import RxSwift

class AppCoordinator: Coordinator {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        
        if loadCurrentUser() != nil {
            // show home
            window.rootViewController = UINavigationController(rootViewController: UIViewController())
        } else {
            // show login/signup
            let nav = UINavigationController(rootViewController: WelcomeViewController())
            nav.navigationBar.turnBrandColorSlightShadow()
            
            window.rootViewController = nav
        }
        
        window.makeKeyAndVisible()
        
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
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
