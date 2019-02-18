//
//  UIViewController+Extension.swift
//  GymRats
//
//  Created by Mack Hasz on 2/5/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func setupBackButton() {
        let yourBackImage = UIImage(named: "chevron-left")
        
        navigationController?.navigationBar.backIndicatorImage = yourBackImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func setupMenuButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem (
            image: UIImage(named: "menu"),
            style: .plain,
            target: GymRatsApp.coordinator,
            action: #selector(AppCoordinator.toggleMenu)
        )
    }
    
    func showLoadingBar(disallowUserInteraction: Bool = false) {
        guard let nav = self.navigationController as? GRNavigationController else { return }
        
        nav.showLoadingBarYo()
        
        if disallowUserInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let dimView = UIView()
            view.backgroundColor = UIColor.fog.withAlphaComponent(0.3)
            view.tag = 333
            
            UIApplication.shared.keyWindow?.addSubview(dimView)
        }
    }

    func hideLoadingBar() {
        guard let nav = self.navigationController as? GRNavigationController else { return }
        
        nav.hideLoadingBarYo()
        UIApplication.shared.endIgnoringInteractionEvents()
        UIApplication.shared.keyWindow?.subviews.first(where: { $0.tag == 333 })?.removeFromSuperview()
    }

    func setupForHome() {
        setupMenuButton()
        setupBackButton()
        
        title = "Gym Rats"
                
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            image: UIImage(named: "kettle-bell"),
            style: .plain,
            target: self,
            action: #selector(presentNewWorkoutViewController)
        )
    }
    
    @objc func presentNewWorkoutViewController() {
        let newWorkoutViewController = NewWorkoutViewController()
        newWorkoutViewController.delegate = self
        
        let nav = GRNavigationController(rootViewController: newWorkoutViewController)
        nav.navigationBar.turnBrandColorSlightShadow()
        
        self.present(nav, animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion:  nil)
        }
    }
    
    func presentAlert(with error: Error) {
        presentAlert(title: "Uh-oh", message: error.localizedDescription)
    }
    
   @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension UIViewController: NewWorkoutDelegate {
    
    func workoutCreated(workouts: [Workout]) {
        (self as? ActiveChallengeViewController)?.fetchUserWorkouts()
    }
    
}
