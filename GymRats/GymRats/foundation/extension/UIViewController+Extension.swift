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
        let yourBackImage = UIImage(named: "back")
        
        navigationController?.navigationBar.backIndicatorImage = yourBackImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func setupMenuButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem (
            title: "Menu",
            style: .plain,
            target: GymRatsApp.coordinator,
            action: #selector(AppCoordinator.toggleMenu)
        )
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
        presentAlert(title: "Error", message: error.localizedDescription)
    }
    
   @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
