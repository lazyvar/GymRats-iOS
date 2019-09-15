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
        viewController.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func inNav() -> UINavigationController {
        return GRNavigationController(rootViewController: self)
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

        navigationItem.rightBarButtonItem = UIBarButtonItem (
            image: UIImage(named: "chat"),
            style: .plain,
            target: self,
            action: #selector(doNothing)
        )
    }
    
    @objc func doNothing() {
        
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
