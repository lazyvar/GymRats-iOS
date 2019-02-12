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

class AppCoordinator: Coordinator {
    
    let window: UIWindow
    
    var currentUser: User!
    var drawer: MMDrawerController!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if let user = loadCurrentUser() {
            // show home
            login(user: user)
        } else {
            // show login/signup
            let nav = GRNavigationController(rootViewController: WelcomeViewController())
            nav.navigationBar.turnBrandColorSlightShadow()
            
            window.rootViewController = nav
        }
        
        window.makeKeyAndVisible()
        
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        
        UINavigationBar.appearance().tintColor = .whiteSmoke
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.whiteSmoke
        ]
        
        GMSPlacesClient.provideAPIKey("AIzaSyD1X4TH-TneFnDqjiJ2rb2FGgxK8JZyrIo")
        FirebaseApp.configure()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
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
