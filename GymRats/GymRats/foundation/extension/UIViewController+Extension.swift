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

    
}
