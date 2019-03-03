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
        
        navigationBar.tintColor = .whiteSmoke
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.whiteSmoke
        ]
        
        navigationBar.turnBrandColorSlightShadow()

        let gradientColorList = [
            #colorLiteral(red: 0.9490196078, green: 0.3215686275, blue: 0.431372549, alpha: 1), #colorLiteral(red: 0.9450980392, green: 0.4784313725, blue: 0.5921568627, alpha: 1), #colorLiteral(red: 0.9529411765, green: 0.737254902, blue: 0.7843137255, alpha: 1), #colorLiteral(red: 0.4274509804, green: 0.8666666667, blue: 0.9490196078, alpha: 1), #colorLiteral(red: 0.7568627451, green: 0.9411764706, blue: 0.9568627451, alpha: 1)
        ]
        
        gradientBar = BottomGradientLoadingBar (
            height: 3.5,
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
