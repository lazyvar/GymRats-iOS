//
//  GRNavigationController.swift
//  GymRats
//
//  Created by Mack Hasz on 2/6/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit
import GradientLoadingBar

class GRNavigationController: UINavigationController {

    var gradientBar: BottomGradientLoadingBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = .black
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        navigationBar.turnSolidWhiteSlightShadow()

        let gradientColorList = [
            #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), #colorLiteral(red: 0.9529411765, green: 0.737254902, blue: 0.7843137255, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.7568627451, green: 0.9411764706, blue: 0.9568627451, alpha: 1)
        ]
        
        gradientBar = BottomGradientLoadingBar (
            height: 4,
            durations: Durations(fadeIn: 0.275, fadeOut: 0.5, progress: 2.75),
            gradientColorList: gradientColorList,
            onView: navigationBar
        )
    }
    
    func showLoadingBarYo() {
        gradientBar.show()
    }
    
    func hideLoadingBarYo() {
        gradientBar.hide()
    }
    
}
